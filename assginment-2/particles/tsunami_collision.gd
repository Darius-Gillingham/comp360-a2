extends Area3D

var car_already_entered = false

func _ready():
	body_entered.connect(car_entered)
	
func car_entered(body: Node3D):
	if body is RigidBody3D and (not body.has_meta("is_opponent") or not body.get_meta("is_opponent")) and not car_already_entered:
		car_already_entered = true
		apply_wave_impulse(body)
	
func apply_wave_impulse(car: RigidBody3D):
	var force = -get_parent().global_transform.basis.z * 1000 + Vector3.UP * 1000
	car.apply_impulse(force)
