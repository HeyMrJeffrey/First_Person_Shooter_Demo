extends Control

@onready var win_sound_effect_audio: AudioStreamPlayer = $WinSoundEffectAudio
@onready var time_section: Label = $CenterContainer/VBoxContainer/TimeSection
@export var time: Label

func win_game() -> void:
	win_sound_effect_audio.play()
	get_tree().paused = true
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	time_section.text = time.text
	
func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_button_pressed() -> void:
	get_tree().quit()
