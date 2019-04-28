extends Node2D

func _ready():
	var game = preload("res://scenes/game.tscn").instance()
	self.add_child(game)
