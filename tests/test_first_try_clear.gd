@tool
extends McpTestSuite


const FIFTEEN_HP := 15.0
const TWO_HITS := 2.0
const CHASER_FAST := "res://scenes/unit/enemy/enemy_chaser_fast.tscn"
const WAVE_1_TO_4 := "res://resources/waves/data/wave_1_to_4.tres"
const WAVE_8 := "res://resources/waves/data/wave_8.tres"
const PLAYER_STATS := {
	"全能": "res://resources/units/players/stats_player_well_rounded.tres",
	"狂人": "res://resources/units/players/stats_player_crazy.tres",
	"兔子": "res://resources/units/players/stats_player_bunny.tres",
	"格斗家": "res://resources/units/players/stats_player_brawler.tres",
	"骑士": "res://resources/units/players/stats_player_knight.tres",
}
const START_WEAPONS := [
	"res://resources/items/weapons/melee/axe/item_axe_1.tres",
	"res://resources/items/weapons/melee/chainsaw/item_chainsaw_1.tres",
	"res://resources/items/weapons/melee/mace/item_mace_1.tres",
	"res://resources/items/weapons/melee/punch/item_punch_1.tres",
	"res://resources/items/weapons/melee/sword/item_sword_1.tres",
	"res://resources/items/weapons/melee/wand/item_wand_1.tres",
	"res://resources/items/weapons/range/laser/item_laser_1.tres",
	"res://resources/items/weapons/range/pistol/item_pistol_1.tres",
	"res://resources/items/weapons/range/revolver/item_revolver_1.tres",
	"res://resources/items/weapons/range/shotgun/item_shotgun_1.tres",
	"res://resources/items/weapons/range/smg/item_smg_1.tres",
]
const ENEMY_STATS := [
	"res://resources/units/enemies/stats_enemy_chaser_slow.tres",
	"res://resources/units/enemies/stats_enemy_chaser_mid.tres",
	"res://resources/units/enemies/stats_enemy_chaser_fast.tres",
	"res://resources/units/enemies/stats_enemy_charger.tres",
	"res://resources/units/enemies/stats_enemy_shooter.tres",
]


func suite_name() -> String:
	return "first_try_clear"


func _load_stats(path: String) -> UnitStats:
	var stats: UnitStats = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
	assert_true(stats != null, path)
	return stats


func _load_wave(path: String) -> WaveData:
	var wave: WaveData = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
	assert_true(wave != null, path)
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


func test_well_rounded_and_crazy_are_the_fifteen_hp_anchor() -> void:
	var well := _load_stats(PLAYER_STATS["全能"])
	var crazy := _load_stats(PLAYER_STATS["狂人"])
	if well == null or crazy == null:
		return
	assert_eq(well.health, int(FIFTEEN_HP))
	assert_eq(crazy.health, int(FIFTEEN_HP))
	assert_true(well.hp_regen >= 1.0, "well-rounded needs sustain at 15 HP")
	assert_true(crazy.hp_regen >= 1.0, "crazy needs sustain at 15 HP")


func test_knight_is_tankier_than_the_fifteen_hp_anchor() -> void:
	var knight := _load_stats(PLAYER_STATS["骑士"])
	if knight == null:
		return
	assert_true(knight.health > int(FIFTEEN_HP), "knight should be tankier than 15 HP")


func test_all_five_characters_exist_for_first_try() -> void:
	for character_name in PLAYER_STATS.keys():
		var stats := _load_stats(PLAYER_STATS[character_name])
		if stats == null:
			return
		assert_eq(stats.name, character_name)
		assert_true(stats.health >= int(FIFTEEN_HP), character_name)


func test_start_weapons_are_common_tier() -> void:
	for path in START_WEAPONS:
		var weapon: ItemWeapon = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
		assert_true(weapon != null, path)
		if weapon == null:
			return
		assert_eq(weapon.item_tier, 0, path)


func test_no_enemy_empties_fifteen_hp_in_two_hits() -> void:
	for path in ENEMY_STATS:
		var stats := _load_stats(path)
		if stats == null:
			return
		assert_true(stats.damage * TWO_HITS < FIFTEEN_HP, path)
		assert_eq(stats.health_increase_per_wave, 0.0, path)
		assert_eq(stats.damage_increase_per_wave, 0.0, path)


func test_shooter_volley_cannot_empty_fifteen_hp() -> void:
	var packed: PackedScene = load("res://scenes/unit/enemy/enemy_shooter.tscn")
	assert_true(packed != null, "shooter scene should load")
	if packed == null:
		return
	var shooter: Node = packed.instantiate()
	var gun: Node = shooter.get_node("ShootingBehavior")
	var stats: UnitStats = shooter.stats
	var volley := stats.damage * float(gun.projectile_count)
	shooter.free()
	assert_true(volley < FIFTEEN_HP, "one shooter volley should not empty 15 HP")


func test_late_wave_pressure_uses_fast_chasers_not_damage() -> void:
	var early := _load_wave(WAVE_1_TO_4)
	var late := _load_wave(WAVE_8)
	if early == null or late == null:
		return
	assert_true(_weight_share(late, CHASER_FAST) > _weight_share(early, CHASER_FAST))
	var fast := _load_stats("res://resources/units/enemies/stats_enemy_chaser_fast.tres")
	if fast == null:
		return
	assert_true(fast.damage * TWO_HITS < FIFTEEN_HP)


func test_spawns_are_not_safe_on_top_of_the_player() -> void:
	var script := load("res://scenes/arena/spawner.gd")
	assert_true(script != null, "spawner script should load")
	if script == null:
		return
	var spawner = script.new()
	assert_false(spawner.is_safe_spawn_position(Vector2.ZERO, Vector2.ZERO))
	assert_false(spawner.is_safe_spawn_position(Vector2(100, 0), Vector2.ZERO))
	assert_true(spawner.is_safe_spawn_position(Vector2(400, 0), Vector2.ZERO))
