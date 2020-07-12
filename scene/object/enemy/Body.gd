extends KinematicBody2D

onready var world = get_node("../../../..")
onready var player = get_node("../../Player/Body")
onready var animationPlayer = get_node("AnimationPlayer")
onready var sprite = get_node("Sprite")

const MaxMovementSpeed = 190
const MaxFarMovementSpeed = 245
const Acceleration = 1200
const DetectionRange = 500
const MourningDetectionRange = 2000
const Friction = 330
const FastSpeedDistance = 501

var velocity = Vector2()
var isMoving = false
var dead = false

func _ready():
	animationPlayer.play("Idle")

func _physics_process(delta):
	if not dead:
		var targetPosition = get_parent().to_local(player.getGlobalPosition())
		var targetVector = targetPosition - position
		
		var detectionRange = DetectionRange
		if player.isMourning:
			detectionRange = MourningDetectionRange
		
		if targetVector.length() < detectionRange:
			if not isMoving:
				isMoving = true
				animationPlayer.play("Walking")
			if targetVector.x < 0:
				sprite.scale.x = -0.5
			elif targetVector.x > 0:
				sprite.scale.x = 0.5
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
		else:
			if isMoving:
				isMoving = false
				animationPlayer.play("Idle")
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
	if not dead:
		body.Damage(get_parent().name)

func getGlobalPosition():
	return to_global(Vector2())

func Damage():
	print("Damage")
	dead = true
	print("1")
	animationPlayer.play("Dead")
	print("2")
	collision_layer = 0
	print("3")
	world.CheckVictory()
	print("Complete")
	sprite.scale.x = 0.5

func Hit(_body, _normal):
	pass
		
func IsEnemy():
	return true
