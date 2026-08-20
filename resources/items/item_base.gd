extends Resource
class_name ItemBase

enum ItemType {
	WEAPON,
	UPGRADE,
	PASSIVE
}

const TYPE_NAMES := {
	ItemType.WEAPON: "武器",
	ItemType.UPGRADE: "升级",
	ItemType.PASSIVE: "被动",
}

@export var item_name: String
@export var item_icon: Texture2D
@export var item_tier: Global.UpgradeTier
@export var item_type: ItemType
@export var item_cost: int

func get_description() -> String:
	return ""


func get_type_name() -> String:
	return TYPE_NAMES.get(item_type, "")
