extends CharacterBody3D

@onready var anim_player = $AnimationPlayer
var speed = 1.0
var gravity = 9.8
var target = null  # Reference to player node
var rotation_speed = 6.0  # Tuned for 1-second turn (radians per second)
var turn_threshold = 0.5  # Radians (~30 degrees) to trigger turn animation
var facing_threshold = 0.1  # Radians (~6 degrees) to consider "facing" the target
var is_turning = false  # Track if the enemy is currently turning

func _physics_process(delta):
	if anim_player.current_animation == "attack":
		return
	if not is_on_floor():
		velocity.y -= gravity * delta

	if target:
		var direction = (target.global_transform.origin - global_transform.origin).normalized()

		# Calculate current and target directions
		var current_direction = transform.basis.z.normalized()  # Current facing direction
		var target_position = Vector3(target.position.x, position.y, target.position.z)
		var target_direction = (target_position - global_transform.origin).normalized()

		# Calculate the angle difference
		var angle = atan2(target_direction.x, target_direction.z) - atan2(current_direction.x, current_direction.z)
		if angle > PI:
			angle -= 2 * PI
		if angle < -PI:
			angle += 2 * PI

		var abs_angle = abs(angle)

		# Handle turning logic
		if abs_angle > turn_threshold and not is_turning:
			# Start turning
			is_turning = true
			velocity.x = 0  # Stop movement during turn
			velocity.z = 0
			if angle > 0:
				anim_player.play("turn_right", 0.2)
			else:
				anim_player.play("turn_left", 0.2)
		elif is_turning:
			# Keep velocity zero and rotate during the turn
			velocity.x = 0
			velocity.z = 0
			var rotation_step = clamp(rotation_speed * delta, 0, abs_angle) * sign(angle)
			rotate_y(rotation_step)
			
			# End turning when animation is near completion or enemy is aligned
			if anim_player.current_animation_position >= 0.9 or abs_angle <= facing_threshold:
				is_turning = false
		else:
			# Not turning, allow movement and align gradually
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
			var rotation_step = clamp(rotation_speed * delta, 0, abs_angle) * sign(angle)
			rotate_y(rotation_step)
			if abs_angle <= facing_threshold:
				# Fully facing target, proceed with movement
				if velocity.length() > 0:
					anim_player.play("run", 0.2)
				else:
					anim_player.play("idle", 0.2)

		# Punch when close to target
		if global_transform.origin.distance_to(target.global_transform.origin) < 0.75:
			anim_player.play("attack", 0.2)
			is_turning = false  # Reset turning state during attack
	else:
		velocity.x = 0
		velocity.z = 0
		anim_player.play("idle", 0.2)
		is_turning = false

	move_and_slide()

func die():
	anim_player.play("die")
	set_physics_process(false)
	await anim_player.animation_finished
	queue_free()
