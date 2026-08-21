@tool
extends McpTestSuite


func suite_name() -> String:
	return "joystick_hud"


func _rules():
	var script := load("res://autoloads/joystick_rules.gd")
	assert_true(script != null, "JoystickRules script should exist")
	if script == null:
		return null
	return script


func test_press_below_top_bar_is_allowed() -> void:
	var rules = _rules()
	if rules == null:
		return
	var stick := Rect2(0, 0, 960, 1080)
	var hud := [Rect2(10, 10, 128, 96), Rect2(400, 20, 560, 90), Rect2(453, 110, 55, 64), Rect2(426, 78, 214, 18)]
	var excluded: Rect2 = rules.top_bar_exclusion(hud, stick)
	assert_true(rules.can_begin_press(Vector2(200, 400), stick, excluded))


func test_press_inside_top_bar_band_is_blocked() -> void:
	var rules = _rules()
	if rules == null:
		return
	var stick := Rect2(0, 0, 960, 1080)
	var hud := [Rect2(10, 10, 128, 96), Rect2(400, 20, 560, 90)]
	var excluded: Rect2 = rules.top_bar_exclusion(hud, stick)
	assert_false(rules.can_begin_press(Vector2(200, 50), stick, excluded))


func test_press_in_gap_between_hud_widgets_is_still_blocked() -> void:
	var rules = _rules()
	if rules == null:
		return
	var stick := Rect2(0, 0, 960, 1080)
	var hud := [Rect2(10, 10, 128, 96), Rect2(400, 20, 560, 90)]
	var excluded: Rect2 = rules.top_bar_exclusion(hud, stick)
	assert_false(rules.can_begin_press(Vector2(300, 40), stick, excluded))


func test_press_outside_left_half_is_blocked() -> void:
	var rules = _rules()
	if rules == null:
		return
	var stick := Rect2(0, 0, 960, 1080)
	assert_false(rules.can_begin_press(Vector2(1200, 400), stick, Rect2()))


func test_joystick_keeps_size_deadzone_and_fades_alpha() -> void:
	var script := load("res://scenes/ui/mobile_controls/virtual_joystick.gd")
	assert_true(script != null, "VirtualJoystick script should exist")
	if script == null:
		return
	var stick: Node = script.new()
	assert_eq(stick.ring_radius, 110.0)
	assert_eq(stick.knob_radius, 42.0)
	assert_eq(stick.deadzone, 0.12)
	assert_true(stick.floating)
	assert_true(is_equal_approx(stick.ring_color.a, 0.14))
	assert_true(is_equal_approx(stick.ring_fill_color.a, 0.16))
	assert_true(is_equal_approx(stick.knob_color.a, 0.44))
	assert_true(stick.knob_pressed_color.a >= 0.5)
	stick.free()


func test_wave_labels_have_dark_outline_and_same_size() -> void:
	var packed: PackedScene = load("res://scenes/arena/arena.tscn")
	assert_true(packed != null, "arena scene should load")
	if packed == null:
		return
	var arena: Node = packed.instantiate()
	var index_label: Label = arena.get_node_or_null("%WaveIndexLabel")
	var time_label: Label = arena.get_node_or_null("%WaveTimeLabel")
	assert_true(index_label != null and time_label != null, "wave labels should exist")
	if index_label == null or time_label == null:
		arena.free()
		return
	assert_eq(index_label.label_settings.font_size, 64)
	assert_eq(time_label.label_settings.font_size, 64)
	assert_true(index_label.label_settings.outline_size >= 4, "wave index should have an outline")
	assert_true(time_label.label_settings.outline_size >= 4, "wave time should have an outline")
	assert_true(index_label.label_settings.outline_color.v <= 0.2, "wave index outline should be dark")
	assert_true(time_label.label_settings.outline_color.v <= 0.2, "wave time outline should be dark")
	arena.free()


func test_dash_button_is_faded_and_same_size() -> void:
	var packed: PackedScene = ResourceLoader.load("res://scenes/ui/mobile_controls/mobile_controls.tscn", "", ResourceLoader.CACHE_MODE_IGNORE)
	assert_true(packed != null, "mobile controls scene should load")
	if packed == null:
		return
	var controls: Node = packed.instantiate()
	var dash: Button = controls.get_node_or_null("%DashButton")
	assert_true(dash != null, "dash button should exist")
	if dash == null:
		controls.free()
		return
	assert_eq(dash.custom_minimum_size.x, 160.0)
	assert_eq(dash.custom_minimum_size.y, 160.0)
	var normal: StyleBoxFlat = dash.get("theme_override_styles/normal")
	assert_true(normal != null, "dash should have a normal style")
	if normal != null:
		assert_true(is_equal_approx(normal.bg_color.a, 0.36))
	controls.free()


func test_pause_button_size_unchanged() -> void:
	var packed: PackedScene = load("res://scenes/arena/arena.tscn")
	assert_true(packed != null, "arena scene should load")
	if packed == null:
		return
	var arena: Node = packed.instantiate()
	var button: Button = arena.get_node_or_null("%PauseButton")
	assert_true(button != null, "pause button should exist")
	if button != null:
		assert_eq(button.custom_minimum_size.x, 96.0)
		assert_eq(button.custom_minimum_size.y, 96.0)
		assert_eq(button.modulate.a, 1.0)
	arena.free()
