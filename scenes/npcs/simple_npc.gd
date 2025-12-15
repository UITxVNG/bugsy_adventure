extends CharacterBody2D

## Simple NPC for warning/notification dialogs
## Không có logic phức tạp như Mush - chỉ hiển thị 1 timeline cố định

@export var timeline_name: String = ""
@export var trigger_once: bool = true
@export var interaction_range: float = 50.0

var is_player_nearby: bool = false
var can_interact: bool = true
var has_triggered: bool = false

@onready var interaction_icon = $InteractionIcon if has_node("InteractionIcon") else null

func _ready() -> void:
	add_to_group("npcs")
	if interaction_icon:
		interaction_icon.visible = false

func _process(_delta: float) -> void:
	_check_player_distance()
	
	if is_player_nearby and can_interact and not has_triggered:
		if interaction_icon:
			interaction_icon.visible = true
		
		if Input.is_action_just_pressed("interact"):
			_start_conversation()
	else:
		if interaction_icon:
			interaction_icon.visible = false

func _check_player_distance() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var distance = global_position.distance_to(player.global_position)
		is_player_nearby = distance <= interaction_range
	else:
		is_player_nearby = false

func _start_conversation() -> void:
	if timeline_name == "" or Dialogic.current_timeline != null:
		return
	
	if trigger_once and has_triggered:
		return
	
	has_triggered = true
	can_interact = false
	
	if interaction_icon:
		interaction_icon.visible = false
	
	# Dừng người chơi
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("set_can_move"):
		player.set_can_move(false)
	
	# Bắt đầu hội thoại
	Dialogic.start(timeline_name)
	Dialogic.timeline_ended.connect(_on_conversation_ended)

func _on_conversation_ended() -> void:
	can_interact = true
	
	# Cho phép người chơi di chuyển
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("set_can_move"):
		player.set_can_move(true)
	
	if not trigger_once:
		has_triggered = false
	
	Dialogic.timeline_ended.disconnect(_on_conversation_ended)
