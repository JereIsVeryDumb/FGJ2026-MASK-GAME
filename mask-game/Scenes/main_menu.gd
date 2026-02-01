extends Control

@onready var start = $VBoxContainer/StartButton
@onready var options_button = $VBoxContainer/OptionsButton
@onready var credits_button = $VBoxContainer/Credits
@onready var quit_button = $VBoxContainer/QuitButton




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_button_button_down() -> void:
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
	




func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/credits.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
