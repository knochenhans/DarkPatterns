extends Node

var ingame = true

var figure_scene = preload("res://assets/scenes/figure.tscn") as PackedScene
var mouse_error = preload("res://assets/scenes/mouse_error.tscn") as PackedScene

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
@export var pattern_preview_scene: PackedScene

# Sprites
@export var figure_sprites: Array[SpriteFrames] = []

# Ticker
@export var ticker: TickerController

var first_names: PackedStringArray
var last_names: PackedStringArray

var current_pattern_selection : DarkPattern
var current_pattern_preview_instance : PatternPreview

var CurrentPatternSelection : DarkPattern

var SpawnedFigures : Array[CharacterBody2D] = []
var CreatedPatterns : Array[PlacedPattern] = []

var play_area : CollisionShape2D = null

enum InputState {
	NONE,
	PLACING_PATTERN
}

var input_state : InputState = InputState.NONE

func _ready() -> void:
	CurrentPatternSelection = null
	play_area = $play_area

	for pattern in AvailablePatterns:
		print("Adding pattern button for: ", pattern.name)
		var button_instance = pattern_button_scene.instantiate()
		pattern_button_container.add_child(button_instance)
		button_instance.set_pattern(pattern)
		button_instance.connect("pattern_selected", on_pattern_selected)

	first_names = get_text_file_content("res://assets/first_names.txt").split("\n")
	last_names = get_text_file_content("res://assets/last_names.txt").split("\n")

	ticker.add_ticker_message("Welcome!!!")
	
func _input(event: InputEvent) -> void:
	if current_pattern_preview_instance != null and event is InputEventMouseMotion:
		# print("Moving pattern preview to: ", event.position)
		current_pattern_preview_instance.position = event.position
	
	if event.is_action_pressed("place_pattern"):
		if not play_area.shape.get_rect().has_point(event.position - play_area.global_position):
			return

		if CurrentPatternSelection == null:
			print("No pattern selected.")
			ui_sound_player.stream = cannot_place_pattern_sound
			ui_sound_player.play()
			return

		if CurrentPatternSelection.use_collision:
			var number_of_figures_in_radius = get_figure_in_radius(event.position, CurrentPatternSelection.size).size()

			if number_of_figures_in_radius > 0:
				print("Cannot place pattern, figures in radius: ", number_of_figures_in_radius)
				ui_sound_player.stream = cannot_place_pattern_sound
				ui_sound_player.play()
				# add_mouse_error(event.position, "Cannot place pattern on figures")
				return

		if not check_money(CurrentPatternSelection.price):
			# add_mouse_error(event.position, "Not enough money to place pattern")
			return

		ui_sound_player.stream = buy_pattern_sound
		ui_sound_player.play()

		var em := event as InputEventMouseButton
		if em:
			var instance : PlacedPattern = placed_pattern.instantiate()
			instance.position = em.global_position
			instance.dark_pattern = CurrentPatternSelection
			add_child(instance)
			CreatedPatterns.append(instance)

		remove_current_pattern_preview()

		input_state = InputState.NONE

func check_money(price: int) -> bool:
	if Global.money < price:
		print("Not enough money to place pattern.")
		ui_sound_player.stream = cannot_place_pattern_sound
		ui_sound_player.play()
		return false

	Global.money -= price
	return true

func add_mouse_error(position: Vector2, text: String):
	var error: MouseError = mouse_error.instantiate()
	error.position = position
	error.label_text = text
	add_child(error)

func remove_current_pattern_preview():
	if current_pattern_preview_instance != null:
		current_pattern_preview_instance.queue_free()
		current_pattern_preview_instance = null
		
func on_apply_artificial_scarcity(pattern: PlacedPattern):
	var figure = SpawnedFigures.pick_random()
	if figure != null && !figure.is_queued_for_deletion():
		figure.apply_artificial_scarcity(pattern)

func on_figure_entered_pattern(figure: Figure, pattern_template: DarkPattern) -> void:
	if figure == null or figure.is_queued_for_deletion():
		return

	if pattern_template == null:
		return

func _on_tick_timeout() -> void:
	for pattern in CreatedPatterns:
		if pattern == null or pattern.is_queued_for_deletion():
			continue

		for figure in pattern.current_figures:
			if figure == null or figure.is_queued_for_deletion():
				continue

			var money_added = 0
			
			match pattern.dark_pattern.effect:
				"lootboxes":
					money_added += pattern.dark_pattern.money_added * ((100 - figure.community) / 2)
				_:
					money_added += pattern.dark_pattern.money_added

			Global.money += money_added

			if money_added > 0:
				ui_sound_player.stream = money_add_sound
				ui_sound_player.play()

	if ingame and SpawnedFigures.size() < number_of_figures:
		var figure_instance = spawn_figure()
		SpawnedFigures.append(figure_instance)
		figure_instance.figure_died.connect(on_figure_died)

func spawn_figure() -> Figure:
	var figure_instance = figure_scene.instantiate()
	figure_instance.play_area = play_area
	figure_instance.position = get_random_spawn_location()
	figure_instance.first_name = first_names[randi() % first_names.size()]
	figure_instance.last_name = last_names[randi() % last_names.size()]

	var random_sprite_index = randi() % figure_sprites.size()
	figure_instance.set_sprite_frames(figure_sprites[random_sprite_index])
	figure_instance.figure_state_changed.connect(on_figure_state_changed)

	$figures.add_child(figure_instance)
	return figure_instance

func get_random_spawn_location():
	var bounds = play_area.shape.size
	return Vector2(randf_range(0, bounds.x), randf_range(0, bounds.y))

func on_pattern_selected(pattern: DarkPattern) -> void:
	print("Pattern selected: ", pattern.name)
	ui_sound_player.stream = button_click_sound
	ui_sound_player.play()

	if not check_money(pattern.price):
		CurrentPatternSelection = null
		return

	CurrentPatternSelection = pattern

	create_pattern_preview()

	input_state = InputState.PLACING_PATTERN

func create_pattern_preview():
	if current_pattern_preview_instance != null:
		current_pattern_preview_instance.queue_free()
	current_pattern_preview_instance = pattern_preview_scene.instantiate()
	current_pattern_preview_instance.dark_pattern = CurrentPatternSelection
	add_child(current_pattern_preview_instance)

func get_figure_in_radius(position: Vector2, radius: float) -> Array[Figure]:
	var figures_in_radius : Array[Figure] = []
	for figure in SpawnedFigures:
		if figure.position.distance_to(position) <= radius:
			figures_in_radius.append(figure)
	return figures_in_radius

func on_figure_died(figure: Figure) -> void:
	if figure in SpawnedFigures:
		SpawnedFigures.erase(figure)

func on_figure_state_changed(figure: Figure, new_state: Figure.FigureState) -> void:
	var state_string = ""
	match new_state:
		Figure.FigureState.HAPPY:
			state_string = "happy"
		Figure.FigureState.SAD:
			state_string = "sad"
	ticker.add_ticker_message(figure.get_figure_name() + " is now " + state_string + "!")

func get_text_file_content(filePath) -> String:
	var file = FileAccess.open(filePath, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	return content

func on_pattern_timeout(pattern: PlacedPattern) -> void:
	if pattern in CreatedPatterns:
		print("Pattern timed out: ", pattern.dark_pattern.name)
		CreatedPatterns.erase(pattern)
