extends Node2D

enum Upgrade {
	W0_BIG,
	W00_BIG_SPEED_UP,
	W01_BIG_INVINCIBLE,
	W000_BIG_360,
	W010_BIG_PROJECTILE_SHIELD,

	W1_DUAL,
	W10_DUAL_CAN_MOVE,
	W11_DUAL_KILL_PROJECTILES,
	W100_DUAL_ROTATING,
	W110_DUAL_360,

	S0_SPEED,
	S00_SPRINT,
	S01_BLINK,
	S000_LONG_SPRINT,
	S010_DOUBLE_BLINK,

	S1_ARMOR,
	S10_BUBBLE,
	S11_INVINCIBILITY_ON_HIT,
	S100_DOUBLE_BUBBLE,
	S110_SHORT_STUN,
}

enum UpgradeStatus {
	UNAVAILABLE,
	AVAILABLE,
	BOUGHT,
}

var UPGRADE_COST: Dictionary = {
	Upgrade.W0_BIG: 10,
	Upgrade.W00_BIG_SPEED_UP: 10,
	Upgrade.W000_BIG_360: 10,
	Upgrade.W01_BIG_INVINCIBLE: 10,
	Upgrade.W010_BIG_PROJECTILE_SHIELD: 10,

	Upgrade.W1_DUAL: 10,
	Upgrade.W10_DUAL_CAN_MOVE: 10,
	Upgrade.W100_DUAL_ROTATING: 10,
	Upgrade.W11_DUAL_KILL_PROJECTILES: 10,
	Upgrade.W110_DUAL_360: 10,

	Upgrade.S0_SPEED: 10,
	Upgrade.S00_SPRINT: 10,
	Upgrade.S000_LONG_SPRINT: 10,
	Upgrade.S01_BLINK: 10,
	Upgrade.S010_DOUBLE_BLINK: 10,

	Upgrade.S1_ARMOR: 10,
	Upgrade.S10_BUBBLE: 10,
	Upgrade.S100_DOUBLE_BUBBLE: 10,
	Upgrade.S11_INVINCIBILITY_ON_HIT: 10,
	Upgrade.S110_SHORT_STUN: 10,
}

var UPGRADE_ICONS: Dictionary = {
	Upgrade.W0_BIG: preload("res://icon.png"),
	Upgrade.W00_BIG_SPEED_UP: preload("res://icon.png"),
	Upgrade.W000_BIG_360: preload("res://icon.png"),
	Upgrade.W01_BIG_INVINCIBLE: preload("res://icon.png"),
	Upgrade.W010_BIG_PROJECTILE_SHIELD: preload("res://icon.png"),

	Upgrade.W1_DUAL: preload("res://icon.png"),
	Upgrade.W10_DUAL_CAN_MOVE: preload("res://icon.png"),
	Upgrade.W100_DUAL_ROTATING: preload("res://icon.png"),
	Upgrade.W11_DUAL_KILL_PROJECTILES: preload("res://icon.png"),
	Upgrade.W110_DUAL_360: preload("res://icon.png"),

	Upgrade.S0_SPEED: preload("res://icon.png"),
	Upgrade.S00_SPRINT: preload("res://icon.png"),
	Upgrade.S000_LONG_SPRINT: preload("res://icon.png"),
	Upgrade.S01_BLINK: preload("res://icon.png"),
	Upgrade.S010_DOUBLE_BLINK: preload("res://icon.png"),

	Upgrade.S1_ARMOR: preload("res://icon.png"),
	Upgrade.S10_BUBBLE: preload("res://icon.png"),
	Upgrade.S100_DOUBLE_BUBBLE: preload("res://icon.png"),
	Upgrade.S11_INVINCIBILITY_ON_HIT: preload("res://icon.png"),
	Upgrade.S110_SHORT_STUN: preload("res://icon.png"),
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
	Upgrade.S000_LONG_SPRINT: "Sprint for two timer longer",
	Upgrade.S01_BLINK: "Blink by pressing SPACE",
	Upgrade.S010_DOUBLE_BLINK: "Blink up to two times in a row",

	Upgrade.S1_ARMOR: "Take 1 less damage from hits that deal more than 1 damage",
	Upgrade.S10_BUBBLE: "A protective bubble that shields from some ranged attacks",
	Upgrade.S100_DOUBLE_BUBBLE: "Have two bubbles to protect you",
	Upgrade.S11_INVINCIBILITY_ON_HIT: "Temporarily become invincible after being hit",
	Upgrade.S110_SHORT_STUN: "Reduced stun duration",
}

const PLAYER_BASE_MAX_HP: int = 50
const UPGRADE_HP_COST: int = 3

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
	self.ep += get_upgrade_cost(upgrade) / 2

