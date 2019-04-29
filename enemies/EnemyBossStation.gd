extends Node2D

signal hp_changed
signal died

const ENEMY_SPEED = 300
const PUSHBACK_DISTANCE = 120
const MAX_HP = 60

const Bullet = preload("res://scenes/BeamPink.tscn")

var hp: int = MAX_HP setget set_hp, get_hp
var phase: int = 0

# major fires once per wave, minor fires BULLETS_PER_WAVE times
const BULLETS_PER_WAVE = 8
const BULLET_MINOR_COOLDOWN = 0.2
const BULLET_MAJOR_COOLDOWN = 5
var bullet_major: Timer = Timer.new()
var bullet_minor: Timer = Timer.new()
var bullets_spawned: int = 0  # reset every wave

onready var health_bar_holder = get_node("../HealthBarHolder")
onready var health_bar = health_bar_holder.get_node("HealthBar")
var bullet_distance
var bullet_angle

var fun  # the coroutine that orchestrates this boss's behavior
var this   # hack to pass args from enemy_process to the coroutine
var player
var delta

func _ready():
	health_bar.value = MAX_HP
	health_bar.max_value = MAX_HP
	assert(OK == self.connect("hp_changed", self, "on_hp_changed"))

	bullet_major.autostart = false
	bullet_major.one_shot = false
	assert(OK == bullet_major.connect("timeout", self, "_on_bullet_major"))
	self.add_child(bullet_major)

	bullet_minor.autostart = false
	bullet_minor.one_shot = false
	assert(OK == bullet_minor.connect("timeout", self, "_on_bullet_minor"))
	self.add_child(bullet_minor)

	var this = get_node("..")
	var p = this.get_node("BulletSpawnPos").position
	bullet_angle = -p.angle_to(Vector2.RIGHT)
	bullet_distance = p.length()  * this.scale.x

	fun = coroutine()

func set_hp(new):
	hp = int(max(0, new))
	emit_signal("hp_changed", hp)
	if hp == 0:
		emit_signal("died")

func get_hp():
	return hp

func on_hp_changed(hp: int):
	health_bar.value = hp

# `this` is the Enemy parent to this Spec
func enemy_process(_this, _player, _delta):
	this = _this
	player = _player
	delta = _delta

	this.rotation_degrees += 30 * delta
	health_bar_holder.rotation = -this.rotation

	fun = fun.resume()

func hit_player(this, player):
	player.hp -= 2
	player.nudge((player.position - this.position).normalized() * PUSHBACK_DISTANCE)

func get_hit(_this):
	self.hp -= 1

func _on_bullet_minor():
	if not is_instance_valid(this):
		return

	var game = this.get_node("..")
	for i in range(3):
		var bullet = Bullet.instance()
		game.add_child(bullet)
		var rot = this.rotation + i * TAU / 3 + bullet_angle
		bullet.position = this.position + (Vector2.RIGHT * bullet_distance).rotated(rot)
		bullet.rotation = rot

	bullets_spawned += 1
	if bullets_spawned >= BULLETS_PER_WAVE:
		bullet_minor.stop()

func _on_bullet_major():
	bullet_minor.start(BULLET_MINOR_COOLDOWN)
	bullets_spawned = 0

# returns false once the target is reached
func move_towards(target: Vector2):
	var to_target = target - this.position
	var move = to_target.normalized() * ENEMY_SPEED * delta
	if to_target.length_squared() <= move.length_squared():
		this.position = target
		return false
	this.position += move
	return true

func coroutine():
	yield()  # the first call happens before this/player/delta are set

	# go to the middle of the screen
	var vr = get_viewport_rect()
	var middle = 0.5 * (vr.position + vr.end)

	while move_towards(middle):
		yield()

	phase = 1
	bullet_major.start(BULLET_MAJOR_COOLDOWN)

	while true:
		yield()
