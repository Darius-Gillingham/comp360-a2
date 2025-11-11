extends Node3D

@export var all_car_scenes = [
	"res://Toyota/Toyota.tscn",
	"res://SportsCar/SportCar.tscn",
	"res://Buggy/Buggy.tscn",
	"res://GolfCart/GolfCart.tscn",
	"res://Police/Police.tscn",
    "res://Wagon/Wagon.tscn"
]

func _ready():
	randomize()

	# Remove any existing children
	for child in get_children():
		child.queue_free()

	# Pick a random car scene
	var random_index = randi() % all_car_scenes.size()
	var car_scene_path = all_car_scenes[random_index]

	# Load and instantiate
	var car_scene = load(car_scene_path)
	if car_scene is PackedScene:
		var car_instance = car_scene.instantiate()
		add_child(car_instance)

		# Reset transform so it appears at the parent node's location
		if car_instance is Node3D:
			car_instance.transform = Transform3D()  # local origin
