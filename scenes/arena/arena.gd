extends Node2D
class_name Arena

@export var normal_color: Color
@export var blocked_color: Color
@export var critical_color: Color
@export var hp_color: Color

@onready var wave_index_label: Label = %WaveIndexLabel
@onready var wave_time_label: Label = %WaveTimeLabel
@onready var wave_pips: HBoxContainer = %WavePips

@onready var spawner: Spawner = $Spawner
@onready var upgrade_panel: UpgradePanel = %UpgradePanel
@onready var shop_panel: ShopPanel = %ShopPanel
@onready var coins_bag: CoinsBag = %CoinsBag
@onready var selection_panel: SelectionPanel = %SelectionPanel
@onready var result_panel: ResultPanel = %ResultPanel
@onready var pause_button: Button = %PauseButton
@onready var pause_panel: PausePanel = %PausePanel
@onready var music_player: AudioStreamPlayer = $MusicPlayer

var gold_list: Array[Coins]

func _ready() -> void:
	Global.on_create_block_text.connect(_on_create_block_text)
	Global.on_create_damage_text.connect(_on_create_damage_text)
	Global.on_upgrade_selected.connect(_on_upgrade_selected)
	Global.on_create_heal_text.connect(_on_create_heal_text)
	Global.on_enemy_died.connect(_on_enemy_died)
	Global.run_state.capture_enemy_baselines(spawner.enemy_collection)
	Global.coins = RunState.STARTING_COINS
	_refresh_wave_hud(false)
	_refresh_pause_button()
	_apply_bgm()


func _process(delta: float) -> void:
	_refresh_pause_button()
	if Global.game_paused:
		return
	_refresh_wave_hud(false)
	wave_time_label.text = spawner.get_wave_timer_text()


func _refresh_wave_hud(wave_finished: bool) -> void:
	var last_wave := spawner.get_last_wave_index()
	wave_index_label.text = WaveHud.format_wave_text(spawner.wave_index, last_wave)
	var pip_nodes := wave_pips.get_children()
	for i in pip_nodes.size():
		var pip := pip_nodes[i] as ColorRect
		if pip == null:
			continue
		match WaveHud.pip_state(i + 1, spawner.wave_index, last_wave, wave_finished):
			WaveHud.PipState.COMPLETED:
				pip.color = Color(0.094, 0.624, 0.745)
			WaveHud.PipState.CURRENT:
				pip.color = Color(0.996, 0.78, 0.38)
			_:
				pip.color = Color(0.22, 0.22, 0.22)


func create_floating_text(unit: Node2D) -> FloatingText:
	var instance := Global.FLOATING_TEXT_SCENE.instantiate() as FloatingText
	get_tree().root.add_child(instance)
	var random_pos := randf_range(0, TAU) * 35
	var spawn_pos := unit.global_position + Vector2.RIGHT.rotated(random_pos)
	instance.global_position = spawn_pos
	return instance


func show_upgrades() -> void:
	upgrade_panel.load_upgrades(spawner.wave_index)
	upgrade_panel.show()


func start_new_wave() -> void:
	Global.game_paused = false
	Global.player.update_player_new_wave()
	spawner.wave_index += 1
	spawner.start_wave()


func clean_arena() -> void:
	if gold_list.size() > 0:
		var target_center_pos := coins_bag.global_position + coins_bag.size / 2.0
		for gold in gold_list:
			if is_instance_valid(gold):
				var gold_item := gold as Coins
				gold_item.set_collection_target(target_center_pos)
	
	gold_list.clear()
	spawner.clear_enemies()


func spawn_coins(enemy: Enemy) -> void:
	var random_angle := randf_range(0, TAU)
	var offset := Vector2.RIGHT.rotated(random_angle) * 35 
	var spawn_pos := enemy.global_position + offset
	
	var gold_instance := Global.COINS_SCENE.instantiate() as Coins
	gold_list.append(gold_instance)
	
	gold_instance.global_position = spawn_pos
	gold_instance.value = enemy.stats.gold_drop
	call_deferred("add_child", gold_instance)


func _show_result_victory() -> void:
	pause_panel.hide()
	Global.game_paused = true
	spawner.stop_wave()
	upgrade_panel.hide()
	shop_panel.hide()
	_refresh_wave_hud(true)
	result_panel.show_victory()


