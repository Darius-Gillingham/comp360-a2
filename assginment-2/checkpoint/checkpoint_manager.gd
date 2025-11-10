extends Node

var checkpoints = []
var current_checkpoint: Node3D = null
var car: RigidBody3D = null
var initial_spawn: Transform3D = Transform3D.IDENTITY
var checkpoint_scene = load("res://checkpoint/checkpoint.tscn")
var red_material: Material = load("res://checkpoint/checkpoint_red.tres")
var green_material: Material = load("res://checkpoint/checkpoint_green.tres")

signal init_checkpoints(num: int, curve: Curve3D, curve_offset: Vector3, active_car: RigidBody3D, initial_spawn_transform: Transform3D)

func _ready() -> void:
	init_checkpoints.connect(create_checkpoints)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("respawn"):
		respawn()
	
func _physics_process(delta: float) -> void:
	if not car: return
	if car.position.y < 50:
		respawn()
	
func create_checkpoints(num: int, curve: Curve3D, curve_offset: Vector3, active_car: RigidBody3D, initial_spawn_transform: Transform3D):
	car = active_car
	initial_spawn = initial_spawn_transform
	
	var curve_length = curve.get_baked_length()
	var checkpoint_spacing = curve_length / (num + 1)
	
	for i in range(num):
		var t = checkpoint_spacing * (i+1)
		var checkpoint_point = curve.sample_baked_with_rotation(t)
		
		var checkpoint: Node3D = checkpoint_scene.instantiate()
		add_child(checkpoint)
		checkpoints.append(checkpoint)
		checkpoint.position = checkpoint_point.origin + curve_offset
		checkpoint.global_basis = checkpoint_point.basis
		#checkpoint.look_at(checkpoint.position + checkpoint_point.)
		
		var area: Area3D = checkpoint.get_node("Area3D")
		#print("Area: " + str(area))
		area.body_entered.connect(
			func entered(body):
				if body is RigidBody3D and (not body.has_meta("is_opponent") or not body.get_meta("is_opponent")):
					claim_checkpoint(checkpoint)
		)
		
func claim_checkpoint(checkpoint: Node3D):
	if checkpoint == current_checkpoint: return
	
	if current_checkpoint:
		var old_banner: MeshInstance3D = current_checkpoint.get_node("Flag/Banner")
		old_banner.set_surface_override_material(0, red_material)
	
	current_checkpoint = checkpoint
	var confetti: GPUParticles3D = checkpoint.get_node("ConfettiParticles")
	confetti.emitting = true
	
	var banner: MeshInstance3D = checkpoint.get_node("Flag/Banner")
	banner.set_surface_override_material(0, green_material)

func respawn():
	if not car: return
	car.freeze = true
	car.linear_velocity = Vector3.ZERO
	car.angular_velocity = Vector3.ZERO
	
	if current_checkpoint:
		car.global_transform.origin = current_checkpoint.position + Vector3.UP * 5
		car.global_basis = current_checkpoint.basis
	else:
		car.global_transform.origin = initial_spawn.origin
		car.global_basis = initial_spawn.basis
	
	car.freeze = false
