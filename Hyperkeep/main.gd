extends Node3D

func _ready() -> void:
	$Player.position = $Map.start
	$Enemy.position = $Map.start + Vector3i(3, 0, 0)
	$Enemy2.position = $Map.start + Vector3i(-3, 0, 0)
	$Enemy3.position = $Map.start + Vector3i(0, 0, 3)
	$Enemy4.position = $Map.start + Vector3i(0, 0, -3)
	$Enemy.target = $Player
	$Enemy2.target = $Player
	$Enemy3.target = $Player
	$Enemy4.target = $Player
