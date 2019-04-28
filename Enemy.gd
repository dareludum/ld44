extends Node2D

const Blade = preload("res://Blade.gd")

onready var SFXEngine = get_tree().root.get_node("Session").get_node("SoundEngine")

var _player

# one of the specs in res://enemies/, use it for anything specific to a particular enemy type
onready var spec = $Spec

onready var play_area = get_node("../PlayArea")

func set_target(player):
	_player = player

func _ready():
	assert(OK == $Area2D.connect("area_entered", self, "on_area_entered"))
	assert(OK == $Area2D.connect("area_exited", self, "on_area_exited"))

func on_area_entered(area: Area2D):
	if area is Blade and area.engaged:
		# todo: take damage instead
		SFXEngine.play_sfx(SFXEngine.SFX_TYPE.SFX_ENEMY_DEATH)
		self.queue_free()

func on_area_exited(area: Area2D):
	if area == play_area:
		# we left the play area / the play area exited us
		self.queue_free()

func _process(delta):
	var speed = Vector2(1, 0) * delta * spec.ENEMY_SPEED

	# follow the player
	# self.look_at(_player.position)
	self.position += speed.rotated(self.rotation)

	# damage the player and disappear
	# if abs((self.position - _player.position).length()) < 10:
	#	_player.hp -= 1
	#	self.queue_free()
