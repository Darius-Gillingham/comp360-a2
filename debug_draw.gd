extends Node

#Draw Force Vector Lines Script, Original Creator: Octodemy


@onready var draw_debug: MeshInstance3D = $MeshInstance3D

func _physics_process(delta: float) -> void:
	if draw_debug.mesh is ImmediateMesh:
		draw_debug.mesh.clear_surfaces()
		
		


func draw_line(point_a: Vector3, point_b: Vector3, colour: Color = Color.RED):
	if point_a.is_equal_approx(point_b):
		return
		
	if draw_debug.mesh is ImmediateMesh:
		draw_debug.mesh.surface_begin(Mesh.PRIMITIVE_LINES)
		draw_debug.mesh.surface_set_color(colour)
		
		draw_debug.mesh.surface_add_vertex(point_a)
		draw_debug.mesh.surface_add_vertex(point_b)
			
		draw_debug.mesh.surface_end()
	
func draw_thick_line(point_A: Vector3, point_B: Vector3, thickness: float = 2.0, colour: Color = Color.RED):
	point_B = point_A+point_B
	
	if point_A.is_equal_approx(point_B):
		return
	if draw_debug.mesh is ImmediateMesh:
		draw_debug.mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
		draw_debug.mesh.surface_set_color(colour)
	
		var scale_factor := 100.0 
		var dir := point_A.direction_to(point_B)
		var EPISILON = 0.00001
		
		var normal := Vector3(-dir.y, dir.x, 0).normalized() \
			if (abs(dir.x) + abs(dir.y) > EPISILON) \
			else Vector3(0, -dir.z, dir.y).normalized()
		normal *= thickness / scale_factor
		
		var verticies_strip_order = [4, 5, 0, 1, 2, 5, 6, 4, 7, 0, 3, 2, 7, 6]
		var localB = (point_B - point_A)
		
		for v in range(14):
			var vertex = normal if verticies_strip_order[v] < 4 else normal + localB
			var final_vert = vertex.rotated(dir, PI * (0.5 * (verticies_strip_order[v] % 4) + 0.25))
			
			final_vert += point_A
			draw_debug.mesh.surface_add_vertex(final_vert)
		draw_debug.mesh.surface_end()
			
