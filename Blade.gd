extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(OK == $Area2D.connect("body_entered", self, "on_body_entered"))
	assert(OK == $Area2D.connect("body_exited", self, "on_body_exited"))

func on_body_entered(body: PhysicsBody2D):
	print("enter: " + str(body))

func on_body_exited(body: PhysicsBody2D):
	print("exit: " + str(body))

func _physics_process(_delta: float):
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
