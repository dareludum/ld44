extends TextureButton

var upgrade : int

onready var Session = get_tree().root.get_node("Session")

func set_upgrade(upgrade):
	self.upgrade = upgrade
	self.hint_tooltip = Session.get_upgrade_description(upgrade)
	match Session.get_upgrade_status(upgrade):
		0: # Unavailable
			self.texture_normal = preload("res://images/tree_unavailable.png")
		1: # Available
			self.texture_normal = preload("res://images/tree_placeholder.png")
		2: # Bought
			self.texture_normal = preload("res://images/tree_unlocked.png")

func get_upgrade():
	return self.upgrade

func _pressed():
	Session.get_node("UpgradesMenu").set_selected_upgrade(upgrade)
