extends CharacterBody3D

const MAX_SPEED = 10.0
const BACKPEDAL_SPEED = 3.0
const ACCELERATION = 20.0
const DECELERATION = 25.0
const AIR_DECELERATION = 10.0
const JUMP_VELOCITY = 4.5
const DASH_SPEED = 25.0
const DASH_DURATION = 0.2
const DOUBLE_TAP_TIME = 0.2

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var neck := $Pivot
@onready var camera := $Pivot/Camera3D
@onready var dash_effect := $Pivot/Camera3D/Dash_Blur
@onready var dash_timer := $Dash/DashTimer
@onready var dash_sound := $Dash/DashSound
@onready var dash_cooldown_timer := $Dash/DashCooldown

var last_tap_times = {
	"move_forward": 0.0,
	"move_backward": 0.0,
	"strafe_left": 0.0,
	"strafe_right": 0.0
}
var dashing = false
var dash_time_left = 0.0
var dash_direction = Vector3.ZERO

func _ready():
	dash_timer.connect("timeout", Callable(self, "_on_DashTimer_timeout"))

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			neck.rotate_y(-event.relative.x * .01)
			camera.rotate_x(-event.relative.y * .01)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))

func _physics_process(delta):
	# Handle dash timing
	if dashing:
		dash_time_left -= delta
		if dash_time_left <= 0:
			dashing = false
			dash_timer.start(0.5)  # Start the timer for fading out the effect

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("strafe_left", "strafe_right", "move_forward", "move_backward")
	var direction = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Normalize the direction vector if it has a length greater than 1 to ensure consistent speed.
	if direction.length() > 1:
		direction = direction.normalized()

	# Handle double-tap detection for dashing
	var current_time = Time.get_ticks_msec() / 1000.0
	for key in last_tap_times.keys():
		if Input.is_action_just_pressed(key):
			if current_time - last_tap_times[key] < DOUBLE_TAP_TIME:
				start_dash(key)
			last_tap_times[key] = current_time

	# Apply acceleration or deceleration to the horizontal velocity
	if dashing:
		velocity.x = dash_direction.x * DASH_SPEED
		velocity.z = dash_direction.z * DASH_SPEED
	else:
		var deceleration = DECELERATION if is_on_floor() else AIR_DECELERATION
		if direction:
			var target_speed = MAX_SPEED
			if input_dir.y > 0:
				target_speed = BACKPEDAL_SPEED

			velocity.x = move_toward(velocity.x, direction.x * target_speed, ACCELERATION * delta)
			velocity.z = move_toward(velocity.z, direction.z * target_speed, ACCELERATION * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, deceleration * delta)
			velocity.z = move_toward(velocity.z, 0, deceleration * delta)

	# Cap the speed to the maximum value if not dashing
	if not dashing:
		var horizontal_speed = Vector3(velocity.x, 0, velocity.z).length()
		if horizontal_speed > MAX_SPEED:
			var speed_ratio = MAX_SPEED / horizontal_speed
			velocity.x *= speed_ratio
			velocity.z *= speed_ratio

	move_and_slide()

func start_dash(direction_key):
	if dash_cooldown_timer.is_stopped():  # Check if the cooldown timer is stopped
		dash_cooldown_timer.start()  # Start the cooldown timer
		dashing = true
		dash_time_left = DASH_DURATION
		dash_effect.material.set_shader_parameter("effect_intensity", 1.0)  # Enable the effect
		dash_sound.play()

		# Reset all dash timers
		for key in last_tap_times.keys():
			last_tap_times[key] = 0.0

		match direction_key:
			"move_forward":
				dash_direction = neck.transform.basis.z.normalized() * -1
			"move_backward":
				dash_direction = neck.transform.basis.z.normalized()
			"strafe_left":
				dash_direction = neck.transform.basis.x.normalized() * -1
			"strafe_right":
				dash_direction = neck.transform.basis.x.normalized()

func _on_DashTimer_timeout():
	var effect_intensity = dash_effect.material.get_shader_parameter("effect_intensity")
	if effect_intensity > 0.0:
		effect_intensity -= 0.1
		dash_effect.material.set_shader_parameter("effect_intensity", effect_intensity)
		dash_timer.start(0.05)  # Continue fading out
	else:
		dash_effect.material.set_shader_parameter("effect_intensity", 0.0)  # Ensure it's fully off
		dash_timer.stop()
