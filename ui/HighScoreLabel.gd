class_name HighScoreLabel
extends RichTextLabel

onready var global = get_node("/root/Global") as Global
onready var score_label := $"../ScoreLabel"


func _ready():
	bbcode_text = "[center]%s[/center]" % score_label.get_color_score(global.high_score, 6)


func update_highscore2(current_score: int) -> void:
	if global.high_score < current_score:
		global.high_score = current_score

	bbcode_text = "[right]%s[/right]" % global.high_score


func update_highscore(bbcode: String) -> void:
	bbcode_text = "[center]%s[/center]" % bbcode
