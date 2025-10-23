extends VehicleBody3D

const MAX_STEER = 0.5
const ENGINE_POWER = 200

@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera_3d: Camera3D = $CameraPivot/Camera3D

var look_toward

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	look_toward = global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	steering = move_toward(steering, Input.get_axis("Left", "Right") * MAX_STEER, delta * 2.5)
	engine_force = Input.get_axis("Brake", "Accelerate") * ENGINE_POWER
	camera_pivot.global_position = camera_pivot.global_position.lerp(global_position, delta * 20.0)
	camera_pivot.transform = camera_pivot.transform.interpolate_with(transform, delta * 5.0)
	look_toward = look_toward.lerp(global_position + linear_velocity, delta * 5.0)
	camera_3d.look_at(look_toward)
	
	
