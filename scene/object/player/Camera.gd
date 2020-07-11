extends Camera2D

const ShakeAmount = 4.0

onready var shakeTimer = get_node("ShakeTimer")

func _physics_process(_delta):
	if not shakeTimer.is_stopped():
		set_offset(Vector2(rand_range(-ShakeAmount, ShakeAmount), rand_range(-ShakeAmount, ShakeAmount)))
	else:
		set_offset(Vector2())
