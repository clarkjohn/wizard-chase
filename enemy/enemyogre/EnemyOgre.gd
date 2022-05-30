extends Enemy

const OGRE_COLOR: Color = Color("#8f4029")

export var is_enabled := true


func _ready():
	set_process(is_enabled)
	# slower than other enemies
	speed = player.speed * 0.7


func change_states():
	if state is IdleState or state is ClydeState:
		change_state(self, EnemyStateEnum.CLYDE, 99)
	else:
		change_state(self, EnemyStateEnum.CLYDE, 99)


func _get_enemy_color() -> Color:
	return OGRE_COLOR
