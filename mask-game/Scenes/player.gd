extends CharacterBody2D



const SPEED = 600.0
const JUMP_VELOCITY = -400.0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	
	var direction := Input.get_axis("walk_left", "walk_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if direction >0:
		$ClawHurtBox.position = $ClawRight.position
		$Sprite2D.flip_h = false
	elif direction <0:
		$Sprite2D.flip_h = true
		$ClawHurtBox.position = $ClawLeft.position

	move_and_slide()
