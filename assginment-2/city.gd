
extends Node3D

@export var order: int = 4                    # number of vertices = 4^order
@export var spacing: float = 20.0             # grid step between consecutive Hilbert points
@export var max_height: float = 60.0          # tallest building cap
@export var export_path: String = "res://hilbert_city.mesh"

# Visuals
@export var wall_color: Color = Color(0.6, 0.6, 0.6)
@export var window_color: Color = Color(0.3, 0.5, 0.9)
@export var ground_color: Color = Color(0.95, 0.95, 0.95)
@export var road_color: Color = Color(0.05, 0.05, 0.05)

func _ready() -> void:
	var mesh: ArrayMesh = build_city_mesh()

	# --- Visual mesh instance ---
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	add_child(mi)

	# --- Static collision for physics ---
	var body := StaticBody3D.new()
	var shape := mesh.create_trimesh_shape()
	var cs := CollisionShape3D.new()
	cs.shape = shape
	body.add_child(cs)
	add_child(body)

	# --- Save mesh to disk ---
	var err := ResourceSaver.save(mesh, export_path)
	if err != OK:
		push_error("City save failed: " + str(err))
	else:
		print("City mesh generated, saved, and collision enabled at:", export_path)


func build_city_mesh() -> ArrayMesh:
	var pts: Array[Vector2] = hilbert_2d(order)
	var n: float = float(1 << order)

	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	# --- Material setup ---
	var mat := StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	mat.albedo_color = Color(1, 1, 1)
	st.set_material(mat)

	# --- General layout parameters ---
	var city_extent: float = n * spacing
	var road_height: float = 0.05
	var road_width: float = spacing * 0.2
	var road_offset: float = spacing * 0.5
	var carve_clearance: float = road_width * 0.25
	var half_extent: float = city_extent * 0.5
	var road_half_w: float = road_width * 0.5

	# --- Building dimensions ---
	var half_vertex_width: float = max(0.1, (spacing - 3.0 * road_width) * 0.5)
	var vertex_side: float = half_vertex_width * 2.0
	var edge_length: float = max(0.1, spacing - 3.0 * road_width)
	var edge_width: float = vertex_side

	# --- Generate buildings and collect their AABBs ---
	var aabbs: Array = []

	for i in range(pts.size()):
		var p: Vector2 = pts[i]
		var x: float = (p.x - n / 2.0) * spacing
		var z: float = (p.y - n / 2.0) * spacing
		var height_v: float = 10.0 + float(i % 7) * (max_height / 7.0)

		# vertex building
		add_building_with_windows(st, Vector3(x, height_v * 0.5, z), Vector3(vertex_side, height_v, vertex_side))
		aabbs.append([x - vertex_side * 0.5, x + vertex_side * 0.5, z - vertex_side * 0.5, z + vertex_side * 0.5])

		# edge buildings
		if i < pts.size() - 1:
			var q: Vector2 = pts[i + 1]
			var nx: float = (q.x - n / 2.0) * spacing
			var nz: float = (q.y - n / 2.0) * spacing
			var mid_x: float = (x + nx) * 0.5
			var mid_z: float = (z + nz) * 0.5
			var height_e: float = height_v

			if abs(nx - x) > 0.001 and abs(nz - z) < 0.001:
				add_building_with_windows(st, Vector3(mid_x, height_e * 0.5, mid_z), Vector3(edge_length, height_e, edge_width))
				aabbs.append([mid_x - edge_length * 0.5, mid_x + edge_length * 0.5, mid_z - edge_width * 0.5, mid_z + edge_width * 0.5])
			elif abs(nz - z) > 0.001 and abs(nx - x) < 0.001:
				add_building_with_windows(st, Vector3(mid_x, height_e * 0.5, mid_z), Vector3(edge_width, height_e, edge_length))
				aabbs.append([mid_x - edge_width * 0.5, mid_x + edge_width * 0.5, mid_z - edge_length * 0.5, mid_z + edge_length * 0.5])

	# --- Base ground ---
	add_box(st, Vector3(0, -0.5, 0), Vector3(city_extent + spacing, 1.0, city_extent + spacing), ground_color)

	# --- Generate roads by carving out negative space ---
	for i in range(int(n) - 1):
		_add_vertical_road_lane(st, i, n, road_offset, road_width, road_half_w, road_height, half_extent, carve_clearance, aabbs)

	for j in range(int(n) - 1):
		_add_horizontal_road_lane(st, j, n, road_offset, road_width, road_half_w, road_height, half_extent, carve_clearance, aabbs)

	st.generate_normals()
	return st.commit()

