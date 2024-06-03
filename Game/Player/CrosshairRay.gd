extends RayCast3D
signal mob_detected(is_detected: bool)

@onready var cross_hair := $"../../UI/Control/Crosshair"
const DEFAULT_COLOR: Color = Color(1,1,1,1)
const HOVER_COLOR: Color = "RED"

# Called when the node enters the scene tree for the first time.
func _ready():
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	if is_colliding():
		var collider = get_collider()
		if collider is Mob:
			cross_hair.modulate = HOVER_COLOR
		else:
			cross_hair.modulate = DEFAULT_COLOR
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
