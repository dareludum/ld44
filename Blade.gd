extends Area2D

export(float) var swing_angular_speed
export(float) var swing_cooldown

# load instead of preload to break a cyclical dependency between Blade and Enemy
var Enemy = load("res://Enemy.gd")

var _enemies_hit: Dictionary = {}
var engaged: bool = false

func get_swing_angular_speed():
	return self.swing_angular_speed

func get_swing_cooldown():
	return self.swing_cooldown

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
