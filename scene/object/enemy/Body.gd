extends KinematicBody2D

onready var world = get_node("../../../..")
onready var player = get_node("../../Player/Body")
onready var animationPlayer = get_node("AnimationPlayer")
onready var sprite = get_node("Sprite")
onready var deathSoundEffect = get_node("DeathSoundEffect")

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
var fleeing = false

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
			if player.mourningState == 1:
				if fleeing and targetVector.length() > 180:
					fleeing = false
				elif targetVector.length() < 120 or fleeing:
					targetVector *= -1
					fleeing = true
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
	dead = true
	animationPlayer.play("Dead")
	collision_layer = 0
	collision_mask = 0
	world.CheckVictory()
	sprite.scale.x = 0.5
	deathSoundEffect.play()

func Hit(_body, _normal):
	pass
		
func IsEnemy():
	return true
