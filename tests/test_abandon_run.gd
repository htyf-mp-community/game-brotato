@tool
extends McpTestSuite


func suite_name() -> String:
	return "abandon_run"


func _rules():
	var script := load("res://autoloads/pause_rules.gd")
	assert_true(script != null, "PauseRules script should exist")
	if script == null:
		return null
	return script


func test_abandon_confirm_copy() -> void:
	var rules = _rules()
	if rules == null:
		return
	assert_eq(rules.pause_title(), "暂停")
	assert_eq(rules.abandon_confirm_title(), "确定放弃？")


func test_pause_panel_hides_confirm_until_abandon() -> void:
	var packed: PackedScene = load("res://scenes/ui/pause_panel/pause_panel.tscn")
	assert_true(packed != null, "pause panel should load")
	if packed == null:
		return
	var panel: Node = packed.instantiate()
	var confirm: Button = panel.get_node_or_null("%ConfirmAbandonButton")
	var cancel: Button = panel.get_node_or_null("%CancelAbandonButton")
	var abandon: Button = panel.get_node_or_null("%AbandonButton")
	assert_true(confirm != null, "pause panel should have %ConfirmAbandonButton")
	assert_true(cancel != null, "pause panel should have %CancelAbandonButton")
	assert_true(abandon != null, "pause panel should have %AbandonButton")
	if confirm == null or cancel == null or abandon == null:
		panel.free()
		return
	assert_eq(confirm.text, "确定")
	assert_eq(cancel.text, "取消")
	assert_eq(abandon.text, "放弃本局")
	assert_false(confirm.visible)
	assert_false(cancel.visible)
	assert_true(abandon.visible)
	panel.free()


func test_arena_wires_abandon_without_result_panel() -> void:
	var packed: PackedScene = load("res://scenes/arena/arena.tscn")
	assert_true(packed != null, "arena scene should load")
	if packed == null:
		return
	var arena: Node = packed.instantiate()
	var panel: Node = arena.get_node_or_null("%PausePanel")
	assert_true(panel != null, "arena should have %PausePanel")
	if panel == null:
		arena.free()
		return
	var connections := panel.get_signal_connection_list("on_abandon_confirmed")
	assert_true(connections.size() > 0, "PausePanel.on_abandon_confirmed should connect to Arena")
	var result: Node = arena.get_node_or_null("%ResultPanel")
	assert_true(result != null, "arena should have %ResultPanel")
	if result != null:
		assert_false(result.visible)
	arena.free()
