# EquipmentSlot.gd
extends BaseSlot
class_name EquipmentSlot

enum EquipmentType { WEAPON, RING, CHEST, HEAD, FEET }

var slot_type: EquipmentType

func can_equip(item: ItemData) -> bool:
	return item.item_type == slot_type

# Function to get all the enum values
static func get_enum_values() -> Array:
	return EquipmentType.values()

# Function to get descriptions for each enum type
static func get_enum_description(slot_type: int) -> String:
	match slot_type:
		EquipmentType.WEAPON:
			return "WPN"
		EquipmentType.RING:
			return "RNG"
		EquipmentType.CHEST:
			return "CHS"
		EquipmentType.HEAD:
			return "HED"
		EquipmentType.FEET:
			return "FET"
		_:
			return "UNK"  # Unknown type placeholder
