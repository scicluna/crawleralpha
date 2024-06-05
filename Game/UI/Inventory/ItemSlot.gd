extends Node
class_name ItemSlot

var item_data: ItemData
var quantity: int
const MAX_QUANTITY = 99

func add_quantity(new_item: ItemData, value: int) -> int:
	item_data = new_item
	
	if item_data == null:
		return value

	var total = quantity + value
	if total > MAX_QUANTITY:
		var overflow = total - MAX_QUANTITY
		quantity = MAX_QUANTITY
		return overflow
	else:
		quantity = total
		return 0

func subtract_quantity(value: int) -> void:
	if item_data == null:
		return

	quantity -= value
	if quantity < 1:
		item_data = null
		quantity = 0
