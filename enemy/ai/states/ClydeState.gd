# Similar to Clyde in pacman
class_name ClydeState
extends WanderState

const TILES_AWAY_FROM_PLAYER_TO_BACK_OFF := 5
const WANDER_MAP_POS_TO_RECHECK_PATH := 4

var is_seeking_player: bool = true
var distance_to_player_to_change_to_stop: float


# weird child constructor, see https://docs.godotengine.org/en/3.0/getting_started/scripting/gdscript/gdscript_basics.html#class-constructor
func _init(player, walls).(player, walls):
	distance_to_player_to_change_to_stop = _walls.get_cell_size().x * TILES_AWAY_FROM_PLAYER_TO_BACK_OFF


func is_able_to_move(enemy, _player: Player) -> bool:
	var position := enemy.position as Vector2
	var current_map_pos_in_path := enemy.current_map_pos_in_path as int

	if is_seeking_player and position.distance_to(_player.position) < distance_to_player_to_change_to_stop:
		return false
	elif not is_seeking_player and current_map_pos_in_path > WANDER_MAP_POS_TO_RECHECK_PATH:
		return false
	else:
		return true


func get_enemy_path(enemy, previous_tile: Vector2) -> Array:
	var position := enemy.position as Vector2

	if not is_seeking_player:
		is_seeking_player = true
		_walls.disable_astar(_walls.map_to_world(previous_tile))
		var path = _walls.getAStarPath(position, _player.position)
		_walls.enable_astar(_walls.map_to_world(previous_tile))

		return path
	else:
		is_seeking_player = false
		return get_wander_path(enemy, previous_tile)
