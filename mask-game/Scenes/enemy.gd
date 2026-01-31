extends CharacterBody2D

@export var speed: float = 200.0
@export var idle_amplitude: float = 5.0
@export var idle_speed: float = 2.0

@onready var alive_sprite = $Sprite2D
@onready var death_sprite = $Death_Sprite
@onready var collider = $CollisionShape2D

var alive = true
var HP = 3
var player_in_left: bool = false
var player_in_right: bool = false
var idle_timer: float = 0.0

func _ready():
	alive = true
	death_sprite.visible = false
	alive_sprite.visible = true
	collider.disabled = false
	add_to_group("Enemy")
	print(name, "ready, alive?", alive)


func _physics_process(delta):
	var direction = Vector2.ZERO
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	if alive == false:
		collider.disabled = true
		velocity = Vector2.ZERO

	if alive:
		if player_in_left:
			direction.x = 1
		elif player_in_right:
			direction.x = -1
		else:
			idle_timer += delta
			direction.x = sin(idle_timer * idle_speed) * (idle_amplitude / speed)

	velocity.x = direction.x * speed
	move_and_slide()


func _on_right_fear_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_in_right = true

func _on_right_fear_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_in_right = false

func _on_left_fear_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_in_left = true

func _on_left_fear_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_in_left = false


func take_damage(amount: int) -> void:
	if alive == false:
		print(name, "is already dead")
		return

	HP -= amount
	print(name, "takes", amount, "damage, HP left:", HP)

	if HP <= 0:
		die()
	else:
		$AnimationPlayer.play("damage")
		$ColorRect.visible = true


func die() -> void:
	alive = false
	collider.disabled = true
	alive_sprite.visible = false
	death_sprite.visible = true
	print(name, "died")
