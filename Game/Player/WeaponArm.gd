extends Node3D

@onready var hit_box := $HitBox

var current_weapon: Weapon = null  # Reference to the current weapon

# Function to load and equip a weapon
func load_weapon(weapon_name: String) -> void:
	var weapon_path = "res://Weapons/%s.tscn" % weapon_name  # Assuming your weapon scenes are in this path
	var weapon_scene = load(weapon_path)
	
	if weapon_scene:
		var weapon_instance = weapon_scene.instantiate() as Weapon
		if weapon_instance:
			# Optionally, clear any previously equipped weapon
			if current_weapon:
				current_weapon.unequip()
				current_weapon.queue_free()
			
			# Add the new weapon instance as a child of WeaponArm
			add_child(weapon_instance)
			weapon_instance.equip(hit_box)
			
			# Store the reference to the current weapon
			current_weapon = weapon_instance
		else:
			print("Failed to instance weapon: %s" % weapon_name)
	else:
		print("Failed to load weapon scene: %s" % weapon_path)
