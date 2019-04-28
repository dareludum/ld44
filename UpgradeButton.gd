extends TextureButton


var upgrades = {"WeaponButton": preload("res://scenes/WeaponUpgrades.tscn"),
                "SurvivalButton": preload("res://scenes/SurvivalUpgrades.tscn"),
                "AbilityButton": preload("res://scenes/AbilityUpgrades.tscn")
}


func instanciate():
    var cur_upgrades = get_node("../../Upgrades")
    
    if (cur_upgrades != null):
        get_node("../..").remove_child(cur_upgrades)
        cur_upgrades.queue_free()
        
    cur_upgrades = upgrades[self.name].instance()
    get_node("../../").add_child(cur_upgrades)
    
func _pressed():
    instanciate()
    print(self.name)