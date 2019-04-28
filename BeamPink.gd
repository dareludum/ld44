extends Node2D

const BULLET_SPEED = 225

func _ready():
	pass # Replace with function body.

func _process(delta):
	var speed = Vector2(1, 0) * delta * BULLET_SPEED
	position += speed.rotated(rotation)
