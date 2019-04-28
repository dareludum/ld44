extends Node2D

onready var Session = get_tree().root.get_node("Session")

var timer: Timer = Timer.new()

func _ready():
	timer.wait_time = 1
	assert(OK == timer.connect("timeout", self, "_on_timer_timeout"))
	self.add_child(timer)
	timer.start()

	assert(OK == $Player.connect("died", self, "_on_player_died"))

func _on_player_died():
	self.timer.stop()
	$Player.hide()
	$Player.queue_free()
	# TODO: fade out

func _on_timer_timeout():
	var enemy = preload("res://scenes/enemy.tscn").instance()
	enemy.set_target($Player)
	self.add_child(enemy)
	$EnemySpawnRect/SpawnLocation.offset = randi()
	enemy.position = $EnemySpawnRect/SpawnLocation.position
	enemy.look_at($Player.position)

func _update_ui():
	if self.find_node("Player") == null:
		return
	$lbl_hp.text = "HP: " + str($Player.hp)
	$lbl_ep.text = "EP: " + str(Session.ep)

func _process(_delta):
	_update_ui()