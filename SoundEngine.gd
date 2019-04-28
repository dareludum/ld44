extends AudioStreamPlayer

var blade_streams: Array

enum SFX_TYPE {SFX_BLADE}

func _ready():
	_load_streams()

func _load_streams():
	blade_streams = [
		preload("res://sfx/blade1.wav"),
		preload("res://sfx/blade2.wav"),
		preload("res://sfx/blade3.wav")
		]

func play_sfx(type):
	var selected_streams = null
	match type:
		SFX_TYPE.SFX_BLADE:
			selected_streams = blade_streams
	if selected_streams == null:
		return
	self.set_stream(selected_streams[rand_range(0, selected_streams.size())])
	self.play()