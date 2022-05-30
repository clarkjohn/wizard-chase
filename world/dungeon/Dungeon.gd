class_name Dungeon
extends TileMap

# TODO move astar/pathfinding to its own class?

onready var global := $"/root/Global" as Global
onready var game := $"/root/Game"
onready var player = game.find_node_by_name("Player") as Player
onready var overlay = game.find_node_by_name("Overlay") as Overlay
onready var door_fore = game.find_node_by_name("DoorFore") as DoorFore
onready var floor_spikes = game.find_node_by_name("FloorSpikes") as FloorSpikes
onready var wall_blades = game.find_node_by_name("WallBlades")  # cyclic
onready var editor_markers = game.find_node_by_name("Markers") as Markers
onready var magic_walls = game.find_node_by_name("MagicWalls")

onready var Tiles := preload("res://world/map_generated/floorspikes/AnimatedSpikes.tres") as AnimatedTexture
onready var blades := preload("res://world/map_generated/wallblades/AnimatedBarSide.tres") as AnimatedTexture

const HALF_CELL_SIZE := Vector2(10, 10)

# tiles
const TILE_EMPTY := 0
const TILE_MAGIC_WALL_HORIZONTAL := 1
const TILE_MAGIC_WALL_VERTICAL := 2
const TILE_HALF_ENTRANCE := 3
const TILE_SPIKES := 21
const TILE_EMPTY_SPIKES_PLACEHOLDER := 22

const TILES_NAVIGABLE_ARRAY := [
	TILE_EMPTY,
	TILE_MAGIC_WALL_HORIZONTAL,
	TILE_MAGIC_WALL_VERTICAL,
	TILE_HALF_ENTRANCE,
	TILE_SPIKES,
	TILE_EMPTY_SPIKES_PLACEHOLDER
]

# astar
const ASTAR_REGULAR_WEIGHT := 1
const ASTAR_WRAP_WEIGHT := ASTAR_REGULAR_WEIGHT * 5

var aStar := AStar2D.new()
var navigable_astar_cells_array := []

# for ai clamps
# TODO derive this from navigable tiles
#warning-ignore:unused_class_variable
var min_x_pos := 50
#warning-ignore:unused_class_variable
var max_x_pos := 330
#warning-ignore:unused_class_variable
var min_y_pos := 50
#warning-ignore:unused_class_variable
var max_y_pos := 210

# state
var has_level_init = false
var is_node_tree_loaded := false


func _ready():
	Tiles.pause = true
	blades.pause = true
	pass


func _process(_delta):
	if not is_node_tree_loaded:
		# need to load all level nodes first
		_init_AStar()
		is_node_tree_loaded = true

	if global.state == global.states.ENTERED_MAZE and not has_level_init:
		_init_level()
		has_level_init = true


func _init_level() -> void:
	Tiles.set_current_frame(0)
	Tiles.pause = false
	blades.set_current_frame(0)
	blades.pause = false
	# TODO add animation


func is_cell_tile_navigable(pos: Vector2) -> bool:
	var cell_value := self.get_cellv(pos)

	return (
		TILES_NAVIGABLE_ARRAY.has(cell_value)
		and not magic_walls.is_magic_wall(pos)
		and not _is_spikes_up(pos, cell_value)
		and not _is_wall_blades_up(pos, cell_value)
		and door_fore.is_door_tile_navigable(pos)
	)


func snap_to_center(pos: Vector2) -> Vector2:
	var map_pos: Vector2 = self.world_to_map(pos)
	var map_pos_center_position = self.map_to_world(map_pos)
	return map_pos_center_position


func handle_possible_screen_wrap(pos: Vector2, direction: Vector2, is_enemy: bool) -> Vector2:
	var map_pos: Vector2 = self.world_to_map(pos)

	if editor_markers.screen_wrap_left == map_pos and _handle_direction(is_enemy, direction, Vector2.LEFT):
		pos = self.map_to_world(editor_markers.screen_wrap_right)
		pos.x -= HALF_CELL_SIZE.x
		pos.y += HALF_CELL_SIZE.y
		return pos
	elif editor_markers.screen_wrap_right == map_pos and _handle_direction(is_enemy, direction, Vector2.RIGHT):
		pos = self.map_to_world(editor_markers.screen_wrap_left)
		pos.x += HALF_CELL_SIZE.x
		pos.y += HALF_CELL_SIZE.y
		return pos
	# TODO add vertical wrap for future?
	else:
		# no screen wrap
		return pos


func _is_spikes_up(pos: Vector2, cell_value: int) -> bool:
	return true if cell_value == TILE_EMPTY_SPIKES_PLACEHOLDER and floor_spikes.is_spikes_up(pos) else false


func _is_wall_blades_up(pos: Vector2, cell_value: int) -> bool:
	return wall_blades.is_blades_up(pos)


# TODO enemy logic might not be needed
func _handle_direction(is_enemy: bool, direction: Vector2, required_direction: Vector2):
	if is_enemy:
		return true
	elif direction == required_direction:
		return true
	else:
		return false


