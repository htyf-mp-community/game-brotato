@tool
extends McpTestSuite


func suite_name() -> String:
	return "wave_hud"


func _hud():
	var script := load("res://autoloads/wave_hud.gd")
	assert_true(script != null, "WaveHud script should exist")
	if script == null:
		return null
	return script


func test_wave_label_shows_index_and_total() -> void:
	var hud = _hud()
	if hud == null:
		return
	assert_eq(hud.format_wave_text(1, 8), "第 1 / 8 波")
	assert_eq(hud.format_wave_text(8, 8), "第 8 / 8 波")


func test_current_wave_pip_is_highlighted() -> void:
	var hud = _hud()
	if hud == null:
		return
	assert_eq(hud.pip_state(1, 1, 8, false), hud.PipState.CURRENT)
	assert_eq(hud.pip_state(2, 1, 8, false), hud.PipState.UPCOMING)


func test_finished_wave_pips_freeze_as_completed() -> void:
	var hud = _hud()
	if hud == null:
		return
	assert_eq(hud.pip_state(1, 1, 8, true), hud.PipState.COMPLETED)
	assert_eq(hud.pip_state(2, 1, 8, true), hud.PipState.UPCOMING)


func test_victory_fills_every_pip() -> void:
	var hud = _hud()
	if hud == null:
		return
	assert_eq(hud.pip_state(1, 8, 8, true), hud.PipState.COMPLETED)
	assert_eq(hud.pip_state(8, 8, 8, true), hud.PipState.COMPLETED)


func test_configured_run_is_eight_waves_of_thirty_seconds() -> void:
	var paths := [
		"res://resources/waves/data/wave_1_to_4.tres",
		"res://resources/waves/data/wave_5_to_6.tres",
		"res://resources/waves/data/wave_7.tres",
		"res://resources/waves/data/wave_8.tres",
	]
	var covered_from := 99
	var covered_to := 0
	for path in paths:
		var wave: WaveData = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
		assert_true(wave != null, path)
		if wave == null:
			return
		assert_eq(wave.wave_time, 30.0, path)
		assert_eq(wave.fixed_spawn_time, 0.8, path)
		covered_from = mini(covered_from, wave.from)
		covered_to = maxi(covered_to, wave.to)
	assert_eq(covered_from, 1)
	assert_eq(covered_to, 8)


func test_enemy_stat_growth_per_wave_is_zero() -> void:
	var paths := [
		"res://resources/units/enemies/stats_enemy_chaser_slow.tres",
		"res://resources/units/enemies/stats_enemy_chaser_mid.tres",
		"res://resources/units/enemies/stats_enemy_chaser_fast.tres",
		"res://resources/units/enemies/stats_enemy_charger.tres",
		"res://resources/units/enemies/stats_enemy_shooter.tres",
	]
	for path in paths:
		var stats: UnitStats = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
		assert_true(stats != null, path)
		if stats == null:
			return
		assert_eq(stats.health_increase_per_wave, 0.0, path)
		assert_eq(stats.damage_increase_per_wave, 0.0, path)
