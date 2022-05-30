extends Node2D

onready var global := get_node("/root/Global")
onready var game := $"/root/Game" as Game
onready var player = game.find_node_by_name("Player") as Player
onready var treasure = game.find_node_by_name("Treasure") as Treasure

onready var total_coins_in_level := treasure.get_used_cells_by_id(treasure.TILE_COIN).size() as int

const POSSIBLE_WANDER_DIRECTIONS = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]

const PERCENTAGE_OF_COINS_LEFT_TO_INCREASE_FIEND_SPEED := .2

const MAX_ENEMY_SPEED_FACTOR_TO_PLAYER := 1.05
const ENEMY_INITIAL_SPEED_FACTOR_TO_PLAYER := .8

var enemy_speed_increase_per_level
var max_enemy_speed
var inital_enemy_speed


func _ready():
	# distribute wander directions; might be more than 4 enemies later on
	for i in self.get_child_count():
		self.get_child(i).wander_direction = POSSIBLE_WANDER_DIRECTIONS[i % POSSIBLE_WANDER_DIRECTIONS.size()]

	inital_enemy_speed = self.get_child(0).speed
	enemy_speed_increase_per_level = (player.speed - inital_enemy_speed) / 10
	max_enemy_speed = player.speed * MAX_ENEMY_SPEED_FACTOR_TO_PLAYER as float


func _process(_delta) -> void:
	if (
		not $EnemyFiend.is_chase_state_enabled
		and (treasure.get_total_coins_left() < total_coins_in_level * PERCENTAGE_OF_COINS_LEFT_TO_INCREASE_FIEND_SPEED)
	):
		$EnemyFiend.enable_chase_state()

	if not $EnemyLizardMan.is_chase_state_enabled and global.current_chest_score_index > 1:
		$EnemyLizardMan.enable_chase_state()

	if not $EnemySlime.is_chase_state_enabled and global.current_chest_score_index > 2:
		$EnemySlime.enable_chase_state()

	if not global.is_enemies_speed_adjustment_per_level:
		global.is_enemies_speed_adjustment_per_level = true

		for i in self.get_child_count():
			var current_speed = self.get_child(i).speed
			var speed_increase = (
				0
				if global.current_level == 1
				else enemy_speed_increase_per_level * (global.current_level - 1)
			)
			self.get_child(i).speed = clamp(current_speed + speed_increase, 0, max_enemy_speed)
