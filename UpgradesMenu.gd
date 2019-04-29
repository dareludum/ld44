extends Control

signal play

func _ready():
	assert(OK == $PlayButton.connect("button_down", self, "_on_play_button_pressed"))

func _on_play_button_pressed():
	emit_signal("play")

func _process(_delta):
	$MarginContainer/VBoxContainer/TopUI/lbl_ep.text = "EP: " + str(get_tree().root.get_node("Session:").get_ep())