extends Control

onready var animationPlayer = get_node("AnimationPlayer")

func _ready():
	animationPlayer.play("FadeIn")


func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
	get_parent().remove_child(self)
