extends KinematicBody2D

onready var animationPlayer = get_node("AnimationPlayer")
onready var sprite = get_node("Sprite")

const MovementSpeed = 230

var isMoving = false

func _ready():
	animationPlayer.play("Idle")

func _physics_process(delta):
	var inputVector = Vector2()
	if Input.is_action_pressed("move_left"):
		inputVector.x -= 1
	if Input.is_action_pressed("move_right"):
		inputVector.x += 1
	if Input.is_action_pressed("move_up"):
		inputVector.y -= 1
	if Input.is_action_pressed("move_down"):
		inputVector.y += 1
	move_and_slide(inputVector.normalized() * MovementSpeed)
	
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

func getGlobalPosition():
	return to_global(Vector2())
