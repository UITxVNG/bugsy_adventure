extends Area2D

@export var timeline_name: String = ""
@export var trigger_once: bool = true
@export var auto_start: bool = false  
@export var require_interaction: bool = true  

var is_player_nearby: bool = false
var can_interact: bool = false

@onready var interaction_label = $InteractionLabel if has_node("InteractionLabel") else null

# Key duy nhất để lưu trạng thái trigger
var trigger_key: String = ""

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Tạo key duy nhất dựa trên tên scene + tên node + timeline
	var scene_name = get_tree().current_scene.name
	trigger_key = "dialog_triggered_%s_%s_%s" % [scene_name, name, timeline_name]
	
	if interaction_label:
		interaction_label.visible = false

func _process(_delta: float) -> void:
	if is_player_nearby and can_interact and require_interaction:
		if Input.is_action_just_pressed("interact"):
			start_dialog()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_nearby = true
		can_interact = not _has_been_triggered()
		
		if interaction_label:
			interaction_label.visible = require_interaction and can_interact
		
		if auto_start and not _has_been_triggered():
			start_dialog()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_nearby = false
		can_interact = false
		
		if interaction_label:
			interaction_label.visible = false

func _has_been_triggered() -> bool:
	if not trigger_once:
		return false
	return GlobalData.has_dialog_triggered(trigger_key)

func start_dialog() -> void:
	if timeline_name == "" or Dialogic.current_timeline != null:
		return
	
	if _has_been_triggered():
		return
	
	if trigger_once:
		GlobalData.set_dialog_triggered(trigger_key, true)
	
	can_interact = false
	
	if interaction_label:
		interaction_label.visible = false
	
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("set_can_move"):
		player.set_can_move(false)
	
	Dialogic.start(timeline_name)
	Dialogic.timeline_ended.connect(_on_timeline_ended, CONNECT_ONE_SHOT)

func _on_timeline_ended() -> void:
	# Safety check - ensure we're still in the tree
	if not is_inside_tree():
		return
	
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("set_can_move"):
		player.set_can_move(true)
	
	if not trigger_once:
		can_interact = true
