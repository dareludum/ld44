extends TextureButton


var upgrades = {"WeaponButton": preload("res://scenes/WeaponUpgrades.tscn").instance(),
                "SurvivalButton": preload("res://scenes/SurvivalUpgrades.tscn").instance(),
                "AbilityButton": preload("res://scenes/AbilityUpgrades.tscn").instance()
}


func instantiate():
    var cur_upgrades = get_node("../../../Tree/Upgrades")
    
    if (cur_upgrades != null):
        get_node("../../../Tree").remove_child(cur_upgrades)
        
    cur_upgrades = upgrades[self.name]
    get_node("../../../Tree").add_child(cur_upgrades)
    
func _pressed():
    instantiate()
    print(self.name)