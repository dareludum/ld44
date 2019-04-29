extends VBoxContainer

onready var player_upgrades = get_tree().root.get_node("Session").get_player_upgrades()
onready var Upgrade = get_tree().root.get_node("Session").Upgrade
onready var buy_button = get_node("../../../../../../BuyButton")

func _ready():
    var err = buy_button.connect("buy", self, "_on_buy")
    if (err):
        return
        
    var counter : int
    if (self.name == "DualBlade"):
        counter = Upgrade.W1_DUAL
    elif (self.name == "SingleBlade"):
        counter = Upgrade.W0_BIG
    for level in get_children():
        for button in level.get_children():
            print(button.name)
            button.set_upgrade(counter)
            if (player_upgrades.has(counter)):
                button.set_unlocked(player_upgrades[counter] == true)
                print(player_upgrades[counter])
            counter += 1

func set_pending_upgrade(button):
    buy_button.set_upgrade_button(button)
    print("Set pending upgrade")
    
func buy():
    var desc = get_node("../../../../BotUI/Description")
    var pending_button = buy_button.get_upgrade_button()
    if (pending_button != null):
        if (!pending_button.unlock()):
            desc.text = "Not enough EP!"
        
func _on_buy():
    buy()
            