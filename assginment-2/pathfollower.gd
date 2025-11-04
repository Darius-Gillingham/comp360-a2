extends PathFollow3D

@export var speed := 0.01  # normalized units per second

func _process(delta):
	# advance along the path
	progress_ratio += speed * delta
	# loop around
	if progress_ratio > 1.0:
		progress_ratio = 0.0
