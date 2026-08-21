@tool
extends McpTestSuite


func suite_name() -> String:
	return "run_state"


func _make_state():
	var script := load("res://autoloads/run_state.gd")
	assert_true(script != null, "RunState script should exist")
	if script == null:
		return null
	return script.new()


func test_new_run_starts_with_twenty_coins() -> void:
	var state = _make_state()
	if state == null:
		return
	assert_eq(state.STARTING_COINS, 20)


func test_coins_bag_placeholder_is_twenty() -> void:
	var packed: PackedScene = load("res://scenes/ui/coins_bag/coins_bag.tscn")
	assert_true(packed != null, "coins bag scene should load")
	if packed == null:
		return
	var bag: Node = packed.instantiate()
	var label: Label = bag.get_node_or_null("Coins")
	assert_true(label != null, "coins bag should have Coins label")
	if label != null:
		assert_eq(label.text, "20")
	bag.free()


func test_last_configured_wave_is_final() -> void:
	var state = _make_state()
	if state == null:
		return
	assert_true(state.is_final_wave(5, 5))
	assert_false(state.is_final_wave(4, 5))
	assert_false(state.is_final_wave(1, 0))


func test_restore_puts_enemy_stats_back_to_captured_baseline() -> void:
	var state = _make_state()
	if state == null:
		return
	var stats := UnitStats.new()
	stats.health = 4
	stats.damage = 1.0
	var collection: Array[UnitStats] = [stats]
	state.capture_enemy_baselines(collection)
	stats.health = 11
	stats.damage = 8.0
	state.restore_enemy_baselines()
	assert_eq(stats.health, 4)
	assert_eq(stats.damage, 1.0)
