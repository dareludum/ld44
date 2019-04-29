extends VBoxContainer

export(int) var first_upgrade_index

func _ready():
	refresh()

func refresh():
	var counter = first_upgrade_index;
	for level in get_children():
		for button in level.get_children():
			button.set_upgrade(counter)
			counter += 1
