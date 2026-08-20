extends Node


var character_name := "全能"
var weapon_substr := "pistol"
var min_hp := 999.0
var finished := false
var title := ""
var detail := ""
var wave := 0


func _ready() -> void:
	Engine.time_scale = 8.0
	call_deferred("_start_run")


func snapshot() -> Dictionary:
	return {
		"finished": finished,
		"title": title,
		"detail": detail,
		"wave": wave,
		"min_hp": min_hp,
		"hp": _current_hp(),
		"character": character_name,
	}


func _current_hp() -> float:
	if is_instance_valid(Global.player):
		return Global.player.health_component.current_health
	return -1.0


func _arena() -> Node:
	return get_parent()


func _start_run() -> void:
	var arena := _arena()
	var sel = arena.selection_panel
	var player_stats: UnitStats = null
	var weapon: ItemWeapon = null
	for stats in sel.players:
		if stats and stats.name == character_name:
			player_stats = stats
			break
	for item in sel.start_weapons:
		if item and str(item.resource_path).contains(weapon_substr):
			weapon = item
			break
	if player_stats == null and sel.players.size() > 0:
		player_stats = sel.players[0]
	if weapon == null and sel.start_weapons.size() > 0:
		weapon = sel.start_weapons[0]
	sel._on_player_selected(player_stats)
	sel._on_weapon_selected(weapon)
	sel._on_continue_buttom_pressed()


func _process(_delta: float) -> void:
	if finished:
		return
	var arena := _arena()
	if is_instance_valid(Global.player):
		var t := Time.get_ticks_msec() * 0.004
		Global.joystick_vector = Vector2(cos(t), sin(t))
		min_hp = minf(min_hp, Global.player.health_component.current_health)
		wave = arena.spawner.wave_index
	if arena.result_panel.visible:
		finished = true
		title = arena.result_panel.title_label.text
		detail = arena.result_panel.detail_label.text
		Engine.time_scale = 1.0
		return
	if arena.upgrade_panel.visible:
		var cards = arena.upgrade_panel.get_node("%ItemsContainer").get_children()
		if cards.size() > 0 and cards[0].has_method("_on_custom_buttom_pressed"):
			cards[0]._on_custom_buttom_pressed()
	elif arena.shop_panel.visible:
		for card in arena.shop_panel.get_node("%ItemsContainer").get_children():
			if card.has_method("_on_buy_buttom_pressed"):
				card._on_buy_buttom_pressed()
		arena.shop_panel._on_new_wave_button_pressed()
