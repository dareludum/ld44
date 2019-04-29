extends Control

signal play

var selected_upgrade: int = -1

onready var Session = get_tree().root.get_node("Session")

func set_selected_upgrade(upgrade: int):
	self.selected_upgrade = upgrade
	get_node("Description").text = "%s (cost %d EP)" % [Session.get_upgrade_description(upgrade), Session.get_upgrade_cost(upgrade)]
	match Session.get_upgrade_status(upgrade):
		0: # Unavailable
			$BuySellButton.hide()
		1: # Available
			$BuySellButton.show()
			$BuySellButton.text = "Buy"
			$BuySellButton.disabled = Session.ep < Session.get_upgrade_cost(upgrade)
		2: # Bought
			$BuySellButton.show()
			$BuySellButton.text = "Sell"
			$BuySellButton.disabled = not Session.can_sell_upgrade(upgrade)

func _ready():
	$EP.text = "Your EP: " + str(get_tree().root.get_node("Session:").get_ep())
	assert(OK == $PlayButton.connect("button_down", self, "_on_play_button_pressed"))
	assert(OK == $BuySellButton.connect("button_down", self, "_on_buy_button_pressed"))

func _on_play_button_pressed():
	emit_signal("play")

func _on_buy_button_pressed():
	match Session.get_upgrade_status(self.selected_upgrade):
		1: # Available
			Session.buy_player_upgrade(self.selected_upgrade)
		2: # Bought
			Session.sell_player_upgrade(self.selected_upgrade)

	var trees = [
		get_node("WeaponUpgrades/BigWeapon"),
		get_node("WeaponUpgrades/DualWeapon"),
		get_node("AbilityUpgrades/SpeedAbilities"),
		get_node("AbilityUpgrades/ProtectionAbilities")
		]
	for tree in trees:
		tree.refresh()
	set_selected_upgrade(self.selected_upgrade)
	$EP.text = "Your EP: " + str(get_tree().root.get_node("Session:").get_ep())
