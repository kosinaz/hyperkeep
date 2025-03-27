extends Node

var versions = []

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

func _ready() -> void:
	for i in range(4):
		var cells = {}
		var open_cells = []
		for child in get_children():
			child.position = round(child.position.rotated(Vector3.UP, i * deg_to_rad(90.0)))
			if child.name.begins_with("Void"):
				cells[Vector3i(child.position)] = Cells.VOID
				if child.open:
					open_cells.append(Vector3i(child.position))
			if child.name.begins_with("Wall"):
				cells[Vector3i(child.position)] = Cells.WALL
			if child.name.begins_with("FloorGrate"):
				cells[Vector3i(child.position)] = Cells.FLOOR_GRATE
			if child.name.begins_with("FillableVoid"):
				cells[Vector3i(child.position)] = Cells.FILLABLE_VOID
			if child.name.begins_with("FillableWall"):
				cells[Vector3i(child.position)] = Cells.FILLABLE_WALL
			if child.name.begins_with("StairsWest"):
				cells[Vector3i(child.position)] = [
					Cells.STAIRS_W,
					Cells.STAIRS_N,
					Cells.STAIRS_S,
					Cells.STAIRS_E,
				][i]
			if child.name.begins_with("StairsEast"):
				cells[Vector3i(child.position)] = [
					Cells.STAIRS_E,
					Cells.STAIRS_S,
					Cells.STAIRS_N,
					Cells.STAIRS_W,
				][i]
			if child.name.begins_with("WallGrateX"):
				cells[Vector3i(child.position)] = [
					Cells.WALL_GRATE_X,
					Cells.WALL_GRATE_Z,
					Cells.WALL_GRATE_Z,
					Cells.WALL_GRATE_X,
				][i]
		versions.append({
			"cells": cells,
			"open_cells": open_cells,
		})
