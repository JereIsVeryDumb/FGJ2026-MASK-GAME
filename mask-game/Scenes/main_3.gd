extends Node2D
@onready var DeathScreen = $CanvasLayer/DeathScreen

@onready var DeathLabel = $CanvasLayer/Label
var enemies
var player
var can_proceed = false
var spawned = false
var can_spawn = false

var dead = false
@onready var spawnpoint = $Spawnpoint
@onready var big_boss = $"Mr Big Boss"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = find_child("Player")
	Global.current_level = 3
	enemies = get_tree().get_nodes_in_group("Enemy")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player == null:
		DeathLabel.visible = true
		DeathScreen.visible = true
	
	if big_boss == null:
		dead = true
	
	if spawned == false and can_spawn:
		spawned = true
		print("Spawned in")
		big_boss.visible = true
	Input.MOUSE_MODE_VISIBLE
	if get_tree().get_nodes_in_group("Enemy").size() == 1:
		print("Can Spawn")
		can_spawn = true
		dead = false
	if spawned == true and dead == false:
		big_boss.position = spawnpoint.position
		
	if dead == true:
		get_tree().change_scene_to_file("res://Scenes/credits.tscn")
func _on_restart_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_3.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
