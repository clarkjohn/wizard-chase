class_name UILives
extends Node


func _ready():
	reset_ui_lives()


func reset_ui_lives() -> void:
	for i in 4:
		var node = self.get_child(i) as TextureRect
		if $"/root/Global".current_player_lives < i + 1:
			node.visible = false
		else:
			node.visible = true


func hide():
	for i in 4:
		var node = self.get_child(i) as TextureRect
		node.hide()
