class_name ChestHoverScoreLabel
extends RichTextLabel

var hover_timer := Timer.new() as Timer
const COLOR_SCORE := "ffad3b"


# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_toplevel(true)
	hide()


func show_score(points: int, pos: Vector2) -> void:
	# hack; endline added due to tornado effect being trimmed off
	var label := " \n+" + str(points)
	pos.y -= 20
	pos.x += 10
	self.rect_position = pos

	bbcode_text = "[tornado radius=1 freq=5][color=#" + COLOR_SCORE + "]%s[/color][/tornado]" % label

	self.add_child(hover_timer)
	hover_timer.set_wait_time(1.6)
	hover_timer.connect("timeout", self, "remove_hover")
	hover_timer.set_one_shot(true)
	hover_timer.start()

	self.show()


func remove_hover():
	hide()
