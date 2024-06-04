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
		if slot.item_data == item_data:
			amount = slot.add_quantity(amount)
			if amount == 0:
				return

	# If there is overflow, add to new slots
	for slot in items:
		if slot.item_data == null:
			slot.item_data = item_data
			amount = slot.add_quantity(amount)
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

func get_inventory_display() -> Array[Dictionary]:
	var display: Array[Dictionary] = []
	for slot in items:
		if slot.item_data != null:
			display.append({
				"item_name": slot.item_data.name,
				"quantity": slot.quantity,
				"icon": slot.item_data.icon
			})
	return display
