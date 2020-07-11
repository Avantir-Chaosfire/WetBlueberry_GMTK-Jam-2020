extends KinematicBody2D

onready var player = get_node("../../Player/Body")

const MovementSpeed = 240
const DetectionRange = 500
const MourningDetectionRange = 2000

func _physics_process(_delta):
	var targetPosition = get_parent().to_local(player.getGlobalPosition())
	var targetVector = targetPosition - position
	
	var detectionRange = DetectionRange
	if player.isMourning:
		detectionRange = MourningDetectionRange
	
	if targetVector.length() < detectionRange:
		move_and_slide(targetVector.normalized() * MovementSpeed)

func _on_DamageArea_body_entered(body):
	body.Damage()

func getGlobalPosition():
	return to_global(Vector2())

func Damage():
	get_parent().unload()
