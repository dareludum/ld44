extends VBoxContainer

var pending_button = null
onready var player_upgrades = get_tree().root.get_node("Session").get_player_upgrades()

func _ready():
    var counter = 8;
    for level in get_children():
        for button in level.get_children():
            print(button.name)
            button.set_upgrade(counter)
            if (player_upgrades.has(counter)):
                button.set_unlocked(player_upgrades[counter] == true)
                print(player_upgrades[counter])
            counter += 1

func set_pending_upgrade(button):
    pending_button = button
    print("Set pending upgrade")
    
func buy():
    var desc = get_node("../../../../../Description")
    if (pending_button != null):
        if (!pending_button.unlock()):
            desc.text = "Not enough EP!"
            