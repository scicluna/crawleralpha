# res://Weapons/Weapon.gd
extends Node3D

class_name Weapon
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hitbox: RayCast3D = $RayCast3D

# Common properties
@export var damage: int = 0
@export var attack_speed: float = 0.0
@export var range: float = 0.0

func _ready() -> void:
	# Connect the animation finished signal
	animation_player.connect("animation_finished", Callable(self, "_on_animation_finished"))
	pass


func attack(player_stats) -> void:
	if animation_player.has_animation("attack"):
		animation_player.play("attack")
		hitbox.enabled = true  # Enable raycast during attack
		check_hit()  # Check for hit immediately or during the animation
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
	# Initialize other properties or states if needed
	hitbox.enabled = false  # Disable raycast initially
	hitbox.target_position = Vector3(0, range, 0)  # Set the range of the raycast
	print(hitbox.target_position)
	pass

func unequip() -> void:
	# Define what happens when the weapon is unequipped
	print("Weapon unequipped: %s" % self.name)
	pass
	
func _on_animation_finished(anim_name):
	# Avoid reset during parry and check if the right mouse button is not pressed
	if anim_name != "RESET" and anim_name != "parry" and !Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		animation_player.play("RESET")
	# Disable raycast after attack animation finishes
		hitbox.enabled = false

func check_hit() -> void:
	if hitbox.is_colliding():
		var collider = hitbox.get_collider()
		if collider:
			# Apply damage or other effects to the collider
			print("Hit: %s" % collider.name)
			# Assuming the collider has a method to receive damage
			if collider.has_method("take_damage"):
				collider.call("take_damage", damage)
	else:
		print("No hit detected")
