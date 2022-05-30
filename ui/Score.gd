class_name ScoreLabel
extends RichTextLabel

onready var global := get_node("/root/Global") as Global
onready var high_score := $"../HighScoreLabel" as HighScoreLabel

const LENGTH_OF_SCORE := 6
const COLOR_PADDED_ZERO := "fdf7ed"
const COLOR_SCORE := "ffad3b"


func _ready():
	format_score()


func update_score(score_increase: int) -> void:
	if global != null:
		global.current_score += score_increase
		format_score()


func format_score() -> void:
	var bbcode_score := get_color_score(global.current_score, LENGTH_OF_SCORE)
	bbcode_text = "[center]%s[/center]" % bbcode_score

	if global.current_score > global.high_score:
		high_score.update_highscore(bbcode_score)


func get_color_score(score: int, total_length: int) -> String:
	var bbcode_score := ""
	var string_format = str("%0" + str(total_length) + "d")
	var padded_score := str(string_format % score)
	
	if padded_score.length() <= total_length and padded_score[0] == "0":
		bbcode_score = "[color=#" + COLOR_PADDED_ZERO + "]"
		for i in padded_score:
			if i == "0":
				bbcode_score = bbcode_score + "0"
			else:
				bbcode_score = bbcode_score + "[/color][color=#" + COLOR_SCORE + "]" + str(score) + "[/color]"
				return bbcode_score
		return bbcode_score + "[/color]"
	else:
		bbcode_score = "[color=#" + COLOR_SCORE + "]" + str(score) + "[/color]"

	return bbcode_score
