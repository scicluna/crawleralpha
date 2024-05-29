# res://Weapons/Weapon.gd
extends Node3D

class_name Weapon

# Common properties
var damage: int = 0
var attack_speed: float = 0.0
var weapon_mesh: String = "Path" # Path to the weapon mesh resource

# Called when the node is added to the scene.
func _ready() -> void:
	# This method can be overridden by child classes to initialize specific weapon properties
	pass

# Common methods
func attack(player_stats) -> void:
	# Define the base attack behavior
	pass

func equip() -> void:
	# Define what happens when the weapon is equipped
	print("Weapon equipped: %s" % self.name)
	pass

func unequip() -> void:
	# Define what happens when the weapon is unequipped
	print("Weapon unequipped: %s" % self.name)
	pass
