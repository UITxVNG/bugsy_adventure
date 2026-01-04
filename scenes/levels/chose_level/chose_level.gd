extends MarginContainer
@onready var grid_container = $TextureRect/GridContainer

var current_max_level = 10

func _ready():
	# Ensure game is not paused when entering level select
	get_tree().paused = false
	
	# Load saved progress from SaveSystem
	current_max_level = SaveSystem.load_max_level()
	
	var buttons = grid_container.get_children()
	
	for i in range(buttons.size()):
		var btn = buttons[i]
		var level_num = i + 1
		
		if level_num < current_max_level:
			btn.setup_level(level_num, "UNLOCKED")
		elif level_num == current_max_level:
			btn.setup_level(level_num, "CURRENT")
		else:
			btn.setup_level(level_num, "LOCKED")
