class_name SeekAheadState
extends EnemyState

var _walls: Dungeon
var _player: Area2D

const MAP_POS_TO_RECHECK_PATH := 8
const TILES_TO_SEEK_AHEAD_OF_PLAYER = 5


func _init(player, walls: Dungeon):
	_player = player
	_walls = walls as Dungeon


func get_enemy_path(enemy, previous_tile: Vector2) -> Array:
	var position := enemy.position as Vector2

	var path := _walls.getAStarPath(position, get_player_future_position())
	return path


func get_player_future_position() -> Vector2:
	return _walls.get_path_ahead(_player.position, _player.direction, TILES_TO_SEEK_AHEAD_OF_PLAYER)
