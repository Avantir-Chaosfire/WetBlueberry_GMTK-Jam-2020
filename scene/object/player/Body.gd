extends KinematicBody2D

onready var world = get_node("../../../..")
onready var inGameUI = get_node("../../../../GUI/InGameMenu")
onready var animationPlayer = get_node("PlayerAnimationPlayer")
onready var helmetAnimationPlayer = get_node("HelmetAnimationPlayer")
onready var model = get_node("PlayerModel")
onready var attackDelayTimer = get_node("AttackDelayTimer")
onready var cameraShakeTimer = get_node("Camera/ShakeTimer")
onready var nearbyEnemyDetector = get_node("NearbyEnemyDetector")
onready var camera = get_node("Camera")
onready var spawnSoundEffect = get_node("SpawnSoundEffect")
onready var attackSoundEffect = get_node("AttackSoundEffect")

const MaxMovementSpeed = 280
const Acceleration = 1600
const Friction = 330
const KnockbackForce = 120
const AttackingFriction = 100
const MourningKills = 5

export var isAttacking = false
export var mourningState = 0 setget SetMourningState
export var completeAttack = false setget CompleteAttack
export var completeHelmetAttack = false setget CompleteHelmetAttack
export var isHelmetActive = false setget SetHelmetActive

var velocity = Vector2()
var isMoving = false
var playIdleAnimation = false
var playHelmetIdleAnimation = false
var playMourningAnimation = false
var killCount = 0
var isMourning = false
var attackQueued = false
var attackDirection = Vector2()
var facingDirection = Vector2()

func _ready():
	animationPlayer.play("Idle")
	helmetAnimationPlayer.play("Inactive")
	inGameUI.SetKillCount(killCount)
	spawnSoundEffect.play()

func _physics_process(delta):
	if playHelmetIdleAnimation:
		playHelmetIdleAnimation = false
		helmetAnimationPlayer.play("Idle")
	if playIdleAnimation:
		playIdleAnimation = false
		animationPlayer.play("Idle")
	if playMourningAnimation:
		playMourningAnimation = false
		animationPlayer.play("Mourning")
		
	if isMourning:
		killCount = 0
		if mourningState == 3 and len(nearbyEnemyDetector.get_overlapping_bodies() + nearbyEnemyDetector.get_overlapping_areas()) == 0:
			animationPlayer.play("End Mourning")
		
	if killCount >= MourningKills:
		isMourning = true
		animationPlayer.play("Start Mourning")
		camera.ZoomIn()
		
	var inputVector = Vector2()
	if not isAttacking:
		if isMourning:
			if (Input.is_action_just_pressed("attack") or attackQueued) and isHelmetActive and not helmetAnimationPlayer.current_animation in ["Left Deploy", "Right Deploy"]:
				attackQueued = false
				var attackVector = Vector2()
				if Input.is_action_pressed("move_up") and not Input.is_action_pressed("move_down"):
					attackVector.y = -1
				elif not Input.is_action_pressed("move_up") and Input.is_action_pressed("move_down"):
					attackVector.y = 1
				if Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
					attackVector.x = -1
				elif not Input.is_action_pressed("move_left") and Input.is_action_pressed("move_right"):
					attackVector.x = 1
				if attackVector == Vector2():
					attackVector = Vector2(model.scale.x, 0)
				attackDirection = attackVector
				if attackVector == Vector2(1, 0):
					helmetAnimationPlayer.play("Attack Right")
					isAttacking = true
				elif attackVector == Vector2(1, 1):
					helmetAnimationPlayer.play("Attack Down Right")
					isAttacking = true
				elif attackVector == Vector2(0, 1):
					helmetAnimationPlayer.play("Attack Down")
					isAttacking = true
				elif attackVector == Vector2(-1, 1):
					helmetAnimationPlayer.play("Attack Down Left")
					isAttacking = true
				elif attackVector == Vector2(-1, 0):
					helmetAnimationPlayer.play("Attack Left")
					isAttacking = true
				elif attackVector == Vector2(-1, -1):
					helmetAnimationPlayer.play("Attack Up Left")
					isAttacking = true
				elif attackVector == Vector2(0, -1):
					helmetAnimationPlayer.play("Attack Up")
					isAttacking = true
				elif attackVector == Vector2(1, -1):
					helmetAnimationPlayer.play("Attack Up Right")
					isAttacking = true
				velocity += attackDirection * KnockbackForce
				attackSoundEffect.play()
		else:
			if Input.is_action_just_pressed("attack") or attackQueued:
				attackQueued = false
				if attackDelayTimer.is_stopped():
					if Input.is_action_pressed("move_up") and not Input.is_action_pressed("move_down"):
						animationPlayer.play("Punch Up")
					elif not Input.is_action_pressed("move_up") and Input.is_action_pressed("move_down"):
						animationPlayer.play("Punch Down")
					else:
						if facingDirection == Vector2(0, -1):
							animationPlayer.play("Punch Up")
						elif facingDirection == Vector2(0, 1):
							animationPlayer.play("Punch Down")
						else:
							animationPlayer.play("Punch")
					isAttacking = true
					isMoving = false
					attackSoundEffect.play()
				else:
					attackQueued = true
			else:
				if Input.is_action_pressed("move_left"):
					inputVector.x -= 1
					facingDirection = Vector2(-1, 0)
				if Input.is_action_pressed("move_right"):
					inputVector.x += 1
					facingDirection = Vector2(1, 0)
				if Input.is_action_pressed("move_up"):
					inputVector.y -= 1
					facingDirection = Vector2(0, -1)
				if Input.is_action_pressed("move_down"):
					inputVector.y += 1
					facingDirection = Vector2(0, 1)
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
	
	if not isAttacking and not isMourning:
		if not isMoving and inputVector.length() > 0:
			isMoving = true
			animationPlayer.play("Walking")
		elif isMoving and not inputVector.length() > 0:
			isMoving = false
			animationPlayer.play("Idle")
		
	if inputVector.x < 0:
		model.scale.x = -1
	elif inputVector.x > 0:
		model.scale.x = 1
		
func IsEnemy():
	return false
		
func CompleteAttack(value):
	completeAttack = value
	if completeAttack:
		playIdleAnimation = true
		attackDelayTimer.start()
		
func CompleteHelmetAttack(value):
	completeHelmetAttack = value
	if completeHelmetAttack:
		playHelmetIdleAnimation = true
		
func SetMourningState(value):
	mourningState = value
	if mourningState == 2:
		playMourningAnimation = true
	elif mourningState == 4:
		camera.ZoomOut()
	elif mourningState == 5:
		isMourning = false
		playIdleAnimation = true
		killCount = 0
		inGameUI.SetKillCount(killCount)
		
func SetHelmetActive(value):
	if not isHelmetActive == value:
		isHelmetActive = value
		if isHelmetActive:
			if model.scale.x < 0:
				helmetAnimationPlayer.play("Left Deploy")
			else:
				helmetAnimationPlayer.play("Right Deploy")
		else:
			helmetAnimationPlayer.play("Inactive")

func getGlobalPosition():
	return to_global(Vector2())
	
func Damage(enemyName):
	world.FailLevel(enemyName)
	
func SetKillCount(value):
	killCount = value
	inGameUI.SetKillCount(killCount)

func _on_DamageArea_body_entered(body):
	cameraShakeTimer.start()
	body.Damage()
	if not isMourning:
		killCount += 1
		inGameUI.SetKillCount(killCount)
