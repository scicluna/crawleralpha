extends ItemUI
class_name EquipmentUI

@onready var equipment: Equipment = get_owner().get_node("Equipment")
@onready var equipment_container: GridContainer = $MarginContainer/EquipmentGrid

func _ready() -> void:
	super._ready()
	connect("item_dragged", Callable(self, "_on_item_dragged"))
	connect("item_dropped", Callable(self, "_on_item_dropped"))

func update_display() -> void:
	for i in range(equipment_container.get_child_count()):
		var child_node = equipment_container.get_child(i)
		child_node.queue_free()

	var i = 0
	for slot in equipment.equipment_slots:
		var slot_container := Control.new()
		slot_container.custom_minimum_size = Vector2(64, 64)
		slot_container.add_theme_color_override("bg_color", Color(0, 0, 0, 0.5))
		var slot_bg: Panel = Panel.new()
		slot_bg.custom_minimum_size = Vector2(64, 64)
		slot_bg.add_theme_color_override("panel", Color(0.1, 0.1, 0.1))
		slot_bg.connect("gui_input", Callable(self, "_on_equipment_slot_gui_input").bind(i))
		slot_container.add_child(slot_bg)
		
		if slot and slot.item_data != null:
			var item_icon: TextureRect = TextureRect.new()
			item_icon.texture = slot.item_data.icon
			item_icon.expand_mode = TextureRect.EXPAND_FIT_HEIGHT
			item_icon.anchor_right = 1.0
			item_icon.anchor_bottom = 1.0
			item_icon.name = str(slot.slot_type)  # Store slot type as name
			item_icon.connect("gui_input", Callable(self, "_on_equipment_item_icon_gui_input").bind(i))
			slot_container.add_child(item_icon)

		equipment_container.add_child(slot_container)
		i += 1

func _on_equipment_item_icon_gui_input(event: InputEvent, slot_index: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_start_drag(slot_index, equipment.equipment_slots, "equipment")
	elif event is InputEventMouseMotion:
		display_description(slot_index, equipment.equipment_slots)

func _on_equipment_slot_gui_input(event: InputEvent, slot_index: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and !is_dragging:
			_start_drag(slot_index, equipment.equipment_slots, "equipment")
	elif hovering and slot_index != hovering_index and event is InputEventMouseMotion:
		clear_description()

func get_slot_container(slot_index: int) -> Control:
	return equipment_container.get_child(slot_index)

func get_slots() -> Array[BaseSlot]:
	return equipment.equipment_slots

func get_slot_count() -> int:
	return equipment.equipment_slots.size()

func _on_item_dragged(dragged_item, dragged_item_slot_index, source_ui):
	if source_ui == "equipment":
		# Handle item being dragged from inventory UI
		if dragged_item_slot_index != -1:
			equipment.equipment_slots[dragged_item_slot_index] = null

func _on_item_dropped(dropped_item, dropped_slot_index, target_ui):
	if target_ui == "equipment":
		# Handle item being dropped from inventory UI
		if dropped_slot_index != -1:
			equipment.equipment_slots[dropped_slot_index] = dropped_item
		update_display()
