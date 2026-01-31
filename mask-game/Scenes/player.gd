extends CharacterBody2D

const SPEED = 600.0
const JUMP_VELOCITY = -400.0

# --- Dash settings ---
const DASH_DISTANCE = 600.0
const DASH_COOLDOWN = 1.0

# --- Sprite blend settings ---
const SPRITE_BLEND_SPEED = 10.0

var can_dash := true
var is_dashing := false
var dash_timer := 0.0

var max_hp = 3
var hp = 0
var damage = 1
var can_block = true
var blocking = false
var block_cooldown = 3.5
var blocking_time = 1.0

var local_mask_count = 0

# Track enemies
var enemies_in_attack_range: Array = []
var enemies_in_pickup_area: Array = []

func _ready():
	$IdleSprite.modulate.a = 1.0
	$WalkingSprite.modulate.a = 0.0
	hp = max_hp

func _physics_process(delta: float) -> void:
	# --- Gravity ---
	if not is_on_floor():
		velocity += get_gravity() * delta
	if local_mask_count >= Global.mask_count:
		Global.mask_count = local_mask_count
		
	if Global.mask_count >= local_mask_count:
		local_mask_count = Global.mask_count
	# --- Quit ---
	print(str(Global.mask_count))
	print(str(local_mask_count))
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	
	for i in range(1, Global.mask_count + 1):
		var mask_name = "Mask" + str(i)
		var mask_node = $Masks.get_node_or_null(mask_name)
		if mask_node:
			mask_node.visible = true
	
	# --- Jump ---
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# --- Dash cooldown ---
	if not can_dash:
		dash_timer -= delta
		if dash_timer <= 0.0:
			can_dash = true

	# --- Input ---
	var direction := Input.get_axis("walk_left", "walk_right")

	# --- Movement ---
	if not is_dashing:
		if direction != 0:
			velocity.x = direction * SPEED
		else:
			if can_dash:
				velocity.x = move_toward(velocity.x, 0, SPEED)

	# --- Facing ---
	if direction > 0:
		$ClawHurtBox.position = $ClawPositionRight.position
		$IdleSprite.flip_h = false
		$WalkingSprite.flip_h = false
	elif direction < 0:
		$ClawHurtBox.position = $ClawPositionLeft.position
		$IdleSprite.flip_h = true
		$WalkingSprite.flip_h = true

	# --- Sprite blending ---
	var walking_target_alpha := 1.0 if direction != 0 else 0.0
	var idle_target_alpha := 1.0 - walking_target_alpha

	$WalkingSprite.modulate.a = lerp(
		$WalkingSprite.modulate.a,
		walking_target_alpha,
		SPRITE_BLEND_SPEED * delta
	)

	$IdleSprite.modulate.a = lerp(
		$IdleSprite.modulate.a,
		idle_target_alpha,
		SPRITE_BLEND_SPEED * delta
	)

	# --- Dash ---
	if Input.is_action_just_pressed("dash") and can_dash and local_mask_count >= 1:
		dash()

	# --- Attack ---
	if Input.is_action_just_pressed("claw"):
		for enemy in enemies_in_attack_range:
			if enemy and enemy.alive:
				enemy.take_damage(damage)
				print("Attacked enemy:", enemy.name)

	# --- Pickup ---
	if Input.is_action_just_pressed("pickup"):
		var dead_in_range = enemies_in_pickup_area.filter(
			func(e): return not e.alive
		)

		if dead_in_range.size() > 0:
			pick_up_enemy(dead_in_range[0])

	# --- Block ---
	if Input.is_action_just_pressed("block") and local_mask_count >= 2 and can_block:
		block()

	# --- Block update ---
	if blocking == true:
		blocking_time -= delta
		Global.enemy_damage = 0

		if blocking_time <= 0.0:
			blocking = false
			$BlockSprite.visible = false
			Global.enemy_damage = 1

	if not can_block:
		block_cooldown -= delta
		if block_cooldown <= 0.0:
			can_block = true
			print("canblock")

	# --- Move ---
	move_and_slide()

	die()

# --------------------
# BLOCK
# --------------------
func block():
	if blocking == true:
		Global.enemy_damage = 0

	blocking = true
	blocking_time = 1.0        # RESET
	block_cooldown = 3.5       # RESET
	can_block = false
	$BlockSprite.visible = true
	print("blocking")

# --------------------
# DASH
# --------------------
func dash():
	can_dash = false
	is_dashing = true
	dash_timer = DASH_COOLDOWN

	var warp_direction = -1 if $IdleSprite.flip_h else 1
	var warp_offset = Vector2(warp_direction * DASH_DISTANCE, 0)

	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(
		global_position,
		global_position + warp_offset
	)

	var result = space_state.intersect_ray(query)

	if result:
		global_position = result.position - warp_offset.normalized() * 4
	else:
		global_position += warp_offset

	velocity.x = 0
	is_dashing = false

# --------------------
# DAMAGE
# --------------------
func take_damage():
	if blocking:
		return
	hp -= Global.enemy_damage
	print("Ai vittu")
	print(str(hp))

func die():
	if hp <= 0:
		queue_free()
		local_mask_count = Global.max_starting_masks
		Global.mask_count = Global.max_starting_masks

# --------------------
# PICKUP
# --------------------
func pick_up_enemy(enemy):
	enemies_in_pickup_area.erase(enemy)
	enemy.queue_free()
	if local_mask_count < Global.max_masks:
		local_mask_count += 1
		damage += 1

# --------------------
# SIGNALS
# --------------------
func _on_claw_hurt_box_body_entered(body):
	if body.is_in_group("Enemy"):
		enemies_in_attack_range.append(body)

func _on_claw_hurt_box_body_exited(body):
	if body.is_in_group("Enemy"):
		enemies_in_attack_range.erase(body)

func _on_pickup_detector_body_entered(body):
	if body.is_in_group("Enemy") and not enemies_in_pickup_area.has(body):
		enemies_in_pickup_area.append(body)

func _on_pickup_detector_body_exited(body):
	if body.is_in_group("Enemy") and body.alive:
		enemies_in_pickup_area.erase(body)
