extends Node2D

signal died
signal ep_add

const Blade = preload("res://Blade.gd")
const Enemy = preload("res://Enemy.gd")
var Upgrade = load("res://Main.gd").Upgrade

const PLAYER_SPEED: float = 150.0

var velocity: Vector2 = Vector2.ZERO

onready var Session = get_tree().root.get_node("Session")
onready var SFXEngine = Session.get_node("SoundEngine")

var blade: Blade
var blade_left: Blade = null
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
	_apply_upgrades()

	self.blade_reset_timer.autostart = false
	self.blade_reset_timer.one_shot = true
	assert(OK == self.blade_reset_timer.connect("timeout", self, "_on_blade_cooldown_timer"))
	self.add_child(self.blade_reset_timer)

	assert(OK == $HeadHolder/Head.connect("area_entered", self, "_on_collision"))

func _apply_upgrades():
	var upgrades: Dictionary = Session.get_player_upgrades()
	var unneeded_blades = []
	if upgrades.has(Upgrade.W0_BIG):
		unneeded_blades.append($BladeHolder/Blade)
		unneeded_blades.append($BladeHolder/BladeRotating)
		unneeded_blades.append($LeftBladeHolder/BladeLeft)
		self.blade = $BladeHolder/BladeBig
	elif upgrades.has(Upgrade.W1_DUAL):
		unneeded_blades.append($BladeHolder/BladeBig)
		unneeded_blades.append($BladeHolder/BladeRotating)
		self.blade = $BladeHolder/Blade
		self.blade_left = $LeftBladeHolder/BladeLeft
		if upgrades.has(Upgrade.W10_DUAL_CAN_MOVE):
			self.blade.can_move_while_swinging = true
			if upgrades.has(Upgrade.W100_DUAL_FAST):
				self.blade.swing_angular_speed = 6 * PI
				self.blade.swing_cooldown = 0.15
			elif upgrades.has(Upgrade.W101_DUAL_ROTATING):
				unneeded_blades.erase($BladeHolder/BladeRotating)
				unneeded_blades.append($LeftBladeHolder/BladeLeft)
				self.blade_left = $BladeHolder/BladeRotating
		elif upgrades.has(Upgrade.W11_DUAL_KILL_PROJECTILES):
			self.blade.can_kill_projectiles = true
			if upgrades.has(Upgrade.W110_DUAL_360):
				self.blade.swing_range = 1.75 * PI
				self.blade.swing_cooldown = 0.05
	else:
		unneeded_blades.append($BladeHolder/BladeBig)
		unneeded_blades.append($LeftBladeHolder/BladeLeft)
		$LeftBladeHolder/BladeLeft.queue_free()
		self.blade = $BladeHolder/Blade

	for unneeded in unneeded_blades:
		unneeded.hide()
		unneeded.queue_free()

func _on_collision(area: Area2D):
	var node = area.get_node("..")
	if node is Enemy:
		self.hp = int(max(0, self.hp - 1))
		if self.hp == 0:
			emit_signal("died")

func _process(delta):
	if not self.is_swinging_blade or self.blade.can_move_while_swinging:
		self.position += velocity * PLAYER_SPEED * delta
	if self.is_swinging_blade:
		$LeftBladeHolder.rotation += self.blade.swing_angular_speed * delta
		$BladeHolder.rotation -= self.blade.swing_angular_speed * delta
		if $BladeHolder.rotation < self.blade_swing_start_rotation - self.blade.swing_range:
			on_blade_swing_end()

func _on_blade_cooldown_timer():
	$BladeHolder.rotation = $HeadHolder.rotation
	$LeftBladeHolder.rotation = $HeadHolder.rotation
	self.can_swing_blade = true

func _swing_blade():
	if not self.can_swing_blade:
		return
	self.blade_swing_start_rotation = $BladeHolder.rotation
	self.is_swinging_blade = true
	self.can_swing_blade = false
	if blade_left != null:
		blade_left.engage()
	blade.engage()
	SFXEngine.play_sfx(SFXEngine.SFX_TYPE.SFX_BLADE)

func on_blade_swing_end():
	self.is_swinging_blade = false
	self.blade_reset_timer.start(self.blade.swing_cooldown)
	if blade_left != null:
		blade_left.disengage()
	blade.disengage()

	# gain evolution points for killing enemies
	var enemies_hit = blade.enemies_hit()
	if blade_left != null:
		var enemies_hit_left = blade_left.enemies_hit()
		for enemy in enemies_hit_left:
			enemies_hit[enemy] = enemies_hit_left[enemy]
	var n = len(enemies_hit)
	if n > 0:
		emit_signal("ep_add", n * n)   # basic combo

func _input(event):
	if event is InputEventMouseMotion:
		var old_rotation = $HeadHolder.rotation
		$HeadHolder.look_at(event.position)
		if not self.is_swinging_blade:
			$BladeHolder.rotate($HeadHolder.rotation - old_rotation)
			$LeftBladeHolder.rotate($HeadHolder.rotation - old_rotation)
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
