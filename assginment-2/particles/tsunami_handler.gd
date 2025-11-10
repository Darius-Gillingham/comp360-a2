extends Node3D

signal start_wave(start_pos: Vector3, direction: Vector3, rise: float, rise_time: float, peak_time: float)

func _ready() -> void:
	start_wave.connect(start_wave_tween)
	
func start_wave_tween(start_pos: Vector3, direction: Vector3, rise: float, rise_time: float, peak_time: float):
	var total_time = rise_time * 2 + peak_time
	position = start_pos
	var target_rise = start_pos + direction * (rise_time / total_time) + Vector3(0, rise, 0)
	var target_rise_end = target_rise + direction * (peak_time / total_time)
	var target_fall = target_rise_end + direction * (rise_time / total_time) - Vector3(0, rise, 0)
	
	var rise_tween = create_tween()
	rise_tween.tween_property(self, "position", target_rise, rise_time)\
		 .set_ease(Tween.EASE_OUT)\
		 .set_trans(Tween.TRANS_LINEAR)

	await rise_tween.finished
	
	var peak_tween = create_tween()
	peak_tween.tween_property(self, "position", target_rise_end, peak_time)\
		 .set_ease(Tween.EASE_OUT)\
		 .set_trans(Tween.TRANS_LINEAR)
		
	await peak_tween.finished
	
	var fall_tween = create_tween()
	fall_tween.tween_property(self, "position", target_fall, rise_time)\
		 .set_ease(Tween.EASE_OUT)\
		 .set_trans(Tween.TRANS_LINEAR)
		
	await fall_tween.finished
	
	queue_free()
