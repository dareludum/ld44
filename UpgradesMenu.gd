extends Control

signal play

func _ready():
	assert(OK == $PlayButton.connect("button_down", self, "_on_play_button_pressed"))

func _on_play_button_pressed():
	emit_signal("play")
