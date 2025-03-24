extends Node3D

@export var width: int = 9  # Number of cells in X direction
@export var height: int = 5  # Number of levels in Y direction (0 to 4)
@export var depth: int = 9  # Number of cells in Z direction
@export var wall_scene: PackedScene = preload("res://wall.tscn")
@export var stairs_scene: PackedScene = preload("res://stairs.tscn")

var grid_level1: Array = []  # 2D array for the maze at Level 1 (y = 1)
var grid_level3: Array = []  # 2D array for the maze at Level 3 (y = 3)
var stairs_positions: Array = []  # Store positions of stairs to create holes

# Helper function to find the nearest path cell in a given grid
func find_nearest_path(start_x: int, start_z: int, grid: Array) -> Vector2:
	var queue = []
	var visited = {}
	queue.append(Vector2(start_x, start_z))
	visited[Vector2(start_x, start_z)] = true
	
	var directions = [
		Vector2(0, -1), Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0)
	]
	
	while queue.size() > 0:
		var pos = queue.pop_front()
		var x = int(pos.x)
		var z = int(pos.y)
		
		if grid[x][z] == 0:
			# Check if this position is already used by another stair
			var unique = true
			for existing_pos in stairs_positions:
				if existing_pos.x == x and existing_pos.z == z:
					unique = false
					break
			if unique:
				return Vector2(x, z)
		
		for dir in directions:
			var new_x = x + int(dir.x)
			var new_z = z + int(dir.y)
			var new_pos = Vector2(new_x, new_z)
			
			if new_x >= 0 and new_x < width and new_z >= 0 and new_z < depth and not visited.has(new_pos):
				queue.append(new_pos)
				visited[new_pos] = true
	
	return Vector2(-1, -1)  # Return invalid position if no unique path found

func _ready():
	generate_mazes()
	place_walls()
	place_stairs()

func generate_mazes():
	# Initialize the grids with walls (1)
	for x in range(width):
		var row1 = []
		var row3 = []
		for z in range(depth):
			row1.append(1)  # Start with all walls for Level 1
			row3.append(1)  # Start with all walls for Level 3
		grid_level1.append(row1)
		grid_level3.append(row3)
	
	# Generate maze for Level 1 (y = 1), starting from (1, 1)
	recursive_backtrack(1, 1, grid_level1)
	
	# Generate maze for Level 3 (y = 3), starting from (1, 1)
	recursive_backtrack(1, 1, grid_level3)
	
	# Ensure the borders are walls for both levels
	for x in range(width):
		grid_level1[x][0] = 1
		grid_level1[x][depth - 1] = 1
		grid_level3[x][0] = 1
		grid_level3[x][depth - 1] = 1
	for z in range(depth):
		grid_level1[0][z] = 1
		grid_level1[width - 1][z] = 1
		grid_level3[0][z] = 1
		grid_level3[width - 1][z] = 1

func recursive_backtrack(x: int, z: int, grid: Array):
	# Mark the current cell as a path (0)
	grid[x][z] = 0
	
	# Define directions to explore (up, right, down, left)
	var directions = [
		Vector2(0, -2),  # Up
		Vector2(2, 0),   # Right
		Vector2(0, 2),   # Down
		Vector2(-2, 0)   # Left
	]
	
	# Shuffle the directions for randomness
	directions.shuffle()
	
	# Explore each direction
	for dir in directions:
		var new_x = x + int(dir.x)
		var new_z = z + int(dir.y)
		
		# Check if the new position is within bounds and is a wall
		if new_x > 0 and new_x < width - 1 and new_z > 0 and new_z < depth - 1 and grid[new_x][new_z] == 1:
			# Carve a path by setting the cell between the current and new position to 0
			grid[x + int(dir.x / 2)][z + int(dir.y / 2)] = 0
			# Recursively continue from the new position
			recursive_backtrack(new_x, new_z, grid)

