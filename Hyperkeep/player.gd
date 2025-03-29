extends CharacterBody3D

@export var speed = 2.0
@export var jump_velocity = 3.0
@export var mouse_sensitivity = 0.002

# Camera bobbing
@export var bob_frequency = 18
@export var bob_amplitude = 0.02
var bob_time = 0.01
var initial_camera_y = 0.0

# Fireball settings
@export var fireball_scene: PackedScene  # Assign fireball.tscn in the editor
var fireball_cooldown = 0.75  # Cooldown in seconds
var cooldown_timer = 0.0  # Tracks time since last shot

# Get the gravity from the project settings
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var camera = $Camera3D
@onready var camera_ray = $Camera3D/RayCast3D

func _ready():
	# Capture the mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	initial_camera_y = camera.position.y

func _input(event):
	# Mouse look
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
	
	# Toggle mouse capture with Escape key
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	# Update cooldown timer
	if cooldown_timer > 0:
		cooldown_timer -= delta

	# Add gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Get input direction
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Handle movement
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		
		# Camera bobbing when moving
		bob_time += delta * bob_frequency * velocity.length() / speed
		camera.position.y = initial_camera_y + sin(bob_time) * bob_amplitude
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		
		# Gradually return camera to neutral position when not moving
		bob_time = 0
		camera.position.y = lerp(camera.position.y, initial_camera_y, delta * 5.0)

	# Shoot fireball on left-click (action "attack") with cooldown
	if Input.is_action_pressed("attack") and cooldown_timer <= 0:
		shoot_fireball()
		cooldown_timer = fireball_cooldown  # Reset cooldown

	move_and_slide()

func shoot_fireball():
	if fireball_scene:
		# Instance the fireball
		var fireball = fireball_scene.instantiate()
		
		# Add it to the scene tree
		get_tree().root.add_child(fireball)
		
		# Position it in front of the camera (player's view direction)
		var spawn_offset = -camera.global_transform.basis.z * 0.1  # 1.5 units forward
		fireball.global_transform.origin = camera.global_transform.origin + spawn_offset
		
		# Set the fireball's direction to match the camera's forward direction
		fireball.direction = -camera.global_transform.basis.z.normalized()
		fireball.rotation = camera.global_rotation
