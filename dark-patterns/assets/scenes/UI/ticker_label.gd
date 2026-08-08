extends Label
class_name TickerLabel

signal label_destroyed(label: TickerLabel)

@export var scroll_speed: float = 100.0 # Pixels per second

var is_moving: bool = false

func push_message(msg: String, start_x: float) -> void:
	text = msg
	reset_size()
	position.x = start_x
	is_moving = true

func _process(delta: float) -> void:
	if not is_moving:
		return

	position.x -= scroll_speed * delta

	# Destroy when completely past the left edge of the screen
	if position.x + size.x < 0:
		emit_signal("label_destroyed", self)
		queue_free()