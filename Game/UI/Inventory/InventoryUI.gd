extends Control
class_name InventoryUI

@onready var player = get_owner()
@onready var inventory: Inventory = player.get_node("Inventory")
@onready var item_container: GridContainer = $MarginContainer/InventoryGrid

func _ready() -> void:
	update_inventory_display()

func update_inventory_display() -> void:
	for i in range(item_container.get_child_count()):
		item_container.get_child(i).queue_free()
	
	var display_data = inventory.get_inventory_display()
	for item in display_data:
		var item_icon = TextureRect.new()
		item_icon.texture = item["icon"]
		
		var item_label = Label.new()
		item_label.text = "%s x%d" % [item["item_name"], item["quantity"]]
		
		var item_box = VBoxContainer.new()
		item_box.add_child(item_icon)
		item_box.add_child(item_label)
		
		item_container.add_child(item_box)
