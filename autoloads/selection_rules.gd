class_name SelectionRules
extends RefCounted


static func is_ready_to_continue(player_selected: bool, weapon_selected: bool) -> bool:
	return player_selected and weapon_selected


static func continue_hint(player_selected: bool, weapon_selected: bool) -> String:
	return "" if is_ready_to_continue(player_selected, weapon_selected) else "请选择角色和武器"
