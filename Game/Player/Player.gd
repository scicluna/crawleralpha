extends CharacterBody3D

const MAX_SPEED = 10.0
const BACKPEDAL_SPEED = 3.0
const ACCELERATION = 20.0
const DECELERATION = 25.0
const AIR_DECELERATION = 10.0
const JUMP_VELOCITY = 4.5

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var neck := $Pivot
@onready var camera := $Pivot/Camera3D
@onready var movement_abilities: Array[Movement] = []

var dashing = false

func _ready():
	# Add movement abilities
	var dash_ability = Dash.new()
	add_child(dash_ability)
	movement_abilities.append(dash_ability)

func _unhandled_input(event: InputEvent) -> void:
	handle_mouse_input(event)
	for ability in movement_abilities:
		ability.process_input(self, get_process_delta_time())

func _physics_process(delta):
	for ability in movement_abilities:
		ability.apply_movement(self, delta)
	apply_gravity(delta)
	handle_jump()
	handle_movement(delta)
	cap_speed()
	move_and_slide()

func handle_mouse_input(event: InputEvent):
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			neck.rotate_y(-event.relative.x * .01)
			camera.rotate_x(-event.relative.y * .01)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

func handle_jump():
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

func handle_movement(delta):
	var input_dir = Input.get_vector("strafe_left", "strafe_right", "move_forward", "move_backward")
	var direction = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction.length() > 1:
		direction = direction.normalized()

	var deceleration = DECELERATION if is_on_floor() else AIR_DECELERATION
	if not dashing:
		if direction:
			var target_speed = BACKPEDAL_SPEED if input_dir.y > 0 else MAX_SPEED
			velocity.x = move_toward(velocity.x, direction.x * target_speed, ACCELERATION * delta)
			velocity.z = move_toward(velocity.z, direction.z * target_speed, ACCELERATION * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, deceleration * delta)
			velocity.z = move_toward(velocity.z, 0, deceleration * delta)

func cap_speed():
	if not dashing:
		var horizontal_speed = Vector3(velocity.x, 0, velocity.z).length()
		if horizontal_speed > MAX_SPEED:
			var speed_ratio = MAX_SPEED / horizontal_speed
			velocity.x *= speed_ratio
			velocity.z *= speed_ratio
