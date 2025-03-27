extends Node3D

@export var width: int = 15  # Number of cells in X direction
@export var height: int = 7  # Number of levels in Y direction
@export var depth: int = 15  # Number of cells in Z direction
@export var wall_scene: PackedScene = preload("res://wall.tscn")
@export var floor_grate_scene: PackedScene = preload("res://floor_grate.tscn")
@export var stairs_e_scene: PackedScene = preload("res://stairs_east.tscn")
@export var stairs_w_scene: PackedScene = preload("res://stairs_west.tscn")
@export var stairs_n_scene: PackedScene = preload("res://stairs_north.tscn")
@export var stairs_s_scene: PackedScene = preload("res://stairs_south.tscn")
@export var wall_grate_x_scene: PackedScene = preload("res://wall_grate_x.tscn")
@export var wall_grate_z_scene: PackedScene = preload("res://wall_grate_z.tscn")
@export var features_scene: PackedScene = preload("res://features/features.tscn")

enum Cells {
	VOID,
	WALL,
	STAIRS_W,
	STAIRS_N,
	STAIRS_S,
	STAIRS_E,
	FILLABLE_VOID,
	FILLABLE_WALL,
	FLOOR_GRATE,
	WALL_GRATE_X,
	WALL_GRATE_Z,
}

var map: Dictionary = {}
var start: Vector3i = Vector3i()
var end: Vector3i = Vector3i()

func _ready():
	randomize()
	generate_map()
	place_walls()

func generate_map():
	var features_instance: Node3D = features_scene.instantiate()
	add_child(features_instance)
	var features: Array = features_instance.features
	features_instance.queue_free()
	for x in range(width):
		for y in range(height):
			for z in range(depth):
				map[Vector3i(x, y, z)] = Cells.WALL
	
	# Add random start position
	var open_cells: Array = []
	@warning_ignore("integer_division")
	var x: int = randi() % (width / 2) * 2 + 1
	@warning_ignore("integer_division")
	var y: int = randi() % (height / 2) * 2 + 1
	@warning_ignore("integer_division")
	var z: int = randi() % (depth / 2) * 2 + 1
	start = Vector3i(x, y, z)
	open_cells.append(start)
	map[start] = Cells.VOID
	
	# Carve the tunnels
	while open_cells.size() > 0:
		# Choose a random cell that can be continued
		open_cells.shuffle()
		var cell: Vector3i = open_cells[0]
		
		# Collect the available directions
		var available_features = []
		for feature in features:
			var available: bool = true
			for feature_cell in feature.cells.keys():
				# Skip if the cell is out of bounds
				if not map.has(cell + feature_cell):
					available = false
					continue
				# Skip if cell is already carved
				var current_cell = feature.cells[feature_cell]
				var next_cell = map[cell + feature_cell]
				if not (
					next_cell == Cells.WALL or
					(next_cell == Cells.FILLABLE_VOID and current_cell == Cells.VOID) or
					(next_cell == Cells.FILLABLE_WALL and current_cell == Cells.WALL)
				):
					available = false
					continue
			# Only add as available if all cells of the feature are available
			if available:
				available_features.append(feature)
		
		# If the cell can't be continued, remove it from the list of open cells
		if available_features == []:
			open_cells.pop_front()
			continue
		
		# Otherwise carve out the randomly chosen feature
		available_features.shuffle()
		var chosen_feature: Dictionary = available_features[0]
		for feature_cell in chosen_feature.cells.keys():
			map[cell + feature_cell] = chosen_feature.cells[feature_cell]
		
		for open_cell in chosen_feature.open_cells:
			open_cells.append(cell + open_cell)
			end = cell + open_cell

func place_walls():
	# Fill with walls
	for cell in map:
		var cell_instance = null
		if map[cell] == Cells.WALL:
			cell_instance = wall_scene.instantiate()
		if map[cell] == Cells.FLOOR_GRATE:
			cell_instance = floor_grate_scene.instantiate()
		if map[cell] == Cells.STAIRS_E:
			cell_instance = stairs_e_scene.instantiate()
		if map[cell] == Cells.STAIRS_W:
			cell_instance = stairs_w_scene.instantiate()
		if map[cell] == Cells.STAIRS_N:
			cell_instance = stairs_n_scene.instantiate()
		if map[cell] == Cells.STAIRS_S:
			cell_instance = stairs_s_scene.instantiate()
		if map[cell] == Cells.WALL_GRATE_X:
			cell_instance = wall_grate_x_scene.instantiate()
		if map[cell] == Cells.WALL_GRATE_Z:
			cell_instance = wall_grate_z_scene.instantiate()
		if cell_instance == null:
			continue
		cell_instance.position = cell
		add_child(cell_instance)