func _on_player_died() -> void:
	if result_panel.visible:
		return
	pause_panel.hide()
	Global.game_paused = true
	spawner.stop_wave()
	upgrade_panel.hide()
	shop_panel.hide()
	result_panel.show_defeat(spawner.wave_index)


func _return_to_selection() -> void:
	pause_panel.hide()
	result_panel.hide()
	upgrade_panel.hide()
	shop_panel.hide()
	shop_panel.clear_run_items()
	if is_instance_valid(Global.player):
		Global.player.queue_free()
	Global.reset_run()
	spawner.reset_for_new_run()
	clean_arena()
	selection_panel.prepare_for_new_run()
	_refresh_wave_hud(false)
	_apply_bgm()


func _on_create_block_text(unit: Node2D) -> void:
	var text := create_floating_text(unit)
	text.setup("格挡!", blocked_color)


func _on_create_damage_text(unit: Node2D, hitbox: HitboxComponent) -> void:
	var text := create_floating_text(unit)
	var color := critical_color if hitbox.critical else normal_color
	text.setup(str(hitbox.damage), color)


func _on_create_heal_text(unit: Node2D, heal: float) -> void:
	var text := create_floating_text(unit)
	text.setup("+ %s" % heal, hp_color)


func _on_upgrade_selected() -> void:
	upgrade_panel.hide()
	shop_panel.load_shop(spawner.wave_index)
	shop_panel.show()


func _on_spawner_on_wave_completed() -> void:
	if not is_instance_valid(Global.player):
		return
	clean_arena()
	_refresh_wave_hud(true)
	if spawner.is_final_wave():
		_show_result_victory()
		return
	await get_tree().create_timer(1.0).timeout
	if not is_instance_valid(Global.player):
		return
	show_upgrades()
	clean_arena()


func _on_shop_panel_on_shop_next_wave() -> void:
	shop_panel.hide()
	start_new_wave()


func _on_enemy_died(enemy: Enemy) -> void:
	spawn_coins(enemy)


func _on_selection_panel_on_selection_completed() -> void:
	var player := Global.get_selected_player()
	add_child(player)
	player.add_weapon(Global.main_weapon_selected)
	player.health_component.on_unit_died.connect(_on_player_died)
	shop_panel.create_item_weapon(Global.main_weapon_selected)
	Global.equipped_weapons.append(Global.main_weapon_selected)
	
	spawner.start_wave()
	Global.game_paused = false


func _on_result_panel_on_retry_pressed() -> void:
	_return_to_selection()


func _is_overlay_open() -> bool:
	return PauseRules.any_overlay_open(
		selection_panel.visible,
		upgrade_panel.visible,
		shop_panel.visible,
		result_panel.visible
	)


func _refresh_pause_button() -> void:
	pause_button.visible = PauseRules.should_show_pause_button(
		is_instance_valid(Global.player),
		_is_overlay_open(),
		pause_panel.visible,
		spawner.is_wave_running()
	)


func open_combat_pause() -> void:
	if pause_panel.visible:
		return
	if not PauseRules.should_show_pause_button(
		is_instance_valid(Global.player),
		_is_overlay_open(),
		false,
		spawner.is_wave_running()
	):
		return
	Global.game_paused = true
	spawner.set_combat_clock_paused(true)
	pause_panel.show()
	pause_panel.set_abandon_confirming(false)
	pause_panel.refresh_audio_buttons()
	_refresh_pause_button()
	_apply_bgm()


func resume_combat() -> void:
	if not pause_panel.visible:
		return
	pause_panel.hide()
	spawner.set_combat_clock_paused(false)
	Global.game_paused = false
	_refresh_pause_button()
	_apply_bgm()


func _on_pause_button_pressed() -> void:
	SoundManager.play_sound(SoundManager.Sound.UI)
	open_combat_pause()


func _on_pause_panel_on_continue_pressed() -> void:
	resume_combat()


func _on_pause_panel_on_abandon_confirmed() -> void:
	_return_to_selection()


func _apply_bgm() -> void:
	if AudioSettings.should_play_bgm(SoundManager.music_enabled, pause_panel.visible):
		if music_player.playing:
			music_player.stream_paused = false
		else:
			music_player.play()
	else:
		music_player.stream_paused = true
