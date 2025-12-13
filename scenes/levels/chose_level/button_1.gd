extends TextureButton

@onready var label = $Label
@onready var locked_overlay = $LockedOverlay
@onready var completed_icon = $CompletedIcon

var level_number: int = 0

func _ready():
	pressed.connect(_on_pressed)

func setup_level(p_level_number: int, status: String):
	level_number = p_level_number
	label.text = str(level_number)
	
	match status:
		"LOCKED":
			locked_overlay.visible = true
			completed_icon.visible = false
			disabled = true
			
		"UNLOCKED":
			locked_overlay.visible = false
			completed_icon.visible = true
			disabled = false
			
		"CURRENT":
			locked_overlay.visible = false
			completed_icon.visible = true
			disabled = false

func _on_pressed():
	if level_number > 0:
		var scene_path = "res://scenes/levels/level_%d/stage_%d.tscn" % [level_number, level_number]
		get_tree().change_scene_to_file(scene_path)
