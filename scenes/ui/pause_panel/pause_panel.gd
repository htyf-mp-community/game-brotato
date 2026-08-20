extends Panel
class_name PausePanel

signal on_continue_pressed

@onready var music_button: Button = %MusicButton
@onready var sfx_button: Button = %SfxButton


func _ready() -> void:
	refresh_audio_buttons()


func refresh_audio_buttons() -> void:
	music_button.text = AudioSettings.music_button_text(SoundManager.music_enabled)
	sfx_button.text = AudioSettings.sfx_button_text(SoundManager.sfx_enabled)


func _on_continue_button_pressed() -> void:
	SoundManager.play_sound(SoundManager.Sound.UI)
	on_continue_pressed.emit()


func _on_music_button_pressed() -> void:
	SoundManager.toggle_music()
	SoundManager.play_sound(SoundManager.Sound.UI)
	refresh_audio_buttons()


func _on_sfx_button_pressed() -> void:
	SoundManager.toggle_sfx()
	SoundManager.play_sound(SoundManager.Sound.UI)
	refresh_audio_buttons()


func _on_placeholder_button_pressed() -> void:
	SoundManager.play_sound(SoundManager.Sound.UI)
