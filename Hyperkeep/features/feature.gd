extends Node

var versions = []

enum Blocks {
	VOID,
	WALL,
	STAIRS_W,
	STAIRS_N,
	STAIRS_S,
	STAIRS_E,
	FILLABLE_VOID,
	FILLABLE_FLOOR,
	FLOOR_GRATE,
	WALL_GRATE_X,
	WALL_GRATE_Z,
	FLOOR,
	CEIL
}

func _ready() -> void:
	for i in range(4):
		var cells = {}
		var open_cells = []
		for child in get_children():
			child.position = round(child.position.rotated(Vector3.UP, i * deg_to_rad(90.0)))
			if child.name.begins_with("Void"):
				cells[Vector3i(child.position)] = Blocks.VOID
				if child.open:
					open_cells.append(Vector3i(child.position))
			if child.name.begins_with("Wall"):
				cells[Vector3i(child.position)] = Blocks.WALL
			if child.name.begins_with("Floor"):
				cells[Vector3i(child.position)] = Blocks.FLOOR
			if child.name.begins_with("Ceil"):
				cells[Vector3i(child.position)] = Blocks.CEIL
			if child.name.begins_with("FloorGrate"):
				cells[Vector3i(child.position)] = Blocks.FLOOR_GRATE
			if child.name.begins_with("FillableVoid"):
				cells[Vector3i(child.position)] = Blocks.FILLABLE_VOID
			if child.name.begins_with("FillableWall"):
				cells[Vector3i(child.position)] = Blocks.FILLABLE_FLOOR
			if child.name.begins_with("StairsWest"):
				cells[Vector3i(child.position)] = [
					Blocks.STAIRS_W,
					Blocks.STAIRS_N,
					Blocks.STAIRS_S,
					Blocks.STAIRS_E,
				][i]
			if child.name.begins_with("StairsEast"):
				cells[Vector3i(child.position)] = [
					Blocks.STAIRS_E,
					Blocks.STAIRS_S,
					Blocks.STAIRS_N,
					Blocks.STAIRS_W,
				][i]
			if child.name.begins_with("WallGrateX"):
				cells[Vector3i(child.position)] = [
					Blocks.WALL_GRATE_X,
					Blocks.WALL_GRATE_Z,
					Blocks.WALL_GRATE_Z,
					Blocks.WALL_GRATE_X,
				][i]
		versions.append({
			"cells": cells,
			"open_cells": open_cells,
		})
