extends Node2D

var ENEMY_SPEED = 250

# `this` is the Enemy parent to this Spec
func enemy_process(this, _player, delta):
	var speed = Vector2(1, 0) * delta * ENEMY_SPEED
	this.position += speed.rotated(this.rotation)

func _silence_unused_warnings():
	print(ENEMY_SPEED)
