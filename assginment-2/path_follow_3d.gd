extends PathFollow3D

@export var speed := 0.005  # normalized units per second
@export var max_speed := 0.01      # target max speed
@export var acceleration := 0.009  # how quickly it accelerates per second
var current_speed := 0.0
func _process(delta: float) -> void:
	# Accelerate like a real car until reaching top speed
	if current_speed < max_speed:
		current_speed += acceleration * delta
		current_speed = min(current_speed, max_speed)  # cap at max speed

	# Move along the path
	progress_ratio += current_speed * delta / 2.3

	# Loop around
	if progress_ratio > 1.0:
		progress_ratio = 0.0
