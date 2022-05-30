class_name MagicWalls
extends TileMap

onready var game := $"/root/Game" as Game
onready var dungeon := game.find_node_by_name("Dungeon") as Dungeon
onready var ui_walls := game.find_node_by_name("UIWalls") as UIWalls

onready var cast_magic_wall_sound := game.find_node_by_name("CastMagicWallSound") as AudioStreamPlayer

const TILE_CASTED_X_AXIS_MAGIC_WALL := 0
const TILE_CASTED_Y_AXIS_MAGIC_WALL := 1

const MAGIC_WALL_WAIT_DURATION_IN_SEC := 10
const MAX_MAGIC_WALLS := 2

var current_magic_map_pos_array := []
# init at ready
var magic_wall_possible_map_pos_array := [] as Array

onready var magic_walls_glow_particle_2d_1 := game.find_node_by_name("MagicWallGlow2D_1") as Particles2D
onready var magic_walls_glow_particle_2d_2 := game.find_node_by_name("MagicWallGlow2D_2") as Particles2D

onready var magic_walls_xaxis_fading_particle_2d_1 := game.find_node_by_name("MagicWallFading_XAxis_Particle2D_1") as Particles2D
onready var magic_walls_xaxis_fading_particle_2d_2 := game.find_node_by_name("MagicWallFading_XAxis_Particle2D_2") as Particles2D

onready var magic_walls_yaxis_fading_particle_2d_1 := game.find_node_by_name("MagicWallFading_YAxis_Particle2D_1") as Particles2D
onready var magic_walls_yaxis_fading_particle_2d_2 := game.find_node_by_name("MagicWallFading_YAxis_Particle2D_2") as Particles2D

var wall_timer_1 := Timer.new() as Timer
var wall_timer_2 := Timer.new() as Timer


func _ready():
	magic_walls_glow_particle_2d_1.hide()
	magic_walls_glow_particle_2d_2.hide()

	magic_walls_xaxis_fading_particle_2d_1.hide()
	magic_walls_xaxis_fading_particle_2d_2.hide()

	magic_walls_yaxis_fading_particle_2d_1.hide()
	magic_walls_yaxis_fading_particle_2d_2.hide()

	magic_wall_possible_map_pos_array.append_array(dungeon.get_used_cells_by_id(dungeon.TILE_MAGIC_WALL_HORIZONTAL))
	magic_wall_possible_map_pos_array.append_array(dungeon.get_used_cells_by_id(dungeon.TILE_MAGIC_WALL_VERTICAL))

	$"/root/Game/Interface/UI/HBoxContainer/UIWalls".set_slot1_available()
	$"/root/Game/Interface/UI/HBoxContainer/UIWalls".set_slot2_available()


func cast_magic_wall(pos: Vector2, direction: Vector2) -> void:
	# magic wall slots available?
	if not ui_walls.is_slot1_available and not ui_walls.is_slot2_available:
		return

	# already have magic wall casted?
	var map_pos := world_to_map(pos)
	if is_magic_wall(map_pos):
		return

	if magic_wall_possible_map_pos_array.has(map_pos):
		if Vector2.RIGHT == direction or Vector2.LEFT == direction:
			#warnings-disable:
			self.set_cell(map_pos.x, map_pos.y, TILE_CASTED_Y_AXIS_MAGIC_WALL)
		else:
			#warnings-disable:
			self.set_cell(map_pos.x, map_pos.y, TILE_CASTED_X_AXIS_MAGIC_WALL)

		cast_magic_wall_sound.play()

		var particle_pos = _get_world_half_pos(map_pos)
		if ui_walls.is_slot1_available == true:
			ui_walls.set_slot1_unavailable()
			if Vector2.RIGHT == direction or Vector2.LEFT == direction:
				particle_pos.y = particle_pos.y - 10
				_start_add_magic_wall_1(
					wall_timer_1,
					"magic_wall_timer_1",
					1,
					map_pos,
					particle_pos,
					magic_walls_glow_particle_2d_1,
					magic_walls_yaxis_fading_particle_2d_1
				)
			else:
				_start_add_magic_wall_1(
					wall_timer_1,
					"magic_wall_timer_1",
					1,
					map_pos,
					particle_pos,
					magic_walls_glow_particle_2d_1,
					magic_walls_xaxis_fading_particle_2d_1
				)
		else:
			ui_walls.set_slot2_unavailable()
			if Vector2.RIGHT == direction or Vector2.LEFT == direction:
				particle_pos.y = particle_pos.y - 10
				_start_add_magic_wall_1(
					wall_timer_1,
					"magic_wall_timer_1",
					2,
					map_pos,
					particle_pos,
					magic_walls_glow_particle_2d_2,
					magic_walls_yaxis_fading_particle_2d_2
				)
			else:
				_start_add_magic_wall_1(
					wall_timer_1,
					"magic_wall_timer_1",
					2,
					map_pos,
					particle_pos,
					magic_walls_glow_particle_2d_2,
					magic_walls_xaxis_fading_particle_2d_2
				)


