class_name WanderState
extends EnemyState

var _walls: TileMap
var _player: Area2D

const MAP_POS_TO_RECHECK_PATH := 20
const MAP_SIZE := 50

var tangent_toggle_x_array := [Vector2.LEFT, Vector2.RIGHT]
var tangent_toggle_y_array := [Vector2.UP, Vector2.DOWN]

# half or a quarter, when finding shift post
var shift_pos_array := [2, 4]


func _init(player, walls):
	_player = player
	_walls = walls


func get_enemy_path(enemy, previous_tile: Vector2) -> Array:
	return get_wander_path(enemy, previous_tile)


func get_wander_path(enemy, previous_tile: Vector2) -> Array:
	var path := []
	var wander_direction = enemy.wander_direction
	var position := enemy.position as Vector2

	var shift_direction = get_shift_direction(_player.position, position)
	var target_wander_direction = get_target_wander_direction(shift_direction, wander_direction)

	_walls.disable_astar(_walls.map_to_world(previous_tile))
	path = _walls.getAStarPath(position, target_wander_direction)
	_walls.enable_astar(_walls.map_to_world(previous_tile))
	if path.size() == 0:
		path = _walls.getAStarPath(position, shift_direction)

	return path


func get_shift_direction(player_pos: Vector2, enemy_pos: Vector2) -> Vector2:
	var shift_amount = swap_get(shift_pos_array) as int

	var new_x = (int(player_pos.x) + (_walls.max_x_pos / shift_amount)) % _walls.max_x_pos
	var new_y = (int(player_pos.y) + (_walls.max_y_pos / shift_amount)) % _walls.max_y_pos

	return Vector2(new_x, new_y)


func is_player_around_corner_of_map(player_pos: Vector2) -> bool:
	return false


func get_target_wander_direction(pos: Vector2, wander_direction: Vector2) -> Vector2:
	var far_pos := get_far_pos(pos, wander_direction)
	var far_with_tangent_pos := get_tangent_pos(far_pos, wander_direction)

	return far_with_tangent_pos


func get_far_pos(pos: Vector2, wander_direction: Vector2) -> Vector2:
	if wander_direction == Vector2.UP:
		pos.y -= MAP_SIZE * _walls.get_cell_size().y
	elif wander_direction == Vector2.RIGHT:
		pos.x += MAP_SIZE * _walls.get_cell_size().x
	elif wander_direction == Vector2.DOWN:
		pos.y += MAP_SIZE * _walls.get_cell_size().y
	elif wander_direction == Vector2.LEFT:
		pos.x -= MAP_SIZE * _walls.get_cell_size().x

	return Vector2(clamp(pos.x, _walls.min_x_pos, _walls.max_x_pos), clamp(pos.y, _walls.min_y_pos, _walls.max_y_pos)) as Vector2


func get_tangent_pos(pos: Vector2, wander_direction: Vector2) -> Vector2:
	if wander_direction == Vector2.UP or wander_direction == Vector2.DOWN:
		var new_dir = swap_get(tangent_toggle_y_array) as Vector2
		if new_dir == Vector2.LEFT:
			pos.x -= _walls.get_cell_size().x * 2
		else:
			pos.x += _walls.get_cell_size().x * 2
	else:
		var new_dir = swap_get(tangent_toggle_x_array) as Vector2
		if new_dir == Vector2.UP:
			pos.y -= _walls.get_cell_size().y * 2
		else:
			pos.y += _walls.get_cell_size().y * 2

	return Vector2(clamp(pos.x, _walls.min_x_pos, _walls.max_x_pos), clamp(pos.y, _walls.min_y_pos, _walls.max_y_pos)) as Vector2


func swap_get(swap_array: Array):
	var temp = swap_array[0]
	swap_array[0] = swap_array[1]
	swap_array[1] = temp
	return swap_array[0]
