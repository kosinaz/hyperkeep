extends Node3D

@onready var collision = $CoreMesh/Area3D

var speed = 5.0
var direction = Vector3.FORWARD
	
func _process(delta):
	global_translate(direction * speed * delta)

func _on_area_3d_body_entered(body):
	# Handle collision
	if body.has_method("take_damage"):
		body.take_damage(25)
	queue_free()
