extends Label

var time_elapsed: float = 0.0

func _process(delta: float) -> void:
	time_elapsed += delta
	var minutes := time_elapsed / 60
	var seconds := fmod(time_elapsed, 60)
	var milliseconds := fmod(time_elapsed, 1) * 100
	var time_string := "%02d:%02d:%02d" % [minutes, seconds, milliseconds]
	text = time_string



