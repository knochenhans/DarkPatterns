extends Control
class_name TickerController

@export var ticker_label_scene: PackedScene

@export var message_spacing: float = 30.0

var label_stack: Array[TickerLabel] = []

func add_ticker_message(message: String) -> void:
	if not ticker_label_scene:
		push_error("TickerController: ticker_label_scene is not assigned.")
		return

	var ticker_label_instance = ticker_label_scene.instantiate() as TickerLabel
	ticker_label_instance.connect("label_destroyed", Callable(self, "on_label_destroyed"))

	add_child(ticker_label_instance)

	ticker_label_instance.text = message
	ticker_label_instance.reset_size()

	var start_x: float = get_next_spawn_position_x()

	label_stack.append(ticker_label_instance)

	ticker_label_instance.push_message("*** " + message + "***", start_x)

func on_label_destroyed(label: TickerLabel) -> void:
	label_stack.erase(label)

func get_next_spawn_position_x() -> float:
	var container_width: float = size.x if size.x > 0 else get_viewport_rect().size.x

	if label_stack.is_empty():
		return container_width

	var last_label: TickerLabel = label_stack.back()
	var last_label_right_edge: float = last_label.position.x + last_label.size.x + message_spacing
	
	return maxf(container_width, last_label_right_edge)
