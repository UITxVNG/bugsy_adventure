extends CanvasLayer

## Death Scene - Hiển thị khi player chết
## Có 2 nút: "Play Again" và "Back to Level Select"

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	# Pause game khi death scene hiển thị
	get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Play animation fade in
	if animation_player:
		animation_player.play("fade_in")


func _on_play_again_button_pressed() -> void:
	get_tree().paused = false
	# Respawn player at latest checkpoint
	GameManager.player_died()


func _on_level_select_button_pressed() -> void:
	get_tree().paused = false
	# Clear Dialogic state before scene change
	_stop_dialogic_safely()
	# Go back to level select screen
	get_tree().change_scene_to_file("res://scenes/levels/chose_level/chose_level.tscn")


func _stop_dialogic_safely() -> void:
	if Dialogic.current_timeline != null:
		Dialogic.end_timeline(true)
	if Dialogic.has_subsystem("Portraits") and Dialogic.is_inside_tree():
		Dialogic.Portraits.clear_game_state()
