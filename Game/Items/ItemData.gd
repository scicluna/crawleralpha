extends Resource
class_name ItemData

@export var name: String
@export_multiline var description: String
@export var icon: Texture2D
@export var item_type: ItemType

enum ItemType {
	WEAPON,
	EQUIPMENT,
	CONSUMABLE,
	MSC
}
