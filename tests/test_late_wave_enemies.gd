@tool
extends McpTestSuite


const CHASER_SLOW := "res://scenes/unit/enemy/enemy_chaser_slow.tscn"
const CHASER_MID := "res://scenes/unit/enemy/enemy_chaser_mid.tscn"
const CHASER_FAST := "res://scenes/unit/enemy/enemy_chaser_fast.tscn"
const CHARGER := "res://scenes/unit/enemy/enemy_charger.tscn"
const SHOOTER := "res://scenes/unit/enemy/enemy_shooter.tscn"
const WAVE_1_TO_4 := "res://resources/waves/data/wave_1_to_4.tres"
const WAVE_5_TO_6 := "res://resources/waves/data/wave_5_to_6.tres"
const WAVE_7 := "res://resources/waves/data/wave_7.tres"
const WAVE_8 := "res://resources/waves/data/wave_8.tres"
const FIFTEEN_HP := 15.0
const LOW_WEIGHT_SHARE := 0.2


func suite_name() -> String:
	return "late_wave_enemies"


func _load_wave(path: String) -> WaveData:
	var wave: WaveData = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
	assert_true(wave != null, "%s should load" % path)
	return wave


func _weight_share(wave: WaveData, scene_path: String) -> float:
	if wave == null:
		return 0.0
	var total := 0.0
	var matched := 0.0
	for unit in wave.units:
		if unit == null:
			continue
		total += unit.weight
		if unit.unit_scene and unit.unit_scene.resource_path == scene_path:
			matched += unit.weight
	if total <= 0.0:
		return 0.0
	return matched / total


func _scene_paths(wave: WaveData) -> PackedStringArray:
	var paths: PackedStringArray = []
	if wave == null:
		return paths
	for unit in wave.units:
		if unit and unit.unit_scene:
			paths.append(unit.unit_scene.resource_path)
	return paths


func test_waves_1_to_4_only_have_chasers() -> void:
	var wave := _load_wave(WAVE_1_TO_4)
	if wave == null:
		return
	assert_eq(wave.from, 1)
	assert_eq(wave.to, 4)
	var paths := _scene_paths(wave)
	assert_true(CHASER_SLOW in paths)
	assert_true(CHASER_MID in paths)
	assert_true(CHASER_FAST in paths)
	assert_true(CHARGER not in paths)
	assert_true(SHOOTER not in paths)


func test_waves_5_and_6_include_few_chargers() -> void:
	var wave := _load_wave(WAVE_5_TO_6)
	if wave == null:
		return
	assert_eq(wave.from, 5)
	assert_eq(wave.to, 6)
	var charger_share := _weight_share(wave, CHARGER)
	assert_true(charger_share > 0.0, "waves 5-6 should include chargers")
	assert_true(charger_share <= LOW_WEIGHT_SHARE, "charger share should stay low")
	assert_eq(_weight_share(wave, SHOOTER), 0.0, "waves 5-6 should not add shooters yet")


func test_wave_7_adds_few_shooters() -> void:
	var wave := _load_wave(WAVE_7)
	if wave == null:
		return
	assert_eq(wave.from, 7)
	assert_eq(wave.to, 7)
	var shooter_share := _weight_share(wave, SHOOTER)
	assert_true(shooter_share > 0.0, "wave 7 should include shooters")
	assert_true(shooter_share <= LOW_WEIGHT_SHARE, "wave 7 shooter share should stay low")
	assert_eq(_weight_share(wave, CHARGER), 0.0, "wave 7 keeps charger for the final wave")


func test_wave_8_has_both_specials_at_low_weight() -> void:
	var wave := _load_wave(WAVE_8)
	if wave == null:
		return
	assert_eq(wave.from, 8)
	assert_eq(wave.to, 8)
	var charger_share := _weight_share(wave, CHARGER)
	var shooter_share := _weight_share(wave, SHOOTER)
	assert_true(charger_share > 0.0, "wave 8 should include chargers")
	assert_true(shooter_share > 0.0, "wave 8 should include shooters")
	assert_true(charger_share <= LOW_WEIGHT_SHARE, "wave 8 charger share should stay low")
	assert_true(shooter_share <= LOW_WEIGHT_SHARE, "wave 8 shooter share should stay low")


func test_late_waves_raise_fast_chaser_share() -> void:
	var early := _load_wave(WAVE_1_TO_4)
	var late := _load_wave(WAVE_8)
	if early == null or late == null:
		return
	assert_true(_weight_share(late, CHASER_FAST) > _weight_share(early, CHASER_FAST), "late waves should slightly raise fast chaser weight")


func test_arena_uses_split_wave_tables() -> void:
	var packed: PackedScene = load("res://scenes/arena/arena.tscn")
	assert_true(packed != null, "arena scene should load")
	if packed == null:
		return
	var arena: Node = packed.instantiate()
	var spawner: Node = arena.get_node("Spawner")
	var paths: PackedStringArray = []
	for wave in spawner.waves_data:
		if wave:
			paths.append(wave.resource_path)
	arena.free()
	assert_true(WAVE_1_TO_4 in paths, "arena should use waves 1-4 table")
	assert_true(WAVE_5_TO_6 in paths, "arena should use waves 5-6 table")
	assert_true(WAVE_7 in paths, "arena should use wave 7 table")
	assert_true(WAVE_8 in paths, "arena should use wave 8 table")


func test_charger_and_shooter_cannot_one_shot_fifteen_hp() -> void:
	var charger: UnitStats = ResourceLoader.load("res://resources/units/enemies/stats_enemy_charger.tres", "", ResourceLoader.CACHE_MODE_IGNORE)
	var shooter: UnitStats = ResourceLoader.load("res://resources/units/enemies/stats_enemy_shooter.tres", "", ResourceLoader.CACHE_MODE_IGNORE)
	assert_true(charger != null, "charger stats should load")
	assert_true(shooter != null, "shooter stats should load")
	if charger == null or shooter == null:
		return
	assert_true(charger.damage < FIFTEEN_HP, "charger should not one-shot 15 HP")
	assert_true(shooter.damage < FIFTEEN_HP, "shooter should not one-shot 15 HP")
	assert_eq(charger.health_increase_per_wave, 0.0)
	assert_eq(charger.damage_increase_per_wave, 0.0)
	assert_eq(shooter.health_increase_per_wave, 0.0)
	assert_eq(shooter.damage_increase_per_wave, 0.0)
