extends Area2D

@export var speed := 400
var direction := Vector2.ZERO

func _physics_process(delta):
	position += direction * speed * delta




func _on_body_entered(body: Node2D) -> void:
	if body.name == "Enemy":
		body.take_damage()
	queue_free()
