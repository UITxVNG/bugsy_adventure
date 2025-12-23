extends Control

@onready var story_label = $CenterContainer/StoryLabel
@onready var background = $ParallaxBackground
@onready var parallax_layer = $ParallaxBackground/ParallaxLayer
@onready var sprite = $ParallaxBackground/ParallaxLayer/Sprite2D

var skip_hint: Panel = null
var vignette: ColorRect = null
var particles: CPUParticles2D = null

var story_lines := [
	"Foxy đã đưa ra lựa chọn cuối cùng —",
	"bằng tất cả lòng dũng cảm và sự hy sinh...",
	"",
	"Lõi Năng Lượng Thiên Thể tan vỡ.",
	"",
	"Một luồng ánh sáng rực rỡ bùng lên,",
	"xé toạc màn đêm u tối...",
	"",
	"Bóng tối bị xóa bỏ,",
	"vĩnh viễn không bao giờ quay trở lại.",
	"",
	"Lời nguyền cổ xưa được giải phóng.",
	"",
	"Hòn đảo Aetheria khẽ rung mình,",
	"bắt đầu hồi sinh sau giấc ngủ dài...",
	"",
	"Những linh hồn lạc lối",
	"cuối cùng cũng được tự do.",
	"",
	"Dân đảo tỉnh dậy,",
	"thoát khỏi cơn ác mộng kéo dài bấy lâu.",
	"",
	"Vài ngày sau...",
	"",
	"Foxy đứng lặng trên chiếc thuyền nhỏ,",
	"giữa đại dương bao la...",
	"",
	"Ánh mắt nhìn về hòn đảo",
	"đang dần khuất sau làn sương mờ.",
	"",
	"Mush và Crabbo mỉm cười,",
	"vẫy tay tiễn biệt người bạn của mình.",
	"",
	"Foxy không còn nhớ về quá khứ...",
	"",
	"Nhưng trái tim cậu,",
	"lần đầu tiên thuộc về chính mình.",
	"",
	"",
	"Phía trước là biển cả vô tận,",
	"và những chân trời chưa từng được đặt chân tới...",
	"",
	"Vô vàn bí ẩn đang chờ đợi,",
	"những câu chuyện chưa được kể...",
	"",
	"Sứ mệnh phiêu lưu và khám phá,",
	"vẫn chưa bao giờ kết thúc.",
	"",
	"Kho báu lớn nhất...",
	"chính là một trái tim tự do.",
]

var current_line := 0
var typing_speed := 0.05
var line_pause := 1.5
var is_typing := false
var story_ended := false
var can_skip := true

func _ready() -> void:
	_setup_background_effects()
	_setup_story_label()
	_setup_skip_hint()
	_setup_vignette()
	_add_sparkle_particles()
	_animate_parallax()
	
	# Fade in toàn bộ
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 2.5).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	
	await get_tree().create_timer(1.0).timeout
	_play_story()

func _setup_background_effects() -> void:
	var overlay = ColorRect.new()
	overlay.name = "GradientOverlay"
	add_child(overlay)
	move_child(overlay, 0)  # Đặt sau background
	
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Gradient từ trong suốt ở trên xuống đen mờ ở dưới
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(0, 0, 0, 0))
	gradient.add_point(0.6, Color(0, 0, 0, 0.3))
	gradient.add_point(1.0, Color(0, 0, 0, 0.7))
	
	var gradient_texture = GradientTexture2D.new()
	gradient_texture.gradient = gradient
	gradient_texture.fill_from = Vector2(0, 0)
	gradient_texture.fill_to = Vector2(0, 1)
	
	# Apply texture (nếu ColorRect support)
	overlay.color = Color(0, 0, 0, 0.3)

func _setup_story_label() -> void:
	"""Tạo text đẹp với shadow và glow"""
	story_label.add_theme_font_size_override("font_size", 42)
	story_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.95))
	
	# Shadow mạnh hơn
	story_label.add_theme_constant_override("shadow_offset_x", 3)
	story_label.add_theme_constant_override("shadow_offset_y", 3)
	story_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	
	# Outline
	story_label.add_theme_constant_override("outline_size", 8)
	story_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.6))
	
	story_label.text = ""
	story_label.modulate.a = 0.0

func _setup_skip_hint() -> void:
	"""Tạo hint box đẹp với panel style"""
	skip_hint = Panel.new()
	add_child(skip_hint)
	
	# Style panel
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.7)
	style.border_color = Color(1, 0.8, 0.3, 0.8)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 15
	style.content_margin_right = 15
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	
	skip_hint.add_theme_stylebox_override("panel", style)
	
	# Label bên trong
	var label = Label.new()
	label.text = "⚡ SPACE - Tăng tốc  |  ⏭ ESC - Bỏ qua"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color(1, 0.9, 0.6))
	skip_hint.add_child(label)
	
	# Position
	skip_hint.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	skip_hint.offset_left = -380
	skip_hint.offset_top = -60
	skip_hint.offset_right = -20
	skip_hint.offset_bottom = -20
	
	_blink_skip_hint()