func get_upgrade_cost(upgrade):
	return UPGRADE_COST[upgrade]

func get_upgrade_description(upgrade):
    return UPGRADE_DESCRIPTIONS[upgrade]

func get_upgrade_icon(upgrade):
	return UPGRADE_ICONS[upgrade]

func get_upgrade_status(upgrade):
	if self.player_upgrades.has(upgrade):
		return UpgradeStatus.BOUGHT
	match upgrade:
		Upgrade.W0_BIG:
			if not self.player_upgrades.has(Upgrade.W1_DUAL):
				return UpgradeStatus.AVAILABLE
		Upgrade.W00_BIG_SPEED_UP:
			if self.player_upgrades.has(Upgrade.W0_BIG) and not self.player_upgrades.has(Upgrade.W01_BIG_INVINCIBLE):
				return UpgradeStatus.AVAILABLE
		Upgrade.W000_BIG_360:
			if self.player_upgrades.has(Upgrade.W0_BIG) and self.player_upgrades.has(Upgrade.W00_BIG_SPEED_UP):
				return UpgradeStatus.AVAILABLE
		Upgrade.W01_BIG_INVINCIBLE:
			if self.player_upgrades.has(Upgrade.W0_BIG) and not self.player_upgrades.has(Upgrade.W00_BIG_SPEED_UP):
				return UpgradeStatus.AVAILABLE
		Upgrade.W010_BIG_PROJECTILE_SHIELD:
			if self.player_upgrades.has(Upgrade.W0_BIG) and self.player_upgrades.has(Upgrade.W01_BIG_INVINCIBLE):
				return UpgradeStatus.AVAILABLE

		Upgrade.W1_DUAL:
			if not self.player_upgrades.has(Upgrade.W0_BIG):
				return UpgradeStatus.AVAILABLE
		Upgrade.W10_DUAL_CAN_MOVE:
			if self.player_upgrades.has(Upgrade.W1_DUAL) and not self.player_upgrades.has(Upgrade.W11_DUAL_KILL_PROJECTILES):
				return UpgradeStatus.AVAILABLE
		Upgrade.W100_DUAL_ROTATING:
			if self.player_upgrades.has(Upgrade.W1_DUAL) and self.player_upgrades.has(Upgrade.W10_DUAL_CAN_MOVE):
				return UpgradeStatus.AVAILABLE
		Upgrade.W11_DUAL_KILL_PROJECTILES:
			if self.player_upgrades.has(Upgrade.W1_DUAL) and not self.player_upgrades.has(Upgrade.W10_DUAL_CAN_MOVE):
				return UpgradeStatus.AVAILABLE
		Upgrade.W110_DUAL_360:
			if self.player_upgrades.has(Upgrade.W1_DUAL) and self.player_upgrades.has(Upgrade.W11_DUAL_KILL_PROJECTILES):
				return UpgradeStatus.AVAILABLE

		Upgrade.S0_SPEED:
			if not self.player_upgrades.has(Upgrade.S1_ARMOR):
				return UpgradeStatus.AVAILABLE
		Upgrade.S00_SPRINT:
			if self.player_upgrades.has(Upgrade.S0_SPEED) and not self.player_upgrades.has(Upgrade.S01_BLINK):
				return UpgradeStatus.AVAILABLE
		Upgrade.S000_LONG_SPRINT:
			if self.player_upgrades.has(Upgrade.S0_SPEED) and self.player_upgrades.has(Upgrade.S00_SPRINT):
				return UpgradeStatus.AVAILABLE
		Upgrade.S01_BLINK:
			if self.player_upgrades.has(Upgrade.S0_SPEED) and not self.player_upgrades.has(Upgrade.S00_SPRINT):
				return UpgradeStatus.AVAILABLE
		Upgrade.S010_DOUBLE_BLINK:
			if self.player_upgrades.has(Upgrade.S0_SPEED) and self.player_upgrades.has(Upgrade.S01_BLINK):
				return UpgradeStatus.AVAILABLE

		Upgrade.S1_ARMOR:
			if not self.player_upgrades.has(Upgrade.S0_SPEED):
				return UpgradeStatus.AVAILABLE
		Upgrade.S10_BUBBLE:
			if self.player_upgrades.has(Upgrade.S1_ARMOR) and not self.player_upgrades.has(Upgrade.S11_INVINCIBILITY_ON_HIT):
				return UpgradeStatus.AVAILABLE
		Upgrade.S100_DOUBLE_BUBBLE:
			if self.player_upgrades.has(Upgrade.S1_ARMOR) and self.player_upgrades.has(Upgrade.S10_BUBBLE):
				return UpgradeStatus.AVAILABLE
		Upgrade.S11_INVINCIBILITY_ON_HIT:
			if self.player_upgrades.has(Upgrade.S1_ARMOR) and not self.player_upgrades.has(Upgrade.S10_BUBBLE):
				return UpgradeStatus.AVAILABLE
		Upgrade.S110_SHORT_STUN:
			if self.player_upgrades.has(Upgrade.S1_ARMOR) and self.player_upgrades.has(Upgrade.S11_INVINCIBILITY_ON_HIT):
				return UpgradeStatus.AVAILABLE

	return UpgradeStatus.UNAVAILABLE

