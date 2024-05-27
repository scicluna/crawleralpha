extends Node

var current_weapon_instance: Node = null

func load_weapon(weapon_path: String):
	# Free the current weapon instance if it exists
	if current_weapon_instance != null:
		current_weapon_instance.queue_free()
	
	# Load the new weapon scene
	var weapon_scene = load("res://Assets/Weapons/%s.glb" % weapon_path)
	if weapon_scene == null:
		print("Failed to load weapon: ", weapon_path)
		return
	
	# Instance the weapon scene
	current_weapon_instance = weapon_scene.instantiate()
	
	# Add the weapon instance to the desired parent node
	self.add_child(current_weapon_instance)
