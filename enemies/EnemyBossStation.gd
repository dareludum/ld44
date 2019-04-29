extends Node2D

signal hp_changed
signal died

const ENEMY_SPEED = 100
const PUSHBACK_DISTANCE = 120
var rotation_speed = TAU / 6
const MAX_HP = 45
const PHASE_2_HP = 35
const PHASE_3_HP = 15

const Bullet = preload("res://scenes/BeamPink.tscn")
onready var game = get_tree().root.get_node("Session/Game")

var hp: int = MAX_HP setget set_hp, get_hp
var phase: int = 0

# major fires once per wave, minor fires BULLETS_PER_WAVE times
const BULLETS_PER_WAVE = 8
const BULLET_MINOR_COOLDOWN = 0.2
const BULLET_MAJOR_COOLDOWN = 5
var bullet_major: Timer = Timer.new()
var bullet_minor: Timer = Timer.new()
var bullets_spawned: int = 0  # reset every wave

const ENEMY_WAVE_COOLDOWN = 6
var enemy_wave_timer: Timer = Timer.new()
var enemy_wave_counter: int = 0
var enemy_wave_configs = [
	[3, preload("res://scenes/EnemyZombieBig.tscn")],
	[5, preload("res://scenes/EnemyZombieSmall.tscn")],
	[4, preload("res://scenes/EnemyZombieNormal.tscn")],
]

onready var health_bar_holder = get_node("../HealthBarHolder")
onready var health_bar = health_bar_holder.get_node("HealthBar")
var bullet_distance
var bullet_angle

var fun    # the coroutine that orchestrates this boss's behavior
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

	enemy_wave_timer.autostart = false
	enemy_wave_timer.one_shot = false
	assert(OK == enemy_wave_timer.connect("timeout", self, "_on_enemy_wave"))
	self.add_child(enemy_wave_timer)

	var this = get_node("..")
	var p = this.get_node("BulletSpawnPos").position
	bullet_angle = -p.angle_to(Vector2.RIGHT)
	bullet_distance = p.length() * this.scale.x

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

	this.rotation += rotation_speed * delta
	health_bar_holder.rotation = -this.rotation

	fun = fun.resume()

func hit_player(this, player):
	if hp > 0:
		player.hp -= 2
	player.nudge((player.position - this.position).normalized() * PUSHBACK_DISTANCE)

func get_hit(_this):
	# invulnerable until phase 1 starts and after it dies
	if phase == 0 or hp == 0:
		return

	self.hp -= 1
	if phase == 1:
		game.spawn_enemy(preload("res://scenes/EnemyAlienSmall.tscn"))

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
	bullet_major.stop()
	bullet_major.start(BULLET_MAJOR_COOLDOWN)
	bullet_minor.start(BULLET_MINOR_COOLDOWN)
	bullets_spawned = 0

func _on_enemy_wave():
	enemy_wave_timer.stop()
	enemy_wave_timer.start(ENEMY_WAVE_COOLDOWN)
	var num_enemies = enemy_wave_configs[enemy_wave_counter][0]
	var enemy_scene = enemy_wave_configs[enemy_wave_counter][1]
	enemy_wave_counter = (enemy_wave_counter + 1) % len(enemy_wave_configs)
	for _i in range(num_enemies):
		game.spawn_enemy(enemy_scene)

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

	#################### PHASE 1 ####################
	phase = 1
	bullet_major.start(2)

	while hp > PHASE_2_HP:
		yield()

	this.get_node("Stage0").hide()
	this.get_node("Stage1").show()
	rotation_speed = -rotation_speed

	#################### PHASE 2 ####################
	phase = 2
	var DX = 0.1
	var DY = 0.15
	var corner_idx = 0
	var corners = [Vector2(DX, DY), Vector2(1 - DX, DY), Vector2(1 - DX, 1 - DY), Vector2(DX, 1 - DY)]
	while hp > PHASE_3_HP:
		var corner = corners[corner_idx]
		corner_idx = (corner_idx + 1) % len(corners)
		var target = Vector2(vr.position.x + vr.size.x * corner.x, vr.position.y + vr.size.y * corner.y)
		while move_towards(target) and hp > PHASE_3_HP:
			yield()

	bullet_major.stop()
	this.get_node("Stage1").hide()
	this.get_node("Stage2").show()
	rotation_speed = -rotation_speed
	corner_idx = (corner_idx + 2) % len(corners)

	#################### PHASE 3 ####################
	phase = 3
	enemy_wave_timer.start(0.5)

	while hp > 0:
		var corner = corners[corner_idx]
		corner_idx = (corner_idx + 3) % len(corners)
		var target = Vector2(vr.position.x + vr.size.x * corner.x, vr.position.y + vr.size.y * corner.y)
		while move_towards(target) and hp > 0:
			yield()

	enemy_wave_timer.stop()
	emit_signal("died")
	rotation_speed = 0

	while true:
		yield()
