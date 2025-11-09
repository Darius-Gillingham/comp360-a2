extends Area3D

@export var attract_force = 7000
@export var swirl_force = 2000
@export var up_force = 700

var cars_in_radius = []

func _ready() -> void:
	body_entered.connect(car_entered)
	body_exited.connect(car_exited)
	
func _physics_process(delta: float) -> void:
	for car in cars_in_radius:
		apply_tornade_force(car)
	
func car_entered(body: Node3D):
	if body is RigidBody3D and (not body.has_meta("is_opponent") or not body.get_meta("is_opponent")):
		cars_in_radius.append(body)
		
func car_exited(body: Node3D):
	if body is RigidBody3D:
		cars_in_radius.erase(body)
		
func apply_tornade_force(body: RigidBody3D):
	var v_attract = global_position - body.global_position
	var distance_to_tornado = max(0.5, v_attract.length())
	
	print(distance_to_tornado)
	
	if distance_to_tornado > 6:
		v_attract = v_attract.normalized() * min((attract_force/ distance_to_tornado), attract_force)
		body.apply_central_force(v_attract)
	else:
		cars_in_radius.erase(body)
		var v_up = Vector3.UP * up_force
		var v_forward = get_parent().get_meta("forward_vec")* 500
		body.apply_impulse(v_forward + v_up)

	
	#if v_attract.y > 0:
		#v_attract = v_attract.normalized() * min((attract_force/ distance_to_tornado), attract_force)
		#var v_up = Vector3.UP * max((up_force / distance_to_tornado), up_force)
#
		#body.apply_central_force(v_attract + v_up)
	#else:
		#var v_up = Vector3.UP * (up_force / distance_to_tornado)
		#var v_forward = get_parent().get_meta("forward_vec")* 5
		#body.apply_central_force(v_forward)


	#var v_swirl = v_attract.cross(Vector3.UP).normalized() * (swirl_force / distance_to_tornado)
	#body.apply_force(Vector3(0,1000,0))
