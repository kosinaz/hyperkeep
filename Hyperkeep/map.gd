extends Node3D

@export var width: int = 9  # Number of cells in X direction
@export var depth: int = 9  # Number of cells in Z direction
@export var wall_scene: PackedScene = preload("res://wall.tscn")

var grid: Array = []  # 2D array to store the maze (1 = wall, 0 = path)

func _ready():
	generate_maze()
	place_walls()

func generate_maze():
	# Initialize the grid with walls (1)
	for x in range(width):
		var row = []
		for z in range(depth):
			row.append(1)  # Start with all walls
		grid.append(row)
	
	# Start the recursive backtracking from (1, 1)
	recursive_backtrack(1, 1)
	
	# Ensure the borders are walls
	for x in range(width):
		grid[x][0] = 1
		grid[x][depth - 1] = 1
	for z in range(depth):
		grid[0][z] = 1
		grid[width - 1][z] = 1

func recursive_backtrack(x: int, z: int):
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
			recursive_backtrack(new_x, new_z)

func place_walls():
	# Place walls for the maze layer (y2, y = 0)
	for x in range(width):
		for z in range(depth):
			if grid[x][z] == 1:
				var wall_instance = wall_scene.instantiate()
				wall_instance.position = Vector3(x, 0, z)  # y2 layer (maze)
				add_child(wall_instance)
	
	# Place walls for the floor layer (y1, y = -1)
	for x in range(width):
		for z in range(depth):
			var floor_instance = wall_scene.instantiate()
			floor_instance.position = Vector3(x, -1, z)  # y1 layer (floor)
			add_child(floor_instance)
	
	# Place walls for the ceiling layer (y3, y = 1)
	for x in range(width):
		for z in range(depth):
			var ceiling_instance = wall_scene.instantiate()
			ceiling_instance.position = Vector3(x, 1, z)  # y3 layer (ceiling)
			add_child(ceiling_instance)
