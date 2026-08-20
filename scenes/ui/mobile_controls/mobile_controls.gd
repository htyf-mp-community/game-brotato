extends Control
class_name MobileControls

@export var preview_in_editor := true

@onready var joystick: VirtualJoystick = $VirtualJoystick
@onready var dash_button: Button = $DashButton


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	focus_mode = Control.FOCUS_NONE
	dash_button.focus_mode = Control.FOCUS_NONE
	dash_button.mouse_filter = Control.MOUSE_FILTER_STOP
	dash_button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	dash_button.button_down.connect(_on_dash_button_down)
	dash_button.gui_input.connect(_on_dash_gui_input)
	joystick.vector_changed.connect(_on_joystick_vector_changed)
	_apply_visibility(false)


func _process(_delta: float) -> void:
	var show_controls := _should_show()
	if visible != show_controls:
		_apply_visibility(show_controls)
	Global.joystick_vector = joystick.output if show_controls else Vector2.ZERO


func _should_show() -> bool:
	if Global.game_paused or Global.player == null:
		return false
	if OS.has_feature("mobile") or DisplayServer.is_touchscreen_available():
		return true
	return preview_in_editor and OS.has_feature("editor")


func _apply_visibility(show_controls: bool) -> void:
	visible = show_controls
	if show_controls:
		return
	joystick.release()
	Global.joystick_vector = Vector2.ZERO


func _on_joystick_vector_changed(vector: Vector2) -> void:
	if visible:
		Global.joystick_vector = vector


func _on_dash_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		_on_dash_button_down()
		dash_button.accept_event()


func _on_dash_button_down() -> void:
	Global.dash_just_pressed = true
