extends Node2D

const Enemy = preload("Enemy.gd")

var _enemies_hit: Dictionary = {}
var engaged: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(OK == $Area2D.connect("body_entered", self, "on_body_entered"))
	# assert(OK == $Area2D.connect("body_exited", self, "on_body_exited"))

func engage():
	_enemies_hit.clear()
	engaged = true

func disengage():
	engaged = false

func enemies_hit():
	return _enemies_hit

func on_body_entered(body: PhysicsBody2D):
	if not engaged:
		return
	var hit = body.get_node("..")
	if hit is Enemy and not (hit in _enemies_hit):
		_enemies_hit[hit] = true

# func on_body_exited(body: PhysicsBody2D):
# print("exit: " + str(body))

func _physics_process(_delta: float):
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
