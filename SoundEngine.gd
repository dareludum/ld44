extends AudioStreamPlayer

var blade_streams: Array
var enemy_death_streams: Array

enum SFX_TYPE {SFX_BLADE, SFX_ENEMY_DEATH}

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

func play_sfx(type):
	var selected_streams = null
	match type:
		SFX_TYPE.SFX_BLADE:
			selected_streams = blade_streams
		SFX_TYPE.SFX_ENEMY_DEATH:
			selected_streams = enemy_death_streams
	if selected_streams == null:
		return
	self.set_stream(selected_streams[rand_range(0, selected_streams.size())])
	self.play()