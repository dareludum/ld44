extends TextureButton


var upgrades = [ 
    preload("res://scenes/WeaponUpgrades.tscn"),
    preload("res://scenes/SurvivalUpgrades.tscn"),
    preload("res://scenes/AbilityUpgrades.tscn")
]

func instanciate(var upgrade_type):
    var cur_upgrades = get_node("../../Upgrades")
    
    if (cur_upgrades != null):
        get_node("../..").remove_child(cur_upgrades)
        cur_upgrades.queue_free()
        
    cur_upgrades = upgrades[upgrade_type].instance()
    get_node("../../").add_child(cur_upgrades)