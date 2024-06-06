extends Node
class_name Equipment

@export var max_slots: int = 8
var equipment_slots: Array[BaseSlot] = []

func _ready() -> void:
	initialize_slots()

func initialize_slots() -> void:
	for slot_type in EquipmentSlot.get_enum_values():
		equipment_slots.append(create_slot(slot_type))

func create_slot(slot_type: int) -> EquipmentSlot:
	var slot = EquipmentSlot.new()
	slot.slot_type = slot_type
	return slot

func equip_item(item_data: ItemData) -> bool:
	for slot in equipment_slots:
		if slot.can_equip(item_data):
			slot.item_data = item_data
			return true
	return false

func unequip_item(slot_type: int) -> ItemData:
	for slot in equipment_slots:
		if slot.slot_type == slot_type:
			var item = slot.item_data
			slot.item_data = null
			return item
	return null
