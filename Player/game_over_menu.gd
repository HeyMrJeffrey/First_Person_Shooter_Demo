extends Control

@onready var death_sound_effect_audio: AudioStreamPlayer = $DeathSoundEffectAudio

func game_over() -> void:
	death_sound_effect_audio.play()
	get_tree().paused = true
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_button_pressed() -> void:
	get_tree().quit()
