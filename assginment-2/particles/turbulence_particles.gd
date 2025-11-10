extends GPUParticles3D

@export var rotation_speed = 8

func _process(delta: float) -> void:
	rotate_y(delta * rotation_speed)
