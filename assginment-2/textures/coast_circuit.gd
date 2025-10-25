extends Node3D

func _input(event):
	if event.is_action_pressed("to_menu"):
		get_tree().change_scene_to_file("res://startMenu.tscn")
