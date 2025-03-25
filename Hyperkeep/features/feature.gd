extends Node

var versions = []

enum Cells {
	VOID,
	WALL,
	STAIRS_W,
	STAIRS_N,
	STAIRS_S,
	STAIRS_E,
}

func _ready() -> void:
	for i in range(4):
		var cells = {}
		var open_cells = []
		for child in get_children():
			child.position = child.position.rotated(Vector3.UP, i * deg_to_rad(90.0))
			if child.name.begins_with("Void"):
				cells[Vector3i(child.position)] = Cells.VOID
				if child.open:
					open_cells.append(Vector3i(child.position))
			if child.name.begins_with("Wall"):
				cells[Vector3i(child.position)] = Cells.WALL
			if child.name.begins_with("StairsWest"):
				cells[Vector3i(child.position)] = i + 2
		versions.append({
			"cells": cells,
			"open_cells": open_cells,
		})
