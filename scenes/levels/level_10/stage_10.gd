extends Node2D

@onready var final_boss = $WarlordTurtle
@onready var celestial_core = $CelestialCore

var triggered := false

func _ready() -> void:
	if final_boss:
		final_boss.boss_defeated.connect(_on_final_boss_defeated)
		print("✅ Connected to Final Boss")
	else:
		push_error("❌ FinalBoss not found")


func _on_final_boss_defeated() -> void:
	if triggered:
		return

	triggered = true
	print("🏆 Boss defeated → start final timeline")

	_start_final_choice_scene()

func _start_final_choice_scene() -> void:
	GameManager.freeze_player()

	await get_tree().create_timer(1.0).timeout
	Dialogic.start("final_choice")

	await Dialogic.timeline_ended
	_transition_to_ending()

func _transition_to_ending():
	var ending = GameManager.calculate_final_ending()
	print("ENDING:", ending)

	match ending:
		"good_ending":
			get_tree().change_scene_to_file("res://scenes/endings/good_ending.tscn")
		"bad_ending":
			get_tree().change_scene_to_file("res://scenes/endings/bad_ending.tscn")
