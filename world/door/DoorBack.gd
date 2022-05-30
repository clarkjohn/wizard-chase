class_name DoorBack
extends TileMap

const CLOSE_TOP_DOOR_CELL_VALUE := 0
const CLOSE_BOTTOM_DOOR_CELL_VALUE := 1
const OPEN_TOP_DOOR_CELL_VALUE := 2
const OPEN_BOTTOM_DOOR_CELL_VALUE := 3

var door_cell_array := self.get_used_cells_by_id(OPEN_BOTTOM_DOOR_CELL_VALUE)

var door_tiles := []


func _ready():
	# block off edge of door tiles
	for exit_doors_cell_position in door_cell_array:
		door_tiles.append(Vector2(exit_doors_cell_position.x + 2, exit_doors_cell_position.y + 1))
