class_name DeathScreenTransition
extends CanvasModulate

onready var global := get_node("/root/Global") as Global
onready var game := $"/root/Game" as Game
onready var level_label := game.find_node_by_name("LevelLabel") as LevelLabel
onready var game_over_label := game.find_node_by_name("GameOverLabel") as RichTextLabel
onready var press_any_key_to_continue_label := game.find_node_by_name("GameOverPressAnyKeyLabel") as RichTextLabel
onready var credits_label := game.find_node_by_name("GameOverCreditsLabel") as RichTextLabel

onready var ui_walls := game.find_node_by_name("UIWalls") as UIWalls
onready var ui_lives := game.find_node_by_name("UILives") as UILives

onready var game_over_music := game.find_node_by_name("GameOverMusic") as AudioStreamPlayer

onready var _anim_player := $AnimationPlayer as AnimationPlayer
var timer := Timer.new() as Timer


func _input(event):
	if global.state == Global.states.GAME_OVER_PLAYER_CAN_RESTART && event.is_pressed():
		game_over_music.stop()

		global.init()
		var world := get_tree().get_root().get_node("Game/World")
		var level = get_tree().get_root().get_node("Game/World/Level")

		world.remove_child(level)
		level.queue_free()

		var next_level_resource = load(global.get_level_scene_path(1))
		var next_level = next_level_resource.instance()
		next_level.name = "Level"
		world.add_child(next_level)

		level_label.update_level()

		_anim_player.play_backwards("Fade to Grey")
		game_over_label.hide()
		press_any_key_to_continue_label.hide()
		credits_label.hide()

		global.is_player_alive = true

		ui_walls.show()
		ui_lives.reset_ui_lives()

		global.set_state(Global.states.PLAYER_WAITING_TO_ENTER)


func start_game_over() -> void:
	# hide lower left UI
	ui_walls.hide()
	ui_lives.hide()
	game_over_music.play()

	game.find_node_by_name("Player").stop_animation()

	_anim_player.play("Fade to Grey")
	yield(_anim_player, "animation_finished")

	game_over_label.show()
	timer = Timer.new()
	self.add_child(timer)
	timer.name = "show_press_any_key_timer"
	timer.set_wait_time(1)
	timer.connect("timeout", self, "_show_press_any_key")
	timer.set_one_shot(true)
	timer.start()


func _show_press_any_key():
	press_any_key_to_continue_label.show()
	credits_label.show()
	global.set_state(Global.states.GAME_OVER_PLAYER_CAN_RESTART)
