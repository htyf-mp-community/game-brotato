@tool
extends McpTestSuite


func suite_name() -> String:
	return "combat_pause"


func _rules():
	var script := load("res://autoloads/pause_rules.gd")
	assert_true(script != null, "PauseRules script should exist")
	if script == null:
		return null
	return script


func test_pause_button_shows_during_combat() -> void:
	var rules = _rules()
	if rules == null:
		return
	assert_true(rules.should_show_pause_button(true, false, false, true))


func test_pause_button_hides_without_player() -> void:
	var rules = _rules()
	if rules == null:
		return
	assert_false(rules.should_show_pause_button(false, false, false, true))


func test_pause_button_hides_when_overlay_open() -> void:
	var rules = _rules()
	if rules == null:
		return
	assert_true(rules.any_overlay_open(true, false, false, false))
	assert_true(rules.any_overlay_open(false, true, false, false))
	assert_true(rules.any_overlay_open(false, false, true, false))
	assert_true(rules.any_overlay_open(false, false, false, true))
	assert_false(rules.any_overlay_open(false, false, false, false))
	assert_false(rules.should_show_pause_button(true, true, false, true))


func test_pause_button_hides_when_pause_menu_open() -> void:
	var rules = _rules()
	if rules == null:
		return
	assert_false(rules.should_show_pause_button(true, false, true, true))


func test_pause_button_hides_when_wave_is_not_running() -> void:
	var rules = _rules()
	if rules == null:
		return
	assert_false(rules.should_show_pause_button(true, false, false, false))


func test_combat_clock_pause_sets_timer_paused() -> void:
	var spawner: Spawner = load("res://scenes/arena/spawner.gd").new()
	var spawn := Timer.new()
	var wave := Timer.new()
	spawner.spawn_timer = spawn
	spawner.wave_timer = wave
	spawner.set_combat_clock_paused(true)
	assert_true(spawn.paused)
	assert_true(wave.paused)
	spawner.set_combat_clock_paused(false)
	assert_false(spawn.paused)
	assert_false(wave.paused)
	spawn.free()
	wave.free()
	spawner.free()


func test_arena_has_large_top_right_pause_button() -> void:
	var packed: PackedScene = load("res://scenes/arena/arena.tscn")
	assert_true(packed != null, "arena scene should load")
	if packed == null:
		return
	var arena: Node = packed.instantiate()
	var button: Button = arena.get_node_or_null("%PauseButton")
	assert_true(button != null, "arena should have %PauseButton")
	if button == null:
		arena.free()
		return
	assert_eq(button.text, "暂停")
	assert_eq(button.custom_minimum_size.x, 96.0)
	assert_eq(button.custom_minimum_size.y, 96.0)
	assert_eq(button.anchor_left, 1.0)
	assert_eq(button.anchor_right, 1.0)
	assert_eq(button.anchor_top, 0.0)
	arena.free()


func test_arena_has_hidden_pause_panel_with_continue() -> void:
	var packed: PackedScene = load("res://scenes/arena/arena.tscn")
	assert_true(packed != null, "arena scene should load")
	if packed == null:
		return
	var arena: Node = packed.instantiate()
	var panel: Control = arena.get_node_or_null("%PausePanel")
	assert_true(panel != null, "arena should have %PausePanel")
	if panel == null:
		arena.free()
		return
	assert_false(panel.visible)
	var continue_button: Button = panel.get_node_or_null("%ContinueButton")
	assert_true(continue_button != null, "pause panel should have %ContinueButton")
	if continue_button != null:
		assert_eq(continue_button.text, "继续")
	arena.free()
