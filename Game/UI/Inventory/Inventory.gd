extends Node
class_name Inventory

@export var max_slots: int = 20
var items: Array[ItemSlot] = []

func _ready() -> void:
	initialize_slots()

func initialize_slots() -> void:
	items.resize(max_slots)
	for i in range(max_slots):
		var slot = ItemSlot.new()
		items[i] = slot

func add_item(item_data: ItemData, amount: int = 1) -> void:
	var overflow: int = 0
	
	# First try to add to existing slots with the same item
	for slot in items:
		if slot and slot.item_data == item_data:
			amount = slot.add_quantity(item_data, amount)
			if amount == 0:
				return

	# If there is overflow, add to new slots
	for slot in items:
		if slot.item_data == null:
			slot.item_data = item_data
			amount = slot.add_quantity(item_data, amount)
			if amount == 0:
				return

	# If we run out of slots, handle the overflow as needed (e.g., drop the item, notify the player, etc.)
	if amount > 0:
		print("No available slots for the remaining items:", amount)

func remove_item(item_data: ItemData, amount: int = 1) -> void:
	for slot in items:
		if slot.item_data == item_data:
			slot.subtract_quantity(amount)
			if slot.quantity <= 0:
				slot.item_data = null
			return
			
func get_item_by_index(item_index: int) -> ItemData:
	var slot = items[item_index]
	return slot.item_data 
	
func get_item_by_name(item_name: String) -> ItemData:
	for item in items:
		if item.item_data.name == item_name:
			return item.item_data
	return null
