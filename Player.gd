extends Node2D

signal hit
signal died
signal ep_add

const Blade = preload("res://Blade.gd")
var Enemy = load("res://Enemy.gd")
var Upgrade = load("res://Main.gd").Upgrade

const PLAYER_SPEED: float = 150.0
const BLADE_SWING_SPEED_MULTIPLIER_DELTA: float = 0.1
const BLADE_SWING_SPEED_MULTIPLIER_DECAY: float = 0.33
const BLADE_SWING_SPEED_MULTIPLIER_DECAY_COOLDOWN: float = 2.0
const SPRINT_TIME_MAX: float = 2.0
const BLINK_DISTANCE: float = 100.0
const BLINK_COOLDOWN: float = 2.0

var velocity: Vector2 = Vector2.ZERO

onready var Session = get_tree().root.get_node("Session")
onready var SFXEngine = preload("res://SoundEngine.gd").new()

var blade: Blade
var blade_left: Blade = null
var blade_swing_start_rotation: float = 0.0
var blade_swing_speed_multiplier_delta: float = 0.0
var blade_swing_speed_multiplier: float = 1.0
var blade_swing_speed_decay_cooldown_timer: Timer = Timer.new()
var blade_swing_speed_is_decaying: bool = true
var is_invincible_while_swinging: bool = false
var is_swinging_blade: bool = false
var can_swing_blade: bool = true
var blade_reset_timer: Timer = Timer.new()
var stun_timer: Timer = Timer.new()
var is_stunned: bool = false
var speed_multiplier: float = 1.0
var sprint_multiplier: float = 1.0
var sprint_seconds_left: float = SPRINT_TIME_MAX
var is_sprinting: bool = false
var can_blink: bool = false
var is_blinking: bool = false
var is_blinking_cooldown_active: bool = false
var blink_cooldown_timer: Timer = Timer.new()

var max_hp: int  # 2 HP == 1 heart
var hp: int setget set_hp, get_hp

func get_position():
	return self.position

func set_hp(new):
	if new < hp and self.is_swinging_blade and self.is_invincible_while_swinging:
		return
	var difference = new - hp
	hp = int(max(0, new))
	if difference < 0:
		emit_signal("hit", -difference)
	if hp == 0:
		emit_signal("died")

func get_hp():
	return hp

func get_max_hp():
	return self.max_hp

func _ready():
	self.add_child(SFXEngine)
	self.max_hp = Session.player_max_hp
	self.hp = self.max_hp
	_apply_upgrades()

	self.blade_swing_speed_decay_cooldown_timer.autostart = false
	self.blade_swing_speed_decay_cooldown_timer.one_shot = true
	assert(OK == self.blade_swing_speed_decay_cooldown_timer.connect("timeout", self, "_on_blade_swing_speed_decay_cooldown_timer"))
	self.add_child(self.blade_swing_speed_decay_cooldown_timer)

	self.blade_reset_timer.autostart = false
	self.blade_reset_timer.one_shot = true
	assert(OK == self.blade_reset_timer.connect("timeout", self, "_on_blade_cooldown_timer"))
	self.add_child(self.blade_reset_timer)

	self.stun_timer.autostart = false
	self.stun_timer.one_shot = true
	assert(OK == self.stun_timer.connect("timeout", self, "_on_stun_timer"))
	self.add_child(self.stun_timer)

	self.blink_cooldown_timer.autostart = false
	self.blink_cooldown_timer.one_shot = true
	assert(OK == self.blink_cooldown_timer.connect("timeout", self, "_on_blink_cooldown_timer"))
	self.add_child(self.blink_cooldown_timer)

	assert(OK == $HeadHolder/Head.connect("area_entered", self, "on_area_entered"))

func _apply_upgrades():
	var upgrades: Dictionary = Session.get_player_upgrades()
	var unneeded_blades = []
	if upgrades.has(Upgrade.W0_BIG):
		unneeded_blades.append($BladeHolder/Blade)
		unneeded_blades.append($BladeHolder/BladeRotating)
		unneeded_blades.append($LeftBladeHolder/BladeLeft)
		self.blade = $BladeHolder/BladeBig
		if upgrades.has(Upgrade.W00_BIG_SPEED_UP):
			self.blade_swing_speed_multiplier_delta = BLADE_SWING_SPEED_MULTIPLIER_DELTA
			if upgrades.has(Upgrade.W000_BIG_360):
				self.blade.swing_range = 2 * PI
		elif upgrades.has(Upgrade.W01_BIG_INVINCIBLE):
			self.is_invincible_while_swinging = true
			if upgrades.has(Upgrade.W010_BIG_PROJECTILE_SHIELD):
				self.blade.shields_against_projectiles = true
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
		unneeded_blades.append($BladeHolder/BladeRotating)
		unneeded_blades.append($LeftBladeHolder/BladeLeft)
		$LeftBladeHolder/BladeLeft.queue_free()
		self.blade = $BladeHolder/Blade

	for unneeded in unneeded_blades:
		unneeded.hide()
		unneeded.queue_free()

	if upgrades.has(Upgrade.S0_SPEED):
		self.speed_multiplier = 1.5
		if upgrades.has(Upgrade.S00_SPRINT):
			self.sprint_multiplier = 1.5
		elif upgrades.has(Upgrade.S01_BLINK):
			self.can_blink = true
	elif upgrades.has(Upgrade.S1_ARMOR):
		pass

