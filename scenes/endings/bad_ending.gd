extends Control

@onready var story_label = $CenterContainer/StoryLabel
@onready var background = $ParallaxBackground

var skip_hint: Label = null

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
var typing_speed := 0.05
var line_pause := 1.0
var is_typing := false
var story_ended := false
var can_skip := true

func _ready() -> void:	
	_setup_background()
	_setup_story_label()
	
	_setup_skip_hint()
	
	story_label.text = "Nhấn space để next nhanh
						Nhấn ESC để skip"
	story_label.modulate.a = 0.0
	
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 2.0)
	await tween.finished
	
	# Show story label
	var fade = create_tween()
	fade.tween_property(story_label, "modulate:a", 1.0, 1.0)
	await fade.finished
	
	# Start story
	await get_tree().create_timer(1.0).timeout
	_play_story()

func _setup_background() -> void:
	"""Tạo background gradient đẹp"""
	if background is ColorRect:
		# Gradient từ tím đậm đến xanh đen
		var gradient = Gradient.new()
		gradient.add_point(0.0, Color("#0f0c29"))
		gradient.add_point(0.5, Color("#302b63"))
		gradient.add_point(1.0, Color("#24243e"))
		
		var gradient_texture = GradientTexture2D.new()
		gradient_texture.gradient = gradient
		gradient_texture.fill_from = Vector2(0, 0)
		gradient_texture.fill_to = Vector2(0, 1)
		
		background.color = Color("#1a1a2e")

func _setup_story_label() -> void:
	story_label.add_theme_font_size_override("font_size", 36)
	story_label.add_theme_color_override("font_color", Color.WHITE)
	
	story_label.add_theme_constant_override("shadow_offset_x", 2)
	story_label.add_theme_constant_override("shadow_offset_y", 2)
	story_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))

func _setup_skip_hint() -> void:
	skip_hint = Label.new()
	add_child(skip_hint)
	
	skip_hint.text = "[SPACE] Tăng tốc | [ESC] Bỏ qua"
	skip_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	skip_hint.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	skip_hint.add_theme_font_size_override("font_size", 20)
	skip_hint.add_theme_color_override("font_color", Color(1, 1, 1, 0.7))
	skip_hint.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	skip_hint.offset_left = -300
	skip_hint.offset_top = -40
	skip_hint.offset_right = -20
	skip_hint.offset_bottom = -10
	
	_blink_skip_hint()

func _blink_skip_hint() -> void:
	if skip_hint:
		var blink = create_tween()
		blink.set_loops()
		blink.tween_property(skip_hint, "modulate:a", 0.3, 1.5)
		blink.tween_property(skip_hint, "modulate:a", 0.7, 1.5)

func _play_story() -> void:
	"""Chạy câu chuyện từng dòng"""
	while current_line < story_lines.size() and can_skip:
		is_typing = true
		var line = story_lines[current_line]
		
		story_label.text = ""
		
		for char in line:
			if not can_skip:  
				break
			story_label.text += char
			await get_tree().create_timer(typing_speed).timeout
		
		is_typing = false
		
		await get_tree().create_timer(line_pause).timeout
		
		current_line += 1
	
	story_ended = true
	print("Story ended")
	_show_continue_prompt()

func _show_continue_prompt() -> void:
	if skip_hint:
		skip_hint.hide()
	
	await get_tree().create_timer(2.0).timeout
	
	var prompt = Label.new()
	prompt.text = "\n\nNhấn phím bất kỳ để quay về Menu..."
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.add_theme_font_size_override("font_size", 28)
	prompt.add_theme_color_override("font_color", Color.YELLOW)
	
	story_label.get_parent().add_child(prompt)
	var blink = create_tween()
	blink.set_loops()
	blink.tween_property(prompt, "modulate:a", 0.3, 0.8)
	blink.tween_property(prompt, "modulate:a", 1.0, 0.8)

func _input(event: InputEvent) -> void:
	if not event.is_pressed():
		return
	
	if story_ended:
		_fade_out_and_return()
		return
	
	if event.is_action("ui_accept") or event.is_action("ui_select"):
		typing_speed = 0.01
		line_pause = 0.2
		print("⚡ Tăng tốc!")
	
	elif event.is_action("ui_cancel"):
		_skip_all()

func _skip_all() -> void:
	"""Skip toàn bộ story"""
	print("⏭️ Skipping all...")
	can_skip = false
	current_line = story_lines.size()
	
	story_label.text = "\n".join(story_lines)
	
	story_ended = true
	_show_continue_prompt()

func _fade_out_and_return() -> void:
	var fade = create_tween()
	fade.tween_property(self, "modulate:a", 0.0, 1.0)
	await fade.finished
	
	#get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
