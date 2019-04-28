extends Node2D

enum Upgrade {
	SLOT_WEAPON,
	SLOT_SURVIVAL,
	SLOT_SPECIAL,

	WEAPON_0,
	# TODO: flat subtree: WEAPON_0_0, etc.
	WEAPON_1,
	SURVIVAL_0,
	SURVIVAL_1,
	SPECIAL_0,
	SPECIAL_1,
}

var UPGRADE_COST: Dictionary = {
	Upgrade.SLOT_WEAPON: 10,
	Upgrade.SLOT_SURVIVAL: 10,
	Upgrade.SLOT_SPECIAL: 10,

	Upgrade.WEAPON_0: 10,
	Upgrade.WEAPON_1: 10,

	Upgrade.SURVIVAL_0: 10,
	Upgrade.SURVIVAL_1: 10,

	Upgrade.SPECIAL_0: 10,
	Upgrade.SPECIAL_1: 10,
}

var UPGRADE_SELL_PRICE: Dictionary = {
	Upgrade.WEAPON_0: 5,
	Upgrade.WEAPON_1: 5,

	Upgrade.SURVIVAL_0: 5,
	Upgrade.SURVIVAL_1: 5,

	Upgrade.SPECIAL_0: 5,
	Upgrade.SPECIAL_1: 5,
}

const PLAYER_BASE_MAX_HP: int = 1

var game = null
var upgrades = null

var player_max_hp: int = PLAYER_BASE_MAX_HP
var player_upgrades: Dictionary = {}
var ep: int = 0

func get_player_max_hp():
	return self.player_max_hp

func get_ep():
	return self.ep

func get_player_upgrades():
	return self.player_upgrades.duplicate()

func buy_player_upgrade(upgrade): # : type ?
	assert(self.ep >= get_upgrade_cost(upgrade))
	self.ep -= get_upgrade_cost(upgrade)
	self.player_upgrades[upgrade] = true

func sell_player_upgrade(upgrade): # : type?
	assert(self.player_upgrades.erase(upgrade))
	# TODO: erase the upgrade subtree
	self.ep += get_sell_price(upgrade)

func get_upgrade_cost(upgrade):
	return UPGRADE_COST[upgrade]

func get_sell_price(upgrade):
	return UPGRADE_SELL_PRICE[upgrade]

func _ready():
	# Test upgrades
	self.player_upgrades[Upgrade.SLOT_WEAPON] = true
	self.player_upgrades[Upgrade.WEAPON_1] = true
	start_new_game()

func start_new_game():
	self.game = preload("res://scenes/game.tscn").instance()
	assert(OK == self.game.connect("gameover", self, "_on_gameover"))
	assert(OK == self.game.get_node("Player").connect("ep_add", self, "_on_ep_add"))
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

func _on_ep_add(value: int):
	self.ep += value
