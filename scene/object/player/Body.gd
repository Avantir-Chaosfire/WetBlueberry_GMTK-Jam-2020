extends KinematicBody2D

onready var world = get_node("../../../..")
onready var animationPlayer = get_node("AnimationPlayer")
onready var sprite = get_node("Sprite")
onready var attackDelayTimer = get_node("AttackDelayTimer")
onready var mourningTimer = get_node("MourningTimer")
onready var cameraShakeTimer = get_node("Camera/ShakeTimer")
onready var nearbyEnemyDetector = get_node("NearbyEnemyDetector")

const MaxMovementSpeed = 280
const Acceleration = 1600
const Friction = 330
const AttackingFriction = 100
const MourningKills = 5

export var isAttacking = false
export var completeAttack = false setget CompleteAttack

var velocity = Vector2()
var isMoving = false
var playIdleAnimation = false
var killCount = 0
var isMourning = false
var attackQueued = false

func _ready():
	animationPlayer.play("Idle")

func _physics_process(delta):
	if playIdleAnimation:
		playIdleAnimation = false
		animationPlayer.play("Idle")
		
	if isMourning:
		killCount = 0
		if mourningTimer.is_stopped() and len(nearbyEnemyDetector.get_overlapping_bodies() + nearbyEnemyDetector.get_overlapping_areas()) == 0:
			isMourning = false
		
	if killCount >= MourningKills:
		isMourning = true
		mourningTimer.start()
		
	var inputVector = Vector2()
	if not isAttacking:
		if Input.is_action_just_pressed("attack") or attackQueued:
			attackQueued = false
			if attackDelayTimer.is_stopped():
				if Input.is_action_pressed("move_up") and not Input.is_action_pressed("move_down"):
					animationPlayer.play("Punch Up")
				elif not Input.is_action_pressed("move_up") and Input.is_action_pressed("move_down"):
					animationPlayer.play("Punch Down")
				else:
					animationPlayer.play("Punch")
				isAttacking = true
				isMoving = false
			else:
				attackQueued = true
		elif not isMourning:
			if Input.is_action_pressed("move_left"):
				inputVector.x -= 1
			if Input.is_action_pressed("move_right"):
				inputVector.x += 1
			if Input.is_action_pressed("move_up"):
				inputVector.y -= 1
			if Input.is_action_pressed("move_down"):
				inputVector.y += 1
			var inputAcceleration = inputVector.normalized() * Acceleration * delta
			if (velocity + inputAcceleration).length() < MaxMovementSpeed:
				velocity += inputAcceleration
			elif velocity.length() < MaxMovementSpeed:
				velocity += inputAcceleration
				velocity = velocity.normalized() * min(velocity.length(), MaxMovementSpeed)
			else:
				var parallelInputAcceleration = inputAcceleration.project(velocity)
				if (velocity + parallelInputAcceleration).length() < velocity.length():
					velocity += parallelInputAcceleration
				velocity += (inputAcceleration - parallelInputAcceleration)
	
	var friction = Friction
	if isAttacking:
		friction = AttackingFriction
	var originalPosition = Vector2(position)
	var slidingVelocity = move_and_slide(velocity)
	if slidingVelocity.length() < velocity.length():
		var newPosition = Vector2(position)
		position = originalPosition
		var collisionInfo = move_and_collide(velocity * delta)
		if collisionInfo:
			collisionInfo.collider.Hit(self, collisionInfo.normal)
		position = newPosition
	velocity = velocity.normalized() * max(0, velocity.length() - (friction * delta))
	
	if not isAttacking:
		if not isMoving and inputVector.length() > 0:
			isMoving = true
			animationPlayer.play("Walking")
		elif isMoving and not inputVector.length() > 0:
			isMoving = false
			animationPlayer.play("Idle")
		
	if inputVector.x < 0:
		sprite.scale.x = -0.5
	elif inputVector.x > 0:
		sprite.scale.x = 0.5
		
func CompleteAttack(value):
	completeAttack = value
	if completeAttack:
		playIdleAnimation = true
		attackDelayTimer.start()

func getGlobalPosition():
	return to_global(Vector2())
	
func Damage():
	world.FailLevel()

func _on_DamageArea_body_entered(body):
	cameraShakeTimer.start()
	body.Damage()
	killCount += 1
