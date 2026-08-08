extends Node

var ingame = true

var figure = preload("res://assets/scenes/figure.tscn") as PackedScene

@export var placed_pattern: PackedScene
@export var AvailablePatterns : Array[DarkPattern]
@export var number_of_figures : int = 5
var CurrentPatternSelection : DarkPattern

var SpawnedFigures : Array[CharacterBody2D] = []

var play_area : CollisionShape2D = null

func _ready() -> void:
	CurrentPatternSelection = AvailablePatterns[0]
	play_area = $play_area

func _process(delta: float) -> void:
	pass
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("place_pattern"):
		if not play_area.shape.get_rect().has_point(event.position - play_area.global_position):
			return

		var	price = CurrentPatternSelection.price
		if Global.money < price:
			print("Not enough money to place pattern.")
			return

		Global.money -= price

		var em := event as InputEventMouseButton
		if em:
			var instance : PlacedPattern = placed_pattern.instantiate()
			instance.position = em.global_position
			instance.dark_pattern = CurrentPatternSelection
			add_child(instance)

func _on_tick_timeout() -> void:
	if ingame and SpawnedFigures.size() < number_of_figures:
		var figure_instance = spawn_figure()
		SpawnedFigures.append(figure_instance)

func spawn_figure() -> Figure:
	var figure_instance = figure.instantiate()
	figure_instance.play_area = play_area
	figure_instance.position = get_random_spawn_location()
	$figures.add_child(figure_instance)
	return figure_instance

func get_random_spawn_location():
	var bounds = play_area.shape.size
	return Vector2(randf_range(0, bounds.x), randf_range(0, bounds.y))
