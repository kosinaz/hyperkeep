extends Node3D

@onready var particles = $FireParticles
@onready var smoke_particles = $SmokeParticles
@onready var light = $OmniLight3D
@onready var collision = $Area3D

var speed = 3.0
var direction = Vector3.FORWARD
var lifetime = 3.0
var current_lifetime = 0.0

func _ready():
	particles.emitting = true
	smoke_particles.emitting = true
	
	# Random rotation for variety
	rotation.z = randf_range(0, TAU)
	
	# Set up light flicker with random intervals
	var tween = create_tween().set_loops()
	tween.tween_property(light, "light_energy", 2.5, randf_range(0.05, 0.15))
	tween.tween_property(light, "light_energy", 1.8, randf_range(0.05, 0.15))

func _process(delta):
	# Move the fireball
	global_translate(direction * speed * delta)
	
	# Rotate slightly for effect
	rotate_y(delta * 0.5)
	
	# Handle lifetime
	current_lifetime += delta
	if current_lifetime >= lifetime:
		queue_free()

func _on_area_3d_body_entered(body):
	# Handle collision
	if body.has_method("take_damage"):
		body.take_damage(25)
	
	# Start explosion and removal sequence
	explode()

func explode():
	# Stop movement
	speed = 0
	
	# Increase particle emission for explosion effect
	particles.amount = 256  # More particles for a big burst
	particles.lifetime = 0.4
	particles.process_material.spread = 90.0  # Wider spread for explosion
	particles.process_material.initial_velocity_min = 2.0
	particles.process_material.initial_velocity_max = 5.0
	
	smoke_particles.amount = 128
	smoke_particles.lifetime = 1.0
	smoke_particles.process_material.spread = 60.0
	smoke_particles.process_material.initial_velocity_min = 1.0
	smoke_particles.process_material.initial_velocity_max = 3.0
	
	# Flash the light
	var tween = create_tween()
	tween.tween_property(light, "light_energy", 6.0, 0.1)
	tween.tween_property(light, "light_energy", 0.0, 0.4)
	
	# Schedule removal
	await get_tree().create_timer(0.5).timeout
	queue_free()
