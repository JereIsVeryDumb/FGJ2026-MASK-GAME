extends Node



var enemy_damage = 1
var mask_count = 0
var max_masks = 2
var current_level = 0
var max_starting_masks = 0

func _physics_process(delta: float) -> void:
	if current_level == 1:
		max_masks = 1
		max_starting_masks = 0
	if current_level == 2:
		max_masks = 2
		max_starting_masks = 1
	if current_level == 3:
		max_masks = 3
		max_starting_masks = 2
	print(str("Max starting masks" + str(max_starting_masks)))
