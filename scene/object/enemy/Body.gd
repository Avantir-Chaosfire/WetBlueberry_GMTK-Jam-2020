extends KinematicBody2D

onready var player = get_node("../../Player/Body")

const MaxMovementSpeed = 190
const MaxFarMovementSpeed = 380
const Acceleration = 1200
const DetectionRange = 500
const MourningDetectionRange = 2000
const Friction = 330
const FastSpeedDistance = 501

var velocity = Vector2()

func _physics_process(delta):
	var targetPosition = get_parent().to_local(player.getGlobalPosition())
	var targetVector = targetPosition - position
	
	var detectionRange = DetectionRange
	if player.isMourning:
		detectionRange = MourningDetectionRange
	
	if targetVector.length() < detectionRange:
		var maxMovementSpeed = MaxMovementSpeed
		if targetVector.length() > FastSpeedDistance:
			maxMovementSpeed = MaxFarMovementSpeed
		var acceleration = targetVector.normalized() * Acceleration * delta
		if (velocity + acceleration).length() < maxMovementSpeed:
			velocity += acceleration
		elif velocity.length() < maxMovementSpeed:
			velocity += acceleration
			velocity = velocity.normalized() * min(velocity.length(), maxMovementSpeed)
		else:
			var parallelAcceleration = acceleration.project(velocity)
			if (velocity + parallelAcceleration).length() < velocity.length():
				velocity += parallelAcceleration
			velocity += (acceleration - parallelAcceleration)
	var originalPosition = Vector2(position)
	var slidingVelocity = move_and_slide(velocity)
	if slidingVelocity.length() < velocity.length():
		var newPosition = Vector2(position)
		position = originalPosition
		var collisionInfo = move_and_collide(velocity * delta)
		if collisionInfo:
			collisionInfo.collider.Hit(self, collisionInfo.normal)
		position = newPosition
	velocity = velocity.normalized() * max(0, velocity.length() - (Friction * delta))

func _on_DamageArea_body_entered(body):
	body.Damage()

func getGlobalPosition():
	return to_global(Vector2())

func Damage():
	get_parent().unload()

func Hit(_body, _normal):
	pass