func place_walls():
	# Level 0 (y = 0): Fill with walls
	for x in range(width):
		for z in range(depth):
			var wall_instance = wall_scene.instantiate()
			wall_instance.position = Vector3(x, 0, z)
			add_child(wall_instance)
	
	# Level 1 (y = 1): Maze
	for x in range(width):
		for z in range(depth):
			if grid_level1[x][z] == 1:
				var wall_instance = wall_scene.instantiate()
				wall_instance.position = Vector3(x, 1, z)
				add_child(wall_instance)
	
	# Level 2 (y = 2): Fill with walls, skip where stairs are
	for x in range(width):
		for z in range(depth):
			var skip = false
			for pos in stairs_positions:
				if pos.x == x and pos.z == z and (pos.y == 1 or pos.y == 3):  # Skip if there's a stair
					skip = true
					break
			if not skip:
				var wall_instance = wall_scene.instantiate()
				wall_instance.position = Vector3(x, 2, z)
				add_child(wall_instance)
	
	# Level 3 (y = 3): Maze
	for x in range(width):
		for z in range(depth):
			if grid_level3[x][z] == 1:
				var wall_instance = wall_scene.instantiate()
				wall_instance.position = Vector3(x, 3, z)
				add_child(wall_instance)
	
	# Level 4 (y = 4): Fill with walls
	for x in range(width):
		for z in range(depth):
			var wall_instance = wall_scene.instantiate()
			wall_instance.position = Vector3(x, 4, z)
			add_child(wall_instance)

func place_stairs():
	# Clear the stairs positions array
	stairs_positions.clear()
	
	# Place stairs from Level 1 (y = 1) to Level 3 (y = 3)
	var pos1 = find_nearest_path(2, 2, grid_level1)
	if pos1 != Vector2(-1, -1):
		var stairs_up = stairs_scene.instantiate()
		stairs_up.position = Vector3(pos1.x, 1, pos1.y)
		stairs_up.rotation = Vector3(0, deg_to_rad(90), 0)
		add_child(stairs_up)
		stairs_positions.append(Vector3(pos1.x, 1, pos1.y))
	
	pos1 = find_nearest_path(4, 4, grid_level1)
	if pos1 != Vector2(-1, -1):
		var stairs_up = stairs_scene.instantiate()
		stairs_up.position = Vector3(pos1.x, 1, pos1.y)
		stairs_up.rotation = Vector3(0, deg_to_rad(90), 0)
		add_child(stairs_up)
		stairs_positions.append(Vector3(pos1.x, 1, pos1.y))
	
	pos1 = find_nearest_path(6, 2, grid_level1)
	if pos1 != Vector2(-1, -1):
		var stairs_up = stairs_scene.instantiate()
		stairs_up.position = Vector3(pos1.x, 1, pos1.y)
		stairs_up.rotation = Vector3(0, deg_to_rad(90), 0)
		add_child(stairs_up)
		stairs_positions.append(Vector3(pos1.x, 1, pos1.y))
	
	# Place stairs from Level 3 (y = 3) to Level 1 (y = 1)
	var pos3 = find_nearest_path(2, 6, grid_level3)
	if pos3 != Vector2(-1, -1):
		var stairs_down = stairs_scene.instantiate()
		stairs_down.position = Vector3(pos3.x, 3, pos3.y)
		stairs_down.rotation = Vector3(0, deg_to_rad(90), 0)
		add_child(stairs_down)
		stairs_positions.append(Vector3(pos3.x, 3, pos3.y))
	
	pos3 = find_nearest_path(6, 6, grid_level3)
	if pos3 != Vector2(-1, -1):
		var stairs_down = stairs_scene.instantiate()
		stairs_down.position = Vector3(pos3.x, 3, pos3.y)
		stairs_down.rotation = Vector3(0, deg_to_rad(90), 0)
		add_child(stairs_down)
		stairs_positions.append(Vector3(pos3.x, 3, pos3.y))
	
	pos3 = find_nearest_path(8, 8, grid_level3)
	if pos3 != Vector2(-1, -1):
		var stairs_down = stairs_scene.instantiate()
		stairs_down.position = Vector3(pos3.x, 3, pos3.y)
		stairs_down.rotation = Vector3(0, deg_to_rad(90), 0)
		add_child(stairs_down)
		stairs_positions.append(Vector3(pos3.x, 3, pos3.y))
