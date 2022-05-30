class_name Player
extends Area2D

onready var game := $"/root/Game" as Game
onready var global := get_node("/root/Global") as Global
onready var dungeon = game.find_node_by_name("Dungeon")  # cyclic
onready var treasure = game.find_node_by_name("Treasure")
onready var door_fore := game.find_node_by_name("DoorFore") as DoorFore
onready var markers := game.find_node_by_name("Markers") as Markers
onready var magic_walls := game.find_node_by_name("MagicWalls")  # cyclic
onready var score_label := game.find_node_by_name("ScoreLabel") as ScoreLabel
onready var walking_sound := game.find_node_by_name("WalkingSound") as AudioStreamPlayer

# enemy speed is derived form this
export var speed = 70

var direction = Vector2.ZERO

var old_direction = Vector2.ZERO
var old_position = Vector2.ZERO

var new_direction = Vector2.ZERO
var new_rotation = deg2rad(0)

var is_casting_magic_wall = true
var is_player_loading_next_level = false

# for enemy ai
var last_map_pos_array := []
const NUM_MAP_POSITIONS_TO_REMEMBER = 3


func _ready():
	last_map_pos_array.resize(NUM_MAP_POSITIONS_TO_REMEMBER)


func _physics_process(_delta):
	if (
		self.get_overlapping_areas().size() > 0
		and global.is_player_alive
		and global.state == global.states.ENTERED_MAZE
	):
		player_dies()
		#pass


func _process(delta: float):
	#var temp_state := global.state

	if (
		!(global.state == global.states.ENTERED_MAZE or global.state == global.states.PLAYER_WAITING_TO_ENTER)
		# needed or else the player can move after death
		or is_player_loading_next_level
	):
		return

	old_direction = direction
	old_position = position

	_get_input()

	# TODO move this to end of method?
	_move(delta)

	# player got all coins and went through door
	if (
		global.state == global.states.ENTERED_MAZE
		and door_fore.has_player_exited_level(dungeon.world_to_map(position))
		and !is_player_loading_next_level
	):
		is_player_loading_next_level = true
		global.load_next_level(true)

	# player got all coins and died before entering door, just go to next level after death
	if (
		global.state == global.states.PLAYER_WAITING_TO_ENTER
		and treasure.get_total_coins_left() == 0
		and !is_player_loading_next_level
	):
		is_player_loading_next_level = true
		global.load_next_level(true)

	if markers.is_triggering_start_button(position):
		if global.state != global.states.ENTERED_MAZE:
			global.set_state(global.states.ENTERED_MAZE)
			door_fore.close_doors()
		elif global.state == global.states.ENTERED_MAZE and treasure.get_total_coins_left() != 0:
			door_fore.close_doors()

	if is_casting_magic_wall:
		magic_walls.cast_magic_wall(position, direction)
		is_casting_magic_wall = false

	if treasure.get_treasure(position):
		# sound is played in treasure class
		pass
	elif dungeon.world_to_map(position) != dungeon.world_to_map(old_position):
		walking_sound.play()

	position = dungeon.handle_possible_screen_wrap(position, direction, false)

	if old_position.x > position.x:
		$AnimatedSprite.flip_h = true
	elif old_position.x < position.x:
		$AnimatedSprite.flip_h = false

	_save_position_for_later()


func _get_input():
	is_casting_magic_wall = false
	if Input.is_action_pressed("ui_up"):
		new_direction = Vector2.UP
		new_rotation = deg2rad(-90)
	elif Input.is_action_pressed("ui_down"):
		new_direction = Vector2.DOWN
		new_rotation = deg2rad(90)
	elif Input.is_action_pressed("ui_left"):
		new_direction = Vector2.LEFT
		new_rotation = deg2rad(180)
	elif Input.is_action_pressed("ui_right"):
		new_direction = Vector2.RIGHT
		new_rotation = deg2rad(0)

	# cast magic walls
	elif Input.is_action_pressed("ui_space"):
		is_casting_magic_wall = true
	elif Input.is_action_just_released("ui_space"):
		is_casting_magic_wall = true
	else:
		new_direction = direction

	# TODO debug only
	if false:
		if Input.is_action_just_released("open_doors"):
			door_fore.open_doors()
		if Input.is_action_just_released("next_level"):
			global.load_next_level(false)
		if Input.is_action_just_released("debug_add_to_score"):
			score_label.update_score(2260)
		if Input.is_action_just_released("debug_lose_life"):
			player_dies()
		if Input.is_action_just_released("debug_get_0"):
			global.debug_get_misc_treasure(0)
		if Input.is_action_just_released("debug_get_1"):
			global.debug_get_misc_treasure(1)
		if Input.is_action_just_released("debug_get_2"):
			global.debug_get_misc_treasure(2)
		if Input.is_action_just_released("debug_get_3"):
			global.debug_get_misc_treasure(3)
		if Input.is_action_just_released("debug_get_4"):
			global.debug_get_misc_treasure(4)
		if Input.is_action_just_released("debug_get_5"):
			global.debug_get_misc_treasure(5)
		if Input.is_action_just_released("debug_get_6"):
			global.debug_get_misc_treasure(6)
		if Input.is_action_just_released("debug_get_7"):
			global.debug_get_misc_treasure(7)
		if Input.is_action_just_released("debug_get_8"):
			global.debug_get_misc_treasure(8)	
		if Input.is_action_just_released("debug_get_9"):
			global.debug_get_misc_treasure(9)	
	
	
