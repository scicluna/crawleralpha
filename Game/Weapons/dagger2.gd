# res://Weapons/Dagger.gd
extends Weapon

# Called when the node is added to the scene.
func _ready() -> void:
	damage = 2
	attack_speed = 3.0
	pass

func attack(player_stats) -> void:
	# Dagger-specific attack logic
	print("Dagger attack! Dealing %d damage" % damage)
	# Implement the attack behavior using player_stats if needed
	pass
