extends Node

var ingame = true

var figure = preload("res://assets/scenes/figure.tscn")
@export var placed_pattern: PackedScene
@export var AvailablePatterns : Array[DarkPattern]
var CurrentPatternSelection : DarkPattern

func _ready() -> void:
	# zum test
	CurrentPatternSelection = AvailablePatterns[0]

func _process(delta: float) -> void:
	pass
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("place_pattern"):
		var em := event as InputEventMouseButton
		if em:
			var instance : PlacedPattern = placed_pattern.instantiate()
			instance.position = em.global_position
			instance.dark_pattern = CurrentPatternSelection
			add_child(instance)

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
