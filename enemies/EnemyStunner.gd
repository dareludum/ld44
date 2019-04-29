extends Node2D

const ENEMY_SPEED = 250
const STUN_DURATION_MS = 750

onready var SFXEngine = get_tree().root.get_node("Session").get_node("SoundEngine")

# `this` is the Enemy parent to this Spec
func enemy_process(this, _player, delta):
	var speed = Vector2(1, 0) * delta * ENEMY_SPEED
	this.position += speed.rotated(this.rotation)

func hit_player(_this, player):
	player.stun(STUN_DURATION_MS)

func get_hit(this):
	SFXEngine.play_sfx(SFXEngine.SFX_TYPE.ENEMY_DEATH)
	this.queue_free()
