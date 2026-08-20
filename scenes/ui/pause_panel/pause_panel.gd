extends Panel
class_name PausePanel

signal on_continue_pressed


func _on_continue_button_pressed() -> void:
	SoundManager.play_sound(SoundManager.Sound.UI)
	on_continue_pressed.emit()


func _on_placeholder_button_pressed() -> void:
	SoundManager.play_sound(SoundManager.Sound.UI)
