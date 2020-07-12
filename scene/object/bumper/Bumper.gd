extends StaticBody2D

onready var bumpSoundEffect = get_node("BumpSoundEffect")

const BounceVelocity = 800

func Hit(body, normal):
	var bounceComponent = body.velocity.project(normal)
	var nonBounceComponent = body.velocity - bounceComponent
	body.velocity = nonBounceComponent - (bounceComponent.normalized() * BounceVelocity)
	bumpSoundEffect.play()
