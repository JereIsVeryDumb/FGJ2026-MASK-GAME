extends CharacterBody2D

@export var speed: float = 400.0
@export var idle_amplitude: float = 5.0   # Max idle sway in pixels
@export var idle_speed: float = 2.0       # Speed of idle sway
var HP = 3

# Track if player is in left or right fear zone
var player_in_left: bool = false
var player_in_right: bool = false

# Idle movement timer
var idle_timer: float = 0.0

func _ready():
	pass

func _physics_process(delta):
	var direction = Vector2.ZERO
	
	# Apply gravity if not on floor
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Determine horizontal movement
	if player_in_left:
		direction.x = 1   # Player is on the left, move right
	elif player_in_right:
		direction.x = -1  # Player is on the right
	else:
		# Idle movement: smooth side-to-side sway
		idle_timer += delta
		direction.x = sin(idle_timer * idle_speed) * (idle_amplitude / speed)

	# Apply horizontal movement
	velocity.x = direction.x * speed

	# Move the enemy
	move_and_slide()

# ---- Fear zone signals ----
func _on_right_fear_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_in_right = true
		print("Player entered right fear zone")

func _on_right_fear_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_in_right = false
		print("Player left right fear zone")

func _on_left_fear_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_in_left = true
		print("Player entered left fear zone")

func _on_left_fear_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_in_left = false
		print("Player left left fear zone")
