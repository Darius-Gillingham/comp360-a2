extends Node3D

@onready var car_spawn: Node3D = $SpawnPoint
@onready var path = $Path3D
@onready var checkpoint_manager = $CheckpointManager

@export var num_dust_devils = 20
@export var num_checkpoints = 10

func _input(event):
	if event.is_action_pressed("to_menu"):
		get_tree().change_scene_to_file("res://startMenu.tscn")


func _ready():
	var chosen_car = load(GlobalData.selected_car_scene)
	var car = chosen_car.instantiate()
	add_child(car)
	car.global_transform = car_spawn.global_transform
	print("spawned", GlobalData.selected_car_scene)
	
	init_weather()
	checkpoint_manager.init_checkpoints.emit(num_checkpoints, path.curve, path.position, car, car_spawn.global_transform)

func init_weather():
	print("init weather")
	var dust_devil_scene = load("res://particles/DustDevil.tscn")
	var track_length = path.curve.get_baked_length()
	
	for i in range(num_dust_devils):
		var dust_devil = dust_devil_scene.instantiate()
		add_child(dust_devil)
		var t = randf() * track_length
		var point = path.curve.sample_baked_with_rotation(t)
		var left_shift = (1 if randf() < 0.5 else -1) * 5
		var pos = point.origin + point.basis.x * left_shift + path.position + Vector3(0,dust_devil.get_meta("half_height"),0)
		
		dust_devil.position = pos
		dust_devil.set_meta("forward_vec", point.basis.z)
	
	#print("Up: " + str(path.curve.up_vector_enabled))
	#var dust_devil = dust_devil_scene.instantiate()
	#add_child(dust_devil)
	#var point = path.curve.sample_baked_with_rotation(500.0)
	#var left_shift = (1 if randf() < 0.5 else -1) * 5
	#var pos = point.origin + point.basis.x * left_shift + path.position + Vector3(0,dust_devil.get_meta("half_height"),0)
	#
	#print(pos)
	#print(path.curve.get_baked_length())
	#dust_devil.position = pos
