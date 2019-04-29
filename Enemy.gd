extends Area2D

const Blade = preload("res://Blade.gd")

var SFXEngine

var player
var spawn_area: Area2D
var play_area: Area2D

var in_play_area: bool
var can_take_blade_exit: bool

# one of the specs in res://enemies/, use it for anything specific to a particular enemy type
onready var spec = $Spec

func init(_player, _spawn_area, _play_area):
	player = _player
	spawn_area = _spawn_area
	play_area = _play_area
	in_play_area = false
	can_take_blade_exit = true

func _ready():
	# WAR: we need to use a global audio stream player since we wouldn't
	# be able to play the death sound if the sound player belonged to the
	# enemy
	SFXEngine = get_tree().root.get_node("Session/Game/EnemySounds")
	assert(OK == self.connect("area_entered", self, "on_area_entered"))
	assert(OK == self.connect("area_exited", self, "on_area_exited"))

func on_area_entered(area: Area2D):
	if area is Blade:
		var blade = area
		if blade.engaged:
			# if we were already in the blade when it was engaged, then
			# - we still want to get hit, but we won't get the entered event anymore
			# - Dmitry "fixed" it by taking damage on exit, too
			# - Kajetan added a WAR to stop taking double damage 
			#   * get hit on exit only if we have not already been hit on entry, reset on exit
			#   * this doesn't work with multiple blades, but I don't have time to track blades
			can_take_blade_exit = false
			if is_instance_valid(spec):
				spec.get_hit(self)

	elif area == play_area:
		in_play_area = true

func on_area_exited(area: Area2D):
	if area is Blade:
		var blade = area
		if blade.engaged and can_take_blade_exit and is_instance_valid(spec):
			spec.get_hit(self)
		# this is the "reset" referenced in on_area_entered 
		can_take_blade_exit = true

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