func _cmp_intervals(a, b) -> bool:
	return a[0] < b[0]

func _merge_intervals(intervals: Array) -> Array:
	if intervals.is_empty():
		return intervals

	intervals.sort_custom(_cmp_intervals)

	var merged: Array = []
	var cur: Array = intervals[0]  # Explicit type
	for k in range(1, intervals.size()):
		var nxt: Array = intervals[k]  # Explicit type
		if nxt[0] <= cur[1]:
			cur[1] = max(cur[1], nxt[1])
		else:
			merged.append(cur)
			cur = nxt
	merged.append(cur)
	return merged




func _add_vertical_road_lane(st: SurfaceTool, i: int, n: float, road_offset: float, road_width: float, road_half_w: float, road_height: float, half_extent: float, carve_clearance: float, aabbs: Array) -> void:
	var x_lane: float = (i - n / 2.0) * spacing + road_offset
	var blocked: Array = []
	for box in aabbs:
		var minx: float = box[0] - carve_clearance
		var maxx: float = box[1] + carve_clearance
		var minz: float = box[2] - carve_clearance
		var maxz: float = box[3] + carve_clearance
		if (x_lane + road_half_w) > minx and (x_lane - road_half_w) < maxx:
			blocked.append([minz, maxz])
	var merged := _merge_intervals(blocked)
	var cursor: float = -half_extent
	for seg in merged:
		var seg_start: float = seg[0]
		var seg_end: float = seg[1]
		if seg_start > cursor:
			var free_mid: float = (cursor + seg_start) * 0.5
			var free_len: float = seg_start - cursor
			if free_len > 0.01:
				add_box(st, Vector3(x_lane, road_height * 0.5, free_mid), Vector3(road_width, road_height, free_len), road_color)
		cursor = max(cursor, seg_end)
	if cursor < half_extent:
		var free_mid_tail: float = (cursor + half_extent) * 0.5
		var free_len_tail: float = half_extent - cursor
		if free_len_tail > 0.01:
			add_box(st, Vector3(x_lane, road_height * 0.5, free_mid_tail), Vector3(road_width, road_height, free_len_tail), road_color)


func _add_horizontal_road_lane(st: SurfaceTool, j: int, n: float, road_offset: float, road_width: float, road_half_w: float, road_height: float, half_extent: float, carve_clearance: float, aabbs: Array) -> void:
	var z_lane: float = (j - n / 2.0) * spacing + road_offset
	var blocked_h: Array = []
	for box in aabbs:
		var minx: float = box[0] - carve_clearance
		var maxx: float = box[1] + carve_clearance
		var minz: float = box[2] - carve_clearance
		var maxz: float = box[3] + carve_clearance
		if (z_lane + road_half_w) > minz and (z_lane - road_half_w) < maxz:
			blocked_h.append([minx, maxx])
	var merged_h := _merge_intervals(blocked_h)
	var cursor_h: float = -half_extent
	for seg_h in merged_h:
		var seg_start_h: float = seg_h[0]
		var seg_end_h: float = seg_h[1]
		if seg_start_h > cursor_h:
			var free_mid_h: float = (cursor_h + seg_start_h) * 0.5
			var free_len_h: float = seg_start_h - cursor_h
			if free_len_h > 0.01:
				add_box(st, Vector3(free_mid_h, road_height * 0.5, z_lane), Vector3(free_len_h, road_height, road_width), road_color)
		cursor_h = max(cursor_h, seg_end_h)
	if cursor_h < half_extent:
		var free_mid_tail_h: float = (cursor_h + half_extent) * 0.5
		var free_len_tail_h: float = half_extent - cursor_h
		if free_len_tail_h > 0.01:
			add_box(st, Vector3(free_mid_tail_h, road_height * 0.5, z_lane), Vector3(free_len_tail_h, road_height, road_width), road_color)



