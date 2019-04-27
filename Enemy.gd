extends Node2D

const ENEMY_SPEED: float = 200.0

var _player

func set_target(player):
	_player = player

func _ready():
	pass # Replace with function body.

func _process(delta):
	var speed = Vector2(1, 0) * delta * ENEMY_SPEED

	# follow the player
	# self.look_at(_player.position)
	self.position += speed.rotated(self.rotation)

	# damage the player and disappear
	# if abs((self.position - _player.position).length()) < 10:
	#	_player.hp -= 1
	#	self.queue_free()
