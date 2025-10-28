extends RigidBody3D

@export var wheels: Array[RaycastWheel]
@export var acceleration := 400.0
@export var max_speed := 20.0
@export var acceleration_curve : Curve
@export var tire_turn_speed := 2.0
@export var tire_max_turn_degrees := 25
@export var show_debug := false


@export var skid_marks: Array[GPUParticles3D]


var motor_input := 0
var hand_break := false
var is_slipping := false
var look_toward := Vector3.ZERO

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("handbreak"):
		hand_break = true
		is_slipping = true
	elif event.is_action_released("handbreak"):
		hand_break = false
		
	if event.is_action_pressed("accelerate"):
		motor_input = 1
	elif event.is_action_released("accelerate"):
		motor_input = 0
		
	if event.is_action_pressed("decelerate"):
		motor_input = -1
	elif event.is_action_released("decelerate"):
		motor_input = 0
		
		
func _basic_steering_rotation(wheel: RaycastWheel, delta: float) -> void:
	if not wheel.is_steer: return
	var turn_input := Input.get_axis("turn_right", "turn_left") * tire_turn_speed
	
	if turn_input:
		
		wheel.rotation.y = clampf(wheel.rotation.y + turn_input * delta, deg_to_rad(-tire_max_turn_degrees), deg_to_rad(tire_max_turn_degrees))
	else:
		wheel.rotation.y = move_toward(wheel.rotation.y, 0, tire_turn_speed * delta)

func _get_point_velocity(point: Vector3) -> Vector3:
	return linear_velocity + angular_velocity.cross(point - global_position)

func _physics_process(delta: float) -> void:
	#if show_debug: DebugDraw.draw_thick_line(global_position ,_get_point_velocity(global_position), 5, Color.YELLOW)

	#initilize physics in each wheel seperatly for more accurate physics to a real car
	for wheel in wheels:
		#check to see if wheel is touching the ground (airborne or not)
		var grounded := false
		skid_marks[0].emitting = false
		var id :=  wheels.rfind(wheel)
		
			
		#function to set up steering controls (front wheels rotate)
		_basic_steering_rotation(wheel, delta)
		if wheel.is_colliding():
			grounded = true
			
		#set up the raycast which powers the wheels
		wheel.force_raycast_update()
		
		#sets up simulated springs to connect the wheel to the car using raycasts to simulate suspension
		_do_single_wheel_suspension(wheel)
		
		#controls the two dimensional movement using accelerate and decelerate inputs as well as raycast
		_do_single_wheel_acceleration(wheel)
		
		#controls steering directions of the wheel
		_do_single_wheel_traction(wheel, id)
		
		#Checks to see if the wheel is on the ground
		if grounded:
			#does nothing/resets if wheel is contacting ground
			center_of_mass = Vector3.ZERO
		else:
			#If airborne find the closest vector to the ground and push it downwards until the collision masks mess up and flip it over
			center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM
			center_of_mass = Vector3.DOWN * 0.5
			skid_marks[id].emitting = false

#Control the wheels traction allowing turning and drifting
func _do_single_wheel_traction(ray: RaycastWheel, idx: int) -> void:
	#Don't do anything unless touching ground (airborne condition)
	if not ray.is_colliding(): return
	
	
	var steer_side_dir := ray.global_basis.x
	var tire_vel := _get_point_velocity(ray.wheel.global_position)
	var steering_x_vel := steer_side_dir.dot(tire_vel)
	
	var grip_factor := absf(steering_x_vel/tire_vel.length())
	var x_traction := ray.grip_curve.sample_baked(grip_factor)
	
	#Skid Marks
	skid_marks[idx].global_position = ray.get_collision_point() + Vector3.UP * 0.1
	skid_marks[idx].look_at(skid_marks[idx].global_position + global_basis.z)
	
	#Control if skid marks are on, off, or if full drift or transition (is_slipping) drift is currently on
	if not hand_break and grip_factor < 0.3:
		is_slipping = false
		skid_marks[idx].emitting = false
		
	if hand_break:
		x_traction = 0.05
		if not skid_marks[idx].emitting:
			skid_marks[idx].emitting = true
			skid_marks[idx].visible = true
			
	elif is_slipping: 
		x_traction = 0.1
	
	
	var gravity := -get_gravity().y
	var x_force := -steer_side_dir * steering_x_vel * x_traction * ((mass * 9.81)/4.0)
	
	# Z force traction
	var f_vel:= -ray.global_basis.z.dot(tire_vel)
	var z_traction := 0.05
	var z_force := global_basis.z * f_vel * z_traction * ((mass*gravity)/4.0)
	
	var force_pos := ray.wheel.global_position - global_position
	#X forxe is steering force pushing the car towards wanted direction and z force is drag force pulling the car back allowing for different tracks to have different driving conditions
	apply_force(x_force, force_pos)
	apply_force(z_force, force_pos)
	if show_debug: DebugDraw.draw_thick_line(ray.wheel.global_position, x_force/100, 5, Color.LIME_GREEN)
	if show_debug: DebugDraw.draw_thick_line(ray.wheel.global_position, z_force/100, 5, Color.PURPLE)
	
#Function for 2 dimensional movement of forwards or backwards
func _do_single_wheel_acceleration(ray:RaycastWheel) -> void:
	var forward_dir := -ray.global_basis.z
	var vel := forward_dir.dot(linear_velocity)
	ray.wheel.rotate_x((-vel * get_process_delta_time())/ray.wheel_radius)
	
	#See if wheel is touching ground
	if ray.is_colliding():
		#
		var contact := ray.wheel.global_position
		var force_pos := contact - global_position
		
		#If there is an input apply acceleration force to chosen  wheels (Rear wheels generally)
		if  ray.is_motor and motor_input:
			var speed_ratio := vel / max_speed
			var ac := acceleration_curve.sample_baked(speed_ratio)
			var accel_vector := forward_dir * acceleration * motor_input * ac
			apply_force(accel_vector, force_pos)
			if show_debug: DebugDraw.draw_thick_line(contact, accel_vector/100, 10, Color.BLUE)
			
	
#Controls the suspension by using raycasts as springs.
func _do_single_wheel_suspension(ray: RaycastWheel) -> void:
	#Don't do anything if not touching ground
	if ray.is_colliding():
		#See where ray is colliding with ground
		var contact := ray.get_collision_point()
		var spring_up_dir := ray.global_transform.basis.y
		var ray_origin := ray.global_position

		# Calculate spring compression
		var hit_distance := ray_origin.distance_to(contact)
		var spring_compression := hit_distance - ray.wheel_radius
		var offset := ray.rest_dist - spring_compression

		# Visual wheel position
		ray.wheel.position.y = -spring_compression

		# Spring force (Hooke's law)
		var spring_force := ray.spring_strength * offset

		# Damping force
		var world_vel := _get_point_velocity(contact)
		var relative_vel := spring_up_dir.dot(world_vel)
		var spring_damping_force := ray.spring_damping * relative_vel

		# Total force
		var force_vector := (spring_force - spring_damping_force) * spring_up_dir

		# Apply force at the actual collision point
		var force_pos_offset := contact - global_position
		apply_force(force_vector, force_pos_offset)

		if show_debug: DebugDraw.draw_thick_line(contact, force_vector / 50, 10, Color.BLUE)
