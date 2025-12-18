extends EnemyCharacter

@export var push_force: float = 300.0

func _ready() -> void:
	fsm = FSM.new(self, $States, $States/Run)
	super._ready()

func _on_push_area_body_entered(body: Node2D) -> void:
	print(body)
	if body is Player:
		var dir = (body.global_position - global_position).normalized()
		body.velocity.x = dir.x * push_force
