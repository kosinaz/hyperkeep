extends Node3D

var features: Array = []

func _ready() -> void:
	for child in get_children():
		if child.visible:
			features.append_array(child.versions)
