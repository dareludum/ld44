extends Node2D

signal died

const Enemy = preload("res://Enemy.gd")

const PLAYER_SPEED: float = 150.0
const BLADE_SWING_ANGULAR_SPEED: float = 6 * PI
const BLADE_SWING_RANGE: float = 1.25 * PI
const BLADE_SWING_COOLDOWN: float = 0.15

var velocity: Vector2 = Vector2.ZERO

onready var Session = get_tree().root.get_node("Session")

onready var blade = $BladeHolder/Blade
var blade_swing_start_rotation: float = 0.0
var is_swinging_blade: bool = false
var can_swing_blade: bool = true
var blade_reset_timer: Timer = Timer.new()

var max_hp: int
var hp: int

func get_position():
	return self.position

func get_hp():
	return self.hp

func get_max_hp():
	return self.max_hp

func _ready():
	self.max_hp = Session.player_max_hp
	self.hp = self.max_hp

	self.blade_reset_timer.autostart = false
	self.blade_reset_timer.one_shot = true
	assert(OK == self.blade_reset_timer.connect("timeout", self, "_on_blade_cooldown_timer"))
	self.add_child(self.blade_reset_timer)

	assert(OK == $HeadHolder/Head.connect("area_entered", self, "_on_collision"))

func _on_collision(area: Area2D):
	var node = area.get_node("..")
	if node is Enemy:
		self.hp = int(max(0, self.hp - 1))
		if self.hp == 0:
			emit_signal("died")

func _process(delta):
	self.position += velocity * PLAYER_SPEED * delta
	if self.is_swinging_blade:
		$BladeHolder.rotation -= BLADE_SWING_ANGULAR_SPEED * delta
		if $BladeHolder.rotation < self.blade_swing_start_rotation - BLADE_SWING_RANGE:
			on_blade_swing_end()

func _on_blade_cooldown_timer():
	$BladeHolder.rotation = $HeadHolder.rotation
	self.can_swing_blade = true

func _swing_blade():
	if not self.can_swing_blade:
		return
	self.blade_swing_start_rotation = $BladeHolder.rotation
	self.is_swinging_blade = true
	self.can_swing_blade = false
	blade.engage()

func on_blade_swing_end():
	self.is_swinging_blade = false
	self.blade_reset_timer.start(BLADE_SWING_COOLDOWN)
	blade.disengage()

	# gain evolution points for killing enemies
	var n = len(blade.enemies_hit())
	Session.ep += n * n   # basic combo

func _input(event):
	if event is InputEventMouseMotion:
		var old_rotation = $HeadHolder.rotation
		$HeadHolder.look_at(event.position)
		if not self.is_swinging_blade:
			$BladeHolder.rotate($HeadHolder.rotation - old_rotation)
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
