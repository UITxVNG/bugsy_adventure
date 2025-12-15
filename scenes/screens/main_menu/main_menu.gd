extends CanvasLayer

func _ready() -> void:
	# Ensure game is not paused when main menu loads
	get_tree().paused = false

func _on_play_button_pressed() -> void:
	# Switch to the level select screen
	get_tree().change_scene_to_file("res://scenes/levels/chose_level/chose_level.tscn")

const SETTINGS_POPUP = preload("res://scenes/screens/game_screen/settings_popup.tscn")

func _on_settings_button_pressed() -> void:
	print("Settings button pressed")
	var popup = SETTINGS_POPUP.instantiate()
	add_child(popup)
