extends Node3D

func _ready() -> void:
	$Player.position = $Map.start
	$Enemy.position = $Map.end
	$Enemy.target = $Player
