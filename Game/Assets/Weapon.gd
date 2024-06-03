extends Node3D
class_name Weapon

@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Item data reference
var item_data: WeaponData

var cooldown_timer: Timer = null
var hitbox: RayCast3D = null

func _ready() -> void:
	# Connect the animation finished signal
	animation_player.connect("animation_finished", Callable(self, "_on_animation_finished"))

func attack(player_stats) -> void:
	if animation_player.has_animation("attack") and cooldown_timer.is_stopped():
		animation_player.play("attack")
		if hitbox:
			hitbox.enabled = true  # Enable raycast during attack
			hitbox.check_hit(item_data.damage)  # Check for hit immediately or during the animation
		cooldown_timer.start()  # Start cooldown timer

func parry() -> void:
	if animation_player.has_animation("parry"):
		animation_player.play("parry")

func stop() -> void:
	if animation_player.has_animation("RESET"):
		animation_player.play("RESET")

func equip(weapon_data: WeaponData, ray: RayCast3D) -> void:
	item_data = weapon_data
	print("Weapon equipped: %s" % item_data.name)
	
	# Configure Attack Cooldown Timer
	cooldown_timer = Timer.new()
	cooldown_timer.wait_time = item_data.attack_speed
	cooldown_timer.one_shot = true
	cooldown_timer.connect("timeout", Callable(self, "_on_cooldown_timeout"))
	add_child(cooldown_timer)
	
	hitbox = ray  # Set the raycast for hit detection
	hitbox.update_range(item_data.range)

func unequip() -> void:
	# Define what happens when the weapon is unequipped
	print("Weapon unequipped: %s" % item_data.name)

func _on_animation_finished(anim_name):
	# Avoid reset during parry and check if the right mouse button is not pressed
	if anim_name != "RESET" and anim_name != "parry" and not Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		animation_player.play("RESET")
		# Disable raycast after attack animation finishes
	if hitbox:
		hitbox.enabled = false

func _on_cooldown_timeout() -> void:
	# Handle cooldown timeout logic if necessary
	pass
