extends Button

var eight_ball = preload("res://scenes/eight-ball.tscn")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_pressed():
	get_node("../Kajetan").text = "SPAWNED!"
	var instance = eight_ball.instance()
	instance.position = Vector2(600, 200)
	get_tree().get_root().add_child(instance)
