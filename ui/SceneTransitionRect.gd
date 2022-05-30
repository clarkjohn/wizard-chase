class_name SceneTransition
extends ColorRect

onready var _anim_player := $AnimationPlayer as AnimationPlayer
onready var level_label := $"../UI/LevelLabel" as LevelLabel

onready var global := get_node("/root/Global") as Global


func transition_to(_next_scene_path: String) -> void:
	_anim_player.play("Fade")
	yield(_anim_player, "animation_finished")

	var world := get_tree().get_root().get_node("Game/World")
	var level = get_tree().get_root().get_node("Game/World/Level")

	world.remove_child(level)
	level.queue_free()

	var next_level_resource = load(_next_scene_path)
	var next_level = next_level_resource.instance()
	next_level.name = "Level"
	world.add_child(next_level)

	level_label.update_level()

	_anim_player.play_backwards("Fade")

	global.is_player_alive = true
	global.set_state(global.states.PLAYER_WAITING_TO_ENTER)
