extends MarginContainer

@onready var music_check_button: CheckButton = $NinePatchRect/MusicCheckButton
@onready var sound_check_button: CheckButton = $NinePatchRect/SoundCheckButton

func _ready():
	music_check_button.button_pressed = not AudioServer.is_bus_mute(AudioServer.get_bus_index("Music"))
	sound_check_button.button_pressed = not AudioServer.is_bus_mute(AudioServer.get_bus_index("SFX"))
	get_tree().paused = true

func _exit_tree() -> void:
	get_tree().paused = false

func _on_music_check_button_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), not toggled_on)

func _on_sound_check_button_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), not toggled_on)

func hide_popup():
	queue_free()
		
func _on_overlay_color_rect_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		hide_popup() # Replace with function body.


func _on_close_texture_button_pressed() -> void:
	hide_popup()

func _on_choose_level_button_pressed() -> void:
	# Unpause the game before changing scene
	get_tree().paused = false
	# Clear Dialogic state before scene change
	if Dialogic.current_timeline != null:
		Dialogic.end_timeline(true)
	if Dialogic.has_subsystem("Portraits") and Dialogic.is_inside_tree():
		Dialogic.Portraits.clear_game_state()
	# Change to level selection screen
	get_tree().change_scene_to_file("res://scenes/levels/chose_level/chose_level.tscn")
