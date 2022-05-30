extends Node


func _ready():
	hide_all()


func hide_all() -> void:
	for i in self.get_child_count():
		var node = self.get_child(i) as TextureRect
		node.visible = false
