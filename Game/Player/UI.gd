extends Node

@onready var inventory_ui: InventoryUI = $ItemUI/InventoryPanel
@onready var equipment_ui: EquipmentUI = $ItemUI/EquipmentPanel

func _ready():
	inventory_ui.connect("item_dragged", Callable(equipment_ui, "_on_item_dragged"))
	inventory_ui.connect("item_dropped", Callable(equipment_ui, "_on_item_dropped"))
	
	equipment_ui.connect("item_dragged", Callable(inventory_ui, "_on_item_dragged"))
	equipment_ui.connect("item_dropped", Callable(inventory_ui, "_on_item_dropped"))
