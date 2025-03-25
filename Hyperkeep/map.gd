extends Node3D

@export var width: int = 9  # Number of cells in X direction
@export var height: int = 9  # Number of levels in Y direction
@export var depth: int = 9  # Number of cells in Z direction
@export var wall_scene: PackedScene = preload("res://wall.tscn")
@export var stairs_scene: PackedScene = preload("res://stairs.tscn")

var map: Dictionary = {}
var start: Vector3i = Vector3i()

func _ready():
	randomize()
	generate_map()
	place_walls()

func generate_map():
	# Initialize the grids with walls (1)
	for x in range(width):
		for y in range(height):
			for z in range(depth):
				map[Vector3i(x, y, z)] = 1
	
	# Define directions to explore
	var directions: Array = [
		Vector3i(-1, 0, 0),
		Vector3i(1, 0, 0),
		Vector3i(0, -1, 0),
		Vector3i(0, 1, 0),
		Vector3i(0, 0, -1),
		Vector3i(0, 0, 1),
	]
	
	# Add random start position
	var open_cells = []
	@warning_ignore("integer_division")
	var x: int = randi() % (width / 2) * 2 + 1
	@warning_ignore("integer_division")
	var y: int = randi() % (height / 2) * 2 + 1
	@warning_ignore("integer_division")
	var z: int = randi() % (depth / 2) * 2 + 1
	start = Vector3i(x, y, z)
	open_cells.append(start)
	map[start] = 0
	
	# Carve the tunnels
	while open_cells.size() > 0:
		# Choose a random cell that can be continued
		open_cells.shuffle()
		var cell: Vector3i = open_cells[0]
		
		# Collect the available directions
		var available_directions = []
		for current_direction in directions:
			var next_cell: Vector3i = cell + 2 * current_direction
			
			# Check if the new position is within bounds and is a wall
			if not map.has(next_cell) or map[next_cell] == 0:
				continue
			
			# Add as an available direction
			available_directions.append(current_direction)
		
		# If the cell can't be continued, remove it from the list of open cells
		if available_directions == []:
			open_cells.pop_front()
			continue
		
		# Otherwise carve a tunnel towards a random direction
		available_directions.shuffle()
		var chosen_direction: Vector3i = available_directions[0]
		map[cell + chosen_direction] = 0
		map[cell + 2 * chosen_direction] = 0
		open_cells.append(cell + 2 * chosen_direction)


func place_walls():
	# Fill with walls
	for cell in map:
		if map[cell] == 1:
			var wall = wall_scene.instantiate()
			wall.position = cell
			add_child(wall)
