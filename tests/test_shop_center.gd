@tool
extends McpTestSuite


func suite_name() -> String:
	return "shop_center"


func _shop_panel() -> Node:
	var packed: PackedScene = ResourceLoader.load("res://scenes/ui/shop_panel/shop_panel.tscn", "", ResourceLoader.CACHE_MODE_IGNORE)
	assert_true(packed != null, "shop panel scene should load")
	if packed == null:
		return null
	return packed.instantiate()


func test_content_board_is_1920_wide_and_horizontally_centered() -> void:
	var panel: Node = _shop_panel()
	if panel == null:
		return
	var board: Control = panel.get_node_or_null("%ContentBoard")
	assert_true(board != null, "shop panel should have %ContentBoard")
	if board != null:
		assert_eq(board.anchor_left, 0.5)
		assert_eq(board.anchor_right, 0.5)
		assert_eq(board.anchor_top, 0.0)
		assert_eq(board.anchor_bottom, 0.0)
		assert_eq(board.offset_left, -960.0)
		assert_eq(board.offset_right, 960.0)
		assert_eq(board.offset_top, 0.0)
		assert_eq(board.offset_bottom, 1080.0)
	panel.free()


func test_shop_sections_live_on_the_board_with_same_offsets() -> void:
	var panel: Node = _shop_panel()
	if panel == null:
		return
	var board: Control = panel.get_node_or_null("%ContentBoard")
	assert_true(board != null, "shop panel should have %ContentBoard")
	if board == null:
		panel.free()
		return
	var items: Control = board.get_node_or_null("ItemsContainer")
	var stats: Control = board.get_node_or_null("StatsContainer")
	var passives: Control = board.get_node_or_null("Passives")
	var weapons: Control = board.get_node_or_null("Weapons")
	var next_wave: Button = board.find_child("NewWaveButton", true, false)
	assert_true(items != null, "ItemsContainer should be on the board")
	assert_true(stats != null, "StatsContainer should be on the board")
	assert_true(passives != null, "Passives should be on the board")
	assert_true(weapons != null, "Weapons should be on the board")
	assert_true(next_wave != null, "NewWaveButton should be on the board")
	if items != null:
		assert_eq(items.offset_left, 20.0)
		assert_eq(items.offset_top, 178.0)
	if stats != null:
		assert_eq(stats.offset_left, 1380.0)
	if passives != null:
		assert_eq(passives.offset_left, 20.0)
	if weapons != null:
		assert_eq(weapons.offset_left, 998.0)
	if next_wave != null:
		assert_eq(next_wave.get_parent().offset_left, 1440.0)
	panel.free()


func test_coins_stay_on_screen_top_left() -> void:
	var panel: Node = _shop_panel()
	if panel == null:
		return
	var board: Control = panel.get_node_or_null("%ContentBoard")
	var coins: Control = panel.find_child("CoinsBag", true, false)
	assert_true(coins != null, "shop panel should have CoinsBag")
	if coins != null:
		assert_true(board == null or coins.get_parent() != board, "CoinsBag should not live on the content board")
		assert_eq(coins.offset_left, 0.0)
		assert_eq(coins.offset_top, 0.0)
	panel.free()


func test_title_stays_full_screen_centered() -> void:
	var panel: Node = _shop_panel()
	if panel == null:
		return
	var board: Control = panel.get_node_or_null("%ContentBoard")
	var title: Label = panel.find_child("Title", true, false)
	assert_true(title != null, "shop panel should have Title")
	if title != null:
		assert_true(board == null or title.get_parent() != board, "Title should not live on the content board")
		assert_eq(title.anchor_left, 0.5)
		assert_eq(title.anchor_right, 0.5)
		assert_eq(title.text, "商店")
	panel.free()
