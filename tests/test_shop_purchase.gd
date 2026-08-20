@tool
extends McpTestSuite


func suite_name() -> String:
	return "shop_purchase"


func _rules():
	var script := load("res://autoloads/shop_purchase_rules.gd")
	assert_true(script != null, "ShopPurchaseRules script should exist")
	if script == null:
		return null
	return script


func test_can_buy_weapon_when_under_limit() -> void:
	var rules = _rules()
	if rules == null:
		return
	assert_true(rules.can_buy(ItemBase.ItemType.WEAPON, 0))
	assert_true(rules.can_buy(ItemBase.ItemType.WEAPON, 5))


func test_cannot_buy_seventh_weapon() -> void:
	var rules = _rules()
	if rules == null:
		return
	assert_false(rules.can_buy(ItemBase.ItemType.WEAPON, 6))


func test_can_buy_passive_when_weapons_are_full() -> void:
	var rules = _rules()
	if rules == null:
		return
	assert_true(rules.can_buy(ItemBase.ItemType.PASSIVE, 6))


func test_can_buy_passive_when_weapons_are_not_full() -> void:
	var rules = _rules()
	if rules == null:
		return
	assert_true(rules.can_buy(ItemBase.ItemType.PASSIVE, 0))
