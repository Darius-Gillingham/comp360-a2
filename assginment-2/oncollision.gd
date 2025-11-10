extends Area3D

@export var text_node_path: NodePath  # drag your MeshInstance3D here in the editor

var text_node: MeshInstance3D
var lap_count := 0  # this persists and increments each time

func _ready():
	text_node = get_node(text_node_path)
	connect("body_entered", _on_body_entered)

func _on_body_entered(body: RigidBody3D):
	# Optional: only count a specific player/car
	if body.name == "CarOpponent":
		return
	
	# Increment lap count
	lap_count += 1
	
	# Change the text
	var mesh := text_node.mesh
	if mesh is TextMesh:
		mesh.text = "Lap" + str(lap_count)
