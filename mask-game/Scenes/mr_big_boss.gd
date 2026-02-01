extends CharacterBody2D

@export var speed: float = 200.0
@export var HP: int = 25

@export var bullet_scene: PackedScene
@export var shoot_offset: float = 16.0

# --- Roaming settings ---
@export var roam_change_time_min := 1.5
@export var roam_change_time_max := 3.5

@onready var alive_sprite: Sprite2D = $Sprite2D
@onready var death_sprite: Sprite2D = $Death_Sprite
@onready var collider: CollisionShape2D = $CollisionShape2D
@onready var shoot_timer: Timer = $ShootTimer

var alive: bool = true
var player_in_left: bool = false
var player_in_right: bool = false
var player_in_left_aim: bool = false
var player_in_right_aim: bool = false
var roam_direction := 1
var roam_timer := 0.0


func _ready():
	alive = true
	death_sprite.visible = false
	alive_sprite.visible = true
	collider.disabled = false
	add_to_group("Enemy")
	shoot_timer.stop()

	roam_timer = randf_range(roam_change_time_min, roam_change_time_max)
	roam_direction = [-1, 1].pick_random()

	print(name, "ready, alive?", alive)


func _physics_process(delta):
	var direction := Vector2.ZERO

	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	if not alive:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# Run away from player
	if player_in_left:
		direction.x = 1
	elif player_in_right:
		direction.x = -1
	else:
		# Roaming idle
		roam_timer -= delta
		if roam_timer <= 0.0:
			roam_timer = randf_range(roam_change_time_min, roam_change_time_max)
			roam_direction = [-1, 1].pick_random()

		direction.x = roam_direction

	velocity.x = direction.x * speed
	move_and_slide()


# --------------------
# Detection
# --------------------

# --------------------
# Shooting
# --------------------
func start_shooting():
	if alive and shoot_timer.is_stopped() and self.visible == true:
		shoot_timer.start()
		print("Time to shoot")

func stop_shooting_if_needed():
	if not player_in_left and not player_in_right:
		shoot_timer.stop()
		print("No more shoot")

func _on_shoot_timer_timeout():
	if not alive or bullet_scene == null:
		return

	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)

	print("Apua vittu")

	var dir := Vector2.ZERO
	if player_in_left_aim:
		dir = Vector2.LEFT
	elif player_in_right_aim:
		dir = Vector2.RIGHT
	else:
		return

	bullet.global_position = global_position + dir * shoot_offset
	bullet.direction = dir


# --------------------
# Damage & Death
# --------------------
func take_damage(amount: int):
	if not alive:
		return

	HP -= amount
	print(name, "takes", amount, "damage, HP left:", HP)

	if HP <= 0:
		die()
	else:
		$AnimationPlayer.play("damage")
		$ColorRect.visible = true


func die():
	alive = false
	shoot_timer.stop()
	collider.disabled = true
	alive_sprite.visible = false
	death_sprite.visible = true
	print(name, "died")


func _on_left_aim_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		start_shooting()
		player_in_left_aim = true

func _on_right_aim_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		start_shooting()
		player_in_right_aim = true

func _on_left_aim_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		stop_shooting_if_needed()
		player_in_left_aim = false

func _on_right_aim_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		stop_shooting_if_needed()
		player_in_right_aim = false
