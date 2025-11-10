extends Node3D

@onready var car_spawn = $SpawnPoint
@onready var tsunami_timer = $TsunamiTimer
@onready var path = $HilbertPath
@onready var checkpoint_manager = $CheckpointManager

var tsuanmi_scene = load("res://particles/tsunami.tscn")

@export var tsunami_start_pos: Vector3 = Vector3(-1000, -50, 420)
@export var tsunami_end_pos: Vector3 = Vector3(80, -50, 420)
@export var tsunami_rise_time: float = 4.5
@export var tsunami_peak_time: float = 6.0
@export var num_checkpoints = 50

func _input(event):
	if event.is_action_pressed("to_menu"):
		get_tree().change_scene_to_file("res://startMenu.tscn")


func _ready():
	var chosen_car = load(GlobalData.selected_car_scene)
	var car = chosen_car.instantiate()
	add_child(car)
	car.global_transform = car_spawn.global_transform
	print("spawned", GlobalData.selected_car_scene)
	
	#$Camera3D2.current = true
	
	init_weather()
	checkpoint_manager.init_checkpoints.emit(num_checkpoints, path.curve, path.position, car, car_spawn.global_transform)


func init_weather():
	#var tsunami: Node3D = tsuanmi_scene.instantiate()
	#add_child(tsunami)
	#tsunami.position = tsunami_start_pos + Vector3.UP * tsunami.get_meta("half_height")
	#tsunami.rotate_y(-PI/2)
	tsunami_timer.timeout.connect(create_tsunami)
	
func create_tsunami():
	print("create tsunami")
	var tsunami: Node3D = tsuanmi_scene.instantiate()
	add_child(tsunami)
	var start_pos = tsunami_start_pos - Vector3.UP * tsunami.get_meta("half_height")
	var end_pos = tsunami_end_pos - Vector3.UP * tsunami.get_meta("half_height")
	tsunami.position = start_pos
	tsunami.rotate_y(-PI/2)
	tsunami.start_wave.emit(start_pos, end_pos - start_pos, tsunami.get_meta("half_height"), tsunami_rise_time, tsunami_peak_time)
	
	
