extends Node2D

const PLAYER_SPEED: float = 100.0
const BLADE_SWING_ANGULAR_SPEED: float = 4 * PI
const BLADE_SWING_COOLDOWN: float = 0.15
const PLAYER_BASE_HP: float = 100.0
const PLAYER_BASE_EP: int = 0

var velocity: Vector2 = Vector2.ZERO
var isSwingingBlade: bool = false
var canSwingBlade: bool = true
var bladeResetTimer: Timer = Timer.new()

var total_hp: float = PLAYER_BASE_HP
var hp: float = PLAYER_BASE_HP
var ep: int = PLAYER_BASE_EP

func get_position():
	return self.position

func get_hp():
	return self.hp

func get_max_hp():
	return self.total_hp

func get_ep():
	return self.ep

func _ready():
	self.bladeResetTimer.autostart = false
	self.bladeResetTimer.one_shot = true
	assert(OK == self.bladeResetTimer.connect("timeout", self, "_on_blade_cooldown_timer"))
	self.add_child(self.bladeResetTimer)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.position += velocity * PLAYER_SPEED * delta
	if self.isSwingingBlade:
		$BladeHolder.rotation -= BLADE_SWING_ANGULAR_SPEED * delta
		if $BladeHolder.rotation < -1.25 * PI:
			self.isSwingingBlade = false
			self.bladeResetTimer.start(BLADE_SWING_COOLDOWN)

func _input(event):
	if event is InputEventMouseMotion:
		self.look_at(event.position)
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.is_pressed():
			self._swing_blade()
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

func _swing_blade():
	if not self.canSwingBlade:
		return
	self.isSwingingBlade = true
	self.canSwingBlade = false

func _on_blade_cooldown_timer():
	$BladeHolder.rotation = 0.0
	self.canSwingBlade = true
