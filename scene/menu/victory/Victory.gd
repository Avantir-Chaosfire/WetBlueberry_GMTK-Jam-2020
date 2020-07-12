extends Control

onready var world = get_node("../..")

func _physics_process(delta):
	if Input.is_action_just_pressed("next_level"):
		advance()

func _on_NextLevelButton_pressed():
	advance()
	
func advance():
	world.advanceLevel()
	queue_free()
	get_parent().remove_child(self)
