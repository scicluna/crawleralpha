extends Control
class_name InventoryUI

@onready var player: Node = get_owner()
@onready var inventory: Inventory = player.get_node("Inventory")
@onready var item_container: GridContainer = $Panel/MarginContainer/InventoryGrid

var dragged_item: ItemSlot = null
var dragged_item_slot_index: int = -1
var drag_preview: TextureRect = null
var is_dragging: bool = false

func _ready() -> void:
	update_inventory_display()
	set_process(true)

func _process(delta: float) -> void:
	if is_dragging and drag_preview != null:
		drag_preview.position = get_global_mouse_position() - drag_preview.custom_minimum_size / 2

func update_inventory_display() -> void:
	for i in range(item_container.get_child_count()):
		item_container.get_child(i).queue_free()
	
	# Ensure all 20 slots are initialized
	for i in range(20):
		if i >= inventory.items.size():
			inventory.items.append(null)

	for i in range(20):
		var slot: ItemSlot = inventory.items[i]
		var slot_container: Control = Control.new()
		slot_container.custom_minimum_size = Vector2(64, 64)
		slot_container.add_theme_color_override("bg_color", Color(0, 0, 0, 0.5))

		var slot_bg: Panel = Panel.new()
		slot_bg.custom_minimum_size = Vector2(64, 64)
		slot_bg.add_theme_color_override("panel", Color(0.1, 0.1, 0.1))
		slot_bg.connect("gui_input", Callable(self, "_on_slot_gui_input").bind(i))
		
		slot_container.add_child(slot_bg)

		if slot != null and slot.item_data != null:
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
	
	# Ensure all 20 slots are displayed
	for i in range(inventory.items.size(), 20):
		var empty_slot_container: Control = Control.new()
		empty_slot_container.custom_minimum_size = Vector2(64, 64)
		empty_slot_container.add_theme_color_override("bg_color", Color(0, 0, 0, 0.5))

		var empty_slot_bg: Panel = Panel.new()
		empty_slot_bg.custom_minimum_size = Vector2(64, 64)
		empty_slot_bg.add_theme_color_override("panel", Color(0.1, 0.1, 0.1))
		empty_slot_bg.connect("gui_input", Callable(self, "_on_slot_gui_input").bind(i))
		
		empty_slot_container.add_child(empty_slot_bg)
		item_container.add_child(empty_slot_container)

func _on_item_icon_gui_input(event: InputEvent, slot_index: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if dragged_item == null:
			dragged_item = inventory.items[slot_index]
			dragged_item_slot_index = slot_index
			inventory.items[slot_index] = null
			
			drag_preview = TextureRect.new()
			drag_preview.texture = dragged_item.item_data.icon
			drag_preview.custom_minimum_size = Vector2(64, 64)
			drag_preview.position = get_global_mouse_position() - drag_preview.custom_minimum_size / 2
			drag_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Ignore mouse events
			add_child(drag_preview)
			is_dragging = true
			update_inventory_display()
		else:
			# Swap the dragged item with the item in this slot and continue dragging the new item
			var target_item: ItemSlot = inventory.items[slot_index]
			inventory.items[slot_index] = dragged_item
			dragged_item = target_item
			dragged_item_slot_index = slot_index

			drag_preview.texture = dragged_item.item_data.icon
			update_inventory_display()

func _on_slot_gui_input(event: InputEvent, slot_index: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed and is_dragging:
			# Drop the dragged item into the slot
			if dragged_item != null:
				if slot_index != dragged_item_slot_index:
					var target_item: ItemSlot = inventory.items[slot_index]
					inventory.items[slot_index] = dragged_item
				else:
					inventory.items[dragged_item_slot_index] = dragged_item
				dragged_item = null
				dragged_item_slot_index = -1
				if drag_preview != null:
					remove_child(drag_preview)
					drag_preview = null
				is_dragging = false
				update_inventory_display()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed and is_dragging:
			# Check if mouse release is outside the inventory
			var mouse_position = get_global_mouse_position()
			var inventory_rect = item_container.get_global_rect()

			if not inventory_rect.has_point(mouse_position):
				# Instantiate item model at the drop position
				var item_instance = dragged_item.item_data.model.instantiate()
				item_instance.position = player.position
				item_instance.position.z -= .2
				item_instance.position.y += .25
				get_parent().add_child(item_instance)
				
			# Reset dragged item state
			dragged_item = null
			dragged_item_slot_index = -1
			if drag_preview != null:
				remove_child(drag_preview)
				drag_preview = null
			is_dragging = false
			update_inventory_display()

func _hide_tooltip(tooltip: Label) -> void:
	if tooltip != null and tooltip.is_inside_tree():
		remove_child(tooltip)
