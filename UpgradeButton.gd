extends TextureButton

var upgrade : int
var unlocked = false
onready var Session = get_tree().root.get_node("Session")
onready var Upgrades = get_node("../../")

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.

func set_upgrade(upgrade):
    self.upgrade = upgrade
    
func get_upgrade():
    return self.upgrade

func set_unlocked(val):
    unlocked = val
    if (unlocked):
        self.texture_normal = self.texture_pressed

func unlock():
    if (unlocked == false):
        var ep = Session.get_ep()
        if (Session.get_upgrade_cost(upgrade) <= ep):
            unlocked = true
            Session.buy_player_upgrade(upgrade)
            #todo: change aspect
            set_unlocked(true)
            return true
        else:
            return false
            
    get_node("../../../../../../../Description").text = "Upgrade already owned!"
    return true

func _pressed():
    var desc = Session.get_upgrade_description(upgrade)
    get_node("../../../../../../../Description").text = desc
    Upgrades.set_pending_upgrade(self)