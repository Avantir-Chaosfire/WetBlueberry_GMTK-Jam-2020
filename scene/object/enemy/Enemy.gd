extends Node2D

func unload():
	queue_free()
	get_parent().remove_child(self)
