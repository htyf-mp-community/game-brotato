class_name RunState
extends RefCounted

const STARTING_COINS := 20

var _enemy_baselines: Array = []


static func is_final_wave(wave_index: int, last_wave: int) -> bool:
	return last_wave > 0 and wave_index >= last_wave


func capture_enemy_baselines(stats_list: Array) -> void:
	_enemy_baselines.clear()
	for stats in stats_list:
		if stats == null:
			continue
		_enemy_baselines.append({
			"stats": stats,
			"health": stats.health,
			"damage": stats.damage,
		})


func restore_enemy_baselines() -> void:
	for baseline in _enemy_baselines:
		var stats = baseline.stats
		stats.health = baseline.health
		stats.damage = baseline.damage
