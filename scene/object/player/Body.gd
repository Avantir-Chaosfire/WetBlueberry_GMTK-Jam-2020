extends KinematicBody2D

const MovementSpeed = 230

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
	move_and_slide(inputVector * MovementSpeed)
