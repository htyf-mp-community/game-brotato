class_name PauseRules
extends RefCounted


static func any_overlay_open(selection_open: bool, upgrade_open: bool, shop_open: bool, result_open: bool) -> bool:
	return selection_open or upgrade_open or shop_open or result_open


static func should_show_pause_button(player_present: bool, overlay_open: bool, pause_menu_open: bool, wave_running: bool) -> bool:
	return player_present and wave_running and not overlay_open and not pause_menu_open


static func pause_title() -> String:
	return "暂停"


static func abandon_confirm_title() -> String:
	return "确定放弃？"
