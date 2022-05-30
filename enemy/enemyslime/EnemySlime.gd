extends Enemy

const SLIME_COLOR: Color = Color("#97da3f")

export var is_enabled := true
var is_chase_state_enabled := false
var primary_AI_only = false


func _ready():
	set_process(is_enabled)
	speed = player.speed * 0.8
	disable_chase_state()


func enable_chase_state() -> void:
	is_chase_state_enabled = true
	primary_AI_only = true


func disable_chase_state() -> void:
	is_chase_state_enabled = false
	primary_AI_only = false


func change_states():
	if primary_AI_only:
		change_state(self, EnemyStateEnum.SEEK_BEHIND, 20)
	elif state is IdleState or state is SeekBehindState:
		change_state(self, EnemyStateEnum.WANDER, 5)
	else:
		change_state(self, EnemyStateEnum.SEEK_BEHIND, 11)


func _get_enemy_color() -> Color:
	return SLIME_COLOR
