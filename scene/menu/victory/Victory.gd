extends Control

onready var world = get_node("../..")

func _on_NextLevelButton_pressed():
	world.advanceLevel()
	queue_free()
	get_parent().remove_child(self)
