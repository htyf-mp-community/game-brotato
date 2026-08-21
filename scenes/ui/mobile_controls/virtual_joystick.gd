extends Control
class_name VirtualJoystick

signal vector_changed(vector: Vector2)

@export var ring_radius := 110.0
@export var knob_radius := 42.0
@export var deadzone := 0.12
@export var floating := true
@export var ring_color := Color(1.0, 1.0, 1.0, 0.14)
@export var ring_fill_color := Color(0.0, 0.0, 0.0, 0.16)
@export var knob_color := Color(0.09, 0.62, 0.75, 0.44)
@export var knob_pressed_color := Color(0.09, 0.62, 0.75, 0.72)

var output := Vector2.ZERO

var _pressing := false
var _pointer_id := -999
var _origin := Vector2.ZERO
var _knob_offset := Vector2.ZERO
var hud_blockers: Array[Control] = []

const NONE_ID := -999
const MOUSE_ID := -1


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_NONE
	set_process_input(true)
	_reset_visual()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and not _pressing:
		_reset_visual()
	elif what == NOTIFICATION_VISIBILITY_CHANGED and not is_visible_in_tree():
		release()


func release() -> void:
	_pressing = false
	_pointer_id = NONE_ID
	_reset_visual()
	vector_changed.emit(output)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if _pointer_id == MOUSE_ID:
				_pointer_id = event.index
				accept_event()
				return
			_try_press(event.index, event.position)
		elif event.index == _pointer_id:
			release()
			accept_event()
		return

	if event is InputEventScreenDrag and event.index == _pointer_id:
		# GUI events are already expressed in this Control's local space.
		_drag_local(event.position)
		accept_event()
		return

	# A real finger already owns the stick; ignore emulated mouse.
	if _pointer_id >= 0:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_try_press(MOUSE_ID, event.position)
		elif _pointer_id == MOUSE_ID:
			release()
			accept_event()
		return

	if event is InputEventMouseMotion and _pointer_id == MOUSE_ID:
		_drag_local(get_local_mouse_position())
		accept_event()


func _input(event: InputEvent) -> void:
	if not _pressing:
		return
	if event is InputEventScreenTouch and not event.pressed and event.index == _pointer_id:
		release()
		get_viewport().set_input_as_handled()
		return
	if event is InputEventScreenDrag and event.index == _pointer_id:
		# Global input uses viewport/canvas coordinates, so convert it once.
		_drag_local(make_canvas_position_local(event.position))
		get_viewport().set_input_as_handled()
		return
	if _pointer_id != MOUSE_ID:
		return
	if event is InputEventMouseMotion:
		_drag_local(get_local_mouse_position())
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		release()
		get_viewport().set_input_as_handled()

func _draw() -> void:
	draw_circle(_origin, ring_radius, ring_fill_color)
	draw_arc(_origin, ring_radius, 0.0, TAU, 64, ring_color, 6.0, true)
	var knob_pos := _origin + _knob_offset
	var fill := knob_pressed_color if _pressing else knob_color
	draw_circle(knob_pos, knob_radius, fill)
	draw_arc(knob_pos, knob_radius, 0.0, TAU, 48, Color(1.0, 1.0, 1.0, 0.2), 3.0, true)


func _try_press(pointer_id: int, local_pos: Vector2) -> void:
	if _pressing:
		return
	var stick_area := Rect2(Vector2.ZERO, size)
	var excluded := JoystickRules.top_bar_exclusion(_hud_rects_local(), stick_area)
	if not JoystickRules.can_begin_press(local_pos, stick_area, excluded):
		return
	_pressing = true
	_pointer_id = pointer_id
	_origin = local_pos if floating else _rest_origin()
	_drag_local(local_pos)
	accept_event()


func _drag_local(local_pos: Vector2) -> void:
	var delta := local_pos - _origin
	if delta.length() > ring_radius:
		delta = delta.normalized() * ring_radius
	_knob_offset = delta
	var strength := 0.0 if ring_radius <= 0.0 else delta.length() / ring_radius
	if strength < deadzone:
		output = Vector2.ZERO
	else:
		var adjusted := (strength - deadzone) / (1.0 - deadzone)
		output = delta.normalized() * clampf(adjusted, 0.0, 1.0)
	queue_redraw()
	vector_changed.emit(output)


func _reset_visual() -> void:
	_origin = _rest_origin()
	_knob_offset = Vector2.ZERO
	output = Vector2.ZERO
	queue_redraw()


func _rest_origin() -> Vector2:
	return Vector2(size.x * 0.5, maxf(ring_radius + 48.0, size.y - ring_radius - 48.0))


func _hud_rects_local() -> Array[Rect2]:
	var rects: Array[Rect2] = []
	var inv := get_global_transform_with_canvas().affine_inverse()
	for node in hud_blockers:
		if not is_instance_valid(node) or not node.visible:
			continue
		var global_rect := node.get_global_rect()
		var top_left: Vector2 = inv * global_rect.position
		var bottom_right: Vector2 = inv * global_rect.end
		rects.append(Rect2(top_left, bottom_right - top_left).abs())
	return rects
