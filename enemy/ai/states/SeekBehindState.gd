class_name SeekBehindState
extends EnemyState

var _walls: Dungeon
var _player: Area2D

const MAP_POS_TO_RECHECK_PATH := 8
const TILES_TO_SEEK_AHEAD_OF_PLAYER = 3


func _init(player, walls: Dungeon):
	_player = player
	_walls = walls as Dungeon


func get_enemy_path(enemy, _previous_tile: Vector2) -> Array:
	var position := enemy.position as Vector2

	var path := _walls.getAStarPath(position, get_player_opposite_position())
	return path


func get_player_opposite_position() -> Vector2:
	return _walls.get_path_ahead(
		_player.position, _get_opposite_direction(_player.direction), TILES_TO_SEEK_AHEAD_OF_PLAYER
	)


func _get_opposite_direction(direction: Vector2) -> Vector2:
	if direction == Vector2.UP:
		return Vector2.DOWN
	elif direction == Vector2.RIGHT:
		return Vector2.LEFT
	elif direction == Vector2.DOWN:
		return Vector2.UP
	elif direction == Vector2.LEFT:
		return Vector2.RIGHT
	else:
		return direction
