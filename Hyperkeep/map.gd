extends Node3D

@export var width: int = 15  # Number of cells in X direction
@export var height: int = 15  # Number of levels in Y direction
@export var depth: int = 15  # Number of cells in Z direction
@export var wall_scene: PackedScene = preload("res://wall.tscn")
@export var stairs_scene: PackedScene = preload("res://stairs.tscn")

enum Cells {
	VOID,
	WALL,
	STAIRS_E,
	STAIRS_W,
	STAIRS_N,
	STAIRS_S,
}

var map: Dictionary = {}
var start: Vector3i = Vector3i()

func _ready():
	randomize()
	generate_map()
	place_walls()

func generate_map():
	for x in range(width):
		for y in range(height):
			for z in range(depth):
				map[Vector3i(x, y, z)] = Cells.WALL
	
	var features: Array = [
		{
			# east corridor
			"cells": {
				Vector3i(-2, 0, 0): Cells.VOID,
				Vector3i(-1, 0, 0): Cells.VOID,
				Vector3i(-1, -1, 0): Cells.WALL,
				Vector3i(-2, -1, 0): Cells.WALL,
				Vector3i(-1, 1, 0): Cells.WALL,
				Vector3i(-2, 1, 0): Cells.WALL,
			},
			"open_cells": [
				Vector3i(-2, 0, 0)
			]
		},
		{
			# west corridor
			"cells": {
				Vector3i(2, 0, 0): Cells.VOID,
				Vector3i(1, 0, 0): Cells.VOID,
				Vector3i(1, -1, 0): Cells.WALL,
				Vector3i(2, -1, 0): Cells.WALL,
				Vector3i(1, 1, 0): Cells.WALL,
				Vector3i(2, 1, 0): Cells.WALL,
			},
			"open_cells": [
				Vector3i(2, 0, 0)
			]
		},
		{
			# north corridor
			"cells": {
				Vector3i(0, 0, -2): Cells.VOID,
				Vector3i(0, 0, -1): Cells.VOID,
				Vector3i(0, -1, -1): Cells.WALL,
				Vector3i(0, -1, -2): Cells.WALL,
				Vector3i(0, 1, -1): Cells.WALL,
				Vector3i(0, 1, -2): Cells.WALL,
			},
			"open_cells": [
				Vector3i(0, 0, -2)
			]
		},
		{
			# south corridor
			"cells": {
				Vector3i(0, 0, 2): Cells.VOID,
				Vector3i(0, 0, 1): Cells.VOID,
				Vector3i(0, -1, 1): Cells.WALL,
				Vector3i(0, -1, 2): Cells.WALL,
				Vector3i(0, 1, 1): Cells.WALL,
				Vector3i(0, 1, 2): Cells.WALL,
			},
			"open_cells": [
				Vector3i(0, 0, 2)
			]
		},
		{
			# east stairs
			"cells": {
				Vector3i(-2, 1, 0): Cells.VOID,
				Vector3i(-1, 1, 0): Cells.VOID,
				Vector3i(-2, 0, 0): Cells.WALL,
				Vector3i(-1, 0, 0): Cells.STAIRS_E,
				Vector3i(-2, -1, 0): Cells.WALL,
				Vector3i(-1, -1, 0): Cells.WALL,
				Vector3i(-2, 2, 0): Cells.WALL,
				Vector3i(-1, 2, 0): Cells.WALL,
			},
			"open_cells": [
				Vector3i(-2, 1, 0)
			]
		},
		{
			# west stairs
			"cells": {
				Vector3i(2, 1, 0): Cells.VOID,
				Vector3i(1, 1, 0): Cells.VOID,
				Vector3i(2, 0, 0): Cells.WALL,
				Vector3i(1, 0, 0): Cells.STAIRS_W,
				Vector3i(2, -1, 0): Cells.WALL,
				Vector3i(1, -1, 0): Cells.WALL,
				Vector3i(2, 2, 0): Cells.WALL,
				Vector3i(1, 2, 0): Cells.WALL,
			},
			"open_cells": [
				Vector3i(2, 1, 0)
			]
		},
		{
			# north stairs
			"cells": {
				Vector3i(0, 1, -2): Cells.VOID,
				Vector3i(0, 1, -1): Cells.VOID,
				Vector3i(0, 0, -2): Cells.WALL,
				Vector3i(0, 0, -1): Cells.STAIRS_N,
				Vector3i(0, -1, -2): Cells.WALL,
				Vector3i(0, -1, -1): Cells.WALL,
				Vector3i(0, 2, -2): Cells.WALL,
				Vector3i(0, 2, -1): Cells.WALL,
			},
			"open_cells": [
				Vector3i(0, 1, -2)
			]
		},
		{
			# south stairs
			"cells": {
				Vector3i(0, 1, 2): Cells.VOID,
				Vector3i(0, 1, 1): Cells.VOID,
				Vector3i(0, 0, 2): Cells.WALL,
				Vector3i(0, 0, 1): Cells.STAIRS_S,
				Vector3i(0, -1, 2): Cells.WALL,
				Vector3i(0, -1, 1): Cells.WALL,
				Vector3i(0, 2, 2): Cells.WALL,
				Vector3i(0, 2, 1): Cells.WALL,
			},
			"open_cells": [
				Vector3i(0, 1, 2)
			]
		},
	]
	
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
				if not map[cell + feature_cell] == Cells.WALL:
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


func place_walls():
	# Fill with walls
	for cell in map:
		var cell_instance = null
		if map[cell] == Cells.WALL:
			cell_instance = wall_scene.instantiate()
		if map[cell] == Cells.STAIRS_E:
			cell_instance = stairs_scene.instantiate()
			cell_instance.rotation_degrees = Vector3i(0, -90, 0)
		if map[cell] == Cells.STAIRS_W:
			cell_instance = stairs_scene.instantiate()
			cell_instance.rotation_degrees = Vector3i(0, 90, 0)
		if map[cell] == Cells.STAIRS_N:
			cell_instance = stairs_scene.instantiate()
			cell_instance.rotation_degrees = Vector3i(0, 180, 0)
		if map[cell] == Cells.STAIRS_S:
			cell_instance = stairs_scene.instantiate()
		if cell_instance == null:
			continue
		cell_instance.position = cell
		add_child(cell_instance)
