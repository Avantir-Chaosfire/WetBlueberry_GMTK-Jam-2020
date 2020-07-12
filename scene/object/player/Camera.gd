extends Camera2D

const ShakeAmount = 4.0

onready var shakeTimer = get_node("ShakeTimer")
onready var animationPlayer = get_node("AnimationPlayer")

func _ready():
	animationPlayer.play("Idle")

func _physics_process(_delta):
	if not shakeTimer.is_stopped():
		set_offset(Vector2(rand_range(-ShakeAmount, ShakeAmount), rand_range(-ShakeAmount, ShakeAmount)))
	else:
		set_offset(Vector2())

func ZoomIn():
	animationPlayer.play("Zoom In")
	
func ZoomOut():
	animationPlayer.play("Zoom Out")
