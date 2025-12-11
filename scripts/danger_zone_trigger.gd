extends Area2D

## Khu vực trigger để kích hoạt nước dâng khi player bước vào

@export var rising_water_path: NodePath  # Path tới node RisingWater
@export var warning_texture: Texture2D  # Texture cảnh báo
@export var warning_duration: float = 2.0  # Thời gian hiển thị warning

var has_triggered: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if has_triggered:
		return
	
	if body.is_in_group("player"):
		has_triggered = true
		
		# Hiển thị warning popup
		_show_warning_popup()
		
		# Kích hoạt nước dâng
		var rising_water = get_node_or_null(rising_water_path)
		if rising_water and rising_water.has_method("start_rising"):
			rising_water.start_rising()
			print("Danger zone triggered! Water is rising...")

func _show_warning_popup() -> void:
	if warning_texture == null:
		return
	
	# Tạo CanvasLayer để warning luôn hiển thị trên UI
	var canvas = CanvasLayer.new()
	canvas.layer = 100
	get_tree().current_scene.add_child(canvas)
	
	# Tạo TextureRect để hiển thị warning
	var warning_sprite = TextureRect.new()
	warning_sprite.texture = warning_texture
	warning_sprite.anchor_left = 0.5
	warning_sprite.anchor_right = 0.5
	warning_sprite.anchor_top = 0.3
	warning_sprite.anchor_bottom = 0.3
	warning_sprite.grow_horizontal = Control.GROW_DIRECTION_BOTH
	warning_sprite.grow_vertical = Control.GROW_DIRECTION_BOTH
	warning_sprite.modulate.a = 0.0
	canvas.add_child(warning_sprite)
	
	# Animation fade in -> hold -> fade out
	var tween = create_tween()
	tween.tween_property(warning_sprite, "modulate:a", 1.0, 0.3)
	tween.tween_interval(warning_duration)
	tween.tween_property(warning_sprite, "modulate:a", 0.0, 0.5)
	tween.tween_callback(canvas.queue_free)
