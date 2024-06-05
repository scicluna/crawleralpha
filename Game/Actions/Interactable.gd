# InteractableComponent.gd
extends Area3D
class_name Interactable

# Signal to indicate interaction
signal interacted

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body):
	if body is Player:
		print("body entered")
		body.add_nearby_interactable(self)

func _on_body_exited(body):
	if body is Player:
		print("body exited")
		body.remove_nearby_interactable(self)

func interact(body):
	if body is Player:
		print(body)
	print("interacted")
	emit_signal("interacted")