func can_sell_upgrade(upgrade):
	if not self.player_upgrades.has(upgrade):
		return false
	match upgrade:
		Upgrade.W0_BIG:
			return not (self.player_upgrades.has(Upgrade.W00_BIG_SPEED_UP) or self.player_upgrades.has(Upgrade.W01_BIG_INVINCIBLE))
		Upgrade.W00_BIG_SPEED_UP:
			return not self.player_upgrades.has(Upgrade.W000_BIG_360)
		Upgrade.W000_BIG_360:
			return true
		Upgrade.W01_BIG_INVINCIBLE:
			return not self.player_upgrades.has(Upgrade.W010_BIG_PROJECTILE_SHIELD)
		Upgrade.W010_BIG_PROJECTILE_SHIELD:
			return true

		Upgrade.W1_DUAL:
			return not (self.player_upgrades.has(Upgrade.W10_DUAL_CAN_MOVE) or self.player_upgrades.has(Upgrade.W11_DUAL_KILL_PROJECTILES))
		Upgrade.W10_DUAL_CAN_MOVE:
			return not self.player_upgrades.has(Upgrade.W100_DUAL_ROTATING)
		Upgrade.W100_DUAL_ROTATING:
			return true
		Upgrade.W11_DUAL_KILL_PROJECTILES:
			return not self.player_upgrades.has(Upgrade.W110_DUAL_360)
		Upgrade.W110_DUAL_360:
			return true

		Upgrade.S0_SPEED:
			return not (self.player_upgrades.has(Upgrade.S00_SPRINT) or self.player_upgrades.has(Upgrade.S01_BLINK))
		Upgrade.S00_SPRINT:
			return not self.player_upgrades.has(Upgrade.S000_LONG_SPRINT)
		Upgrade.S000_LONG_SPRINT:
			return true
		Upgrade.S01_BLINK:
			return not self.player_upgrades.has(Upgrade.S010_DOUBLE_BLINK)
		Upgrade.S010_DOUBLE_BLINK:
			return true

		Upgrade.S1_ARMOR:
			return not (self.player_upgrades.has(Upgrade.S10_BUBBLE) or self.player_upgrades.has(Upgrade.S11_INVINCIBILITY_ON_HIT))
		Upgrade.S10_BUBBLE:
			return not self.player_upgrades.has(Upgrade.S100_DOUBLE_BUBBLE)
		Upgrade.S100_DOUBLE_BUBBLE:
			return true
		Upgrade.S11_INVINCIBILITY_ON_HIT:
			return not self.player_upgrades.has(Upgrade.S110_SHORT_STUN)
		Upgrade.S110_SHORT_STUN:
			return true

	return UpgradeStatus.UNAVAILABLE

func _ready():
	# Test upgrades
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
	# self.player_upgrades[Upgrade.S0_SPEED] = true
	# self.player_upgrades[Upgrade.S00_SPRINT] = true
	# self.player_upgrades[Upgrade.S000_LONG_SPRINT] = true
	# self.player_upgrades[Upgrade.S01_BLINK] = true
	# self.player_upgrades[Upgrade.S010_DOUBLE_BLINK] = true
	# self.player_upgrades[Upgrade.S1_ARMOR] = true
	# self.player_upgrades[Upgrade.S10_BUBBLE] = true
	# self.player_upgrades[Upgrade.S100_DOUBLE_BUBBLE] = true
	# self.player_upgrades[Upgrade.S11_INVINCIBILITY_ON_HIT] = true
	# self.player_upgrades[Upgrade.S110_SHORT_STUN] = true
	# self.ep = 5
	start_new_game()
	# show_upgrades_screen()

func start_new_game():
	self.player_max_hp = PLAYER_BASE_MAX_HP - len(player_upgrades) * UPGRADE_HP_COST
	self.game = preload("res://scenes/game.tscn").instance()
	assert(OK == self.game.connect("gameover", self, "_on_gameover"))
	assert(OK == self.game.get_node("Player").connect("ep_add", self, "_on_ep_add"))
	self.add_child(self.game)

func show_upgrades_screen():
	self.upgrades = preload("res://scenes/UpgradeMenu.tscn").instance()
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
