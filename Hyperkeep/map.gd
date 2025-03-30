extends Node3D

@export var number_of_features: int = 25
@export var wall_scene: PackedScene = preload("res://wall.tscn")
@export var floor_grate_scene: PackedScene = preload("res://floor_grate.tscn")
@export var stairs_e_scene: PackedScene = preload("res://stairs_east.tscn")
@export var stairs_w_scene: PackedScene = preload("res://stairs_west.tscn")
@export var stairs_n_scene: PackedScene = preload("res://stairs_north.tscn")
@export var stairs_s_scene: PackedScene = preload("res://stairs_south.tscn")
@export var wall_grate_x_scene: PackedScene = preload("res://wall_grate_x.tscn")
@export var wall_grate_z_scene: PackedScene = preload("res://wall_grate_z.tscn")
@export var features_scene: PackedScene = preload("res://features/features.tscn")

# Feature: A set of blocks.
# Block: A physical piece of the map occupying a single cell.
# Cell: A Vector3 position of the map.

enum Blocks {
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

func _ready():
	randomize()
	generate_map()
	place_walls()

func generate_map():
	var features_instance: Node3D = features_scene.instantiate()
	add_child(features_instance)
	var features: Array = features_instance.features
	features_instance.queue_free()
	var open_cells: Array = []
	open_cells.append(Vector3i())
	map[Vector3i()] = Blocks.VOID
	map[Vector3i(0, 1, 0)] = Blocks.WALL
	map[Vector3i(0, -1, 0)] = Blocks.WALL
	map[Vector3i(1, 0, 0)] = Blocks.WALL
	map[Vector3i(-1, 0, 0)] = Blocks.WALL
	map[Vector3i(0, 0, 1)] = Blocks.WALL
	map[Vector3i(0, 0, -1)] = Blocks.WALL
	
	# Carve the tunnels
	for _i in range(number_of_features):
		# Choose a random cell that can be continued
		open_cells.shuffle()
		var cell: Vector3i = open_cells[0]
		
		# Collect the available directions
		var available_features = []
		for feature in features:
			var available: bool = true
			for feature_cell in feature.cells.keys():
				var current_cell = feature.cells[feature_cell]
				# Walls can be placed anywhere, they are anyway the outer parts of any feature,
				# and they won't be placed, if the map already contains void-like cells there.
				if current_cell == Blocks.WALL:
					continue
				# Non-tracked cells are always available.
				if not map.has(cell + feature_cell):
					continue
				
				var next_cell = map[cell + feature_cell]
				if not (
					next_cell == Blocks.WALL or
					(next_cell == Blocks.FILLABLE_VOID and current_cell == Blocks.VOID) #or
					#(next_cell == Blocks.FILLABLE_WALL and current_cell == Blocks.WALL)
				):
					available = false
					continue
			# Only add as available if all cells of the feature are available
			if available:
				available_features.append(feature)
		
		# If the cell can't be continued after this, remove it from the list of open cells
		if available_features.size() < 2:
			open_cells.pop_front()
			if available_features == []:
				continue
		
		# Carve out the randomly chosen feature
		available_features.shuffle()
		var chosen_feature: Dictionary = available_features[0]
		for feature_cell in chosen_feature.cells.keys():
			if map.has(cell + feature_cell):
				if map[cell + feature_cell] == Blocks.VOID:
					continue
				if map[cell + feature_cell] == Blocks.WALL_GRATE_X:
					continue
				if map[cell + feature_cell] == Blocks.WALL_GRATE_Z:
					continue
			map[cell + feature_cell] = chosen_feature.cells[feature_cell]
		
		for open_cell in chosen_feature.open_cells:
			open_cells.append(cell + open_cell)

func place_walls():
	# Fill with walls
	for cell in map:
		var cell_instance = null
		if map[cell] == Blocks.WALL:
			cell_instance = wall_scene.instantiate()
		if map[cell] == Blocks.FLOOR_GRATE:
			cell_instance = floor_grate_scene.instantiate()
		if map[cell] == Blocks.STAIRS_E:
			cell_instance = stairs_e_scene.instantiate()
		if map[cell] == Blocks.STAIRS_W:
			cell_instance = stairs_w_scene.instantiate()
		if map[cell] == Blocks.STAIRS_N:
			cell_instance = stairs_n_scene.instantiate()
		if map[cell] == Blocks.STAIRS_S:
			cell_instance = stairs_s_scene.instantiate()
		if map[cell] == Blocks.WALL_GRATE_X:
			cell_instance = wall_grate_x_scene.instantiate()
		if map[cell] == Blocks.WALL_GRATE_Z:
			cell_instance = wall_grate_z_scene.instantiate()
		if cell_instance == null:
			continue
		cell_instance.position = cell
		add_child(cell_instance)
