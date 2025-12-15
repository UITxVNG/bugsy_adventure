extends Node2D

@onready var final_boss = $WarlordTurtle
@onready var celestial_core = $CelestialCore

var triggered := false

func _ready() -> void:
	print("\n=== MAP 10 READY ===")
	print("Artifacts: %d/7" % GameManager.artifacts_collected)
	
	if final_boss:
		final_boss.boss_defeated.connect(_on_final_boss_defeated)
		print("Connected to Final Boss")
	else:
		push_error("FinalBoss not found")

func _on_final_boss_defeated() -> void:
	if triggered:
		print("Already triggered, ignoring")
		return
	
	triggered = true
	
	await get_tree().create_timer(2.0).timeout
	
	_start_final_choice_scene()

func _start_final_choice_scene() -> void:
	
	GameManager.freeze_player()
	
	await get_tree().create_timer(0.5).timeout
	
	var has_enough = GameManager.artifacts_collected >= 7
	print("Has 7 artifacts: ", has_enough)
	
	var timeline_name = ""
	if has_enough:
		timeline_name = "final_choice_good"
	else:
		timeline_name = "final_choice_bad"
	
	print("Starting timeline: ", timeline_name)
	
	Dialogic.start(timeline_name)
	
	
	# ⭐ QUAN TRỌNG: Đợi signal
	await Dialogic.timeline_ended
	
	print("Timeline ended!")
	
	# Wait thêm một chút
	await get_tree().create_timer(1.0).timeout
	
	# Transition
	_transition_to_ending()

func _transition_to_ending() -> void:
	print("\n🏁 TRANSITIONING TO ENDING")
	
	# Calculate ending
	var ending = GameManager.calculate_final_ending()
	print("Calculated ending: ", ending.to_upper())
	
	# Debug info
	print("Final state:")
	print("- Artifacts: %d/7" % GameManager.artifacts_collected)
	print("- Choice made: ", GameManager.final_choice_made)
	print("- Refused: ", GameManager.refused_dark_voice)
	
	# Fade out
	print("🌑 Fading to black...")
	var fade = _create_fade_overlay()
	await fade.finished
	
	# Change scene
	print("🎬 Changing to scene: ", ending)
	
	match ending:
		"good_ending":
			var result = get_tree().change_scene_to_file("res://scenes/endings/good_ending.tscn")
			if result != OK:
				push_error("Failed to load good_ending.tscn: Error " + str(result))
		
		"bad_ending":
			var result = get_tree().change_scene_to_file("res://scenes/endings/bad_ending.tscn")
			if result != OK:
				push_error("Failed to load bad_ending.tscn: Error " + str(result))
		
		_:
			push_error("Invalid ending state: " + ending)

func _create_fade_overlay() -> Tween:
	var overlay = ColorRect.new()
	overlay.color = Color.BLACK
	overlay.color.a = 0.0
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	add_child(overlay)
	
	var tween = create_tween()
	tween.tween_property(overlay, "color:a", 1.0, 2.0)
	
	return tween
