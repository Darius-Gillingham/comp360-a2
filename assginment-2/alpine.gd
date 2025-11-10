extends Node3D

@onready var car_spawn = $SpawnPoint

func _input(event):
	if event.is_action_pressed("to_menu"):
		get_tree().change_scene_to_file("res://startMenu.tscn")

func _ready():
	var chosen_car = load(GlobalData.selected_car_scene)
	var car = chosen_car.instantiate()
	add_child(car)
	car.global_transform = car_spawn.global_transform
	print("spawned", GlobalData.selected_car_scene)
