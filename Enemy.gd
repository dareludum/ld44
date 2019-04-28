extends Area2D

const Blade = preload("res://Blade.gd")

onready var SFXEngine = get_tree().root.get_node("Session").get_node("SoundEngine")

var player
var spawn_area: Area2D
var play_area: Area2D

var in_play_area: bool

# one of the specs in res://enemies/, use it for anything specific to a particular enemy type
onready var spec = $Spec

func init(_player, _spawn_area, _play_area):
	player = _player
	spawn_area = _spawn_area
	play_area = _play_area

func _ready():
	assert(OK == self.connect("area_entered", self, "on_area_entered"))
	assert(OK == self.connect("area_exited", self, "on_area_exited"))

func on_area_entered(area: Area2D):
	if area is Blade and area.engaged:
		# todo: take damage instead
		SFXEngine.play_sfx(SFXEngine.SFX_TYPE.ENEMY_DEATH)
		self.queue_free()
	elif area == play_area:
		in_play_area = true

func on_area_exited(area: Area2D):
	if area == spawn_area:
		# we left the game area or got pushed out of it
		self.queue_free()
	elif area == play_area:
		in_play_area = false

func hit_player(player):
	if is_instance_valid(spec):
		spec.hit_player(self, player)

func _process(delta):
	if is_instance_valid(spec) and is_instance_valid(player):
		spec.enemy_process(self, player, delta)

func cleanup():
	spec = null
	player = null
	spawn_area = null
	play_area = null
	in_play_area = false
