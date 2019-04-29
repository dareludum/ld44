extends Node2D

enum Upgrade {
	SLOT_WEAPON,
	SLOT_SURVIVAL,

	W0_BIG,
	W00_BIG_SPEED_UP,
	W000_BIG_360,
	W01_BIG_INVINCIBLE,
	W010_BIG_PROJECTILE_SHIELD,
	W1_DUAL,
	W10_DUAL_CAN_MOVE,
	W100_DUAL_ROTATING,
	W11_DUAL_KILL_PROJECTILES,
	W110_DUAL_360,
	S0_SPEED,
	S00_SPRINT,
	S01_BLINK,
	S1_ARMOR,
	S10_BUBBLE,
	S11_INVINCIBILITY_ON_HIT,
	S110_SHORT_STUN,
}

var UPGRADE_COST: Dictionary = {
	Upgrade.SLOT_WEAPON: 10,
	Upgrade.SLOT_SURVIVAL: 10,

	Upgrade.W0_BIG: 10,
	Upgrade.W1_DUAL: 10,
    
    Upgrade.W10_DUAL_CAN_MOVE: 10,
	Upgrade.W100_DUAL_ROTATING: 10,
	Upgrade.W11_DUAL_KILL_PROJECTILES: 10,
	Upgrade.W110_DUAL_360: 10,

	Upgrade.S0_SPEED: 10,
	Upgrade.S1_ARMOR: 10,
}

var UPGRADE_SELL_PRICE: Dictionary = {
	Upgrade.W0_BIG: 5,
	Upgrade.W1_DUAL: 5,

	Upgrade.S0_SPEED: 5,
	Upgrade.S1_ARMOR: 5,
}

var UPGRADE_DESCRIPTIONS : Dictionary = {
	Upgrade.W0_BIG: "A huge sword to swing at your enemies",
	Upgrade.W00_BIG_SPEED_UP: "Build up swinging speed by hitting enemies",
	Upgrade.W000_BIG_360: "Swing in a full circle",
	Upgrade.W01_BIG_INVINCIBLE: "Become invincible while swinging",
	Upgrade.W010_BIG_PROJECTILE_SHIELD: "Blade serves as a shield against projectiles when not swinging",
	Upgrade.W1_DUAL: "Twice as many blades, for twice as many victims",
	Upgrade.W10_DUAL_CAN_MOVE: "Move while swinging",
	Upgrade.W100_DUAL_ROTATING: "Rotate your blades while swinging",
	Upgrade.W11_DUAL_KILL_PROJECTILES: "Swing at projectiles to make them disappear",
	Upgrade.W110_DUAL_360: "Swing your blades in a 360 fashion",
	Upgrade.S0_SPEED: "Run 1.5 times faster",
	Upgrade.S00_SPRINT: "Sprint by holding SHIFT",
	Upgrade.S01_BLINK: "Blink by pressing SPACE",
	Upgrade.S1_ARMOR: "Take 1 less damage from hits that deal more than 1 damage",
	Upgrade.S10_BUBBLE: "A protective bubble that shields from some ranged attacks",
	Upgrade.S11_INVINCIBILITY_ON_HIT: "Temporarily become invincible after being hit",
	Upgrade.S110_SHORT_STUN: "Reduced stun duration",
}

const PLAYER_BASE_MAX_HP: int = 100

var game = null
var upgrades = null

var player_max_hp: int = PLAYER_BASE_MAX_HP
var player_upgrades: Dictionary = {}
var ep: int = 20

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
    
func get_upgrade_description(upgrade):
    return UPGRADE_DESCRIPTIONS[upgrade]

func _ready():
	# Test upgrades
	# self.player_upgrades[Upgrade.SLOT_WEAPON] = true
	# self.player_upgrades[Upgrade.W0_BIG] = true
	# self.player_upgrades[Upgrade.W00_BIG_SPEED_UP] = true
	# self.player_upgrades[Upgrade.W000_BIG_360] = true
	# self.player_upgrades[Upgrade.W01_BIG_INVINCIBLE] = true
	# self.player_upgrades[Upgrade.W010_BIG_PROJECTILE_SHIELD] = true
	# self.player_upgrades[Upgrade.W1_DUAL] = true
	# self.player_upgrades[Upgrade.W10_DUAL_CAN_MOVE] = true
	# self.player_upgrades[Upgrade.W100_DUAL_ROTATING] = true
	# self.player_upgrades[Upgrade.W11_DUAL_KILL_PROJECTILES] = true
	# self.player_upgrades[Upgrade.W110_DUAL_360] = true
	# self.player_upgrades[Upgrade.SLOT_SURVIVAL] = true
	# self.player_upgrades[Upgrade.S0_SPEED] = true
	# self.player_upgrades[Upgrade.S01_BLINK] = true
	# self.player_upgrades[Upgrade.S1_ARMOR] = true
	# self.player_upgrades[Upgrade.S10_BUBBLE] = true
	# self.player_upgrades[Upgrade.S11_INVINCIBILITY_ON_HIT] = true
	# self.player_upgrades[Upgrade.S110_SHORT_STUN] = true
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
