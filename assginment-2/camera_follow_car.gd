extends Camera3D
#
#@export var min_distance := 2.0
#@export var max_distance := 6.0
#@export var cam_height := 2.0
#
#@onready var target: Node3D = get_parent()
#
#
#func _physics_process(delta: float) -> void:
	#var to_target := global_position - target.global_position
	#
	#if to_target.length() < min_distance:
		#to_target = to_target.normalized() * min_distance
	#elif to_target.length() > max_distance:
		#to_target = to_target.normalized() * max_distance
		#
	#to_target.y = cam_height
	#global_position = target.global_position + to_target
	#
	#var look_dir := global_position.direction_to(target.global_position).abs() - Vector3.UP
	#if not look_dir.is_zero_approx():
		#look_at_from_position(global_position, target.global_position, Vector3.UP)