func on_area_entered(area: Area2D):
	if area is Enemy:
		area.hit_player(self)

func _process(delta):
	if (not self.is_stunned) and (not self.is_swinging_blade or self.blade.can_move_while_swinging):
		var distance = velocity * PLAYER_SPEED * speed_multiplier * delta
		if self.is_sprinting and self.sprint_seconds_left > 0.0:
			self.sprint_seconds_left = max(0, self.sprint_seconds_left - delta)
			distance *= self.sprint_multiplier
		if not self.is_sprinting:
			self.sprint_seconds_left = min(SPRINT_TIME_MAX, self.sprint_seconds_left + delta)
		if self.is_blinking:
			distance = velocity * BLINK_DISTANCE
			self.blink_cooldown_timer.start(BLINK_COOLDOWN)
			self.is_blinking = false
			self.is_blinking_cooldown_active = true
		self.position += distance
		var vr = get_viewport_rect()
		self.position.x = clamp(self.position.x, vr.position.x, vr.end.x)
		self.position.y = clamp(self.position.y, vr.position.y, vr.end.y)

	if self.blade_swing_speed_is_decaying:
		self.blade_swing_speed_multiplier = clamp(self.blade_swing_speed_multiplier - BLADE_SWING_SPEED_MULTIPLIER_DECAY * delta, 1.0, 2.0)

	if self.is_swinging_blade:
		var distance = self.blade.swing_angular_speed * self.blade_swing_speed_multiplier * delta
		$LeftBladeHolder.rotation += distance
		$BladeHolder.rotation -= distance
		if $BladeHolder.rotation < self.blade_swing_start_rotation - self.blade.swing_range:
			on_blade_swing_end()

	self.blade.update_multiplier(self.blade_swing_speed_multiplier)

func _on_blade_cooldown_timer():
	$BladeHolder.rotation = $HeadHolder.rotation
	$LeftBladeHolder.rotation = $HeadHolder.rotation
	self.can_swing_blade = true

func _on_blade_swing_speed_decay_cooldown_timer():
	self.blade_swing_speed_is_decaying = true

func _on_blink_cooldown_timer():
	self.is_blinking_cooldown_active = false

func _swing_blade():
	if not self.can_swing_blade:
		return
	self.blade_swing_start_rotation = $BladeHolder.rotation
	self.is_swinging_blade = true
	self.can_swing_blade = false
	if blade_left != null:
		blade_left.engage()
	blade.engage()
	SFXEngine.play_sfx(SFXEngine.SFX_TYPE.BLADE)
	if self.is_invincible_while_swinging:
		$HeadHolder/Head/HeadSprite.modulate = Color.skyblue

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
		self.blade_swing_speed_multiplier = clamp(self.blade_swing_speed_multiplier + n * self.blade_swing_speed_multiplier_delta, 1.0, 2.0)
		self.blade_swing_speed_is_decaying = false
		self.blade_swing_speed_decay_cooldown_timer.stop()
		self.blade_swing_speed_decay_cooldown_timer.start(BLADE_SWING_SPEED_MULTIPLIER_DECAY_COOLDOWN)
		emit_signal("ep_add", n * n)   # basic combo

	if self.is_invincible_while_swinging and not self.is_stunned:
		$HeadHolder/Head/HeadSprite.modulate = Color.white

func stun(duration_ms):
	# stun duration does not add up, but it's not clipped either (3s stun followed up by 1s stays at 3s)
	if self.stun_timer.time_left > duration_ms / 1000:
		return
	self.stun_timer.stop()
	self.stun_timer.start(duration_ms / 1000)
	self.is_stunned = true
	self.velocity = Vector2.ZERO
	$HeadHolder/Head/HeadSprite.modulate = Color.darkgray

func _on_stun_timer():
	self.is_stunned = false
	$HeadHolder/Head/HeadSprite.modulate = Color.white

func _input(event):
	if self.is_stunned:
		return

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
		self.velocity = Vector2.ZERO
		if Input.is_action_pressed("go_up"):
			self.velocity.y -= 1
		if Input.is_action_pressed("go_down"):
			self.velocity.y += 1
		if Input.is_action_pressed("go_left"):
			self.velocity.x -= 1
		if Input.is_action_pressed("go_right"):
			self.velocity.x += 1
		self.velocity = self.velocity.normalized()
		self.is_sprinting = Input.is_action_pressed("sprint")
		self.is_blinking = Input.is_action_just_pressed("blink") and self.can_blink and not self.is_blinking_cooldown_active
