class_name Game
extends Node2D


# convience, better way?
func find_node_by_name(node_name) -> Node:
	return get_tree().get_root().find_node(node_name, true, false)
