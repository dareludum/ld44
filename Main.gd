extends Node2D

const PLAYER_BASE_MAX_HP: int = 1

var player_max_hp: int = PLAYER_BASE_MAX_HP
var ep: int = 0

func get_player_max_hp():
	return self.player_max_hp

func get_ep():
	return self.ep

func set_ep(value: int):
	self.ep = value

func _ready():
	var game = preload("res://scenes/game.tscn").instance()
	self.add_child(game)
