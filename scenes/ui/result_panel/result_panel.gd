extends Panel
class_name ResultPanel

signal on_retry_pressed

@onready var title_label: Label = %TitleLabel
@onready var detail_label: Label = %DetailLabel


func show_victory() -> void:
	title_label.text = "胜利"
	detail_label.text = ""
	detail_label.hide()
	show()


func show_defeat(wave_index: int) -> void:
	title_label.text = "失败"
	detail_label.text = "死于第 %s 波" % wave_index
	detail_label.show()
	show()


func _on_retry_button_pressed() -> void:
	SoundManager.play_sound(SoundManager.Sound.UI)
	on_retry_pressed.emit()
