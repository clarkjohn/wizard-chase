class_name Treasure
extends TileMap

onready var game := $"/root/Game" as Game
onready var global := get_node("/root/Global") as Global
onready var door_fore := game.find_node_by_name("DoorFore") as DoorFore
onready var score_label := game.find_node_by_name("ScoreLabel") as ScoreLabel
onready var treasure_chest_hover := game.find_node_by_name("TreasureChestHoverScoreLabel")
onready var misc_treasure_hover := game.find_node_by_name("MiscTreasureHoverScoreLabel")
onready var misc_treasure := game.find_node_by_name("MiscTreasure")
onready var animate_coin := game.find_node_by_name("AnimateCoin")

onready var get_coin_sound := game.find_node_by_name("GetCoinSound") as AudioStreamPlayer
onready var get_treasure_chest_sound := game.find_node_by_name("GetTreasureChestSound") as AudioStreamPlayer
onready var get_misc_treasure_sound := game.find_node_by_name("GetMiscTreasureSound") as AudioStreamPlayer

onready var misc_treasure_particle_2d := game.find_node_by_name("MiscTreasureParticle2D") as Particles2D
onready var treasure_chest_particle_2d := game.find_node_by_name("TreasureChestParticle2D") as Particles2D

onready var animated_coin_oneshot: AnimatedTexture = preload("res://world/overlay/treasure/coin/CoinAnimatedOneShot.tres") as AnimatedTexture

# treasure tilemap
const TILE_COIN := 0
const TILE_TREASURE_CHEST := 1
const TILE_MISC_TREASURE := 2

# animated coin tilemap
const TILE_ANIMATED_COIN := 0

onready var treasure_chest_map_pos := self.get_used_cells_by_id(TILE_TREASURE_CHEST).front() as Vector2
onready var misc_treasure_map_pos := self.get_used_cells_by_id(TILE_MISC_TREASURE).front() as Vector2

var treasure_chest_timer := Timer.new() as Timer
var treasure_chest_remove_timer := Timer.new() as Timer
var misc_treasure_timer := Timer.new() as Timer
var animate_random_coin_timer := Timer.new() as Timer

var init := false

var random = RandomNumberGenerator.new()

const MAX_LEVEL_MISC_TREASURE := 11


func _enter_tree():
	self.connect("state_changed", global, "on_state_changed")


func on_state_changed(from: int, to: int) -> void:
	# TODO is this needed with current reset?
	if to == global.states.PLAYER_WAITING_TO_ENTER:
		if !global.has_player_got_misc_treasure():
			# replace placeholder misc treasure tile with level specific
			misc_treasure_particle_2d.restart()
			misc_treasure_particle_2d.set_one_shot(false)
			misc_treasure_particle_2d.show()
			treasure_chest_particle_2d.restart()
			treasure_chest_particle_2d.set_one_shot(false)
			treasure_chest_particle_2d.show()


func _ready():
	hide()
	misc_treasure_particle_2d.hide()
	treasure_chest_particle_2d.hide()

	# remove placeholder
	misc_treasure.hide()

	random.randomize()

	# misc treasure
	for i in MAX_LEVEL_MISC_TREASURE - 1:
		for cell in misc_treasure.get_used_cells_by_id(i):
			misc_treasure.set_cell(cell.x, cell.y, -1)

	# fill coins
	for i in global.empty_coin_map_pos:
		self.set_cell(i.x, i.y, -1)

	# remove placeholder
	self.set_cell(misc_treasure_map_pos.x, misc_treasure_map_pos.y, -1)
	if !global.has_player_got_misc_treasure():
		misc_treasure.show()

		# replace placeholder misc treasure tile with level specific
		misc_treasure.set_cell(misc_treasure_map_pos.x, misc_treasure_map_pos.y, _get_misc_treasure_per_level())

		var misc_world_pos := self.map_to_world(Vector2(misc_treasure_map_pos.x, misc_treasure_map_pos.y)) as Vector2
		misc_world_pos.x = misc_world_pos.x + 10
		misc_world_pos.y = misc_world_pos.y + 10
		misc_treasure_particle_2d.set_position(misc_world_pos)
		misc_treasure_particle_2d.set_one_shot(false)
		misc_treasure_particle_2d.restart()
		misc_treasure_particle_2d.set_modulate(_get_misc_treasure_color_animation_per_level())
		misc_treasure_particle_2d.show()

	var treasure_chest_pos := self.map_to_world(Vector2(treasure_chest_map_pos.x, treasure_chest_map_pos.y)) as Vector2
	treasure_chest_pos.x = treasure_chest_pos.x + 10
	treasure_chest_pos.y = treasure_chest_pos.y + 10
	treasure_chest_particle_2d.set_position(treasure_chest_pos)
	treasure_chest_particle_2d.set_one_shot(false)
	treasure_chest_particle_2d.restart()
	treasure_chest_particle_2d.show()

	self.add_child(animate_random_coin_timer)
	animate_random_coin_timer.set_wait_time(2)
	animate_random_coin_timer.name = "_future_animate_random_coin"
	animate_random_coin_timer.connect("timeout", self, "_future_animate_random_coin")
	animate_random_coin_timer.start()

	show()


