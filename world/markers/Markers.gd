class_name Markers
extends TileMap

onready var game := $"/root/Game"
onready var door_fore = game.find_node_by_name("DoorFore") as DoorFore

# delay markers
const TILE_DELAY_MARKER_CONTSTANT := 0
const TILE_DELAY_MARKER_1_INT_DELAY := 1
const TILE_DELAY_MARKER_2_INT_DELAY := 2
const TILE_DELAY_MARKER_3_INT_DELAY := 3
const TILE_DELAY_MARKER_4_INT_DELAY := 4
const TILE_DELAY_MARKER_5_INT_DELAY := 5

# button
const TILE_START_BUTTON := 8

# wrap
const TILE_SCREEN_WRAP_RIGHT := 9
const TILE_SCREEN_WRAP_LEFT := 10

onready var delay_constant_array := self.get_used_cells_by_id(TILE_DELAY_MARKER_CONTSTANT) as Array
onready var delay_1_sec_delay_array := self.get_used_cells_by_id(TILE_DELAY_MARKER_1_INT_DELAY) as Array
onready var delay_2_sec_delay_array := self.get_used_cells_by_id(TILE_DELAY_MARKER_2_INT_DELAY) as Array
onready var delay_3_sec_delay_array := self.get_used_cells_by_id(TILE_DELAY_MARKER_3_INT_DELAY) as Array
onready var delay_4_sec_delay_array := self.get_used_cells_by_id(TILE_DELAY_MARKER_4_INT_DELAY) as Array
onready var delay_5_sec_delay_array := self.get_used_cells_by_id(TILE_DELAY_MARKER_5_INT_DELAY) as Array

onready var button_start_map_pos := self.get_used_cells_by_id(TILE_START_BUTTON).front() as Vector2

onready var screen_wrap_right := self.get_used_cells_by_id(TILE_SCREEN_WRAP_RIGHT).front() as Vector2
onready var screen_wrap_left := self.get_used_cells_by_id(TILE_SCREEN_WRAP_LEFT).front() as Vector2


func _ready():
	# graphics for editor only
	hide()


func is_triggering_start_button(position: Vector2) -> bool:
	var current_map_pos: Vector2 = world_to_map(position)
	if current_map_pos == button_start_map_pos:
		return true
	else:
		return false


func is_wrap_tile(map_pos: Vector2) -> bool:
	return true if map_pos == screen_wrap_left or map_pos == screen_wrap_right else false
