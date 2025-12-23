extends Control

@onready var story_label = $CenterContainer/StoryLabel
@onready var background = $ParallaxBackground
@onready var parallax_layer = $ParallaxBackground/ParallaxLayer
@onready var sprite = $ParallaxBackground/ParallaxLayer/Sprite2D

var skip_hint: Panel = null
var vignette: ColorRect = null
var glitch_timer: Timer = null
var screen_shake_intensity := 0.0

var story_lines := [
	"Foxy đã không đủ mạnh...",
	"",
	"Hoặc tệ hơn...",
	"Không đủ dũng cảm để chống lại chính mình...",
	"",
	"",
	"Dark Voice chiến thắng.",
	"",
	"Bóng tối tràn ngập linh hồn Foxy...",
	"",
	"Đôi mắt từng phản chiếu ánh sáng...",
	"",
	"Giờ chỉ còn lại sắc đỏ thẫm của hủy diệt...",
	"",
	'"HA... HA... HA...!"',
	"",
	"Foxy và Dark Voice...",
	"Không còn ranh giới.",
	"Chỉ còn một thực thể duy nhất.",
	"",
	"",
	"Sức mạnh kinh hoàng bùng nổ...",
	"",
	"Mặt đất nứt vỡ.",
	"",
	"Cây cối cháy rụi thành tro tàn...",
	"",
	"Đại dương gào thét, sôi sục...",
	"",
	"Bầu trời rạn nứt như tấm gương vỡ.",
	"",
	"",
	"Hòn đảo Aetheria bước vào diệt vong.",
	"",
	"Những linh hồn kêu gào trong tuyệt vọng...",
	"",
	"Nhưng không ai có thể ngăn cản định mệnh.",
	"",
	"",
	"Từ nơi xa...",
	"",
	"Mush và Crabbo chỉ có thể đứng nhìn.",
	"",
	"Ánh mắt họ trống rỗng, tuyệt vọng...",
	"",
	'"Foxy... đã không còn là Foxy nữa..."',
	"",
	"",
	"Mọi thứ chìm dần vào bóng tối.",
	"",
	"Âm thanh biến mất.",
	"",
	"Ánh sáng tắt lịm.",
	"",
	"Hòn đảo Aetheria...",
	"Biến mất khỏi thế giới.",
	"",
	"",
	"Nhưng ngay cả trong hủy diệt...",
	"",
	"Một mảnh vụn nhỏ bé vẫn tồn tại.",
	"",
	"Một tia linh hồn cuối cùng...",
	"",
	"Thoát khỏi vòng xoáy bóng tối.",
	"",
	"",
	"Bờ biển mờ ảo.",
	"",
	"Sóng vỗ nhẹ, như chưa từng có bi kịch nào xảy ra.",
	"",
	"Một bóng dáng nằm bất động trên cát.",
	"",
	"Từ từ...",
	"Mở mắt.",
	"",
	"",
	'"Đầu... đau quá..."',
	"",
	'"Đây là đâu...?"',
	"",
	"Foxy không còn ký ức.",
	"",
	"Không quá khứ.",
	"Không tội lỗi.",
	"",
	"Như thể mọi thứ...",
	"Chưa từng xảy ra.",
	"",
	"",
	"Nhưng hòn đảo vẫn nhớ.",
	"",
	"Lời nguyền vẫn tồn tại.",
	"",
	"Và số phận...",
	"Không bao giờ buông tha.",
	"",
	"",
	"Vòng lặp bắt đầu lại.",
	"",
	"",
	"Lần này...",
	"Sẽ khác chứ?",
]

var current_line := 0
var typing_speed := 0.06
var line_pause := 1.8
var is_typing := false
var story_ended := false
var can_skip := true

func _ready() -> void:
	_setup_dark_effects()
	_setup_story_label()
	_setup_skip_hint()
	_setup_heavy_vignette()
	_setup_glitch_effect()
	_animate_dark_parallax()
	
	# Fade in từ đen tuyền
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 3.0).set_ease(Tween.EASE_IN)
	await tween.finished
	
	await get_tree().create_timer(1.5).timeout
	_play_story()

