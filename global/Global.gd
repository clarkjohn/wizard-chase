#warning-ignore-all:unused_variable
extends Node2D

var default_player_lives := 3
var current_player_lives := default_player_lives

var current_level := 1  # continues
# actual levels that exist in the /levels folder
const MAX_LEVEL_MAPS := 5

var empty_coin_map_pos := [] as Array

var current_score := 00
# saw this on arcade donky kong sceenshot
var high_score := 7640

#var has_game_started := false

const chest_score_value := [500, 750, 1000, 1250]
var current_chest_score_index := 0

# https://strategywiki.org/wiki/Lock%27n%27Chase/Walkthrough
const misc_treasure_score_value := [200, 300, 500]
const misc_treasure_animation_color := [
	"4ba747", "ac3232", "ee8e2e", "b6cbcf", "9b1a0a", "4ba747", "da4e38", "da4e38", "5698cc", "97da3f", "da4e38"
]

var misc_treasure_get := []

# local
var timer
var is_player_alive

var is_enemies_speed_adjustment_per_level := false

signal state_changed
enum states {
	PLAYER_WAITING_TO_ENTER,
	ENTERED_MAZE,
	DIED_RESTARTING,
	LOADING_NEXT_LEVEL,
	GAME_OVER_RESTARTING,
	GAME_OVER_PLAYER_CAN_RESTART
}
var state: int = states.PLAYER_WAITING_TO_ENTER setget set_state


func set_state(new_state: int) -> void:
	var old_state: int = state
	if new_state == old_state:
		return
	if new_state == null:
		breakpoint
	state = new_state
	emit_signal("state_changed", old_state, new_state)


func _ready():
	set_state(states.PLAYER_WAITING_TO_ENTER)
	init()
	connect("state_changed", self, "on_state_changed")
	connect("state_changed", $"/root/Game".find_node_by_name("Treasure"), "on_state_changed")


func on_state_changed(from: int, to: int) -> void:
	if from == states.GAME_OVER_PLAYER_CAN_RESTART and to == states.PLAYER_WAITING_TO_ENTER:
		$"/root/Game/Audio/GameStartMusic".play()

	if to == states.ENTERED_MAZE and $"/root/Game/Audio/GameStartMusic".playing == true:
		$"/root/Game/Audio/GameStartMusic/GameStartMusicTween".fade_music_out($"/root/Game/Audio/GameStartMusic")


func init() -> void:
	timer = null
	is_player_alive = true
	#is_loading_next_level = false
	empty_coin_map_pos = []
	current_chest_score_index = 0
	current_player_lives = default_player_lives

	#self.set_state(states.ENTERED_MAZE)
	#has_game_started = false
	current_score = 00
	if $"/root/Game/Interface/UI/ScoreLabel" != null:
		$"/root/Game/Interface/UI/ScoreLabel".update_score(0)

	misc_treasure_get = []
	for i in $"/root/Game/World/Level/Treasure".MAX_LEVEL_MISC_TREASURE:
		misc_treasure_get.append(false)

	$"/root/Game/Interface/UI/HBoxContainer/UILives".reset_ui_lives()
	$"/root/Game/Interface/UI/HBoxContainer/UIInventory".hide_all()

	is_enemies_speed_adjustment_per_level = false
	var game_music_start := $"/root/Game/Audio/GameStartMusic" as AudioStreamPlayer
	game_music_start.volume_db = -20
	game_music_start.play()


func player_dies() -> void:
	set_state(states.DIED_RESTARTING)
	is_player_alive = false
	current_player_lives -= 1
	$"/root/Game/Audio/PlayerDieSound".play()

	if current_player_lives == 0:
		timer = Timer.new()
		timer.name = "start_game_over"
		self.add_child(timer)
		timer.set_wait_time(.5)
		timer.connect("timeout", self, "start_game_over")
		timer.set_one_shot(true)
		timer.start()
	else:
		$"/root/Game/Interface/UI/HBoxContainer/UILives".reset_ui_lives()

		timer = Timer.new()
		timer.name = "reset_level"
		self.add_child(timer)
		timer.set_wait_time(1)
		timer.connect("timeout", self, "reset_level")
		timer.set_one_shot(true)
		timer.start()


func reset_level() -> void:
	var map_level := _get_map_level()
	var level_scene_path = get_level_scene_path(map_level)
	$"/root/Game/Interface/SceneTransitionRect".transition_to(level_scene_path)
	set_state(states.PLAYER_WAITING_TO_ENTER)


func start_game_over() -> void:
	current_level = 1
	var map_level := _get_map_level()
	var level_scene_path = get_level_scene_path(map_level)

	$"/root/Game/World/GameOverCanvasModulate".start_game_over()

	#init()
	#set_state(states.PLAYER_WAITING_TO_ENTER)


func get_misc_treasure() -> void:
	var misc_treasue_index := get_misc_treasure_index_for_level()

	misc_treasure_get[misc_treasue_index] = true
	var ui_node = $"/root/Game/Interface/UI/HBoxContainer/UIInventory".get_child(misc_treasue_index) as TextureRect
	if ui_node:
		ui_node.visible = true


func debug_get_misc_treasure(treasure_index : int) -> void:
	var misc_treasue_index := treasure_index

	misc_treasure_get[misc_treasue_index] = true
	var ui_node = $"/root/Game/Interface/UI/HBoxContainer/UIInventory".get_child(misc_treasue_index) as TextureRect
	if ui_node:
		ui_node.visible = true

func has_player_got_misc_treasure() -> bool:
	return misc_treasure_get[get_misc_treasure_index_for_level()]


func get_misc_treasure_index_for_level() -> int:
	var treasure = $"/root/Game".find_node_by_name("Treasure")
	if current_level < treasure.MAX_LEVEL_MISC_TREASURE:
		return current_level - 1
	else:
		return treasure.MAX_LEVEL_MISC_TREASURE - 1


func load_next_level(check_for_total_coins: bool) -> void:
	set_state(states.LOADING_NEXT_LEVEL)
	#if not is_loading_next_level:

	var treasure = $"/root/Game".find_node_by_name("Treasure")

	# TODO Remove is debug on?
	if check_for_total_coins:
		# load each time
		if treasure.get_total_coins_left() != 0:
			return

	#is_loading_next_level = true
	current_level += 1

	# reset last treasure slot to be false
	misc_treasure_get[treasure.MAX_LEVEL_MISC_TREASURE - 1] = false

	# level only
	empty_coin_map_pos = []
	$"/root/Game/World/Level/EnemyAI/EnemyFiend".disable_chase_state()
	$"/root/Game/World/Level/EnemyAI/EnemyLizardMan".disable_chase_state()
	$"/root/Game/World/Level/EnemyAI/EnemySlime".disable_chase_state()
	is_enemies_speed_adjustment_per_level = false

	$"/root/Game/Audio/NextLevelSound".play()

	var map_level := _get_map_level()
	var level_scene_path = get_level_scene_path(map_level)
	$"/root/Game/Interface/SceneTransitionRect".transition_to(level_scene_path)

	current_chest_score_index = 0
	#has_game_started = false

	return


func _get_map_level() -> int:
	var map_level := current_level % MAX_LEVEL_MAPS
	return MAX_LEVEL_MAPS if map_level == 0 else map_level


func get_level_scene_path(level: int) -> String:
	return "res://levels/Level_" + str(level) + ".tscn"
