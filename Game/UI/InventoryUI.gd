extends ItemUI
class_name InventoryUI

@onready var player: Node = get_owner()
@onready var inventory: Inventory = player.get_node("Inventory")
@onready var item_container: GridContainer = $MarginContainer/InventoryGrid

func _ready() -> void:
	super._ready()
	connect("item_dragged", Callable(self, "_on_item_dragged"))
	connect("item_dropped", Callable(self, "_on_item_dropped"))

func update_display() -> void:
	for i in range(item_container.get_child_count()):
		var child_node = item_container.get_child(i)
		child_node.queue_free()

	for i in range(inventory.max_slots):
		var slot := inventory.items[i]
		var slot_container := Control.new()

		if not slot or not slot.item_data:
			slot_container.custom_minimum_size = Vector2(64, 64)
			slot_container.add_theme_color_override("bg_color", Color(0, 0, 0, 0.5))

			var slot_bg: Panel = Panel.new()
			slot_bg.custom_minimum_size = Vector2(64, 64)
			slot_bg.add_theme_color_override("panel", Color(0.1, 0.1, 0.1))
			slot_bg.connect("gui_input", Callable(self, "_on_slot_gui_input").bind(i))
			slot_container.add_child(slot_bg)

		if slot and slot.item_data != null:
			var item_icon: TextureRect = TextureRect.new()
			item_icon.texture = slot.item_data.icon
			item_icon.expand_mode = TextureRect.EXPAND_FIT_HEIGHT
			item_icon.anchor_right = 1.0
			item_icon.anchor_bottom = 1.0
			item_icon.name = str(i)  # Store slot index as name
			item_icon.connect("gui_input", Callable(self, "_on_item_icon_gui_input").bind(i))
			slot_container.add_child(item_icon)

			var item_label: Label = Label.new()
			item_label.text = "x" + str(slot.quantity)
			item_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			item_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
			item_label.custom_minimum_size = Vector2(64, 64)
			slot_container.add_child(item_label)

		item_container.add_child(slot_container)

func _on_item_icon_gui_input(event: InputEvent, slot_index: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_start_drag(slot_index, inventory.items, "inventory")
	elif event is InputEventMouseMotion:
		display_description(slot_index, inventory.items)

func _on_slot_gui_input(event: InputEvent, slot_index: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and !is_dragging:
			_start_drag(slot_index, inventory.items, "inventory")
	elif hovering and slot_index != hovering_index and event is InputEventMouseMotion:
		clear_description()

func get_slot_container(slot_index: int) -> Control:
	return item_container.get_child(slot_index)

func get_slots() -> Array[BaseSlot]:
	return inventory.items

func get_slot_count() -> int:
	return inventory.max_slots

func _on_item_dragged(dragged_item, dragged_item_slot_index, source_ui):
	if source_ui == "inventory":
		# Handle item being dragged from equipment UI
		if dragged_item_slot_index != -1:
			inventory.items[dragged_item_slot_index] = BaseSlot.new()

func _on_item_dropped(dropped_item, dropped_slot_index, target_ui):
	if target_ui == "inventory":
		# Handle item being dropped from equipment UI
		if dropped_slot_index != -1:
			inventory.items[dropped_slot_index] = dropped_item
		update_display()
