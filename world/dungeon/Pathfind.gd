class_name PathFind
extends Node2D

onready var game := $"/root/Game"
onready var dungeon = game.find_node_by_name("Dungeon") as Dungeon

var aStar := AStar2D.new()


func _ready():
	init_AStar()


func init_AStar() -> void:
	var map_size := dungeon.get_used_rect().size as Vector2
	aStar.reserve_space(map_size.x * map_size.y)
	#aStar.duplicate
	#print(["astate=", size.x, size.y])

	# Creates AStar grid
	for x in map_size.x:
		for y in map_size.y:
			var astar_cell_id = getAStarCellId(Vector2(x, y))
			# TODO Fix this
			if astar_cell_id == 6 or astar_cell_id == 222:
				aStar.add_point(astar_cell_id, dungeon.map_to_world(Vector2(x, y)), 5)
			elif dungeon.navigable_cell_tile_values.has(dungeon.get_cellv(Vector2(x, y))):
				aStar.add_point(astar_cell_id, dungeon.map_to_world(Vector2(x, y)), 20)

			#else:
			#aStar.add_point(astar_cell_id, map_to_world(Vector2(x, y)), 20)

	# Fills AStar grid with info about valid tiles
	for x in map_size.x:
		for y in map_size.y:
			if dungeon.navigable_cell_tile_values.has(dungeon.get_cellv(Vector2(x, y))):
				var astar_cell_id := getAStarCellId(Vector2(x, y))
				for astar_cell_id_neighbor_map_position in [
					Vector2(x, y - 1), Vector2(x, y + 1), Vector2(x - 1, y), Vector2(x + 1, y)
				]:
					if dungeon.navigable_cell_tile_values.has(dungeon.get_cellv(astar_cell_id_neighbor_map_position)):
						# store for later
						dungeon.navigable_cells.append(astar_cell_id)

						# connect neighbor
						var neightbor_cell_id := getAStarCellId(astar_cell_id_neighbor_map_position)
						if aStar.has_point(neightbor_cell_id):
							aStar.connect_points(astar_cell_id, neightbor_cell_id, false)

	# connect screen wrap tiles
	#print(["editor_markers.screen_wrap_right=",editor_markers.screen_wrap_right])
	# TODO hardcoidng per loading issue
	# r 18,6
	# l 0, 6
	var right := getAStarCellId(Vector2(18, 6))
	var left := getAStarCellId(Vector2(0, 6))
	aStar.connect_points(right, left, false)
	aStar.connect_points(left, right, false)


func getAStarCellId(map_position: Vector2) -> int:
	return int(map_position.y + map_position.x * dungeon.get_used_rect().size.y)


func getAStarPath2(start_position: Vector2, target_position: Vector2, is_adjusted: bool) -> Array:
	return getAStarPath(start_position, target_position)


func getAStarPath(start_position: Vector2, target_position: Vector2) -> Array:
	var start_tilemap_position := dungeon.world_to_map(start_position) as Vector2
	var start_cell_id := getAStarCellId(start_tilemap_position)
	var target_tilemap_position = dungeon.world_to_map(target_position)
	var target_cell_id = getAStarCellId(target_tilemap_position)

	#var clamped_target_position := Vector2(clamp(target_position.x, 0, 300), clamp(target_position.y, 0, 300))
	#var clamped_target_tilemap_position = world_to_map(clamped_target_position)
	#var clamped_target_cell_id=getAStarCellId(clamped_target_tilemap_position)

	#var closet_target_point = aStar.get_closest_point(target_position, false)
	#var closet_target_point_cell_id=getAStarCellId(closet_target_point)

	# Just a small check to see if both points are in the grid
	if aStar.has_point(start_cell_id) and aStar.has_point(target_cell_id):
		var path: Array = Array(aStar.get_point_path(start_cell_id, target_cell_id))

		_center_path(path)
		return path
	else:
		return []


func _center_path(path: Array) -> void:
	# center path points in a cell
	for p in range(path.size()):
		path[p].x = path[p].x + dungeon.half_cell_size.x
		path[p].y = path[p].y + dungeon.half_cell_size.y


func get_path_ahead(source_world_pos: Vector2, direction: Vector2, tiles_ahead: int) -> Vector2:
	var target_path := []
	var source_map_pos := dungeon.world_to_map(source_world_pos) as Vector2
	target_path.append(source_map_pos)
	_get_next_path(source_map_pos, direction, tiles_ahead, target_path)

	var target_world_pos := dungeon.map_to_world(target_path.back()) as Vector2
	target_world_pos.x = target_world_pos.x + dungeon.half_cell_size.x
	target_world_pos.y = target_world_pos.y + half_cell_size.y

	return target_world_pos


# recursive
func _get_next_path(source_map_pos: Vector2, direction: Vector2, tiles_ahead: int, target_path: Array):
	if tiles_ahead == 0:
		return target_path
	else:
		var map_pos_array = []
		for astar_cell in aStar.get_point_connections(getAStarCellId(source_map_pos)):
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


func disable_astar(world_pos: Vector2) -> void:
	aStar.set_point_disabled(getAStarCellId(world_to_map(world_pos)), true)


func enable_astar(world_pos: Vector2) -> void:
	aStar.set_point_disabled(getAStarCellId(world_to_map(world_pos)), false)


func update_astar() -> void:
	var size = self.get_used_rect().size

	for i in size.x:
		for j in size.y:
			var idx = getAStarCellId(Vector2(i, j))
			aStar.add_point(idx, map_to_world(Vector2(i, j)))


func relocate(pos):
	var tile = world_to_map(pos)
	return map_to_world(tile) + half_cell_size


var has_level_init = false


func _process(delta):
	# TODO remove?
	#update_astar()

	if game.has_game_started and not has_level_init:
		_init_level()
		# TODO
		# overlay.init_level()

		has_level_init = true
	var count = 0
	for i in range(get_used_rect().size.x):
		for j in range(get_used_rect().size.y):
			var tile = get_cell(i, j)
			if tile == 12:
				count += 1

	if count == 0:
		print("won")
		set_process(false)
