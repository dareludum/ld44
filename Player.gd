extends Node2D

const PLAYER_SPEED: float = 100.0

var velocity: Vector2 = Vector2.ZERO

func get_position():
	return self.position

func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.position += velocity * PLAYER_SPEED * delta

func _input(event):
	if event is InputEventMouseMotion:
		self.look_at(event.position)
	elif event is InputEventKey:
		velocity = Vector2.ZERO
		if Input.is_action_pressed("go_up"):
			velocity.y -= 1
		if Input.is_action_pressed("go_down"):
			velocity.y += 1
		if Input.is_action_pressed("go_left"):
			velocity.x -= 1
		if Input.is_action_pressed("go_right"):
			velocity.x += 1
		velocity = velocity.normalized()
