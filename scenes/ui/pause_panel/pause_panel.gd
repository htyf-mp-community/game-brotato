extends Panel
class_name PausePanel

signal on_continue_pressed
signal on_abandon_confirmed

@onready var music_button: Button = %MusicButton
@onready var sfx_button: Button = %SfxButton


func _ready() -> void:
	refresh_audio_buttons()
	set_abandon_confirming(false)


func refresh_audio_buttons() -> void:
	music_button.text = AudioSettings.music_button_text(SoundManager.music_enabled)
	sfx_button.text = AudioSettings.sfx_button_text(SoundManager.sfx_enabled)


func set_abandon_confirming(confirming: bool) -> void:
	%TitleLabel.text = PauseRules.abandon_confirm_title() if confirming else PauseRules.pause_title()
	%ContinueButton.visible = not confirming
	%MusicButton.visible = not confirming
	%SfxButton.visible = not confirming
	%AbandonButton.visible = not confirming
	%ConfirmAbandonButton.visible = confirming
	%CancelAbandonButton.visible = confirming


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


func _on_abandon_button_pressed() -> void:
	SoundManager.play_sound(SoundManager.Sound.UI)
	set_abandon_confirming(true)


func _on_cancel_abandon_button_pressed() -> void:
	SoundManager.play_sound(SoundManager.Sound.UI)
	set_abandon_confirming(false)


func _on_confirm_abandon_button_pressed() -> void:
	SoundManager.play_sound(SoundManager.Sound.UI)
	set_abandon_confirming(false)
	on_abandon_confirmed.emit()
