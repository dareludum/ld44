extends AudioStreamPlayer

var blade_streams: Array
var enemy_death_streams: Array
var game_over_streams: Array

enum SFX_TYPE {BLADE, ENEMY_DEATH, GAME_OVER}

func _ready():
	_load_streams()

func _load_streams():
	blade_streams = [
		preload("res://sfx/blade1.wav"),
		preload("res://sfx/blade2.wav"),
		preload("res://sfx/blade3.wav")
		]
	enemy_death_streams = [
		preload("res://sfx/enemy_death1.wav"),
		preload("res://sfx/enemy_death2.wav"),
		preload("res://sfx/enemy_death3.wav")
		]
	game_over_streams = [
		preload("res://sfx/game_over.wav")
		]

func play_sfx(type):
	var selected_streams = null
	match type:
		SFX_TYPE.BLADE:
			selected_streams = blade_streams
		SFX_TYPE.ENEMY_DEATH:
			selected_streams = enemy_death_streams
		SFX_TYPE.GAME_OVER:
			selected_streams = game_over_streams
	if selected_streams == null:
		return
	self.set_stream(selected_streams[rand_range(0, selected_streams.size())])
	self.play()