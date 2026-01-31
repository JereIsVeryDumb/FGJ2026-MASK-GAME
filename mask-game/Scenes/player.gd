extends CharacterBody2D

const SPEED = 600.0
const JUMP_VELOCITY = -400.0

# Track enemies in attack range
var enemies_in_attack_range: Array = []

# Track enemies inside pickup detector (alive or dead)
var enemies_in_pickup_area: Array = []

func _physics_process(delta: float) -> void:
	# --- Gravity ---
	if not is_on_floor():
		velocity += get_gravity() * delta

	# --- Quit ---
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

	# --- Jump ---
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# --- Movement ---
	var direction := Input.get_axis("walk_left", "walk_right")
	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# --- Facing ---
	if direction > 0:
		$ClawHurtBox.position = $ClawPositionRight.position
		$Sprite2D.flip_h = false
	elif direction < 0:
		$ClawHurtBox.position = $ClawPositionLeft.position
		$Sprite2D.flip_h = true

	# --- Attack ---
	if Input.is_action_just_pressed("claw"):
		for enemy in enemies_in_attack_range:
			if enemy and enemy.alive:
				enemy.take_damage(1)
				print("Attacked enemy:", enemy.name)

	# --- Pickup dead enemies ---
	if Input.is_action_just_pressed("pickup"):
		print("Pickup action pressed")
		
		# Only consider dead enemies currently inside the pickup detector
		var dead_in_range = enemies_in_pickup_area.filter(func(e): return not e.alive)
		print("Dead enemies in range:", dead_in_range.size())
		for e in dead_in_range:
			print(" - In range:", e.name)

		if dead_in_range.size() > 0:
			pick_up_enemy(dead_in_range[0])

	# --- Move the player ---
	move_and_slide()


# --- Pickup function ---
func pick_up_enemy(enemy):
	print("Picked up enemy:", enemy.name)
	enemies_in_pickup_area.erase(enemy)
	enemy.queue_free()


# --- Claw hurtbox signals ---
func _on_claw_hurt_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		enemies_in_attack_range.append(body)
		print("Enemy entered attack range:", body.name)

func _on_claw_hurt_box_body_exited(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		enemies_in_attack_range.erase(body)
		print("Enemy exited attack range:", body.name)


# --- Pickup detector signals ---
func _on_pickup_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy") and not enemies_in_pickup_area.has(body):
		enemies_in_pickup_area.append(body)
		print("Pickup detector entered by:", body.name, "alive?", body.alive)

func _on_pickup_detector_body_exited(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		# Only remove from array if the enemy is still alive
		if body.alive and enemies_in_pickup_area.has(body):
			enemies_in_pickup_area.erase(body)
			print("Pickup detector exited by:", body.name)