func _init_AStar() -> void:
	aStar = AStar2D.new()
	var map_size := self.get_used_rect().size
	aStar.reserve_space((map_size.x + 1) * map_size.y)

	# get all x tiles, make to get negative map tiles
	var x_map_pos_array := []
	x_map_pos_array.append(-1)
	for x in map_size.x:
		x_map_pos_array.append(x)

	# create astar grid
	for x in x_map_pos_array:
		for y in map_size.y:
			var map_pos := Vector2(x, y)
			var astar_cell_id = _getAStarCellId(map_pos)
			if editor_markers.is_wrap_tile(map_pos):
				aStar.add_point(astar_cell_id, map_to_world(map_pos), ASTAR_WRAP_WEIGHT)
			elif TILES_NAVIGABLE_ARRAY.has(get_cellv(map_pos)):
				aStar.add_point(astar_cell_id, map_to_world(map_pos), ASTAR_REGULAR_WEIGHT)

	# rest of map
	for x in x_map_pos_array:
		for y in map_size.y:
			var map_pos := Vector2(x, y)
			if TILES_NAVIGABLE_ARRAY.has(get_cellv(map_pos)):
				var astar_cell_id := _getAStarCellId(map_pos)
				for astar_cell_id_neighbor_map_pos in [
					Vector2(map_pos.x, map_pos.y - 1),
					Vector2(map_pos.x, map_pos.y + 1),
					Vector2(map_pos.x - 1, map_pos.y),
					Vector2(map_pos.x + 1, map_pos.y)
				]:
					if TILES_NAVIGABLE_ARRAY.has(get_cellv(astar_cell_id_neighbor_map_pos)):
						# store for later
						navigable_astar_cells_array.append(astar_cell_id)

						# connect neighbor
						var neightbor_cell_id := _getAStarCellId(astar_cell_id_neighbor_map_pos)
						if aStar.has_point(neightbor_cell_id):
							aStar.connect_points(astar_cell_id, neightbor_cell_id, false)

	# connect wrap tiles
	var right_wrap_astar_cell_id := _getAStarCellId(
		Vector2(editor_markers.screen_wrap_right.x, editor_markers.screen_wrap_right.y)
	)
	var left_warp_astar_cell_id := _getAStarCellId(
		Vector2(editor_markers.screen_wrap_left.x, editor_markers.screen_wrap_left.y)
	)
	aStar.connect_points(right_wrap_astar_cell_id, left_warp_astar_cell_id, false)
	aStar.connect_points(left_warp_astar_cell_id, right_wrap_astar_cell_id, false)

	return


func _getAStarCellId(map_pos: Vector2) -> int:
	# Astar grid has to account for the single -1 map pos from tile wrap, so all x values are shifted right
	return int(map_pos.y + (map_pos.x + 1) * self.get_used_rect().size.y)


func getAStarPath(start_position: Vector2, target_position: Vector2) -> Array:
	var start_tilemap_pos := world_to_map(start_position)
	var start_cell_id := _getAStarCellId(Vector2(start_tilemap_pos.x, start_tilemap_pos.y))
	var target_tilemap_pos = world_to_map(target_position)
	var target_cell_id = _getAStarCellId(Vector2(target_tilemap_pos.x, target_tilemap_pos.y))

	# TODO Remover this?
	# check to see if both points are in the grid
	if aStar.has_point(start_cell_id) and aStar.has_point(target_cell_id):
		var path: Array = Array(aStar.get_point_path(start_cell_id, target_cell_id))

		_center_path(path)
		return path
	else:
		return []


# center path points in a cell
func _center_path(path: Array) -> void:
	for p in range(path.size()):
		path[p].x = path[p].x + HALF_CELL_SIZE.x
		path[p].y = path[p].y + HALF_CELL_SIZE.y


func get_path_ahead(source_world_pos: Vector2, direction: Vector2, tiles_ahead: int) -> Vector2:
	var target_path := []
	var source_map_pos := self.world_to_map(source_world_pos)
	target_path.append(source_map_pos)
	_get_next_path(source_map_pos, direction, tiles_ahead, target_path)

	var target_world_pos := self.map_to_world(target_path.back())
	target_world_pos.x = target_world_pos.x + HALF_CELL_SIZE.x
	target_world_pos.y = target_world_pos.y + HALF_CELL_SIZE.y

	return target_world_pos


# recursive
func _get_next_path(source_map_pos: Vector2, direction: Vector2, tiles_ahead: int, target_path: Array):
	if tiles_ahead == 0:
		return target_path
	else:
		var map_pos_array = []
		for astar_cell in aStar.get_point_connections(_getAStarCellId(source_map_pos)):
			map_pos_array.append(self.world_to_map(aStar.get_point_position(astar_cell)))

		var next_step_target = direction + source_map_pos
		var clockwise_step_target = direction + _get_next_direction_clockwise(direction)
		if map_pos_array.has(next_step_target):
			target_path.append(next_step_target)
			tiles_ahead -= 1
			_get_next_path(next_step_target, direction, tiles_ahead, target_path)
		elif map_pos_array.has(clockwise_step_target):
			target_path.append(clockwise_step_target)
			tiles_ahead -= 1
			_get_next_path(clockwise_step_target, direction, tiles_ahead, target_path)

		return target_path


func _get_next_direction_clockwise(direction: Vector2) -> Vector2:
	if direction == Vector2.UP:
		return Vector2.RIGHT
	elif direction == Vector2.RIGHT:
		return Vector2.DOWN
	elif direction == Vector2.DOWN:
		return Vector2.LEFT
	elif direction == Vector2.LEFT:
		return Vector2.UP
	else:
		return direction


func disable_astar(pos: Vector2) -> void:
	aStar.set_point_disabled(_getAStarCellId(world_to_map(pos)), true)


func enable_astar(pos: Vector2) -> void:
	aStar.set_point_disabled(_getAStarCellId(world_to_map(pos)), false)


# TODO Delete?
func update_astar() -> void:
	var size = self.get_used_rect().size
	for i in size.x:
		for j in size.y:
			var idx = _getAStarCellId(Vector2(i, j))
			aStar.add_point(idx, map_to_world(Vector2(i, j)))


# TODO Delete?
func relocate(pos):
	var tile = world_to_map(pos)
	return map_to_world(tile) + HALF_CELL_SIZE
