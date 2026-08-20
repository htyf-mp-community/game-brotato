extends ItemBase
class_name ItemPassive

const STAT_NAMES := {
	"health": "生命",
	"hp_regen": "生命回复",
	"life_steal": "生命偷取",
	"damage": "伤害",
	"luck": "幸运",
	"speed": "移速",
	"block_chance": "格挡几率",
	"harvesting": "收获",
}

@export var add_value: float
@export var add_stats: String
@export var remove_value: float
@export var remove_stats: String

func get_description() -> String:
	var description := "[code]"
	
	if add_value != 0:
		description += "[color=green]+%s %s[/color]\n" % [add_value, STAT_NAMES.get(add_stats, add_stats)]
	
	if remove_value != 0:
		description += "[color=red]-%s %s[/color]" % [remove_value, STAT_NAMES.get(remove_stats, remove_stats)]
	
	description += "[/code]"
	return description

func apply_passive() -> void:
	if add_value != 0:
		Global.player.stats[add_stats] += add_value
	
	if remove_value != 0:
		Global.player.stats[remove_stats] -= remove_value
