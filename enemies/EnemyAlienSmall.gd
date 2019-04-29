extends Node2D

const ENEMY_SPEED = 200
const PREFERRED_DIST_LOW = 200
const PREFERRED_DIST_HIGH = 400
const SHOT_COOLDOWN_MS = 2000

const Bullet = preload("res://scenes/BeamPink.tscn")
onready var SFXEngine = get_tree().root.get_node("Session").get_node("SoundEngine")
var next_shot_after = 0

# `this` is the Enemy parent to this Spec
func enemy_process(this, player, delta):
	var moved = process_movement(this, player, delta)
	if not moved:
		process_shooting(this, player, delta)

# returns true if moved, false if the distance to the player is within the preferred range 
func process_movement(this, player, delta):
	var to_player = player.position - this.position
	var dist = to_player.length()
	var speed = 0
	if dist < PREFERRED_DIST_LOW:
		speed = -0.25 * ENEMY_SPEED
	elif dist > PREFERRED_DIST_HIGH:
		speed = ENEMY_SPEED
		
	this.look_at(player.position)
	if speed != 0:
		this.position += speed * delta * Vector2(1, 0).rotated(this.rotation)
		return true
	return false

func process_shooting(this, player, _delta):
	var now = OS.get_ticks_msec()
	
	if now < next_shot_after or not this.in_play_area:
		return

	var game = this.get_node("..")
	var bullet = Bullet.instance()
	game.add_child(bullet)
	bullet.position = this.position + Vector2(35, 0).rotated(this.rotation)
	bullet.look_at(player.position)
	next_shot_after = now + SHOT_COOLDOWN_MS

func hit_player(_this, _player):
	pass

func get_hit(this):
	SFXEngine.play_sfx(SFXEngine.SFX_TYPE.ENEMY_DEATH)
	this.queue_free()

