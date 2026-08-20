class_name ShopPurchaseRules
extends RefCounted

const MAX_WEAPONS := 6


static func can_buy(item_type: ItemBase.ItemType, equipped_weapon_count: int) -> bool:
	if item_type == ItemBase.ItemType.WEAPON:
		return equipped_weapon_count < MAX_WEAPONS
	return true
