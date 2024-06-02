extends Node3D
class_name Item

@export var item_data: ItemData

func _ready() -> void:
	print("Item: %s" % item_data.name)
	
	# Instance the 3D model and add it as a child
	if item_data.model:
		var model_instance = item_data.model.instance()
		add_child(model_instance)

func apply_stat_changes(character: Node) -> void:
	for stat in item_data.stat_changes.keys():
		if character.has_method("change_stat"):
			character.change_stat(stat, item_data.stat_changes[stat])
		else:
			print("Character does not have method 'change_stat'")

func grant_movement_abilities(character: Node) -> void:
	for ability in item_data.movement_abilities:
		if character.has_method("add_ability"):
			character.add_ability(ability)
		else:
			print("Character does not have method 'add_ability'")
