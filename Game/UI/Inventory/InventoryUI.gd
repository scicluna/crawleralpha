extends Control
class_name InventoryUI

@onready var player: Node = get_owner()
@onready var inventory: Inventory = player.get_node("Inventory")
@onready var item_container: GridContainer = $Panel/MarginContainer/InventoryGrid
@onready var hover_label: Label = $Panel/HoverLabel

var dragged_item: ItemSlot
var dragged_item_slot_index: int = -1
var drag_preview: TextureRect = null
var is_dragging: bool = false

var hovering: bool = false
var hovering_index: int = -1

func _ready() -> void:
	set_process(true)
	hover_label.visible = false
	hover_label.custom_minimum_size = Vector2(200, 100)  # Adjust the size as needed

func _process(delta):
	if is_dragging:
		_update_drag_preview_position()

func update_inventory_display() -> void:
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
			_start_drag(slot_index)
	elif event is InputEventMouseMotion:
		display_description(slot_index)

func _on_slot_gui_input(event: InputEvent, slot_index: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and !is_dragging:
			_start_drag(slot_index)
	elif hovering and slot_index != hovering_index and event is InputEventMouseMotion:
		clear_description()

func _start_drag(slot_index: int) -> void:
	if dragged_item == null and inventory.items[slot_index] != null and inventory.items[slot_index].item_data != null:
		dragged_item = inventory.items[slot_index]
		dragged_item_slot_index = slot_index
		
		drag_preview = TextureRect.new()
		drag_preview.texture = dragged_item.item_data.icon
		drag_preview.custom_minimum_size = Vector2(64, 64)
		drag_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Ignore mouse events
		add_child(drag_preview)
		
		is_dragging = true
		update_inventory_display()
		
		# Update the position after adding to the scene to ensure correct positioning
		_update_drag_preview_position()

func _update_drag_preview_position():
	if is_dragging and drag_preview != null:
		drag_preview.position = get_global_mouse_position() - drag_preview.custom_minimum_size / 2

func _drop_item(slot_index: int) -> void:
	if is_dragging and dragged_item != null and dragged_item.item_data != null:
		# Drop in Empty Slot
		if inventory.items[slot_index] == null or inventory.items[slot_index].item_data == null:
			
			# Replace slot with dragged item
			inventory.items[slot_index] = dragged_item
			
			# Delete the Origin point if we didn't just swap
			if inventory.items[dragged_item_slot_index] == dragged_item and slot_index != dragged_item_slot_index:
				inventory.items[dragged_item_slot_index] = ItemSlot.new()
				
			# Get rid of dragged_item and turn off dragging
			dragged_item = null
			dragged_item_slot_index = -1
			if drag_preview != null:
				remove_child(drag_preview)
				drag_preview = null
			is_dragging = false
			
		# Drop in Occupied Slot
		else:
			# Take note of the object we dropped on
			var new_item := inventory.items[slot_index]
			
			# Move dropped object into new slot
			inventory.items[slot_index] = dragged_item
			
			# Delete the Origin point if we didn't just swap
			if inventory.items[dragged_item_slot_index] == dragged_item and dragged_item_slot_index != slot_index:
				inventory.items[dragged_item_slot_index] = ItemSlot.new()
			
			# Change drag preview to the new item
			drag_preview.texture = new_item.item_data.icon
			
			# Overwrite old dragged_item states
			dragged_item = new_item
			dragged_item_slot_index = slot_index

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
		if is_dragging:
			var mouse_position = get_global_mouse_position()
			var inventory_rect = item_container.get_global_rect()

			# Dropping within inventory
			if inventory_rect.has_point(mouse_position):
				var closest_slot_index = -1
				var closest_distance = INF

				for i in range(inventory.max_slots):
					var slot_container = item_container.get_child(i)
					var slot_rect = slot_container.get_global_rect()
					if slot_rect.has_point(mouse_position):
						_drop_item(i)
						update_inventory_display()
						return
					else:
						# Calculate the distance to the center of the slot
						var slot_center = slot_rect.position + slot_rect.size / 2
						var distance = slot_center.distance_to(mouse_position)
						if distance < closest_distance:
							closest_distance = distance
							closest_slot_index = i

				# If not over any slot, drop into the closest slot
				if closest_slot_index != -1:
					_drop_item(closest_slot_index)
					update_inventory_display()
					return
				
			# Dropping outside of inventory
			if not inventory_rect.has_point(mouse_position):
				var item_instance = dragged_item.item_data.model.duplicate(true).instantiate()
					
				# Get the camera node
				var camera = player.get_node("Pivot/Camera3D")
				
				# Calculate the drop position in front of the camera
				var forward_vector = -camera.global_transform.basis.z.normalized()
				var drop_position = camera.global_transform.origin + (forward_vector * 1.0)  # Drop the item 1 unit in front of the camera
				drop_position.y = player.global_transform.origin.y  # Keep the drop height consistent with the player's position
				item_instance.position = drop_position
				item_instance.item_data = dragged_item.item_data
				
				# Set animation for dropped item
				if item_instance is Weapon:
					item_instance.is_equipped = false
				
				get_parent().add_child(item_instance)
				
				if drag_preview != null:
					remove_child(drag_preview)
					drag_preview = null
				inventory.items[dragged_item_slot_index] = ItemSlot.new()
				dragged_item = null
				dragged_item_slot_index = -1
				is_dragging = false
				update_inventory_display()

func display_description(slot_index: int) -> void:
	var slot = inventory.items[slot_index]
	if slot != null and slot.item_data != null and slot_index != hovering_index:
		hovering = true
		hovering_index = slot_index
		hover_label.text = "Name: %s \nDescription: %s" % [slot.item_data.name, slot.item_data.description]
		hover_label.custom_minimum_size = hover_label.get_minimum_size()  # Ensure size is correct

		# Get the global position of the slot container
		var slot_container = item_container.get_child(slot_index)
		var slot_container_position = slot_container.position

		# Position the hover label above the slot container
		hover_label.position = slot_container_position - Vector2(0, 50)
		hover_label.visible = true

func clear_description() -> void:
	hovering = false
	hovering_index = -1
	hover_label.visible = false
