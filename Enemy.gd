extends Node2D

const ENEMY_SPEED: float = 200.0

func _ready():
	pass # Replace with function body.

func _process(delta):
	var speed = Vector2(1, 0) * delta * ENEMY_SPEED
	self.position += speed.rotated(self.rotation)
