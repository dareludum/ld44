extends Node2D

const ENEMY_SPEED = 300
const PUSHBACK_DISTANCE = 120

onready var health_bar_holder = get_node("../HealthBarHolder")
# onready var health_bar = health_bar_holder.get_node("HealthBar")

var fun  # the coroutine that orchestrates this boss's behavior
var this   # hack to pass args from enemy_process to the coroutine
var player
var delta

func _ready():
	fun = coroutine()

# `this` is the Enemy parent to this Spec
func enemy_process(_this, _player, _delta):
	this = _this
	player = _player
	delta = _delta
	fun = fun.resume()
	health_bar_holder.rotation = -this.rotation

func hit_player(this, player):
	player.hp -= 2
	player.nudge((player.position - this.position).normalized() * PUSHBACK_DISTANCE)

func get_hit(_this):
	pass

func coroutine():
	yield()  # the first call happens before this/player/delta are set

	var to_target = Vector2.RIGHT * 10
	while to_target.length() > 5:
		var vr = get_viewport_rect()
		var target = 0.5 * (vr.position + vr.end)
		to_target = target - this.position
		this.look_at(target)
		this.position += ENEMY_SPEED * delta * Vector2(1, 0).rotated(this.rotation)
		yield()

	while true:
		this.rotation_degrees += 30 * delta
		yield()
