extends Node3D

@onready var hit_box := $"../HitBox"

var current_weapon: Weapon = null  # Reference to the current weapon

# Function to load and equip a weapon
func load_weapon(weapon_path: String) -> void:
	var weapon_data = load(weapon_path) as WeaponData  # Ensure it's loaded as WeaponData
	
	if weapon_data:
		# Instance the model from WeaponData
		var weapon_scene = weapon_data.model
		if weapon_scene:
			var weapon_instance = weapon_scene.instantiate()
			
			# Check if the instance has the Weapon script attached
			if weapon_instance and weapon_instance is Weapon:
				# Optionally, clear any previously equipped weapon
				if current_weapon:
					current_weapon.unequip()
					current_weapon.queue_free()
				
				# Add the new weapon instance as a child of WeaponArm
				add_child(weapon_instance)
				weapon_instance.equip(weapon_data, hit_box)
				
				# Store the reference to the current weapon
				current_weapon = weapon_instance as Weapon
				print("Weapon loaded and equipped: %s" % weapon_data.name)
			else:
				print("Failed to instance weapon: %s. Type: %s" % [weapon_path, typeof(weapon_instance)])
		else:
			print("Failed to load weapon model from WeaponData: %s" % weapon_path)
	else:
		print("Failed to load WeaponData resource: %s" % weapon_path)
