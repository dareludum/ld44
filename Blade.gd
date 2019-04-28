extends Area2D

export(float) var swing_angular_speed
export(float) var swing_range
export(float) var swing_cooldown
export(bool) var can_move_while_swinging
export(bool) var can_kill_projectiles

# load instead of preload to break a cyclical dependency between Blade and Enemy
var Enemy = load("res://Enemy.gd")
var Beam = load("res://BeamPink.gd")

var _enemies_hit: Dictionary = {}
var engaged: bool = false

func get_swing_angular_speed():
	return self.swing_angular_speed

func get_swing_cooldown():
	return self.swing_cooldown

func get_swing_range():
	return self.swing_range

func get_can_move_while_swinging():
	return self.can_move_while_swinging

func set_can_move_while_swinging(value: bool):
	self.can_move_while_swinging = value

func get_can_kill_projectiles():
	return self.can_kill_projectiles

func set_can_kill_projectiles(value: bool):
	self.can_kill_projectiles = value

func _ready():
	assert(OK == self.connect("area_entered", self, "on_area_entered"))

func engage():
	assert(not engaged)
	_enemies_hit.clear()
	engaged = true

func disengage():
	assert(engaged)
	engaged = false

func enemies_hit():
	return _enemies_hit

func on_area_entered(area: Area2D):
	if not engaged:
		return
	var hit = area.get_node("..")
	if hit is Enemy and not (hit in _enemies_hit):
		_enemies_hit[hit] = true
	if area is Beam and self.can_kill_projectiles:
		area.hide()
		area.queue_free()
