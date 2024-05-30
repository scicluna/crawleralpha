# res://Weapons/Weapon.gd
extends Node3D

class_name Weapon
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Common properties
@export var damage: int = 0
@export var attack_speed: float = 0.0
@export var range: float = 0.0

var cooldown_timer: Timer = null
var hitbox: RayCast3D = null

func _ready() -> void:
	# Connect the animation finished signal
	animation_player.connect("animation_finished", Callable(self, "_on_animation_finished"))
	pass


func attack(player_stats) -> void:
	if animation_player.has_animation("attack") and cooldown_timer.is_stopped():
		animation_player.play("attack")
		if hitbox:
			hitbox.enabled = true  # Enable raycast during attack
			hitbox.check_hit(damage)  # Check for hit immediately or during the animation
		cooldown_timer.start()  # Start cooldown timer
	pass
	
func parry() -> void:
	if animation_player.has_animation("parry"):
		animation_player.play("parry")
	pass
	
func stop() -> void:
	if animation_player.has_animation("RESET"):
		animation_player.play("RESET")
	pass

func equip(ray: RayCast3D) -> void:
	print("Weapon equipped: %s" % self.name)
	
	# Configure Attack Cooldown Timer
	cooldown_timer = Timer.new()
	cooldown_timer.wait_time = attack_speed
	cooldown_timer.one_shot = true
	cooldown_timer.connect("timeout", Callable(self, "_on_cooldown_timeout"))
	add_child(cooldown_timer)
	
	hitbox = ray  # Set the raycast for hit detection
	hitbox.update_range(range)
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
	if hitbox:
		hitbox.enabled = false
