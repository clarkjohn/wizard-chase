class_name WallBlades
extends TileMap

const WALL_BLADES_INITIAL_TILE := 1

const WALL_BLADES_CONSTANT_TILE := 1
const WALL_BLADES_1_SEC_DELAY_TILE := 2
const WALL_BLADES_2_SEC_DELAY_TILE := 3
const WALL_BLADES_3_SEC_DELAY_TILE := 4
const WALL_BLADES_4_SEC_DELAY_TILE := 5
const WALL_BLADES_5_SEC_DELAY_TILE := 6

onready var global := $"/root/Global" as Global
onready var game := $"/root/Game" as Game
onready var delayMarkers := game.find_node_by_name("Markers") as Markers
onready var overlay := game.find_node_by_name("Overlay") as Overlay

onready var wall_blades_animated_initial: AnimatedTexture = preload("res://world/map_generated/wallblades/WallBlades_initial.tres") as AnimatedTexture
onready var wall_blades_animated_constant: AnimatedTexture = preload("res://world/map_generated/wallblades/WallBlades_constant.tres") as AnimatedTexture
onready var wall_blades_animated_1_sec_delay: AnimatedTexture = preload("res://world/map_generated/wallblades/WallBlades_1_int_delay.tres") as AnimatedTexture
onready var wall_blades_animated_2_sec_delay: AnimatedTexture = preload("res://world/map_generated/wallblades/WallBlades_2_int_delay.tres") as AnimatedTexture
onready var wall_blades_animated_3_sec_delay: AnimatedTexture = preload("res://world/map_generated/wallblades/WallBlades_3_int_delay.tres") as AnimatedTexture
onready var wall_blades_animated_4_sec_delay: AnimatedTexture = preload("res://world/map_generated/wallblades/WallBlades_4_int_delay.tres") as AnimatedTexture
onready var wall_blades_animated_5_sec_delay: AnimatedTexture = preload("res://world/map_generated/wallblades/WallBlades_5_int_delay.tres") as AnimatedTexture

var wall_blades_constant_array := []
var wall_blades_1_sec_delay_array := []
var wall_blades_2_sec_delay_array := []
var wall_blades_3_sec_delay_array := []
var wall_blades_4_sec_delay_array := []
var wall_blades_5_sec_delay_array := []

var original_wall_blades := []
var init_wall_blades := false as bool



func _ready():
	original_wall_blades = overlay.get_wall_blades()
	
	for wall_blade_pos in original_wall_blades:
		# disable original wall blades
		overlay.set_cell(wall_blade_pos.x, wall_blade_pos.y, -1)
		self.set_cell(wall_blade_pos.x,wall_blade_pos.y, WALL_BLADES_INITIAL_TILE)


func is_blades_up(pos: Vector2) -> bool:
	if wall_blades_constant_array.has(pos):
		return _is_wall_blades_animation_extracted(wall_blades_animated_initial)
	elif wall_blades_1_sec_delay_array.has(pos):
		return _is_wall_blades_animation_extracted(wall_blades_animated_1_sec_delay)
	elif wall_blades_2_sec_delay_array.has(pos):
		return _is_wall_blades_animation_extracted(wall_blades_animated_2_sec_delay)
	elif wall_blades_3_sec_delay_array.has(pos):
		return _is_wall_blades_animation_extracted(wall_blades_animated_3_sec_delay)
	elif wall_blades_4_sec_delay_array.has(pos):
		return _is_wall_blades_animation_extracted(wall_blades_animated_4_sec_delay)
	elif wall_blades_5_sec_delay_array.has(pos):
		return _is_wall_blades_animation_extracted(wall_blades_animated_5_sec_delay)
	else:
		return false


func _is_wall_blades_animation_extracted(animated_blades: AnimatedTexture):
	return true if animated_blades.current_frame > 3 and animated_blades.current_frame < 9 else false


func _process(_delta: float):
	if global.state == global.states.ENTERED_MAZE:
		if not init_wall_blades:
			init_wall_blades = true
			init()


# TODO this all needs to be cleaned up... this was intended to:
# 1) Before the player enteres the maze, the floor and wall spikes were 
#    going to run on their timers to give a preview of the level
# 2) when the player enteres the maze, the timers would reset (but not in
#    mid-animation)
# Having issues getting this to work
func init() -> void:
	for wall_blade in original_wall_blades:
		self.set_cell(wall_blade.x,wall_blade.y, -1) 
		
		# set to various timing delays
		if delayMarkers.delay_constant_array.has(wall_blade):
			wall_blades_animated_constant.set_pause(true)
			wall_blades_animated_constant.set_current_frame(0)
			self.set_cell(wall_blade.x, wall_blade.y, WALL_BLADES_CONSTANT_TILE)
			wall_blades_constant_array.append(wall_blade)
			wall_blades_animated_constant.set_pause(false)
		elif delayMarkers.delay_1_sec_delay_array.has(wall_blade):
			wall_blades_animated_1_sec_delay.set_pause(true)
			wall_blades_animated_1_sec_delay.set_current_frame(0)
			self.set_cell(wall_blade.x, wall_blade.y, WALL_BLADES_1_SEC_DELAY_TILE)
			wall_blades_1_sec_delay_array.append(wall_blade)
			wall_blades_animated_1_sec_delay.set_pause(false)		
		elif delayMarkers.delay_2_sec_delay_array.has(wall_blade):
			wall_blades_animated_2_sec_delay.set_pause(true)
			wall_blades_animated_2_sec_delay.set_current_frame(0)
			self.set_cell(wall_blade.x, wall_blade.y, WALL_BLADES_2_SEC_DELAY_TILE)
			wall_blades_2_sec_delay_array.append(wall_blade)
			wall_blades_animated_2_sec_delay.set_pause(false)
		elif delayMarkers.delay_3_sec_delay_array.has(wall_blade):
			wall_blades_animated_3_sec_delay.set_pause(true)
			wall_blades_animated_3_sec_delay.set_current_frame(0)
			self.set_cell(wall_blade.x, wall_blade.y, WALL_BLADES_3_SEC_DELAY_TILE)
			wall_blades_3_sec_delay_array.append(wall_blade)
			wall_blades_animated_3_sec_delay.set_pause(false)
		elif delayMarkers.delay_4_sec_delay_array.has(wall_blade):
			wall_blades_animated_4_sec_delay.set_pause(true)
			wall_blades_animated_4_sec_delay.set_current_frame(0)
			self.set_cell(wall_blade.x, wall_blade.y, WALL_BLADES_4_SEC_DELAY_TILE)
			wall_blades_4_sec_delay_array.append(wall_blade)
			wall_blades_animated_4_sec_delay.set_pause(false)
		elif delayMarkers.delay_5_sec_delay_array.has(wall_blade):
			wall_blades_animated_5_sec_delay.set_pause(true)
			wall_blades_animated_5_sec_delay.set_current_frame(0)
			self.set_cell(wall_blade.x, wall_blade.y, WALL_BLADES_5_SEC_DELAY_TILE)
			wall_blades_5_sec_delay_array.append(wall_blade)
			wall_blades_animated_5_sec_delay.set_pause(false)
