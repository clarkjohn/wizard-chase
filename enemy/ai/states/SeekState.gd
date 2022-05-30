class_name SeekState
extends EnemyState

var _walls: Dungeon
var _player: Area2D

const MAP_POS_TO_RECHECK_PATH := 8


func _init(player, walls: Dungeon):
	_player = player as Player
	_walls = walls as Dungeon


func get_enemy_path(enemy, previous_tile: Vector2) -> Array:
	var path := []
	var position := enemy.position as Vector2

	_walls.disable_astar(_walls.map_to_world(previous_tile))
	path = _walls.getAStarPath(position, _player.position)
	_walls.enable_astar(_walls.map_to_world(previous_tile))

	return path
