### Step 1: Setting Up the GridMap
- New Scene
- Root Node = Spatial
- Add new node
	- GridMap
		- Rename it to Environment
- With Environment Selected 
	- Go to inspector and find the "Theme" property
	- Click on the drop-down menu and select "New MeshLibrary"
	- Click on the Mesh Library to open its properties
		- Click on Meshes Tab in the MeshLibrary editor
		- Click the + button to add a new mesh slot
		- Assign a BoxMesh or any other mesh to this slot for your floor
		- Set the dimensions to match your desired floor size(e.g.,1x1x1)
		- Repeat this process to add meshes for your walls and ceiling. You can use different slots for different wall types if needed.

### Step 2: Painting the Environment
- Select "Environment"
- In the Inspector, under "GridMap", click on the "MeshLibrary" property and select the MeshLibrary you created
- Set the cell size to match the dimensions of your meshes (e.g., 1x1x1 for a grid of 1 unit cubes).
- With the "Environment" node selected, switch to the 3D viewport.
- You will see a grid where you can place your meshes.
- Select the mesh you want to paint from the MeshLibrary. You can do this by clicking on the mesh icon in the toolbar at the top of the 3D viewport.
- Click on the grid to paint the selected mesh.

### Step 3: Adding a Camera
- **Add a Camera Node:**
    - Click on the "+" button to add a new node.
    - Search for "Camera" and add it to the scene.
    - Position and rotate the camera to your liking (e.g., position at `(0, 1.8, -8)` and rotate it slightly downwards).

### Step 4: Adding Lighting
- **Add a Directional Light:**
    - Click on the "+" button to add a new node.
    - Search for "DirectionalLight" and add it to the scene.
    - Rotate the light to ensure it lights the room properly (e.g., set the rotation degrees to `(-45, 0, 0)`).

### Step 5: Saving and Running the Scene
- **Save the Scene:**
    - Click on "Scene" and select "Save Scene."
    - Name the scene (e.g., "Main.tscn").
- **Set the Main Scene:**
    - Go to "Project" -> "Project Settings."
    - In the "General" tab, find "Run" -> "Main Scene."
    - Click on the folder icon and select the "Main.tscn" file.
- **Run the Scene:**
    - Click on the "Play" button to run your scene.