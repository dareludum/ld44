extends Node2D

enum Upgrade {
	SLOT_WEAPON,
	SLOT_SURVIVAL,
	SLOT_ULTIMATE,

	W0_BIG,
	W00_BIG_SPEED_UP,
	W000_BIG_360,
	W01_BIG_INVINCIBLE,
	W010_BIG_PASSIVE_PROJECTILE_DEFENSE,
	W1_DUAL,
	W10_DUAL_CAN_MOVE,
	W100_DUAL_FAST,
	W101_DUAL_ROTATING,
	W11_DUAL_KILL_PROJECTILES,
	W110_DUAL_360,
	S0_TODO,
	S1_TODO,
	U0_TODO,
	U1_TODO,
}

var UPGRADE_COST: Dictionary = {
	Upgrade.SLOT_WEAPON: 10,
	Upgrade.SLOT_SURVIVAL: 10,
	Upgrade.SLOT_ULTIMATE: 10,

	Upgrade.W0_BIG: 10,
	Upgrade.W1_DUAL: 10,

	Upgrade.S0_TODO: 10,
	Upgrade.S1_TODO: 10,

	Upgrade.U0_TODO: 10,
	Upgrade.U1_TODO: 10,
}

var UPGRADE_SELL_PRICE: Dictionary = {
	Upgrade.W0_BIG: 5,
	Upgrade.W1_DUAL: 5,

	Upgrade.S0_TODO: 5,
	Upgrade.S1_TODO: 5,

	Upgrade.U0_TODO: 5,
	Upgrade.U1_TODO: 5,
}

const PLAYER_BASE_MAX_HP: int = 6

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
	self.player_upgrades[Upgrade.W0_BIG] = true
	self.player_upgrades[Upgrade.W00_BIG_SPEED_UP] = true
	self.player_upgrades[Upgrade.W000_BIG_360] = true
	# self.player_upgrades[Upgrade.W1_DUAL] = true
	# self.player_upgrades[Upgrade.W10_DUAL_CAN_MOVE] = true
	# self.player_upgrades[Upgrade.W100_DUAL_FAST] = true
	# self.player_upgrades[Upgrade.W101_DUAL_ROTATING] = true
	# self.player_upgrades[Upgrade.W11_DUAL_KILL_PROJECTILES] = true
	# self.player_upgrades[Upgrade.W110_DUAL_360] = true
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
	self.game.cleanup()
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
