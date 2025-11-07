
extends Node3D

@export_group("Hilbert Track Parameters")
@export var order: int = 4                 # Hilbert curve order
@export var spacing: float = 20.0          # step between Hilbert points
@export var scale_factor: float = 6.0      # global scale multiplier
@export var save_curve_path: String = "res://hilbert_track_path.tres"

var path_node: Path3D

func _ready() -> void:
	var curve := _build_flat_hilbert_curve()
	_attach_path3d(curve)
	_save_curve(curve)
	print("Hilbert Path3D generated and saved.")


# ---------------------------
# Build flat spline
# ---------------------------
func _build_flat_hilbert_curve() -> Curve3D:
	var pts: Array[Vector2] = hilbert_2d(order)
	var n: int = 1 << order
	var curve := Curve3D.new()

	for i in range(pts.size()):
		var p: Vector2 = pts[i]
		var x: float = (p.x - n / 2.0) * spacing * scale_factor
		var z: float = (p.y - n / 2.0) * spacing * scale_factor
		curve.add_point(Vector3(x, 0.0, z))

	curve.bake_interval = spacing * 0.25
	return curve


# ---------------------------
# Create visible Path3D node
# ---------------------------
func _attach_path3d(curve: Curve3D) -> void:
	path_node = Path3D.new()
	path_node.name = "HilbertTrackPath"
	path_node.curve = curve
	add_child(path_node)
	path_node.owner = get_tree().edited_scene_root   # ensures it appears in the editor


# ---------------------------
# Save to .tres for reuse
# ---------------------------
func _save_curve(curve: Curve3D) -> void:
	var err := ResourceSaver.save(curve, save_curve_path)
	if err != OK:
		push_error("Curve save failed: %s" % str(err))


# ---------------------------
# Copy from city.gd
# ---------------------------
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
