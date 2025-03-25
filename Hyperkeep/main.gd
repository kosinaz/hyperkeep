extends Node3D

func _ready() -> void:
	$Player.position = $Map.start