func _setup_dark_effects() -> void:
	"""Tạo overlay tối đè lên background"""
	var dark_overlay = ColorRect.new()
	dark_overlay.name = "DarkOverlay"
	add_child(dark_overlay)
	move_child(dark_overlay, 0)
	
	dark_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	dark_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dark_overlay.color = Color(0.1, 0, 0.05, 0.6)  # Tím đỏ đen
	
	# Thêm noise/grain effect
	var noise_overlay = ColorRect.new()
	noise_overlay.name = "NoiseOverlay"
	add_child(noise_overlay)
	noise_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	noise_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	noise_overlay.color = Color(0, 0, 0, 0.2)
	
	# Flicker effect
	_create_flicker_effect(noise_overlay)

func _create_flicker_effect(target: Control) -> void:
	"""Tạo hiệu ứng nhấp nháy đáng sợ"""
	var flicker = create_tween()
	flicker.set_loops()
	flicker.set_trans(Tween.TRANS_LINEAR)
	
	flicker.tween_property(target, "modulate:a", 0.3, 0.1)
	flicker.tween_property(target, "modulate:a", 0.2, 0.05)
	flicker.tween_property(target, "modulate:a", 0.25, 0.15)
	flicker.tween_interval(randf_range(2.0, 5.0))

func _setup_story_label() -> void:
	"""Text với màu đỏ blood và distortion"""
	story_label.add_theme_font_size_override("font_size", 40)
	
	# Màu đỏ blood cho text
	story_label.add_theme_color_override("font_color", Color(0.9, 0.2, 0.2, 0.95))
	
	# Shadow đậm hơn
	story_label.add_theme_constant_override("shadow_offset_x", 4)
	story_label.add_theme_constant_override("shadow_offset_y", 4)
	story_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 1))
	
	# Outline đen
	story_label.add_theme_constant_override("outline_size", 10)
	story_label.add_theme_color_override("font_outline_color", Color(0.05, 0, 0, 0.9))
	
	story_label.text = ""
	story_label.modulate.a = 0.0

func _setup_skip_hint() -> void:
	"""Hint box với phong cách đen tối"""
	skip_hint = Panel.new()
	add_child(skip_hint)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0, 0, 0.8)
	style.border_color = Color(0.6, 0, 0, 0.9)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	
	skip_hint.add_theme_stylebox_override("panel", style)
	
	var label = Label.new()
	label.text = "⚡ SPACE - Tăng tốc  |  ⏭ ESC - Bỏ qua"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color(0.8, 0.3, 0.3))
	skip_hint.add_child(label)
	
	skip_hint.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	skip_hint.offset_left = -360
	skip_hint.offset_top = -50
	skip_hint.offset_right = -20
	skip_hint.offset_bottom = -20
	
	_pulse_skip_hint()

func _setup_heavy_vignette() -> void:
	"""Vignette đậm hơn cho không khí nặng nề"""
	vignette = ColorRect.new()
	vignette.name = "HeavyVignette"
	add_child(vignette)
	
	vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Gradient radial từ giữa, đậm hơn
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(0, 0, 0, 0))
	gradient.add_point(0.5, Color(0, 0, 0, 0.3))
	gradient.add_point(1.0, Color(0, 0, 0, 0.85))
	
	var gradient_texture = GradientTexture2D.new()
	gradient_texture.gradient = gradient
	gradient_texture.fill_from = Vector2(0.5, 0.5)
	gradient_texture.fill_to = Vector2(0.5, 0)
	gradient_texture.fill = GradientTexture2D.FILL_RADIAL

func _setup_glitch_effect() -> void:
	"""Random glitch cho màn hình"""
	glitch_timer = Timer.new()
	add_child(glitch_timer)
	glitch_timer.wait_time = randf_range(3.0, 8.0)
	glitch_timer.timeout.connect(_trigger_glitch)
	glitch_timer.start()

func _trigger_glitch() -> void:
	"""Kích hoạt hiệu ứng glitch ngẫu nhiên"""
	screen_shake_intensity = randf_range(5.0, 15.0)
	
	# Screen distortion
	var original_pos = position
	var shake_tween = create_tween()
	shake_tween.tween_property(self, "position:x", original_pos.x + randf_range(-10, 10), 0.05)
	shake_tween.tween_property(self, "position:x", original_pos.x + randf_range(-10, 10), 0.05)
	shake_tween.tween_property(self, "position", original_pos, 0.05)
	
	# Color flash
	var color_flash = ColorRect.new()
	color_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	color_flash.color = Color(randf_range(0.5, 1), 0, 0, 0.3)
	add_child(color_flash)
	
	var flash_tween = create_tween()
	flash_tween.tween_property(color_flash, "modulate:a", 0, 0.1)
	await flash_tween.finished
	color_flash.queue_free()
	
	screen_shake_intensity = 0.0
	glitch_timer.wait_time = randf_range(3.0, 8.0)
	glitch_timer.start()

