extends Node2D
@onready var DeathScreen = $CanvasLayer/DeathScreen

@onready var DeathLabel = $CanvasLayer/Label

var enemies
var player
var can_proceed = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = find_child("Player")
	Global.current_level = 2
	enemies = get_tree().get_nodes_in_group("Enemy")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player == null:
		DeathLabel.visible = true
		DeathScreen.visible = true
	Input.MOUSE_MODE_VISIBLE
	if get_tree().get_nodes_in_group("Enemy").size() == 0:
		can_proceed = true
func _on_restart_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_2.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()




func _on_level_2_pass_body_entered(body: Node2D) -> void:
	print("Skibidi")
	if can_proceed == true:
		print("Juu")
		get_tree().change_scene_to_file("res://Scenes/main_3.tscn")
