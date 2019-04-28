extends Node2D

const PLAYER_BASE_MAX_HP: int = 1

var game = null
var upgrades = null

var player_max_hp: int = PLAYER_BASE_MAX_HP
var ep: int = 0

func get_player_max_hp():
	return self.player_max_hp

func get_ep():
	return self.ep

func set_ep(value: int):
	self.ep = value

func _ready():
	start_new_game()

func start_new_game():
	self.game = preload("res://scenes/game.tscn").instance()
	assert(OK == self.game.connect("gameover", self, "_on_gameover"))
	self.add_child(self.game)

func show_upgrades_screen():
	self.upgrades = preload("res://scenes/UpgradesMenu.tscn").instance()
	assert(OK == self.upgrades.connect("play", self, "_on_play"))
	self.add_child(self.upgrades)

func _on_gameover():
	self.game.hide()
	self.game.queue_free()
	self.game = null
	show_upgrades_screen()

func _on_play():
	self.upgrades.hide()
	self.upgrades.queue_free()
	self.upgrades = null
	start_new_game()
