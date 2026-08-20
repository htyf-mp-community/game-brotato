extends ItemBase
class_name ItemWeapon

enum WeaponType {
	MELEE,
	RANGE
}

@export var type: WeaponType
@export var scene: PackedScene
@export var stats: WeaponStats
@export var upgrade_to: ItemWeapon

func get_description() -> String:
	return "[code]伤害: [color=green]%s[/color]\n冷却: [color=green]%s[/color]\n范围: [color=green]%s[/color]\n暴击: [color=green]%s%%[/color][/code]" % [stats.damage, stats.cooldown, stats.max_range, stats.crit_chance * 100]   
