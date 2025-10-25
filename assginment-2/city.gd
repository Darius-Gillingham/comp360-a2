
extends Node3D

@export var order: int = 4
@export var spacing: float = 20.0
@export var max_height: float = 60.0
@export var building_size: Vector3 = Vector3(8, 1, 8)
@export var export_path: String = "res://hilbert_city.mesh"

func _ready() -> void:
	var mesh = build_city_mesh()
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = mesh
	add_child(mesh_instance)

	var err = ResourceSaver.save(mesh, export_path)
	if err != OK:
		push_error("City save failed: " + str(err))
	else:
		print("City mesh generated and saved to:", export_path)


func build_city_mesh() -> ArrayMesh:
	var pts = hilbert_2d(order)
	var n: float = float(1 << order)

	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	# Material for visible vertex colors
	var mat := StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	mat.albedo_color = Color(1, 1, 1)
	st.set_material(mat)

	# --- Buildings ---
	for i in range(pts.size()):
		var p: Vector2 = pts[i]
		var x: float = (p.x - n / 2.0) * spacing
		var z: float = (p.y - n / 2.0) * spacing
		var height: float = 10.0 + (i % 7) * (max_height / 7.0)
		add_building_with_windows(st, Vector3(x, height / 2.0, z), Vector3(building_size.x, height, building_size.z))

	# --- Base ground ---
	var ground_color := Color(0.95, 0.95, 0.95)
	var city_extent: float = n * spacing
	add_box(st, Vector3(0, -0.5, 0), Vector3(city_extent + spacing, 1.0, city_extent + spacing), ground_color)

	# --- Offset straight grid roads between buildings ---
	var road_color := Color(0.05, 0.05, 0.05)
	var road_height: float = 0.05
	var road_width: float = spacing * 0.2
	var offset := spacing * 0.5  # half block offset to align roads between buildings

	# vertical roads (Z direction)
	for i in range(int(n)):
		var x := (i - n / 2.0) * spacing + offset
		add_box(st, Vector3(x, 0.0, 0), Vector3(road_width, road_height, city_extent + spacing), road_color)

	# horizontal roads (X direction)
	for j in range(int(n)):
		var z := (j - n / 2.0) * spacing + offset
		add_box(st, Vector3(0, 0.0, z), Vector3(city_extent + spacing, road_height, road_width), road_color)
	st.generate_normals()
	return st.commit()



func add_building_with_windows(st: SurfaceTool, center: Vector3, size: Vector3) -> void:
	var wall_color := Color(0.6, 0.6, 0.6)
	var window_color := Color(0.3, 0.5, 0.9)
	var floors: int = 6
	var windows_per_floor: int = 3
	var floor_h: float = size.y / floors
	var window_w: float = size.x / (windows_per_floor + 1)
	var window_h: float = floor_h * 0.6

	# Add windows on all four sides
	for f in range(floors):
		var y = -size.y / 2.0 + (f + 0.5) * floor_h + center.y
		for w in range(windows_per_floor):
			var x = center.x - size.x / 2.0 + (w + 1) * window_w
			var z_front = center.z + size.z / 2.0 + 0.01
			var z_back = center.z - size.z / 2.0 - 0.01
			var x_left = center.x - size.x / 2.0 - 0.01
			var x_right = center.x + size.x / 2.0 + 0.01
			var z_left = center.z - size.z / 2.0 + (w + 1) * window_w
			var z_right = center.z - size.z / 2.0 + (w + 1) * window_w

			# front and back
			add_box(st, Vector3(x, y, z_front), Vector3(window_w * 0.4, window_h, 0.1), window_color)
			add_box(st, Vector3(x, y, z_back), Vector3(window_w * 0.4, window_h, 0.1), window_color)
			# left and right
			add_box(st, Vector3(x_left, y, z_left), Vector3(0.1, window_h, window_w * 0.4), window_color)
			add_box(st, Vector3(x_right, y, z_right), Vector3(0.1, window_h, window_w * 0.4), window_color)

	# main building block
	add_box(st, center, size, wall_color)


func forward_box(st: SurfaceTool, center: Vector3, size: Vector3, basis: Basis, color: Color) -> void:
	var sx: float = size.x * 0.5
	var sy: float = size.y * 0.5
	var sz: float = size.z * 0.5
	var v = [
		Vector3(-sx, -sy, -sz), Vector3(sx, -sy, -sz),
		Vector3(sx, sy, -sz), Vector3(-sx, sy, -sz),
		Vector3(-sx, -sy, sz), Vector3(sx, -sy, sz),
		Vector3(sx, sy, sz), Vector3(-sx, sy, sz)
	]

	for j in range(v.size()):
		v[j] = basis * v[j] + center

	var f = [
		[0,1,2,3],[5,4,7,6],[4,0,3,7],
		[1,5,6,2],[3,2,6,7],[4,5,1,0]
	]

	for face in f:
		st.set_color(color)
		st.add_vertex(v[face[0]])
		st.set_color(color)
		st.add_vertex(v[face[1]])
		st.set_color(color)
		st.add_vertex(v[face[2]])
		st.set_color(color)
		st.add_vertex(v[face[0]])
		st.set_color(color)
		st.add_vertex(v[face[2]])
		st.set_color(color)
		st.add_vertex(v[face[3]])


func add_box(st: SurfaceTool, center: Vector3, size: Vector3, color: Color) -> void:
	var sx = size.x * 0.5
	var sy = size.y * 0.5
	var sz = size.z * 0.5
	var v = [
		Vector3(-sx, -sy, -sz), Vector3(sx, -sy, -sz),
		Vector3(sx, sy, -sz), Vector3(-sx, sy, -sz),
		Vector3(-sx, -sy, sz), Vector3(sx, -sy, sz),
		Vector3(sx, sy, sz), Vector3(-sx, sy, sz)
	]
	for j in range(v.size()):
		v[j] += center

	var f = [
		[0,1,2,3],[5,4,7,6],[4,0,3,7],
		[1,5,6,2],[3,2,6,7],[4,5,1,0]
	]
	for face in f:
		st.set_color(color)
		st.add_vertex(v[face[0]])
		st.set_color(color)
		st.add_vertex(v[face[1]])
		st.set_color(color)
		st.add_vertex(v[face[2]])
		st.set_color(color)
		st.add_vertex(v[face[0]])
		st.set_color(color)
		st.add_vertex(v[face[2]])
		st.set_color(color)
		st.add_vertex(v[face[3]])


func hilbert_2d(order: int) -> Array:
	var points = [Vector2(0, 0)]
	for i in range(order):
		var np: Array[Vector2] = []
		var n = 1 << i
		for p in points: np.append(Vector2(p.y, p.x))
		for p in points: np.append(Vector2(p.x, p.y + n))
		for p in points: np.append(Vector2(p.x + n, p.y + n))
		for p in points: np.append(Vector2((2*n - 1 - p.y), (n - 1 - p.x)))
		points = np
	return points
