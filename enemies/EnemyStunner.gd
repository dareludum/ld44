extends Node2D

const ENEMY_SPEED = 250
const STUN_DURATION_MS = 750

# `this` is the Enemy parent to this Spec
func enemy_process(this, _player, delta):
	var speed = Vector2(1, 0) * delta * ENEMY_SPEED
	this.position += speed.rotated(this.rotation)

func hit_player(_this, player):
	player.stun(STUN_DURATION_MS)

func _silence_unused_warnings():
	print(ENEMY_SPEED)
