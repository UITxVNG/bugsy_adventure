extends Node2D


@export_file("*.tscn") var target_stage = ""

@export var target_door = "Door"

# Set this to the level number this door belongs to (e.g., 1 for stage_1)
@export var current_level: int = 0


func load_next_stage():
	# Unlock next level if current_level is set
	if current_level > 0:
		SaveSystem.unlock_next_level(current_level)
	
	# load next stage with target door name
	GameManager.change_stage(target_stage, target_door)


func _on_interactive_area_2d_interacted() -> void:
	load_next_stage()
