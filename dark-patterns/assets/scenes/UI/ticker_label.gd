extends Label
class_name TickerLabel

signal label_destroyed(label: TickerLabel)

@export var scroll_speed: float = 100.0

var is_moving: bool = false

func push_message(msg: String, start_x: float, warning: bool = false) -> void:
	text = msg
	reset_size()
	position.x = start_x
	is_moving = true

	var style_box := StyleBoxFlat.new()

	if warning:
		style_box.bg_color = Color.RED
		add_theme_stylebox_override("normal", style_box)
		
		# Set text color on LabelSettings or via Theme Override
		if label_settings:
			var label_settings_copy = label_settings.duplicate() as LabelSettings
			label_settings_copy.font_color = Color.WHITE
			label_settings = label_settings_copy

func _process(delta: float) -> void:
	if not is_moving:
		return

	position.x -= scroll_speed * delta

	# Destroy when completely past the left edge of the screen
	if position.x + size.x < 0:
		emit_signal("label_destroyed", self)
		queue_free()
