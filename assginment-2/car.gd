extends VehicleBody3D

const MAX_STEER = 0.8
const ENGINE_POWER = 800

func _ready():
	pass
	
func _process(delta):
	steering = move_toward(steering, Input.get_axis("vi_right", "vi_left") * MAX_STEER, delta *2.5)
	engine_force = Input.get_axis("vi_down", "vi_up") * ENGINE_POWER
	
