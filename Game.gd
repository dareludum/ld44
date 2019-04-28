extends Node2D

signal gameover

const FADEOUT_INTERVAL: float = 0.015
const FADEOUT_INCREMENT: float = 0.007
const FADEOUT_UNTIL: float = 1.2 # this is > 1 to let the screen be black for some time
const FADEIN_INCREMENT: float = 0.05

const Enemy = preload("res://Enemy.gd")

onready var Session = get_tree().root.get_node("Session")

var spawn_timer: Timer = Timer.new()
var fade_out_timer: Timer = Timer.new()

const enemy_scenes = [
	preload("res://scenes/EnemyStunner.tscn"),
	preload("res://scenes/EnemyZombie.tscn"),
	preload("res://scenes/EnemyAlienSmall.tscn"),
]

func _ready():
	spawn_timer.wait_time = 1
	assert(OK == spawn_timer.connect("timeout", self, "_on_spawn_timer_timeout"))
	self.add_child(spawn_timer)
	spawn_timer.start()
	
	fade_out_timer.autostart = false
	fade_out_timer.wait_time = FADEOUT_INTERVAL
	assert(OK == fade_out_timer.connect("timeout", self, "_on_fade_out_timer_timeout"))
	self.add_child(fade_out_timer)

	assert(OK == $Player.connect("died", self, "_on_player_died"))
	assert(OK == $Player.connect("ep_add", self, "_on_ep_add"))

func _on_player_died():
	self.spawn_timer.stop()
	$Player.hide()
	$Player.queue_free()
	fade_out_timer.start()

func _on_fade_out_timer_timeout():
	$BlackScreen.modulate.a += FADEOUT_INCREMENT
	if $BlackScreen.modulate.a >= 0.3:
		$YouDied.modulate.a += FADEIN_INCREMENT
	if $BlackScreen.modulate.a >= FADEOUT_UNTIL:
		emit_signal("gameover")

func _on_ep_add(value: int):
	var info = preload("res://scenes/EvolutionPointsUp.tscn").instance()
	info.set_value(value)
	info.rect_position = $Player.position + Vector2(20, -40)
	self.add_child(info)

func _on_spawn_timer_timeout():
	var enemy = enemy_scenes[randi() % enemy_scenes.size()].instance()
	self.add_child(enemy)
	enemy.init($Player, $PlayArea)
	$EnemySpawnRect/SpawnLocation.offset = randi()
	enemy.position = $EnemySpawnRect/SpawnLocation.position
	enemy.look_at($Player.position)

func _update_ui():
	if self.find_node("Player") == null:
		$lbl_hp.text = "HP: 0"
		return
	$lbl_hp.text = "HP: " + str($Player.hp)
	$lbl_ep.text = "EP: " + str(Session.ep)

func _process(_delta):
	_update_ui()

# WAR for the apparent reuse of IDs
func cleanup():
	for node in get_children():
		if node is Enemy:
			print("cleaning up " + str(node))
			node.cleanup()
