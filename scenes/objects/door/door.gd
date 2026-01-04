extends Node2D


@export_file("*.tscn") var target_stage = ""

@export var target_door = "Door"

# Set this to the level number this door belongs to (e.g., 1 for stage_1)
@export var current_level: int = 0

# Checkpoint functionality
@export var is_checkpoint: bool = true
@export var checkpoint_id: String = ""

var checkpoint_activated: bool = false


func _ready() -> void:
	if checkpoint_id.is_empty():
		checkpoint_id = "door_" + str(get_path())
	
	# Check if this checkpoint was already activated
	if is_checkpoint and GameManager.current_checkpoint_id == checkpoint_id:
		checkpoint_activated = true


func _on_area_2d_body_entered(body: Node2D) -> void:
	# Save checkpoint when player enters door area
	if is_checkpoint and body is Player and not checkpoint_activated:
		checkpoint_activated = true
		GameManager.save_checkpoint(checkpoint_id)
		GameManager.save_checkpoint_data()
		print("Door checkpoint activated: ", checkpoint_id)


func load_next_stage():
	# Unlock next level if current_level is set
	if current_level > 0:
		SaveSystem.unlock_next_level(current_level)
	
	# load next stage with target door name
	GameManager.change_stage(target_stage, target_door)


func _on_interactive_area_2d_interacted() -> void:
	load_next_stage()
