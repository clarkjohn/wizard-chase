class_name Enemy
extends Area2D

onready var global := $"/root/Global" as Global
onready var game := $"/root/Game" as Game
onready var dungeon = game.find_node_by_name("Dungeon") as Dungeon
onready var player = game.find_node_by_name("Player") as Player

export var is_debug_path_enable := false

const ENEMY_COLOR: Color = Color("#000000")

# init at EnemyAi.gd
var wander_direction: Vector2

var old_pos: Vector2
var direction: Vector2

var timer = null
var speed = null

var wrapped_screen: bool
var wrapped_tile := Vector2(0, 0)

var state

var last_map_pos_array := []
const NUM_MAP_POSITIONS_TO_REMEBER = 2

var path := []
var current_map_pos_in_path := 0

var is_stuck := false as bool

enum EnemyStateEnum { IDLE, SEEK, WANDER, OPPOSITE, CLYDE, SEEK_AHEAD, SEEK_BEHIND }
var enemy_state_factory


func _init():
	enemy_state_factory = {
		EnemyStateEnum.IDLE: IdleState,
		EnemyStateEnum.SEEK: SeekState,
		EnemyStateEnum.WANDER: WanderState,
		EnemyStateEnum.CLYDE: ClydeState,
		EnemyStateEnum.SEEK_AHEAD: SeekAheadState,
		EnemyStateEnum.SEEK_BEHIND: SeekBehindState
	}


func get_state(get_state):
	return enemy_state_factory.get(get_state)


func _ready():
	position = dungeon.snap_to_center(position)
	position.x += dungeon.HALF_CELL_SIZE.x
	position.y += dungeon.HALF_CELL_SIZE.y

	var current_tile := dungeon.world_to_map(position) as Vector2
	last_map_pos_array.push_front(current_tile)


func _process(delta: float):
	if global.state != global.states.ENTERED_MAZE:
		return

	# pause all enemires if player is dead
	if !global.is_player_alive:
		return

	# track position for enemy ai
	var current_tile := dungeon.world_to_map(position) as Vector2
	var last_map_pos = last_map_pos_array.front()
	if last_map_pos == null or last_map_pos != current_tile:
		last_map_pos_array.push_front(current_tile)
		last_map_pos_array.resize(NUM_MAP_POSITIONS_TO_REMEBER)

	# prevent enemies from getting stuck in a wrap tile
	if not wrapped_screen:
		var post_wrap_pos := dungeon.handle_possible_screen_wrap(position, direction, true) as Vector2
		if post_wrap_pos != position:
			wrapped_screen = true
			wrapped_tile = dungeon.world_to_map(post_wrap_pos)
		position = post_wrap_pos
	else:
		wrapped_screen = false

	# directions
	if old_pos.x > position.x:
		$AnimatedSprite.flip_h = true
		direction = Vector2.LEFT
	elif old_pos.x < position.x:
		$AnimatedSprite.flip_h = false
		direction = Vector2.RIGHT
	elif old_pos.y < position.y:
		direction = Vector2.UP
	elif old_pos.y > position.y:
		direction = Vector2.DOWN
	else:
		direction = Vector2.ZERO

	old_pos = position

	# move
	if global.state == global.states.ENTERED_MAZE:
		if state == null:
			change_state(self, EnemyStateEnum.IDLE, 2)
		elif is_able_to_move():
			var pos_to_move = path[0] as Vector2
			direction = (pos_to_move - position).normalized()
			var distance = position.distance_to(pos_to_move)
			if distance > 1:
				var target_pos = position + (speed * delta * direction)
				if is_stuck:
					position = target_pos
				elif dungeon.is_cell_tile_navigable(dungeon.world_to_map(target_pos)):
					position = target_pos
				else:
					# is stuck on blades, wall, spikes?
					# TODO fix this, getting stuck in the middle of spikes
					if dungeon.is_cell_tile_navigable(dungeon.world_to_map(position)):
						is_stuck = true
						path = dungeon.getAStarPath(position, dungeon.map_to_world(last_map_pos_array.back()))
						current_map_pos_in_path = 0
						pos_to_move = path[0] as Vector2
						direction = (pos_to_move - position).normalized()
						position = position + (speed * delta * direction)
					else:
						is_stuck = false
						var obstacle_pos := pos_to_move as Vector2
						dungeon.disable_astar(obstacle_pos)
						path = state.get_enemy_path(self, last_map_pos_array.back())
						current_map_pos_in_path = 0
						dungeon.enable_astar(obstacle_pos)
			else:
				path.remove(0)
				current_map_pos_in_path += 1
		else:
			# Enemy AI
			is_stuck = false
			path = state.get_enemy_path(self, last_map_pos_array.back())
			current_map_pos_in_path = 0

		# only for debug drawing of path in _draw
		update()


func is_able_to_move():
	return (
		path.size() > 0
		and current_map_pos_in_path < state.MAP_POS_TO_RECHECK_PATH
		and !wrapped_screen
		and state.is_able_to_move(self, player)
	)


func change_state(caller, new_state, wait_time: float):
	# free old change_state timers
	for child_node in get_children():
		if child_node.name == "change_states":
			child_node.queue_free()

	state = get_state(new_state).new(player, dungeon)
	timer = Timer.new()
	self.add_child(timer)
	timer.set_wait_time(wait_time)
	timer.name = "change_states"
	timer.connect("timeout", caller, "change_states")
	timer.set_one_shot(true)
	timer.start()


func _draw():
	if is_debug_path_enable:
		if state != null and path.size() > 1:
			for p in path:
				draw_circle(p - get_global_position(), 4, _get_enemy_color())


# to override
func _get_enemy_color() -> Color:
	return Color.white