func _animate_dark_parallax() -> void:
	if not parallax_layer:
		return
	
	var tween = create_tween()
	tween.set_loops()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	# Di chuyển chậm rãi
	tween.tween_property(parallax_layer, "motion_offset:x", 30, 12.0)
	tween.tween_property(parallax_layer, "motion_offset:x", -30, 12.0)
	
	# Pulsing darkness
	var pulse = create_tween()
	pulse.set_loops()
	pulse.tween_property(sprite, "modulate", Color(0.7, 0.5, 0.5), 4.0)
	pulse.tween_property(sprite, "modulate", Color(1, 1, 1), 4.0)

func _pulse_skip_hint() -> void:
	if skip_hint:
		var pulse = create_tween()
		pulse.set_loops()
		pulse.set_trans(Tween.TRANS_SINE)
		pulse.tween_property(skip_hint, "modulate:a", 0.4, 2.0)
		pulse.tween_property(skip_hint, "modulate:a", 0.8, 2.0)

func _play_story() -> void:
	var fade_in = create_tween()
	fade_in.tween_property(story_label, "modulate:a", 1.0, 1.5)
	await fade_in.finished
	
	while current_line < story_lines.size() and can_skip:
		is_typing = true
		var line = story_lines[current_line]
		
		# Fade out cũ
		if story_label.text != "":
			var fade_out = create_tween()
			fade_out.tween_property(story_label, "modulate:a", 0.0, 0.4)
			await fade_out.finished
		
		story_label.text = ""
		story_label.modulate.a = 1.0
		
		# Type với random delay
		for char in line:
			if not can_skip:
				break
			story_label.text += char
			
			# Random stutter effect
			var delay = typing_speed
			if randf() < 0.1:
				delay *= randf_range(2, 4)
			
			await get_tree().create_timer(delay).timeout
		
		is_typing = false
		
		if line.contains("HA...") or line.contains("chiến thắng") or line.contains("hủy diệt"):
			_trigger_glitch()
		
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
	
	# Dark prompt panel
	var prompt_panel = Panel.new()
	add_child(prompt_panel)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0, 0, 0.9)
	style.border_color = Color(0.7, 0, 0, 1)
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_width_top = 3
	style.border_width_bottom = 3
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	
	prompt_panel.add_theme_stylebox_override("panel", style)
	prompt_panel.set_anchors_preset(Control.PRESET_CENTER)
	prompt_panel.custom_minimum_size = Vector2(500, 80)
	prompt_panel.offset_left = -250
	prompt_panel.offset_right = 250
	prompt_panel.offset_top = -40
	prompt_panel.offset_bottom = 40
	
	var prompt = Label.new()
	prompt.text = "⚠ Nhấn phím bất kỳ để tiếp tục..."
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	prompt.add_theme_font_size_override("font_size", 26)
	prompt.add_theme_color_override("font_color", Color(0.9, 0.3, 0.3))
	prompt_panel.add_child(prompt)
	
	prompt.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	# Slow ominous blink
	var blink = create_tween()
	blink.set_loops()
	blink.tween_property(prompt_panel, "modulate:a", 0.3, 1.2)
	blink.tween_property(prompt_panel, "modulate:a", 1.0, 1.2)

func _input(event: InputEvent) -> void:
	if not event.is_pressed():
		return
	
	if story_ended:
		_fade_out_and_return()
		return
	
	if event.is_action("ui_accept") or event.is_action("ui_select"):
		typing_speed = 0.01
		line_pause = 0.4
	
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
	# Fade to black
	var fade = create_tween()
	fade.tween_property(self, "modulate:a", 0.0, 2.0)
	await fade.finished
	get_tree().change_scene_to_file("res://scenes/screens/main_menu/main_menu.tscn")

	
