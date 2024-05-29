# res://Weapons/Weapon.gd
extends Node3D

class_name Weapon
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Common properties
var damage: int = 0
var attack_speed: float = 0.0

func _ready() -> void:
	# This method can be overridden by child classes to initialize specific weapon properties
	pass

func attack(player_stats) -> void:
	if animation_player.has_animation("attack"):
		animation_player.play("attack")
	pass
	
func parry() -> void:
	if animation_player.has_animation("parry"):
		animation_player.play("parry")
	pass
	
func stop() -> void:
	if animation_player.has_animation("RESET"):
		animation_player.play("RESET")
	pass

func equip() -> void:
	# Define what happens when the weapon is equipped
	print("Weapon equipped: %s" % self.name)
	pass

func unequip() -> void:
	# Define what happens when the weapon is unequipped
	print("Weapon unequipped: %s" % self.name)
	pass