func _remove_magic_wall1(map_pos: Vector2):
	ui_walls.set_slot1_available()
	self.set_cell(map_pos.x, map_pos.y, -1)


func _remove_magic_wall2(map_pos: Vector2):
	ui_walls.set_slot2_available()
	self.set_cell(map_pos.x, map_pos.y, -1)


func is_magic_wall(pos: Vector2):
	var magic_wall_map_pos_array := []
	magic_wall_map_pos_array.append_array(get_used_cells_by_id(TILE_CASTED_X_AXIS_MAGIC_WALL))
	magic_wall_map_pos_array.append_array(get_used_cells_by_id(TILE_CASTED_Y_AXIS_MAGIC_WALL))

	return magic_wall_map_pos_array.has(pos)


func _start_add_magic_wall_1(
	timer: Timer,
	timerName,
	magic_wall_index: int,
	magic_walls_world_pos: Vector2,
	particle_world_pos: Vector2,
	glow_particle_2d: Particles2D,
	fading_particle_2d: Particles2D
):
	#glow_particle_2d.set_position(_get_world_half_pos(magic_walls_world_pos))
	#glow_particle_2d.set_one_shot(false)
	#glow_particle_2d.restart()
	#glow_particle_2d.show()

	timer = Timer.new()
	self.add_child(timer)
	timer.name = timerName
	timer.set_wait_time(MAGIC_WALL_WAIT_DURATION_IN_SEC)
	timer.connect(
		"timeout",
		self,
		"_update_magic_breaking_animation_2",
		[
			timer,
			timerName,
			magic_wall_index,
			magic_walls_world_pos,
			particle_world_pos,
			glow_particle_2d,
			fading_particle_2d
		]
	)
	timer.set_one_shot(true)
	timer.start()


func _update_magic_breaking_animation_2(
	timer: Timer,
	timerName,
	magic_wall_index: int,
	magic_walls_world_pos: Vector2,
	particle_world_pos: Vector2,
	glow_particle_2d: Particles2D,
	fading_particle_2d: Particles2D
):
	fading_particle_2d.set_position(particle_world_pos)
	fading_particle_2d.set_one_shot(false)
	fading_particle_2d.restart()
	fading_particle_2d.show()

	timer = Timer.new()
	self.add_child(timer)
	timer.name = timerName
	timer.set_wait_time(2.5)
	timer.connect(
		"timeout",
		self,
		"_remove_magic_wall_3",
		[
			timer,
			timerName,
			magic_wall_index,
			magic_walls_world_pos,
			particle_world_pos,
			glow_particle_2d,
			fading_particle_2d
		]
	)
	timer.set_one_shot(true)
	timer.start()


func _remove_magic_wall_3(
	timer: Timer,
	timerName,
	magic_wall_index: int,
	magic_walls_world_pos: Vector2,
	particle_world_pos: Vector2,
	glow_particle_2d: Particles2D,
	fading_particle_2d: Particles2D
):
	self.set_cell(magic_walls_world_pos.x, magic_walls_world_pos.y, -1)
	#glow_particle_2d.hide()
	fading_particle_2d.set_one_shot(true)

	if magic_wall_index == 1:
		ui_walls.set_slot1_available()
	else:
		ui_walls.set_slot2_available()


func _get_world_half_pos(pos: Vector2) -> Vector2:
	var half_world_pos := self.map_to_world(Vector2(pos.x, pos.y)) as Vector2
	half_world_pos.x = half_world_pos.x + 10
	half_world_pos.y = half_world_pos.y + 10

	return half_world_pos