func add_building_with_windows(st: SurfaceTool, center: Vector3, size: Vector3) -> void:
	# main block
	add_box(st, center, size, wall_color)

	# windows with larger offsets to avoid z-fighting and culling
	var floors: int = max(1, int(size.y / 6.0))
	var windows_per_floor: int = 3
	var floor_h: float = size.y / float(floors)
	var window_w: float = size.x / float(windows_per_floor + 1)
	var window_h: float = floor_h * 0.6
	var face_push: float = 0.15
	var side_push: float = 0.15
	var win_depth: float = 0.12

	for f in range(floors):
		var y: float = center.y - size.y * 0.5 + (f + 0.5) * floor_h
		for w in range(windows_per_floor):
			var x: float = center.x - size.x * 0.5 + (w + 1) * window_w
			var z_front: float = center.z + size.z * 0.5 + face_push
			var z_back: float = center.z - size.z * 0.5 - face_push
			var x_left: float = center.x - size.x * 0.5 - side_push
			var x_right: float = center.x + size.x * 0.5 + side_push
			var z_side: float = center.z - size.z * 0.5 + (w + 1) * window_w

			add_box(st, Vector3(x, y, z_front), Vector3(window_w * 0.42, window_h, win_depth), window_color)
			add_box(st, Vector3(x, y, z_back),  Vector3(window_w * 0.42, window_h, win_depth), window_color)
			add_box(st, Vector3(x_left,  y, z_side), Vector3(win_depth, window_h, window_w * 0.42), window_color)
			add_box(st, Vector3(x_right, y, z_side), Vector3(win_depth, window_h, window_w * 0.42), window_color)


func add_box(st: SurfaceTool, center: Vector3, size: Vector3, color: Color) -> void:
	var sx: float = size.x * 0.5
	var sy: float = size.y * 0.5
	var sz: float = size.z * 0.5
	var v := [
		Vector3(-sx, -sy, -sz), Vector3(sx, -sy, -sz),
		Vector3(sx, sy, -sz),   Vector3(-sx, sy, -sz),
		Vector3(-sx, -sy, sz),  Vector3(sx, -sy, sz),
		Vector3(sx, sy, sz),    Vector3(-sx, sy, sz)
	]
	for i in range(v.size()):
		v[i] += center

	var f := [
		[0,1,2,3],[5,4,7,6],[4,0,3,7],
		[1,5,6,2],[3,2,6,7],[4,5,1,0]
	]
	for face in f:
		st.set_color(color); st.add_vertex(v[face[0]])
		st.set_color(color); st.add_vertex(v[face[1]])
		st.set_color(color); st.add_vertex(v[face[2]])
		st.set_color(color); st.add_vertex(v[face[0]])
		st.set_color(color); st.add_vertex(v[face[2]])
		st.set_color(color); st.add_vertex(v[face[3]])


func hilbert_2d(order: int) -> Array[Vector2]:
	var points: Array[Vector2] = [Vector2(0, 0)]
	for i in range(order):
		var np: Array[Vector2] = []
		var n: int = 1 << i
		for p: Vector2 in points: np.append(Vector2(p.y, p.x))
		for p: Vector2 in points: np.append(Vector2(p.x, p.y + n))
		for p: Vector2 in points: np.append(Vector2(p.x + n, p.y + n))
		for p: Vector2 in points: np.append(Vector2((2 * n - 1 - p.y), (n - 1 - p.x)))
		points = np
	return points
