@tool
extends McpTestSuite


func suite_name() -> String:
	return "host_background_pause"


func _rules():
	var script := load("res://autoloads/pause_rules.gd")
	assert_true(script != null, "PauseRules script should exist")
	if script == null:
		return null
	return script


func test_host_background_is_paused_or_focus_out() -> void:
	var rules = _rules()
	if rules == null:
		return
	assert_true(rules.is_host_background_event(MainLoop.NOTIFICATION_APPLICATION_PAUSED))
	assert_true(rules.is_host_background_event(MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT))
	assert_false(rules.is_host_background_event(MainLoop.NOTIFICATION_APPLICATION_RESUMED))
	assert_false(rules.is_host_background_event(MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN))
	assert_true(rules.is_host_background_event(2017))


func test_arena_instances_host_sdk() -> void:
	var packed: PackedScene = load("res://scenes/arena/arena.tscn")
	assert_true(packed != null, "arena scene should load")
	if packed == null:
		return
	var arena: Node = packed.instantiate()
	var sdk: Node = arena.get_node_or_null("HTYF-SDK")
	assert_true(sdk != null, "arena should instance HTYF-SDK for host lifecycle")
	if sdk != null:
		assert_true(sdk.get_script() != null, "HTYF-SDK should have the SDK script")
	arena.free()
