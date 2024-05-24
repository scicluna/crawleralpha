### Step 1: Creating the Player Scene

1. **Create a New Scene:**
    
    - Click on "Scene" and select "New Scene."
    - Set the root node to "KinematicBody."
2. **Rename the Root Node:**
    
    - Rename the root node to "Player."
3. **Add a CollisionShape to the Player:**
    
    - With the "Player" node selected, click the "+" button to add a new node.
    - Search for "CollisionShape" and add it.
    - In the Inspector, set the "Shape" property to "New CapsuleShape."
    - Adjust the shape's height and radius to match your player's size (e.g., Height: 2, Radius: 0.5).
4. **Add a MeshInstance for the Player Body:**
    
    - With the "Player" node selected, click the "+" button to add a new node.
    - Search for "MeshInstance" and add it.
    - In the Inspector, set the "Mesh" property to "New CapsuleMesh" to visually represent the player (optional for debugging).

### Step 2: Adding the First-Person Camera

1. **Add a Camera Node:**
    
    - With the "Player" node selected, click the "+" button to add a new node.
    - Search for "Camera" and add it.
    - Rename it to "FPCamera."
    - Position the camera slightly above the player's origin (e.g., Position: (0, 1.8, 0)).
2. **Add a Camera Pivot:**
    
    - Add a "Spatial" node as a child of the "Player" node and name it "CameraPivot."
    - Move the "FPCamera" node to be a child of "CameraPivot."
    - This will help with rotating the camera up and down.

### Step 3: Implementing Player Movement and Mouse Look

1. **Create a Player Script:**
    
    - Select the "Player" node.
    - Click on the "Attach Script" button (or press Ctrl + A).
    - Name the script "Player.gd" and save it.
2. **Write the Player Script:**
    

gdscript

Copy code

`extends KinematicBody  # Player movement speed var speed = 5.0 # Mouse sensitivity var mouse_sensitivity = 0.1  # Variables for movement and rotation var velocity = Vector3() var camera_pivot = null var mouse_lock = true  # Called when the node is added to the scene func _ready():     # Lock the mouse cursor     Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)     camera_pivot = $CameraPivot  # Called every frame func _process(delta):     if Input.is_action_just_pressed("ui_cancel"):         mouse_lock = not mouse_lock         if mouse_lock:             Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)         else:             Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)  # Called every physics frame func _physics_process(delta):     handle_input(delta)     move_and_slide(velocity, Vector3.UP)  # Handle player input func handle_input(delta):     var input_direction = Vector3()      if Input.is_action_pressed("move_forward"):         input_direction.z -= 1     if Input.is_action_pressed("move_backward"):         input_direction.z += 1     if Input.is_action_pressed("move_left"):         input_direction.x -= 1     if Input.is_action_pressed("move_right"):         input_direction.x += 1      input_direction = input_direction.normalized()      # Apply movement     velocity = input_direction * speed     velocity = global_transform.basis.xform(velocity)      # Mouse look     if mouse_lock:         var mouse_movement = Input.get_last_mouse_speed() * mouse_sensitivity         rotate_y(-mouse_movement.x * delta)         camera_pivot.rotate_x(-mouse_movement.y * delta)         # Clamp the camera pivot rotation to prevent flipping         camera_pivot.rotation_degrees.x = clamp(camera_pivot.rotation_degrees.x, -90, 90)`

### Step 4: Setting Up Input Actions

1. **Go to Project Settings:**
    
    - Click on "Project" -> "Project Settings."
2. **Add Input Map Actions:**
    
    - In the "Input Map" tab, add the following actions and assign keys:
        - "move_forward" (W)
        - "move_backward" (S)
        - "move_left" (A)
        - "move_right" (D)
        - "ui_cancel" (Esc)

### Step 5: Adding the Player to the Main Scene

1. **Save the Player Scene:**
    
    - Click on "Scene" -> "Save Scene."
    - Name it "Player.tscn."
2. **Instance the Player in the Main Scene:**
    
    - Open your "MainEnvironment.tscn" scene.
    - Click on the "+" button to add a new node.
    - Search for "Instance" and select "Instance Child Scene."
    - Choose "Player.tscn."
    - Position the player in the main scene appropriately.

### Step 6: Run and Test the Game

1. **Run the Scene:**
    - Click on the "Play" button to run your scene.
    - You should now be able to move the player using WASD and look around with the mouse.

### Summary

This setup provides a basic player character with first-person camera controls and movement. You can now navigate your 3D environment and further develop your game by adding interactions, enemies, and other gameplay elements.