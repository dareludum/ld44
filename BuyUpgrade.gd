extends Button

signal buy
var upgrade_button

func _pressed():
        emit_signal("buy")
        
func set_upgrade_button(upgrade_button):
    self.upgrade_button = upgrade_button
    
func get_upgrade_button():
    return upgrade_button