extends Control
class_name ItemUI

signal item_dragged(dragged_item, dragged_item_slot_index, source_ui)
signal item_dropped(dropped_item, dropped_slot_index, target_ui)

@onready var item_ui := $".."
@onready var hover_label: Label = $"../HoverLabel"

var dragged_item: BaseSlot
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

func _start_drag(slot_index: int, slots: Array[BaseSlot], source_ui: String) -> void:
	if dragged_item == null and slots[slot_index] != null and slots[slot_index].item_data != null:
		dragged_item = slots[slot_index]
		dragged_item_slot_index = slot_index

		drag_preview = TextureRect.new()
		drag_preview.texture = dragged_item.item_data.icon
		drag_preview.custom_minimum_size = Vector2(64, 64)
		drag_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Ignore mouse events
		drag_preview.position = get_global_mouse_position()
		item_ui.add_child(drag_preview)

		is_dragging = true
		update_display()

		# Emit signal for item dragged
		emit_signal("item_dragged", dragged_item, dragged_item_slot_index, source_ui)

		# Update the position after adding to the scene to ensure correct positioning
		_update_drag_preview_position()

func _update_drag_preview_position():
	if is_dragging and drag_preview != null:
		var mouse_position = get_global_mouse_position()
		drag_preview.position = mouse_position - drag_preview.custom_minimum_size / 2

func display_description(slot_index: int, slots: Array[BaseSlot]) -> void:
	var slot = slots[slot_index]
	if slot != null and slot.item_data != null and slot_index != hovering_index:
		hovering = true
		hovering_index = slot_index
		hover_label.text = "Name: %s \nDescription: %s" % [slot.item_data.name, slot.item_data.description]
		hover_label.custom_minimum_size = hover_label.get_minimum_size()  # Ensure size is correct

		# Get the global position of the slot container
		var slot_container = get_slot_container(slot_index)
		var slot_container_position = slot_container.get_global_transform_with_canvas().origin

		# Position the hover label above the slot container
		hover_label.position = slot_container_position - Vector2(0, 50)
		hover_label.visible = true

func clear_description() -> void:
	hovering = false
	hovering_index = -1
	hover_label.visible = false

func update_display() -> void:
	pass  # This will be implemented in the derived classes

func get_slot_container(slot_index: int):
	pass  # This will be implemented in the derived classes

func get_slots():
	pass  # This will be implemented in the derived classes

func get_slot_count():
	pass  # This will be implemented in the derived classes

func _drop_item(slot_index: int, slots: Array[BaseSlot], target_ui: String) -> void:
	if is_dragging and dragged_item != null and dragged_item.item_data != null:
		# Drop in Empty Slot
		if slots[slot_index] == null or slots[slot_index].item_data == null:

			# Replace slot with dragged item
			slots[slot_index] = dragged_item

			# Delete the Origin point if we didn't just swap
			if slots[dragged_item_slot_index] == dragged_item and slot_index != dragged_item_slot_index:
				slots[dragged_item_slot_index] = BaseSlot.new()

			# Get rid of dragged_item and turn off dragging
			dragged_item = null
			dragged_item_slot_index = -1
			if drag_preview != null:
				item_ui.remove_child(drag_preview)
				drag_preview = null
			is_dragging = false

		# Drop in Occupied Slot
		else:
			# Take note of the object we dropped on
			var new_item := slots[slot_index]

			# Move dropped object into new slot
			slots[slot_index] = dragged_item

			# Delete the Origin point if we didn't just swap
			if slots[dragged_item_slot_index] == dragged_item and dragged_item_slot_index != slot_index:
				slots[dragged_item_slot_index] = BaseSlot.new()

			# Change drag preview to the new item
			drag_preview.texture = new_item.item_data.icon

			# Overwrite old dragged_item states
			dragged_item = new_item
			dragged_item_slot_index = slot_index

		# Emit signal for item dropped
		emit_signal("item_dropped", dragged_item, slot_index, target_ui)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
		if is_dragging:
			var mouse_position = get_global_mouse_position()
			var rect = get_global_rect()

			# Dropping within bounds of the current UI element
			if rect.has_point(mouse_position):
				var closest_slot_index = -1
				var closest_distance = INF

				for i in range(get_slot_count()):
					var slot_container = get_slot_container(i)
					var slot_rect = slot_container.get_global_rect()
					if slot_rect.has_point(mouse_position):
						_drop_item(i, get_slots(), "this")
						update_display()
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
					_drop_item(closest_slot_index, get_slots(), "this")
					update_display()
					return

			# Dropping outside of bounds
			if not rect.has_point(mouse_position):
				var item_instance = dragged_item.item_data.model.duplicate(true).instantiate()

				# Get the camera node
				var camera = $"../../.."  # Adjust the path to your camera node

				# Calculate the drop position in front of the camera
				var forward_vector = -camera.global_transform.basis.z.normalized()
				var drop_position = camera.global_transform.origin + (forward_vector * 1.0)  # Drop the item 1 unit in front of the camera
				drop_position.y = owner.global_transform.origin.y  # Keep the drop height consistent with the player's position
				item_instance.position = drop_position
				item_instance.item_data = dragged_item.item_data

				# Set animation for dropped item
				if item_instance is Weapon:
					item_instance.is_equipped = false

				get_parent().add_child(item_instance)

				if drag_preview != null:
					item_ui.remove_child(drag_preview)
					drag_preview = null
				get_slots()[dragged_item_slot_index] = BaseSlot.new()
				dragged_item = null
				dragged_item_slot_index = -1
				is_dragging = false
				update_display()
