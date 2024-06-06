extends ItemData
class_name ArmorData

@export var defense: int
@export var stat_changes: Dictionary = {
	"strength": 0,
	"agility": 0,
	"intelligence": 0,
	"defense": 0
}
enum ItemSlot {
	WEAPON,
	RING,
	ACCESSORY,
	BACK,
	HEAD,
	BODY,
	LEGS,
	HANDS,
	FEET,
}

@export var movement_abilities: Array = [] #wip, not sure how to do this
