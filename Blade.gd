extends Area2D

export(float) var swing_angular_speed
export(float) var swing_range
export(float) var swing_cooldown
export(bool) var can_move_while_swinging
export(bool) var can_kill_projectiles
export(bool) var shields_against_projectiles

# load instead of preload to break a cyclical dependency between Blade and Enemy
var Enemy = load("res://Enemy.gd")
var Beam = load("res://BeamPink.gd")
var EnemyBossStation = load("res://enemies/EnemyBossStation.gd")

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
	assert(OK == self.connect("area_exited", self, "on_area_exited"))

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
		if area is Beam and self.shields_against_projectiles:
			area.hide()
			area.queue_free()
		return

	maybe_hit_enemy(area)

	if area is Beam and self.can_kill_projectiles:
		area.hide()
		area.queue_free()

func on_area_exited(area: Area2D):
	maybe_hit_enemy(area)

func maybe_hit_enemy(area: Area2D):
	if area is Enemy and not (area in _enemies_hit):
		# quick and dirty hack: this should only count enemies that died
		# but the boss is the only enemy that doesn't die from one hit
		if area.get_node("Spec") is EnemyBossStation:
			return
		_enemies_hit[area] = true

func update_multiplier(value: float):
	# value is 1.0 to 2.0
	var non_red_color = clamp(2 - value, 0.0, 1.0)
	$Sprite.modulate.g = non_red_color
	$Sprite.modulate.b = non_red_color
