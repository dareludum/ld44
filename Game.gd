extends Node2D

signal gameover

const FADEOUT_INTERVAL: float = 0.015
const FADEOUT_INCREMENT: float = 0.007
const FADEOUT_UNTIL: float = 1.2 # this is > 1 to let the screen be black for some time
const FADEIN_INCREMENT: float = 0.05

const Enemy = preload("res://Enemy.gd")

onready var Session = get_tree().root.get_node("Session")
onready var SFXEngine = preload("res://SoundEngine.gd").new()

var progression_timer: Timer = Timer.new()
var fade_out_timer: Timer = Timer.new()

const enemy_scenes = [  # indices coupled with `progression`
	preload("res://scenes/EnemyAlienSmall.tscn"),
	preload("res://scenes/EnemyStunner.tscn"),
	preload("res://scenes/EnemyZombie.tscn"),
	preload("res://scenes/EnemyZombieSmall.tscn"),
	preload("res://scenes/EnemyZombieNormal.tscn"),
	preload("res://scenes/EnemyZombieBig.tscn"),
]

const TARGET_PLAY_SESSION_DURATION_SECONDS = 3 * 60

const progression = [  # indices coupled with `enemy_scenes`
	[0, 0, 0, 2, 2, 2, 0, 0, 0, 3, 3, 3, 3, 0, 0],  # shooter
	[0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 0, 1],  # stunner
	[1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1],  # dumb zombie
	[0, 1, 1, 0, 0, 0, 3, 3, 2, 2, 0, 0, 2, 2, 2],  # chaser
	[0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 2, 2, 2, 2],  # normal zombie
	[0, 0, 0, 0, 0, 2, 2, 2, 0, 0, 3, 3, 3, 3, 3],  # big zombie
]

# indexed by the numbers from `progression`
const spawn_interval_for_level = [0, 1.5, 3, 5]

const boss_scene = preload("res://scenes/EnemyBossStation.tscn")
var boss_spawned = false
var spawners = []  # one for each enemy type, couple with enemy_scenes and progression
var progression_level = -1

func _ready():
	self.add_child(SFXEngine)

	assert(OK == progression_timer.connect("timeout", self, "_on_progression_timeout"))
	self.add_child(progression_timer)
	progression_timer.start(TARGET_PLAY_SESSION_DURATION_SECONDS / float(len(progression[0])))

	for i in range(len(enemy_scenes)):
		var timer = Timer.new()
		assert(OK == timer.connect("timeout", self, "_on_spawn_timer_timeout", [i]))
		self.add_child(timer)
		spawners.append(timer)

	assert(OK == $BackgroundMusic.connect("finished", self, "_on_music_finished"))
	fade_out_timer.autostart = false
	fade_out_timer.wait_time = FADEOUT_INTERVAL
	assert(OK == fade_out_timer.connect("timeout", self, "_on_fade_out_timer_timeout"))
	self.add_child(fade_out_timer)
	assert(OK == $Player.connect("hit", self, "_on_player_hit"))
	assert(OK == $Player.connect("died", self, "_on_player_died"))
	assert(OK == $Player.connect("ep_add", self, "_on_ep_add"))

	_on_progression_timeout()

func _on_music_finished():
	$BackgroundMusic.play()

func _on_player_died():
	progression_timer.stop()
	for timer in spawners:
		timer.stop()
	$Player.hide()
	$Player.queue_free()
	fade_out_timer.start()

func _on_fade_out_timer_timeout():
	if $BlackScreen.modulate.a == 0:
		SFXEngine.play_sfx(SFXEngine.SFX_TYPE.GAME_OVER)
		$BackgroundMusic.stop()
	$BlackScreen.modulate.a += FADEOUT_INCREMENT
	if $BlackScreen.modulate.a >= 0.3:
		$YouDied.modulate.a += FADEIN_INCREMENT
	if $BlackScreen.modulate.a >= FADEOUT_UNTIL:
		emit_signal("gameover")

func _on_player_hit(value: int):
	var info = preload("res://scenes/ScrollingUpdateText.tscn").instance()
	info.set_value("-" + str(value) + " HP", Color.red)
	info.rect_position = $Player.position + Vector2(20, -40)
	self.add_child(info)

func _on_ep_add(value: int):
	var info = preload("res://scenes/ScrollingUpdateText.tscn").instance()
	info.set_value("+" + str(value) + " EP", Color.green)
	info.rect_position = $Player.position + Vector2(20, -40)
	self.add_child(info)

func _on_spawn_timer_timeout(enemy_idx):
	spawn_enemy(enemy_scenes[enemy_idx])

func _on_progression_timeout():
	progression_level += 1
	print("progression level: " + str(progression_level))
	if progression_level >= len(progression[0]):
		progression_timer.stop()
		for timer in spawners:
			timer.stop()
		if not boss_spawned:
			spawn_enemy(boss_scene)
			boss_spawned = true
		return

	for enemy_idx in len(enemy_scenes):
		var level = progression[enemy_idx][progression_level]
		if level == 0:
			spawners[enemy_idx].stop()
		else:
			spawners[enemy_idx].start(spawn_interval_for_level[level])

func spawn_enemy(scene):
	var enemy = scene.instance()
	self.add_child(enemy)
	enemy.init($Player, $SpawnArea, $FairPlayArea)
	$EnemySpawnRect/SpawnLocation.offset = randi()
	enemy.position = $EnemySpawnRect/SpawnLocation.position
	enemy.look_at($Player.position)

func _update_ui():
	if self.find_node("Player") == null:
		$lbl_hp.text = "HP: 0"
		return
	$lbl_hp.text = "HP: " + str($Player.hp)
	$lbl_ep.text = "EP: " + str(Session.ep)
	if $Player.sprint_multiplier > 1.0:
		$lbl_extra.text = "Sprint: %.2fs" % $Player.sprint_seconds_left
	elif $Player.blink_charges_max > 0:
		$lbl_extra.text = "Blink charges: %d" % $Player.blink_charges

func _process(_delta):
	_update_ui()

# WAR for the apparent reuse of IDs
func cleanup():
	for node in get_children():
		if node is Enemy:
			node.cleanup()
