extends Enemy

const FIEND_COLOR: Color = Color("#da4e38")

export var is_enabled := true

var primary_AI_only := false
var is_chase_state_enabled := false


func _ready():
	set_process(is_enabled)
	disable_chase_state()


func enable_chase_state() -> void:
	is_chase_state_enabled = true
	speed = player.speed * $"../".MAX_ENEMY_SPEED_FACTOR_TO_PLAYER
	primary_AI_only = true


func disable_chase_state() -> void:
	is_chase_state_enabled = false
	speed = player.speed * 0.8
	primary_AI_only = false


func change_states():
	if primary_AI_only:
		change_state(self, EnemyStateEnum.SEEK, 100)
	elif state is IdleState or state is SeekState:
		change_state(self, EnemyStateEnum.WANDER, 5)
	else:
		change_state(self, EnemyStateEnum.SEEK, 5)


func _get_enemy_color() -> Color:
	return FIEND_COLOR