func _setup_vignette() -> void:
	"""Thêm vignette effect ở viền màn hình"""
	vignette = ColorRect.new()
	vignette.name = "Vignette"
	add_child(vignette)
	
	vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Gradient radial từ giữa ra ngoài
	vignette.color = Color(0, 0, 0, 0)
	
	# Tạo vignette bằng gradient texture
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(0, 0, 0, 0))
	gradient.add_point(0.7, Color(0, 0, 0, 0))
	gradient.add_point(1.0, Color(0, 0, 0, 0.6))
	
	var gradient_texture = GradientTexture2D.new()
	gradient_texture.gradient = gradient
	gradient_texture.fill_from = Vector2(0.5, 0.5)
	gradient_texture.fill_to = Vector2(0.5, 0)
	gradient_texture.fill = GradientTexture2D.FILL_RADIAL

func _add_sparkle_particles() -> void:
	"""Thêm hạt sáng lấp lánh"""
	particles = CPUParticles2D.new()
	particles.name = "Sparkles"
	add_child(particles)
	
	particles.position = Vector2(get_viewport_rect().size.x / 2, 0)
	particles.amount = 30
	particles.lifetime = 8.0
	particles.preprocess = 2.0
	
	# Emission - Rectangle shape
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	particles.emission_rect_extents = Vector2(get_viewport_rect().size.x / 2, 10)
	
	# Movement
	particles.direction = Vector2(0, 1)
	particles.spread = 5
	particles.gravity = Vector2(0, 20)
	particles.initial_velocity_min = 50
	particles.initial_velocity_max = 100
	
	# Appearance
	particles.scale_amount_min = 1.0
	particles.scale_amount_max = 3.0
	particles.color = Color(1, 1, 0.8, 0.6)
	
	particles.emitting = true

func _animate_parallax() -> void:
	"""Tạo chuyển động nhẹ cho parallax background"""
	if not parallax_layer:
		return
	
	var tween = create_tween()
	tween.set_loops()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	# Di chuyển nhẹ theo chiều ngang
	tween.tween_property(parallax_layer, "motion_offset:x", 50, 8.0)
	tween.tween_property(parallax_layer, "motion_offset:x", -50, 8.0)

func _blink_skip_hint() -> void:
	if skip_hint:
		var blink = create_tween()
		blink.set_loops()
		blink.set_trans(Tween.TRANS_SINE)
		blink.tween_property(skip_hint, "modulate:a", 0.5, 1.5)
		blink.tween_property(skip_hint, "modulate:a", 1.0, 1.5)

func _play_story() -> void:
	"""Chạy câu chuyện với hiệu ứng fade in/out"""
	# Fade in story label
	var fade_in = create_tween()
	fade_in.tween_property(story_label, "modulate:a", 1.0, 1.0)
	await fade_in.finished
	
	while current_line < story_lines.size() and can_skip:
		is_typing = true
		var line = story_lines[current_line]
		
		# Fade out dòng cũ
		if story_label.text != "":
			var fade_out = create_tween()
			fade_out.tween_property(story_label, "modulate:a", 0.0, 0.3)
			await fade_out.finished
		
		story_label.text = ""
		story_label.modulate.a = 1.0
		
		# Type text
		for char in line:
			if not can_skip:
				break
			story_label.text += char
			await get_tree().create_timer(typing_speed).timeout
		
		is_typing = false
		await get_tree().create_timer(line_pause).timeout
		
		current_line += 1
	
	story_ended = true
	_show_continue_prompt()

func _show_continue_prompt() -> void:
	if skip_hint:
		var fade = create_tween()
		fade.tween_property(skip_hint, "modulate:a", 0.0, 0.5)
		await fade.finished
		skip_hint.hide()
	
	await get_tree().create_timer(2.0).timeout
	
	# Tạo panel đẹp cho prompt
	var prompt_panel = Panel.new()
	add_child(prompt_panel)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.8)
	style.border_color = Color(1, 0.84, 0, 1)
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_width_top = 3
	style.border_width_bottom = 3
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	
	prompt_panel.add_theme_stylebox_override("panel", style)
	prompt_panel.set_anchors_preset(Control.PRESET_CENTER)
	prompt_panel.custom_minimum_size = Vector2(500, 80)
	prompt_panel.offset_left = -250
	prompt_panel.offset_right = 250
	prompt_panel.offset_top = -40
	prompt_panel.offset_bottom = 40
	
	var prompt = Label.new()
	prompt.text = "✨ Nhấn phím bất kỳ để tiếp tục ✨"
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	prompt.add_theme_font_size_override("font_size", 28)
	prompt.add_theme_color_override("font_color", Color(1, 0.9, 0.4))
	prompt_panel.add_child(prompt)
	
	prompt.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	# Blink animation
	var blink = create_tween()
	blink.set_loops()
	blink.tween_property(prompt_panel, "modulate:a", 0.5, 0.8)
	blink.tween_property(prompt_panel, "modulate:a", 1.0, 0.8)

func _input(event: InputEvent) -> void:
	if not event.is_pressed():
		return
	
	if story_ended:
		_fade_out_and_return()
		return
	
	if event.is_action("ui_accept") or event.is_action("ui_select"):
		typing_speed = 0.01
		line_pause = 0.3
	
	elif event.is_action("ui_cancel"):
		_skip_all()

func _skip_all() -> void:
	can_skip = false
	current_line = story_lines.size()
	
	story_label.text = "\n".join(story_lines)
	story_label.modulate.a = 1.0
	
	story_ended = true
	_show_continue_prompt()

func _fade_out_and_return() -> void:
	var fade = create_tween()
	fade.tween_property(self, "modulate:a", 0.0, 1.5)
	await fade.finished
	get_tree().change_scene_to_file("res://scenes/screens/main_menu/main_menu.tscn")