func _move(delta: float) -> void:
	var map_pos: Vector2 = dungeon.world_to_map(position)
	var current_map_pos_center: Vector2 = dungeon.map_to_world(map_pos)

	# center in tilemap
	current_map_pos_center.x += dungeon.HALF_CELL_SIZE.x
	# dont center player on half tile
	if dungeon.get_cellv(map_pos) != dungeon.TILE_HALF_ENTRANCE:
		current_map_pos_center.y += dungeon.HALF_CELL_SIZE.y

	# next tile can
	if dungeon.is_cell_tile_navigable(map_pos + new_direction):
		direction = new_direction

	# TODOis able to move to next tile?
	# TODO this needs be cleaned up
	# TODO somewhere there is a bug with the player going beyone the center grid
	if dungeon.is_cell_tile_navigable(map_pos + direction) and direction != Vector2.ZERO:
		# is changing direction
		if (
			(position != current_map_pos_center)
			and (old_direction != Vector2.ZERO and (direction != old_direction or direction == Vector2.ZERO))
		):
			if _is_new_direction_x_tangent():
				var velocity = speed * delta * direction
				var target_pos = position + velocity
				var distance = target_pos.x - current_map_pos_center.x
				#print(["position=",position,", velocity=",velocity,", target_pos=",target_pos,", distance=",distance, ", current_map_pos_center=",current_map_pos_center])
				if distance < velocity.x:
					#change direction
					#print(["negative distance.x=",distance.x])
					position = target_pos
					position.y = current_map_pos_center.y

				else:
					#keep going
					direction = old_direction
					position += speed * delta * direction

			elif _is_new_direction_y_tangent():
				var velocity = speed * delta * direction
				var target_pos = position + velocity
				var distance = target_pos.y - current_map_pos_center.y

				if distance < velocity.y:
					#print(["negative distance.x=",distance.x])
					position = target_pos
					position.x = current_map_pos_center.x

				else:
					direction = old_direction
					position += speed * delta * direction

			else:
				position += speed * delta * direction
		else:
			position += speed * delta * direction

	else:
		# handle collision
		if position != current_map_pos_center:
			# if X
			if direction == Vector2.LEFT or direction == Vector2.RIGHT:
				var velocity = speed * delta * direction
				var target_pos = position + velocity
				#var distance = target_pos.x - current_map_pos_center.x

				#print(["position=",position,", velocity=",velocity,", target_pos=",target_pos,", distance=",distance, ", current_map_pos_center=",current_map_pos_center])

				if (
					target_pos.x < current_map_pos_center.x
					or (direction == Vector2.LEFT and position.x < current_map_pos_center.x)
					or (direction == Vector2.RIGHT and position.x > current_map_pos_center.x)
				):
					position = current_map_pos_center

				else:
					direction = old_direction
					position += speed * delta * direction

			# if Y
			elif direction == Vector2.UP or direction == Vector2.DOWN:
				var velocity = speed * delta * direction
				var target_pos = position + velocity
				#var distance = target_pos.y - current_map_pos_center.y

				#print(["position=",position,", velocity=",velocity,", target_pos=",target_pos,", distance=",distance, ", current_map_pos_center=",current_map_pos_center])

				#TODO is this needed?
				var future_tile: Vector2 = dungeon.world_to_map(target_pos)
				var futre_current_map_pos_center = dungeon.map_to_world(future_tile)
				futre_current_map_pos_center.x += dungeon.HALF_CELL_SIZE.x
				var future_type_type = dungeon.get_cellv(future_tile)

				# if player has passed current tile center position
				if (
					target_pos.y < current_map_pos_center.y
					or (direction == Vector2.UP and position.y < current_map_pos_center.y)
					or (direction == Vector2.DOWN and position.y > current_map_pos_center.y)
				):
					position = current_map_pos_center
				else:
					direction = old_direction
					position += speed * delta * direction

	if old_position == position and position != current_map_pos_center:
		position = current_map_pos_center


func player_dies():
	global.player_dies()
	stop_animation()
	is_player_loading_next_level = true


func stop_animation():
	$AnimatedSprite.stop()


func start_animation():
	$AnimatedSprite.start()


# track position for enemy ai
func _save_position_for_later() -> void:
	var last_map_pos = last_map_pos_array.front()
	var current_map_pos := dungeon.world_to_map(position) as Vector2
	if last_map_pos == null or last_map_pos != current_map_pos:
		last_map_pos_array.push_front(current_map_pos)
		last_map_pos_array.resize(NUM_MAP_POSITIONS_TO_REMEMBER)


func _is_new_direction_x_tangent():
	if old_direction == Vector2.ZERO and (new_direction == Vector2.DOWN or new_direction == Vector2.UP):
		return true
	elif old_direction == Vector2.LEFT and (new_direction == Vector2.DOWN or new_direction == Vector2.UP):
		return true
	elif old_direction == Vector2.RIGHT and (new_direction == Vector2.DOWN or new_direction == Vector2.UP):
		return true
	else:
		return false


func _is_new_direction_y_tangent():
	if direction == Vector2.ZERO and (new_direction == Vector2.DOWN or new_direction == Vector2.UP):
		return true
	elif old_direction == Vector2.UP and (new_direction == Vector2.LEFT or new_direction == Vector2.RIGHT):
		return true
	elif old_direction == Vector2.DOWN and (new_direction == Vector2.LEFT or new_direction == Vector2.RIGHT):
		return true
	else:
		return false
