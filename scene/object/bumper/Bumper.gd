extends StaticBody2D

const BounceVelocity = 800

func Hit(body, normal):
	var bounceComponent = body.velocity.project(normal)
	var nonBounceComponent = body.velocity - bounceComponent
	body.velocity = nonBounceComponent - (bounceComponent.normalized() * BounceVelocity)
