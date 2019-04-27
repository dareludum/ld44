extends Node2D

var timer: Timer = Timer.new()

func _ready():
	timer.wait_time = 1
	assert(OK == timer.connect("timeout", self, "_on_timer_timeout"))
	self.add_child(timer)
	timer.start()

func _on_timer_timeout():
	var enemy = preload("res://scenes/enemy.tscn").instance()
	self.add_child(enemy)
	$EnemySpawnRect/SpawnLocation.offset = randi()
	enemy.position = $EnemySpawnRect/SpawnLocation.position
	enemy.look_at($Player.position)

func _update_ui():
	$lbl_hp.text = "HP: " + str($Player.get_hp())
	$lbl_ep.text = "EP:" + str($Player.get_ep())

func _process(_delta):
	_update_ui()