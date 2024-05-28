extends Node

@onready var weapon = $Weapon

func load_weapon(weapon_name: String, orientation: String):
	# Free the current weapon instance if it exists
	if weapon_name != null:
		weapon.mesh = null
		
	if orientation == "down":
		weapon.rotate_x(179.5)
	
	# Load the new weapon scene
	weapon.mesh = load("res://Assets/Weapons/%s.obj" % weapon_name)
