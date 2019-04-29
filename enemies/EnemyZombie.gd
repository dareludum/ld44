extends Node2D

var ENEMY_SPEED = 150

onready var SFXEngine = get_tree().root.get_node("Session").get_node("SoundEngine")

# `this` is the Enemy parent to this Spec
func enemy_process(this, _player, delta):
	var speed = Vector2(1, 0) * delta * ENEMY_SPEED
	this.position += speed.rotated(this.rotation)

func hit_player(this, player):
	player.hp -= 2  # 1 heart
	this.queue_free()

func get_hit(this):
	SFXEngine.play_sfx(SFXEngine.SFX_TYPE.ENEMY_DEATH)
	this.queue_free()
