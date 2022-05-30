class_name FloorSpikes
extends TileMap

const TILE_FLOOR_SPIKE_INITIAL := 0
const TILE_FLOOR_SPIKE_CONSTANT := 1
const TILE_FLOOR_SPIKE_1_SEC_DELAY := 2
const TILE_FLOOR_SPIKE_2_SEC_DELAY := 3
const TILE_FLOOR_SPIKE_3_SEC_DELAY := 4
const TILE_FLOOR_SPIKE_4_SEC_DELAY := 5
const TILE_FLOOR_SPIKE_5_SEC_DELAY := 6

onready var global := $"/root/Global" as Global
onready var game := $"/root/Game" as Game
onready var dungeon := game.find_node_by_name("Dungeon")  # cyclic
onready var preview := game.find_node_by_name("Preview")
onready var markers := game.find_node_by_name("Markers") as Markers

onready var floor_spikes_animated_initial: AnimatedTexture = preload("res://world/map_generated/floorspikes/FloorSpikes_initial.tres") as AnimatedTexture
onready var floor_spikes_animated_constant: AnimatedTexture = preload("res://world/map_generated/floorspikes/FloorSpikes_constant.tres") as AnimatedTexture
onready var floor_spikes_animated_1_sec_delay: AnimatedTexture = preload("res://world/map_generated/floorspikes/FloorSpikes_1_int_delay.tres") as AnimatedTexture
onready var floor_spikes_animated_2_sec_delay: AnimatedTexture = preload("res://world/map_generated/floorspikes/FloorSpikes_2_int_delay.tres") as AnimatedTexture
onready var floor_spikes_animated_3_sec_delay: AnimatedTexture = preload("res://world/map_generated/floorspikes/FloorSpikes_3_int_delay.tres") as AnimatedTexture
onready var floor_spikes_animated_4_sec_delay: AnimatedTexture = preload("res://world/map_generated/floorspikes/FloorSpikes_4_int_delay.tres") as AnimatedTexture
onready var floor_spikes_animated_5_sec_delay: AnimatedTexture = preload("res://world/map_generated/floorspikes/FloorSpikes_5_int_delay.tres") as AnimatedTexture

var floor_spikes_constant_array := []
var floor_spikes_1_sec_delay_array := []
var floor_spikes_2_sec_delay_array := []
var floor_spikes_3_sec_delay_array := []
var floor_spikes_4_sec_delay_array := []
var floor_spikes_5_sec_delay_array := []
var original_floor_spikes := []

var init := false as bool


func _ready():
	original_floor_spikes = dungeon.get_used_cells_by_id(dungeon.TILE_SPIKES)

	for floor_spike in original_floor_spikes:
		# disable original dungeon spikes
		dungeon.set_cell(floor_spike.x, floor_spike.y, dungeon.TILE_EMPTY_SPIKES_PLACEHOLDER)

		# replace with animated spike based on interval
		self.set_cell(floor_spike.x, floor_spike.y, TILE_FLOOR_SPIKE_INITIAL)


func _process(_delta: float):
	if global.state == global.states.ENTERED_MAZE:
		if not init:
			init = true
			_game_started()


func is_spikes_up(pos: Vector2) -> bool:
	if floor_spikes_constant_array.has(pos):
		return _is_spikes_animation_up(floor_spikes_animated_constant)
	elif floor_spikes_1_sec_delay_array.has(pos):
		return _is_spikes_animation_up(floor_spikes_animated_1_sec_delay)
	elif floor_spikes_2_sec_delay_array.has(pos):
		return _is_spikes_animation_up(floor_spikes_animated_2_sec_delay)
	elif floor_spikes_3_sec_delay_array.has(pos):
		return _is_spikes_animation_up(floor_spikes_animated_3_sec_delay)
	elif floor_spikes_4_sec_delay_array.has(pos):
		return _is_spikes_animation_up(floor_spikes_animated_4_sec_delay)
	elif floor_spikes_5_sec_delay_array.has(pos):
		return _is_spikes_animation_up(floor_spikes_animated_5_sec_delay)
	else:
		return false


func _is_spikes_animation_up(animated_spikes: AnimatedTexture):
	return true if animated_spikes.current_frame > 2 and animated_spikes.current_frame < 6 else false


func _game_started() -> void:
	floor_spikes_animated_initial.set_oneshot(true)

	for floor_spike in original_floor_spikes:
		# set to various timing delays
		if markers.delay_constant_array != null and markers.delay_constant_array.has(floor_spike):
			floor_spikes_animated_constant.set_pause(true)
			floor_spikes_animated_constant.set_current_frame(0)
			self.set_cell(floor_spike.x, floor_spike.y, TILE_FLOOR_SPIKE_CONSTANT)
			floor_spikes_constant_array.append(floor_spike)
			floor_spikes_animated_constant.set_pause(false)
		if markers.delay_1_sec_delay_array != null and markers.delay_1_sec_delay_array.has(floor_spike):
			floor_spikes_animated_1_sec_delay.set_pause(true)
			floor_spikes_animated_1_sec_delay.set_current_frame(0)
			self.set_cell(floor_spike.x, floor_spike.y, TILE_FLOOR_SPIKE_1_SEC_DELAY)
			floor_spikes_1_sec_delay_array.append(floor_spike)
			floor_spikes_animated_1_sec_delay.set_pause(false)
		elif markers.delay_2_sec_delay_array != null and markers.delay_2_sec_delay_array.has(floor_spike):
			floor_spikes_animated_2_sec_delay.set_pause(true)
			floor_spikes_animated_2_sec_delay.set_current_frame(0)
			self.set_cell(floor_spike.x, floor_spike.y, TILE_FLOOR_SPIKE_2_SEC_DELAY)
			floor_spikes_2_sec_delay_array.append(floor_spike)
			floor_spikes_animated_2_sec_delay.set_pause(false)
		elif markers.delay_3_sec_delay_array != null and markers.delay_3_sec_delay_array.has(floor_spike):
			floor_spikes_animated_3_sec_delay.set_pause(true)
			floor_spikes_animated_3_sec_delay.set_current_frame(0)
			self.set_cell(floor_spike.x, floor_spike.y, TILE_FLOOR_SPIKE_3_SEC_DELAY)
			floor_spikes_3_sec_delay_array.append(floor_spike)
			floor_spikes_animated_3_sec_delay.set_pause(false)
		elif markers.delay_4_sec_delay_array != null and markers.delay_4_sec_delay_array.has(floor_spike):
			floor_spikes_animated_4_sec_delay.set_pause(true)
			floor_spikes_animated_4_sec_delay.set_current_frame(0)
			self.set_cell(floor_spike.x, floor_spike.y, TILE_FLOOR_SPIKE_4_SEC_DELAY)
			floor_spikes_4_sec_delay_array.append(floor_spike)
			floor_spikes_animated_4_sec_delay.set_pause(false)
		elif markers.delay_4_sec_delay_array != null and markers.delay_5_sec_delay_array.has(floor_spike):
			floor_spikes_animated_5_sec_delay.set_pause(true)
			floor_spikes_animated_5_sec_delay.set_current_frame(0)
			self.set_cell(floor_spike.x, floor_spike.y, TILE_FLOOR_SPIKE_5_SEC_DELAY)
			floor_spikes_5_sec_delay_array.append(floor_spike)
			floor_spikes_animated_5_sec_delay.set_pause(false)
