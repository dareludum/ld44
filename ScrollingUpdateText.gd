extends Control

const SCROLL_SPEED: float = 50.0
const SCROLL_TIME: float = 0.75

func set_value(text: String, color: Color):
	$Text.add_color_override("font_color", color)
	$Text.text = text

func _ready():
	var timer = Timer.new()
	timer.connect("timeout", self, "_on_timer_timeout")
	timer.start(SCROLL_TIME)
	self.add_child(timer)

func _on_timer_timeout():
	self.hide()
	self.queue_free()

func _process(delta: float):
	self.rect_position.y -= SCROLL_SPEED * delta
