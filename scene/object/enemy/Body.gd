extends KinematicBody2D

onready var player = get_node("../../../Player/Body")

const MovementSpeed = 120
const DetectionRange = 500

func _physics_process(delta):
	var targetPosition = get_parent().to_local(player.getGlobalPosition())
	var targetVector = targetPosition - position
	if targetVector.length() < DetectionRange:
		move_and_slide(targetVector.normalized() * MovementSpeed)
