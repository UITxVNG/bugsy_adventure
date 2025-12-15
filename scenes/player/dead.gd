extends PlayerState

const DEATH_SCENE = preload("res://scenes/screens/death_scene/death_scene.tscn")

func _enter():
	#change animation to dead
	obj.is_dead = true
	obj.change_animation("dead")
	obj.velocity.x = 0
	timer = 1.5  # Thời gian chờ trước khi hiện death scene

func _update(delta: float):
	if update_timer(delta):
		_show_death_scene()

func _show_death_scene():
	# Tạo và thêm death scene vào scene tree
	var death_scene = DEATH_SCENE.instantiate()
	obj.get_tree().current_scene.add_child(death_scene)
