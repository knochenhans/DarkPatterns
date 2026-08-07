extends Node

var ingame = true

var figure = preload("res://figure.tscn")
func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass
	


func _on_tick_timeout() -> void:
	if ingame:
		spawn_figure()
		pass

func spawn_figure():
	
	var figure_instance = figure.instantiate()
	figure_instance.play_area = $play_area
	figure_instance.position = get_random_spawn_location()
	$figures.add_child(figure_instance)
	pass

func get_random_spawn_location():
	var bounds = $play_area.shape.size
	return Vector2(randf_range(0, bounds.x), randf_range(0, bounds.y))
