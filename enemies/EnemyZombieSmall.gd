extends Node2D

var ENEMY_SPEED = 200

# `this` is the Enemy parent to this Spec
func enemy_process(this, player, delta):
	var speed = Vector2(1, 0) * delta * ENEMY_SPEED
	get_node("..").look_at(player.position)
	this.position += speed.rotated(this.rotation)

func hit_player(this, player):
	player.hp -= 1
	this.queue_free()

func get_hit(this):
	this.SFXEngine.play_sfx(this.SFXEngine.SFX_TYPE.ENEMY_DEATH)
	this.queue_free()