func _process(_delta: float):
	if global.state == global.states.ENTERED_MAZE:
		if not init:
			init = true
			_post_init()


func _post_init():
	# start treasure animations
	_finish_treasure_2_remove_animation(
		misc_treasure_timer,
		"misc_treasure_timer",
		6,
		15,
		funcref(self, "_is_misc_treasure_check"),
		misc_treasure_particle_2d,
		misc_treasure,
		misc_treasure_map_pos,
		_get_misc_treasure_per_level()
	)
	_finish_treasure_2_remove_animation(
		treasure_chest_timer,
		"treasure_chest_timer",
		5,
		10,
		funcref(self, "_is_treasure_chest_check"),
		treasure_chest_particle_2d,
		self,
		treasure_chest_map_pos,
		TILE_TREASURE_CHEST
	)


func _is_misc_treasure_check() -> bool:
	return not global.has_player_got_misc_treasure()


func _is_treasure_chest_check() -> bool:
	return global.current_chest_score_index < global.chest_score_value.size()


func _get_misc_treasure_color_animation_per_level() -> String:
	return global.misc_treasure_animation_color[_get_misc_treasure_per_level()]


func _get_misc_treasure_per_level() -> int:
	var misc_treasure_item = global.current_level - 1
	if misc_treasure_item >= MAX_LEVEL_MISC_TREASURE:
		return MAX_LEVEL_MISC_TREASURE - 1
	else:
		return misc_treasure_item


func get_treasure(position: Vector2) -> bool:
	var current_tile: Vector2 = world_to_map(position)

	# coins
	if get_cellv(current_tile) == TILE_COIN or animate_coin.get_cellv(current_tile) == TILE_ANIMATED_COIN:
		global.empty_coin_map_pos.append(current_tile)
		score_label.update_score(20)
		self.set_cellv(current_tile, -1)
		animate_coin.set_cellv(current_tile, -1)
		get_coin_sound.play()

		if get_total_coins_left() == 0:
			door_fore.open_doors()
		return true

	# treasure chest
	elif get_cellv(current_tile) == TILE_TREASURE_CHEST:
		set_cellv(current_tile, -1)
		get_treasure_chest_sound.play()

		var treasure_value := global.chest_score_value[global.current_chest_score_index] as int
		global.current_chest_score_index += 1
		treasure_chest_hover.show_score(treasure_value, map_to_world(treasure_chest_map_pos))
		score_label.update_score(treasure_value)

		if global.current_chest_score_index < global.chest_score_value.size():
			_finish_treasure_2_remove_animation(
				treasure_chest_timer,
				"treasure_chest_timer",
				5,
				10,
				funcref(self, "_is_treasure_chest_check"),
				treasure_chest_particle_2d,
				self,
				treasure_chest_map_pos,
				TILE_TREASURE_CHEST
			)

		return true

	# misc treasure
	elif misc_treasure.get_cellv(current_tile) > -1:
		misc_treasure.set_cellv(current_tile, -1)
		get_misc_treasure_sound.play()

		misc_treasure_hover.show_score(500, map_to_world(misc_treasure_map_pos))
		misc_treasure.set_cell(current_tile.x, current_tile.y, -1)
		global.get_misc_treasure()
		return true

	return false


func get_total_coins_left() -> int:
	return self.get_used_cells_by_id(TILE_COIN).size() + animate_coin.get_used_cells_by_id(TILE_ANIMATED_COIN).size()


