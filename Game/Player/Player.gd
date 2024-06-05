extends CharacterBody3D
class_name Player

# speed consts
const MAX_SPEED = 8.0
const BACKPEDAL_SPEED = 3.0
const ACCELERATION = 20.0
const DECELERATION = 30.0
const gravity = 12.50

# jump consts
const AIR_DECELERATION = 10.0
const JUMP_VELOCITY = 6

# headbob consts
const BOB_FREQ = 1.5
const BOB_AMP = 0.05
var t_bob = 0.0

# fov consts
const BASE_FOV = 75
const FOV_CHANGE = .5

# handle interactables
var nearby_interactables: Array[Interactable] = []

@onready var neck := $Pivot
@onready var camera := $Pivot/Camera3D
@onready var weapon_arm := $Pivot/Camera3D/WeaponArm
@onready var hit_box := $Pivot/Camera3D/WeaponArm/HitBox
@onready var inventory := $Inventory
@onready var inventory_ui := $Pivot/Camera3D/UI/InventoryUI
@onready var movement_abilities: Array[Movement] = []

var dashing = false
var equipped_weapon: String = ""
var inventory_open = false

func _ready():
	# Placeholder Movement Ability Granted
	# Will eventually need to obtain this in game
	var dash_ability = load("res://Movement/Techniques/Dash.tscn")
	if dash_ability:
		dash_ability = dash_ability.instantiate()
	else:
		print("Failed to load dash ability")
	add_child(dash_ability)
	movement_abilities.append(dash_ability)
		
	# Placeholder Item Acquisition
	# Will eventually all be handled in game
	var new_item_data = load("res://Items/Weapons/Resources/dagger3.tres")
	var another_data = load("res://Items/Weapons/Resources/dagger2.tres")
	inventory.add_item(new_item_data, 1)
	inventory.add_item(another_data, 1)
	
	# Placeholder Weapon
	# Will eventually need a way to change out weapons. but since its tied to just a string, should be easy
	weapon_arm.load_weapon("res://Items/Weapons/Resources/dagger3.tres")

func _physics_process(delta):
	for ability in movement_abilities:
		ability.apply_movement(self, delta)
	apply_gravity(delta)
	handle_jump()
	handle_movement(delta)
	cap_speed()
	head_bob(delta)
	fov_change(delta)
	move_and_slide()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and not inventory_open:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			neck.rotate_y(-event.relative.x * 0.01)
			camera.rotate_x(-event.relative.y * 0.01)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))
			
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not inventory_open:
		if event.pressed:
			if weapon_arm.current_weapon:
				weapon_arm.current_weapon.attack(null)  # Pass in player stats if necessary
			else:
				if weapon_arm.current_weapon:
					weapon_arm.current_weapon.stop()
			
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and not inventory_open:
		if event.pressed:
			if weapon_arm.current_weapon:
				weapon_arm.current_weapon.parry()
		else:
			if weapon_arm.current_weapon:
				weapon_arm.current_weapon.stop()
				
	for ability in movement_abilities:
		ability.process_input(self, get_process_delta_time())
				
	if event is InputEventKey and event.is_action_pressed("inventory_toggle"):
		if event.pressed:
			toggle_inventory()
			
	if event is InputEventKey and event.is_action_pressed("interact"):
		if event.pressed:
			interact_with_nearest()
		
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

func head_bob(delta) -> void:
	t_bob += delta * velocity.length() * float(is_on_floor())
	
	var pos = Vector3.ZERO
	pos.y = sin(t_bob * BOB_FREQ) * BOB_AMP
	pos.x = cos(t_bob * BOB_FREQ / 2) * BOB_AMP
	
	camera.transform.origin = pos

func fov_change(delta) -> void:
	var velocity_clamped = clamp(velocity.length(), 0.5, MAX_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 5.0)

func toggle_inventory():
	inventory_open = !inventory_open
	inventory_ui.visible = inventory_open
	if inventory_open:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		inventory_ui.update_inventory_display()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
func pick_up_item(item_data: ItemData, amount: int) -> void:
	inventory.add_item(item_data, amount)
	if inventory_ui.visible:
		inventory_ui.update_inventory_display()

func interact_with_nearest():
	print("interactables:", nearby_interactables)
	if nearby_interactables.size() > 0:
		var nearest = nearby_interactables[0]  # Assuming the nearest is the first in the list
		nearest.interact(self)

func add_nearby_interactable(interactable):
	print('add nearby')
	if not nearby_interactables.has(interactable):
		nearby_interactables.append(interactable)

func remove_nearby_interactable(interactable):
	print("remove nearby")
	if nearby_interactables.has(interactable):
		nearby_interactables.erase(interactable)
