class_name LevelLabel
extends RichTextLabel

onready var global := get_node("/root/Global")  #
onready var score_label := $"../ScoreLabel"


func _ready():
	update_level()


func update_level():
	bbcode_text = "[center]%s[/center]" % score_label.get_color_score(global.current_level, 2)