func _start_treasure_1_remove_animation(
	timer: Timer,
	timerName,
	show_treasure_interval: int,
	hide_treasure_interval,
	is_treasure_available,
	particle2d: Particles2D,
	tile_map: TileMap,
	world_pos: Vector2,
	treasure_tile: int
):
	if is_treasure_available.call_func():
		particle2d.set_one_shot(false)
		particle2d.restart()
		particle2d.show()

		timer = Timer.new()
		self.add_child(timer)
		timer.name = timerName
		timer.set_wait_time(1)
		timer.connect(
			"timeout",
			self,
			"_finish_treasure_2_remove_animation",
			[
				timer,
				timerName,
				show_treasure_interval,
				hide_treasure_interval,
				is_treasure_available,
				particle2d,
				tile_map,
				world_pos,
				treasure_tile
			]
		)
		timer.set_one_shot(true)
		timer.start()


func _finish_treasure_2_remove_animation(
	timer: Timer,
	timerName,
	show_treasure_interval: int,
	hide_treasure_interval,
	is_treasure_available,
	particle2d: Particles2D,
	tile_map: TileMap,
	world_pos: Vector2,
	treasure_tile: int
):
	particle2d.set_one_shot(true)

	if is_treasure_available.call_func():
		tile_map.set_cell(world_pos.x, world_pos.y, -1)

		timer = Timer.new()
		self.add_child(timer)
		timer.name = timerName
		timer.set_wait_time(hide_treasure_interval)
		timer.connect(
			"timeout",
			self,
			"_start_treasure_3_add_animation",
			[
				timer,
				timerName,
				show_treasure_interval,
				hide_treasure_interval,
				is_treasure_available,
				particle2d,
				tile_map,
				world_pos,
				treasure_tile
			]
		)
		timer.set_one_shot(true)
		timer.start()


func _start_treasure_3_add_animation(
	timer: Timer,
	timerName,
	show_treasure_interval: int,
	hide_treasure_interval,
	is_treasure_available,
	particle2d: Particles2D,
	tile_map: TileMap,
	world_pos: Vector2,
	treasure_tile: int
):
	if is_treasure_available.call_func():
		particle2d.set_one_shot(false)
		particle2d.restart()
		particle2d.show()

		timer = Timer.new()
		self.add_child(timer)
		timer.name = timerName
		timer.set_wait_time(1)
		timer.connect(
			"timeout",
			self,
			"_finish_treasure_4_add_animation",
			[
				timer,
				timerName,
				show_treasure_interval,
				hide_treasure_interval,
				is_treasure_available,
				particle2d,
				tile_map,
				world_pos,
				treasure_tile
			]
		)
		timer.set_one_shot(true)
		timer.start()


func _finish_treasure_4_add_animation(
	timer: Timer,
	timerName,
	show_treasure_interval: int,
	hide_treasure_interval,
	is_treasure_available,
	particle2d: Particles2D,
	tile_map: TileMap,
	world_pos: Vector2,
	treasure_tile: int
):
	particle2d.set_one_shot(true)

	if is_treasure_available.call_func():
		tile_map.set_cell(world_pos.x, world_pos.y, treasure_tile)

		timer = Timer.new()
		self.add_child(timer)
		timer.name = timerName
		timer.set_wait_time(show_treasure_interval)
		timer.connect(
			"timeout",
			self,
			"_start_treasure_1_remove_animation",
			[
				timer,
				timerName,
				show_treasure_interval,
				hide_treasure_interval,
				is_treasure_available,
				particle2d,
				tile_map,
				world_pos,
				treasure_tile
			]
		)
		timer.set_one_shot(true)
		timer.start()


func _future_animate_random_coin():
	# change animated coins back to non moving coin
	var current_animated_coin_array := animate_coin.get_used_cells_by_id(TILE_ANIMATED_COIN) as Array
	if current_animated_coin_array.size() > 0:
		for i in current_animated_coin_array:
			animate_coin.set_cell(i.x, i.y, -1)
			self.set_cell(i.x, i.y, TILE_COIN)

	#switch random non moving coin with animated one shot coin
	var current_coins_map_pos_array := self.get_used_cells_by_id(TILE_COIN)
	if current_coins_map_pos_array.size() > 0:
		var my_random_number = random.randi_range(0, current_coins_map_pos_array.size() - 1)
		var random_coin_map_pos = current_coins_map_pos_array[my_random_number]

		animate_coin.set_cell(random_coin_map_pos.x, random_coin_map_pos.y, -1)
		self.set_cell(random_coin_map_pos.x, random_coin_map_pos.y, -1)
		animate_coin.set_cell(random_coin_map_pos.x, random_coin_map_pos.y, TILE_ANIMATED_COIN)

		# restart oneshot
		animated_coin_oneshot.current_frame = 0
