extends Area2D

const BULLET_SPEED = 225

const Player = preload("res://Player.gd")
const Blade = preload("res://Blade.gd")

func _ready():
	assert(OK == self.connect("area_entered", self, "on_area_entered"))

func _process(delta):
	var speed = Vector2(1, 0) * delta * BULLET_SPEED
	position += speed.rotated(rotation)

func on_area_entered(area: Area2D):
	# tightly coupled with Dmitry's player structure
	if area is Blade:
		# todo: get destroyed if the blade is engaged and the player has an appropriate upgrade
		return

	var node = area.get_node("../..")  # head => holder => player
	if node is Player:  # warning: this is true not just for the player's head, but also for the blade
		node.hp -= 1
		# todo: play a sound
		self.queue_free()
