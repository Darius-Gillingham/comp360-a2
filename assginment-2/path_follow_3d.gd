extends PathFollow3D

@export var speed := 0.005  # normalized units per second

func _process(delta):
	# advance along the path
	progress_ratio += speed * delta/3
	# loop around
	if progress_ratio > 1.0:
		progress_ratio = 0.0
