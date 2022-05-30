class_name UIWalls
extends Node

var texture_wall_unavailable = preload("res://ui/uiwalls/ui_wall_unavailable.png")
var texture_wall_available = preload("res://ui/uiwalls/ui_wall.png")

var is_slot1_available := true
var is_slot2_available := true


func set_slot1_available():
	is_slot1_available = true
	$Wall1.texture = texture_wall_available


func set_slot1_unavailable():
	is_slot1_available = false
	$Wall1.texture = texture_wall_unavailable


func set_slot2_available():
	is_slot2_available = true
	$Wall2.texture = texture_wall_available


func set_slot2_unavailable():
	is_slot2_available = false
	$Wall2.texture = texture_wall_unavailable


func hide():
	$Wall1.hide()
	$Wall2.hide()


func show():
	$Wall1.show()
	$Wall2.show()
