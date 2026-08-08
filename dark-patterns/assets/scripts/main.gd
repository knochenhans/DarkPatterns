extends Node

var ingame = true

var figure_scene = preload("res://assets/scenes/figure.tscn") as PackedScene

@export var placed_pattern: PackedScene
@export var AvailablePatterns : Array[DarkPattern]
@export var number_of_figures : int = 5

# Sounds
@export var money_add_sound: AudioStream
@export var buy_pattern_sound: AudioStream
@export var cannot_place_pattern_sound: AudioStream
@export var ui_sound_player: AudioStreamPlayer2D
@export var button_click_sound: AudioStream

# Pattern selection
@export var pattern_button_container: Container
@export var pattern_button_scene: PackedScene

var current_pattern_selection : DarkPattern

var CurrentPatternSelection : DarkPattern

var SpawnedFigures : Array[CharacterBody2D] = []

var play_area : CollisionShape2D = null

func _ready() -> void:
	CurrentPatternSelection = null
	play_area = $play_area

	for pattern in AvailablePatterns:
		print("Adding pattern button for: ", pattern.name)
		var button_instance = pattern_button_scene.instantiate()
		pattern_button_container.add_child(button_instance)
		button_instance.set_pattern(pattern)
		button_instance.connect("pattern_selected", on_pattern_selected)


func _process(delta: float) -> void:
	pass
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("place_pattern"):
		if not play_area.shape.get_rect().has_point(event.position - play_area.global_position):
			return

		if CurrentPatternSelection == null:
			print("No pattern selected.")
			ui_sound_player.stream = cannot_place_pattern_sound
			ui_sound_player.play()
			return

		var	price = CurrentPatternSelection.price
		if Global.money < price:
			print("Not enough money to place pattern.")
			ui_sound_player.stream = cannot_place_pattern_sound
			ui_sound_player.play()
			return

		Global.money -= price

		ui_sound_player.stream = buy_pattern_sound
		ui_sound_player.play()

		var em := event as InputEventMouseButton
		if em:
			var instance : PlacedPattern = placed_pattern.instantiate()
			instance.position = em.global_position
			instance.dark_pattern = CurrentPatternSelection
			instance.figure_entered.connect(func(figure: Figure) -> void:
				on_figure_entered_pattern(figure, CurrentPatternSelection)
			)
			add_child(instance)

func on_figure_entered_pattern(figure: Figure, pattern: DarkPattern) -> void:
	match pattern.effect:
		"addictive_design":
			Global.money += pattern.money_added
		"lootboxes":
			Global.money += pattern.money_added * ((100 - figure.community) / 2)
	print("money: ", Global.money)
	ui_sound_player.stream = money_add_sound
	ui_sound_player.play()

func _on_tick_timeout() -> void:
	if ingame and SpawnedFigures.size() < number_of_figures:
		var figure_instance = spawn_figure()
		SpawnedFigures.append(figure_instance)

func spawn_figure() -> Figure:
	var figure_instance = figure_scene.instantiate()
	figure_instance.play_area = play_area
	figure_instance.position = get_random_spawn_location()
	$figures.add_child(figure_instance)
	return figure_instance

func get_random_spawn_location():
	var bounds = play_area.shape.size
	return Vector2(randf_range(0, bounds.x), randf_range(0, bounds.y))

func on_pattern_selected(pattern: DarkPattern) -> void:
	print("Pattern selected: ", pattern.name)
	ui_sound_player.stream = button_click_sound
	ui_sound_player.play()
	CurrentPatternSelection = pattern

func get_figure_in_radius(position: Vector2, radius: float) -> Array[Figure]:
	var figures_in_radius : Array[Figure] = []
	for figure in SpawnedFigures:
		if figure.position.distance_to(position) <= radius:
			figures_in_radius.append(figure)
	return figures_in_radius
