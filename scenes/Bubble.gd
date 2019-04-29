extends Area2D

const Beam = preload("res://BeamPink.gd")

const COOLDOWN: float = 2.0

var cooldown_timer: Timer = Timer.new()
var is_active: bool = true

func _ready():
	self.cooldown_timer.autostart = false
	self.cooldown_timer.one_shot = true
	assert(OK == self.cooldown_timer.connect("timeout", self, "_on_cooldown_timer"))
	self.add_child(self.cooldown_timer)

	assert(OK == self.connect("area_entered", self, "_on_area_entered"))

func _on_cooldown_timer():
	self.show()
	self.is_active = true

func _on_area_entered(area: Area2D):
	if self.is_active and area is Beam:
		area.hide()
		area.queue_free()
		self.hide()
		self.is_active = false
		self.cooldown_timer.start(COOLDOWN)
