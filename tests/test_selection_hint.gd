@tool
extends McpTestSuite


func suite_name() -> String:
	return "selection_hint"


func _rules():
	var script := load("res://autoloads/selection_rules.gd")
	assert_true(script != null, "SelectionRules script should exist")
	if script == null:
		return null
	return script


func test_hint_shows_when_player_and_weapon_missing() -> void:
	var rules = _rules()
	if rules == null:
		return
	assert_eq(rules.continue_hint(false, false), "请选择角色和武器")
	assert_false(rules.is_ready_to_continue(false, false))


func test_hint_shows_when_only_player_selected() -> void:
	var rules = _rules()
	if rules == null:
		return
	assert_eq(rules.continue_hint(true, false), "请选择角色和武器")
	assert_false(rules.is_ready_to_continue(true, false))


func test_hint_shows_when_only_weapon_selected() -> void:
	var rules = _rules()
	if rules == null:
		return
	assert_eq(rules.continue_hint(false, true), "请选择角色和武器")
	assert_false(rules.is_ready_to_continue(false, true))


func test_hint_hides_when_player_and_weapon_selected() -> void:
	var rules = _rules()
	if rules == null:
		return
	assert_eq(rules.continue_hint(true, true), "")
	assert_true(rules.is_ready_to_continue(true, true))


func test_selection_panel_has_hint_near_continue() -> void:
	var packed: PackedScene = load("res://scenes/ui/selection_panel/selection_panel.tscn")
	assert_true(packed != null, "selection panel scene should load")
	if packed == null:
		return
	var panel: Node = packed.instantiate()
	var hint: Label = panel.get_node_or_null("%SelectionHint")
	assert_true(hint != null, "selection panel should have %SelectionHint")
	if hint != null:
		assert_eq(hint.text, "请选择角色和武器")
	panel.free()
