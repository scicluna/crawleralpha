extends Interactable
class_name InteractableWeapon

func _on_body_entered(body):
	if body is Player:
		if not self.get_parent().is_equipped:
			print("body entered")
			body.add_nearby_interactable(self)

func _on_body_exited(body):
	if body is Player:
		if not self.get_parent().is_equipped:
			print("body exited")
			body.remove_nearby_interactable(self)

func interact(body: Player):
	body.pick_up_item(self.get_parent().item_data, 1)
	print("interacted")
	self.get_parent().queue_free()
	
