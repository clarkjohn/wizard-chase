class_name DoorFore
extends TileMap

onready var door_back := $"../DoorBack" as DoorBack

const TILE_CLOSE_TOP_DOOR := 0
const TILE_CLOSE_BOTTOM_DOOR := 1
const TILE_OPEN_TOP_DOOR := 2
const TILE_OPEN_BOTTOM_DOOR := 3

#warning-ignore:unused_variable
var door_cell_array := self.get_used_cells_by_id(TILE_OPEN_BOTTOM_DOOR)
var door_side_tiles := []
var doorway_tiles := []
var exit_pos := []
var is_door_open := true


func _ready():
	for doors_cell_pos in door_back.door_cell_array:
		door_side_tiles.append(Vector2(doors_cell_pos.x + 2, doors_cell_pos.y))
		doorway_tiles.append(Vector2(doors_cell_pos.x + 1, doors_cell_pos.y))
		if _is_top_door(doors_cell_pos):
			exit_pos.append(Vector2(doors_cell_pos.x + 1, doors_cell_pos.y))
		else:
			exit_pos.append(Vector2(doors_cell_pos.x + 1, doors_cell_pos.y + 1))


func close_doors() -> void:
	is_door_open = false
	for exit_doors_cell_pos in door_back.door_cell_array:
		if _is_top_door(exit_doors_cell_pos):
			door_back.set_cell(exit_doors_cell_pos.x, exit_doors_cell_pos.y, TILE_CLOSE_BOTTOM_DOOR)
			door_back.set_cell(exit_doors_cell_pos.x, exit_doors_cell_pos.y - 1, TILE_CLOSE_TOP_DOOR)
			self.set_cell(exit_doors_cell_pos.x, exit_doors_cell_pos.y, -1)
			self.set_cell(exit_doors_cell_pos.x, exit_doors_cell_pos.y - 1, -1)
		else:
			self.set_cell(exit_doors_cell_pos.x, exit_doors_cell_pos.y, TILE_CLOSE_BOTTOM_DOOR)
			self.set_cell(exit_doors_cell_pos.x, exit_doors_cell_pos.y - 1, TILE_CLOSE_TOP_DOOR)
			door_back.set_cell(exit_doors_cell_pos.x, exit_doors_cell_pos.y, -1)
			door_back.set_cell(exit_doors_cell_pos.x, exit_doors_cell_pos.y - 1, -1)


func open_doors() -> void:
	is_door_open = true
	for exit_doors_cell_pos in door_back.door_cell_array:
		if _is_top_door(exit_doors_cell_pos):
			door_back.set_cell(exit_doors_cell_pos.x, exit_doors_cell_pos.y, TILE_OPEN_BOTTOM_DOOR)
			door_back.set_cell(exit_doors_cell_pos.x, exit_doors_cell_pos.y - 1, TILE_OPEN_TOP_DOOR)
			self.set_cell(exit_doors_cell_pos.x, exit_doors_cell_pos.y, -1)
			self.set_cell(exit_doors_cell_pos.x, exit_doors_cell_pos.y - 1, -1)
		else:
			self.set_cell(exit_doors_cell_pos.x, exit_doors_cell_pos.y, -1)
			self.set_cell(exit_doors_cell_pos.x, exit_doors_cell_pos.y - 1, TILE_OPEN_TOP_DOOR)
			door_back.set_cell(exit_doors_cell_pos.x, exit_doors_cell_pos.y, TILE_OPEN_BOTTOM_DOOR)
			door_back.set_cell(exit_doors_cell_pos.x, exit_doors_cell_pos.y - 1, -1)


func _is_top_door(pos: Vector2) -> bool:
	# TODO fix this constant
	return true if pos.y < 10 else false


func is_door_tile_navigable(pos: Vector2) -> bool:
	if door_side_tiles.has(pos):
		return false
	elif !is_door_open and doorway_tiles.has(pos):
		return false
	else:
		return true


func has_player_exited_level(map_pos: Vector2) -> bool:
	return true if exit_pos.has(map_pos) else false
