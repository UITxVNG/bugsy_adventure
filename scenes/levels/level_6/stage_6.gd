extends Node2D
@onready var king_crab = $KingCrab
@onready var manual_platform = $ManualMovingPlatform

func _ready() -> void:
	# Check if boss was already killed (stored in story flags)
	if GameManager.story_flags.get("king_crab_defeated", false):
		_hide_platform()
		if king_crab:
			king_crab.queue_free()
	else:
		# Connect to boss death signal
		if king_crab:
			king_crab.enemy_defeated.connect(_on_king_crab_defeated)

func _on_king_crab_defeated() -> void:
	# Save boss defeated state
	GameManager.story_flags["king_crab_defeated"] = true
	_hide_platform()

func _hide_platform() -> void:
	if manual_platform:
		manual_platform.queue_free()
