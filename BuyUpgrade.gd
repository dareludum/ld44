extends Button

func _pressed():
    var Upgrades = get_node("../MarginContainer/VBoxContainer/MidUI/Tree/Upgrades")
    if (Upgrades != null):
        Upgrades.buy()
