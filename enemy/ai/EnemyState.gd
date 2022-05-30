class_name EnemyState
extends Area2D

func _init():
	pass

func _ready():
	pass

func move(_delta: float, _enemy, _previous_tile: Vector2) -> Vector2:
	return Vector2(0, 0)

func is_able_to_move(enemy, player: Player) -> bool:
	return true

func get_enemy_path(enemy, previous_tile: Vector2) -> Array:
	return []
