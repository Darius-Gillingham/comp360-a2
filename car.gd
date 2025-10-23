extends VehicleBody3D

const STEER_LIMIT= deg_to_rad(20)
const ENGINE_POWER = 200

@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera_3d: Camera3D = $CameraPivot/Camera3D

var move_input
var turn_input
var look_toward

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	look_toward = global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	move_input = Input.get_action_strength("Accelerate") - Input.get_action_strength("Brake")
	turn_input = Input.get_action_strength("Right") - Input.get_action_strength("Left")
	
	engine_force = move_input*ENGINE_POWER
	steering = turn_input*STEER_LIMIT
	
	
	camera_pivot.global_position = camera_pivot.global_position.lerp(global_position, delta * 20.0)
	camera_pivot.transform = camera_pivot.transform.interpolate_with(transform, delta * 5.0)
	look_toward = look_toward.lerp(global_position + linear_velocity, delta * 5.0)
	camera_3d.look_at(look_toward)
	
	
