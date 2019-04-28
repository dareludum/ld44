extends Node2D

const ENEMY_SPEED: float = 200.0

const Blade = preload("res://Blade.gd")

var _player

func set_target(player):
	_player = player

func _ready():
	assert(OK == $Area2D.connect("area_entered", self, "on_area_entered"))

func on_area_entered(area: Area2D):
	var node = area.get_node("..")
	if node is Blade and node.engaged:
		# todo: take damage instead
		self.queue_free()

func _process(delta):
	var speed = Vector2(1, 0) * delta * ENEMY_SPEED

	# follow the player
	# self.look_at(_player.position)
	self.position += speed.rotated(self.rotation)

	# damage the player and disappear
	# if abs((self.position - _player.position).length()) < 10:
	#	_player.hp -= 1
	#	self.queue_free()
