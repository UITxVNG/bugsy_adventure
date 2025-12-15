extends Area2D
class_name Artifact

@export_group("Artifact Settings")
@export var artifact_id: int = 1  
@export var artifact_name: String = "Di Vật Biển Sâu"
@export var artifact_description: String = "Một mảnh của Lõi Năng Lượng"

@export_group("Visual Effects")
@export var glow_color: Color = Color(0.0, 0.8, 1.0)  
@export var float_amplitude: float = 10.0 
@export var float_speed: float = 2.0
@export var rotate_speed: float = 1.0

@export_group("Audio")
@export var collect_sound: AudioStream

var start_position: Vector2
var time_passed: float = 0.0
var is_collected: bool = false

@onready var sprite = $Sprite2D
@onready var glow_particles = $GlowParticles if has_node("GlowParticles") else null
@onready var light = $PointLight2D if has_node("PointLight2D") else null
@onready var audio_player = $AudioStreamPlayer if has_node("AudioStreamPlayer") else null
@onready var collision_shape = $CollisionShape2D

func _ready() -> void:
	add_to_group("artifacts")
	start_position = global_position
	if light:
		light.color = glow_color
	
	if glow_particles:
		glow_particles.emitting = true

	body_entered.connect(_on_body_entered)
	
	_check_if_already_collected()

func _check_if_already_collected() -> void:
	if GameManager.has_artifact(artifact_id):
		queue_free()

func _physics_process(delta: float) -> void:
	if is_collected:
		return
	
	time_passed += delta
	var new_y = start_position.y + sin(time_passed * float_speed) * float_amplitude
	global_position.y = new_y
	

func _on_body_entered(body: Node2D) -> void:
	if is_collected:
		return
	
	if body.is_in_group("player"):
		_collect()

func _collect() -> void:
	if is_collected:
		return
	
	is_collected = true
	
	if audio_player and collect_sound:
		audio_player.stream = collect_sound
		audio_player.play()

	_play_collect_animation()
	
	GameManager.collect_artifact_with_id(artifact_id, artifact_name)
	
	_show_artifact_popup()
	

	await get_tree().create_timer(0.3).timeout
	_trigger_dialogic_timeline()

func _play_collect_animation() -> void:
	"""Animation khi thu thập: scale up và fade out"""
	var tween = create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(sprite, "scale", Vector2(2.0, 2.0), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	tween.tween_property(sprite, "modulate:a", 0.0, 0.5)
	
	if light:
		tween.tween_property(light, "energy", 0.0, 0.5)
	
	if glow_particles:
		glow_particles.emitting = false

	tween.tween_callback(queue_free).set_delay(0.6)

func _show_artifact_popup() -> void:
	print("Đã thu thập: %s (ID: %d)" % [artifact_name, artifact_id])

func _trigger_dialogic_timeline() -> void:
	var timeline_name = ""

	match artifact_id:
		1:
			timeline_name = "artifact_1_collected"
		2:
			timeline_name = "artifact_2_collected"
		3:
			timeline_name = "artifact_3_collected"
		4:
			timeline_name = "artifact_4_collected"
		5:
			timeline_name = "artifact_5_collected"
		6:
			timeline_name = "artifact_6_collected"
		7:
			timeline_name = "artifact_7_collected"

	if timeline_name != "":
		print("🎬 Starting timeline: ", timeline_name)
		#GameManager.freeze_player()
		Dialogic.start(timeline_name)
		await Dialogic.timeline_ended
		#GameManager.unfreeze_player()
		
		print("✅ Timeline ended: ", timeline_name)
	else:
		push_warning("No timeline for artifact ID: %d" % artifact_id)
