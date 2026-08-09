extends Node

var ingame = true

var figure_scene = preload("res://assets/scenes/figure.tscn") as PackedScene
var mouse_error = preload("res://assets/scenes/mouse_error.tscn") as PackedScene

@export var placed_pattern: PackedScene
@export var AvailablePatterns : Array[DarkPattern]
@export var number_of_figures : int = 5
@export var tick: Timer
@export var stop_button: TextureButton

# Sounds
@export var money_add_sound: AudioStream
@export var buy_pattern_sound: AudioStream
@export var cannot_place_pattern_sound: AudioStream
@export var ui_sound_player: AudioStreamPlayer2D
@export var button_click_sound: AudioStream
@export var character_sets: Array[CharacterSet] = []

# Pattern selection
@export var pattern_button_container: Container
@export var pattern_button_scene: PackedScene
@export var pattern_preview_scene: PackedScene

# Sprites
@export var figure_sprites: Array[SpriteFrames] = []

# Screens
@export var start_screen: StartScreen
@export var game_over_screen: GameOverScreen

@export var out_of_order_sticker: Control
@export var stop_experiment_sticker: Control
@export var money_font: Control

# Display containters
@export var description_container: DescriptionContainer
@export var money_container: MoneyContainer
@export var ticker_controller: TickerController

var first_names: PackedStringArray
var last_names: PackedStringArray

var current_pattern_selection : DarkPattern
var current_pattern_preview_instance : PatternPreview

var CurrentPatternSelection : DarkPattern
var CurrentPatternHovered : DarkPattern

var SpawnedFigures : Array[CharacterBody2D] = []
var CreatedPatterns : Array[PlacedPattern] = []

var play_area : CollisionShape2D = null

enum InputState {
	NONE,
	PLACING_PATTERN
}

enum GameState {
	STARTSCREEN,
	INGAME,
	GAMEOVER
}

var input_state : InputState = InputState.NONE
var game_state : GameState = GameState.STARTSCREEN

var happiness_messages = []
var death_messages = []
var depression_messages = []

func _ready() -> void:
	play_area = $play_area
	first_names = get_text_file_lines("res://assets/first_names.txt")
	last_names = get_text_file_lines("res://assets/last_names.txt")
	happiness_messages = get_text_file_lines("res://assets/happiness_messsages.txt")
	death_messages = get_text_file_lines("res://assets/death_messages.txt")
	depression_messages = get_text_file_lines("res://assets/depression_messages.txt")
	
	CurrentPatternSelection = null

	for pattern in AvailablePatterns:
		print("Adding pattern button for: ", pattern.name)
		var button_instance = pattern_button_scene.instantiate()
		pattern_button_container.add_child(button_instance)
		button_instance.set_pattern(pattern)
		button_instance.connect("pattern_selected", on_pattern_selected)

	start_game()
	# show_start_screen()

func show_start_screen() -> void:
	game_state = GameState.STARTSCREEN

	start_screen.visible = true
	game_over_screen.visible = false

	start_screen.connect("start_game_requested", Callable(self, "start_game"))

func show_game_over_screen() -> void:
	if game_state == GameState.GAMEOVER:
		return
	game_state = GameState.GAMEOVER
	stop_button.texture_disabled = stop_button.texture_pressed
	stop_button.disabled = true

	start_screen.visible = false
	game_over_screen.visible = true
	game_over_screen.run_game_over()

	out_of_order_sticker.visible = true
	
	stop_experiment_sticker.offset_transform_scale = Vector2.ZERO
	money_font.visible = false

	money_container.clear()
	description_container.clear()
	ticker_controller.clear()

	stop_game()

func start_game() -> void:	
	game_state = GameState.INGAME

	start_screen.visible = false
	game_over_screen.visible = false

	stop_button.connect("pressed", Callable(self, "show_game_over_screen"))

	tick.start()
	ticker_controller.add_ticker_message("Welcome!!!")

func stop_game() -> void:
	tick.stop()

	for figure in SpawnedFigures:
		if figure != null and not figure.is_queued_for_deletion():
			figure.stop()
	
func _input(event: InputEvent) -> void:
	if current_pattern_preview_instance != null and event is InputEventMouseMotion:
		current_pattern_preview_instance.global_position = event.position
	
	if event.is_action_pressed("place_pattern") && game_state == GameState.INGAME:
		if CurrentPatternSelection == null:
			print("No pattern selected.")
			ui_sound_player.stream = cannot_place_pattern_sound
			ui_sound_player.play()
			return


		if CurrentPatternSelection.use_collision:
			var number_of_figures_in_radius = get_figure_in_radius(event.position, CurrentPatternSelection.size).size()
			if not check_can_be_placed(event.position, CurrentPatternSelection.size):
				return

			if number_of_figures_in_radius > 0:
				print("Cannot place pattern, figures in radius: ", number_of_figures_in_radius)
				ui_sound_player.stream = cannot_place_pattern_sound
				ui_sound_player.play()
				#add_mouse_error(event.position, "Cannot place pattern on figures")
				return

		if not check_price(CurrentPatternSelection.price):
			#add_mouse_error(event.position, "Not enough money to place pattern")
			return

		Global.money -= CurrentPatternSelection.price

		ui_sound_player.stream = buy_pattern_sound
		ui_sound_player.play()

		var em := event as InputEventMouseButton
		if em:
			var instance : PlacedPattern = placed_pattern.instantiate()
			instance.global_position = em.global_position - %cliprect.global_position
			instance.dark_pattern = CurrentPatternSelection
			instance.apply_artificial_scarcity.connect(on_apply_artificial_scarcity)
			%patterns.add_child(instance)
			CreatedPatterns.append(instance)

		if not check_price(CurrentPatternSelection.price, false):
			hide_current_pattern_preview()

		# input_state = InputState.NONE
	
	var ik := event as InputEventKey
	if ik and ik.pressed and ik.keycode == Key.KEY_0:
		Global.money = 0

func check_price(price: int, play_sound: bool = true) -> bool:
	if Global.money < price:
		print("Not enough money to place pattern.")
		if play_sound:
			ui_sound_player.stream = cannot_place_pattern_sound
			ui_sound_player.play()
		return false
	return true

func check_can_be_placed(position: Vector2, size: float) -> bool:
	var figures_in_radius = get_figure_in_radius(position, size)
	if figures_in_radius.size() > 0:
		return false
	return true

func add_mouse_error(position: Vector2, text: String):
	var error: MouseError = mouse_error.instantiate()
	error.position = position
	error.label_text = text
	add_child(error)

func hide_current_pattern_preview():
	if current_pattern_preview_instance != null:
		print("Hiding current pattern preview for: ", current_pattern_preview_instance.dark_pattern.name)
		current_pattern_preview_instance.visible = false

func show_current_pattern_preview():
	if current_pattern_preview_instance != null:
		print("Showing current pattern preview for: ", current_pattern_preview_instance.dark_pattern.name)
		current_pattern_preview_instance.visible = true
		
func on_apply_artificial_scarcity(pattern: PlacedPattern):
	var figure = SpawnedFigures.pick_random()
	print("helooooooo1")
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

			if figure.current_state == Figure.FigureState.DIED:
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

	if game_state == GameState.INGAME and SpawnedFigures.size() < number_of_figures:
		var figure_instance = spawn_figure()
		SpawnedFigures.append(figure_instance)
		figure_instance.figure_died.connect(on_figure_died)

func _process(delta: float) -> void:
	var show_preview : int= 0
	if input_state == InputState.PLACING_PATTERN and current_pattern_preview_instance != null and CurrentPatternSelection != null:
		
		show_preview += 1
		if check_price(CurrentPatternSelection.price, false):
			show_preview += 1
			if CurrentPatternSelection.use_collision:
				if check_can_be_placed(current_pattern_preview_instance.global_position, CurrentPatternSelection.size):
					show_preview += 1
			else:
				show_preview += 1
	if show_preview == 1:
		Global.change_mouse_cursor(Global.cursors.no_money)
	elif show_preview == 2:
		Global.change_mouse_cursor(Global.cursors.bad_placement)
	else:
		Global.change_mouse_cursor(Global.cursors.normal)
	
	if show_preview >= 3:
		show_current_pattern_preview()
	else:
		hide_current_pattern_preview()

	if Global.money <= 5 and game_state == GameState.INGAME and CreatedPatterns.size() == 0:
		ticker_controller.add_ticker_message("You were unable to keep users on your platform and you can’t afford to place any more patterns.", true)

func spawn_figure() -> Figure:
	var figure_instance = figure_scene.instantiate()
	figure_instance.play_area = play_area
	figure_instance.position = get_random_spawn_location()
	figure_instance.first_name = first_names[randi() % first_names.size()]
	figure_instance.last_name = last_names[randi() % last_names.size()]

	var random_sprite_index = randi() % figure_sprites.size()
	figure_instance.set_character_set(character_sets[random_sprite_index % character_sets.size()])
	figure_instance.figure_state_changed.connect(on_figure_state_changed)

	%figures.add_child(figure_instance)
	return figure_instance

func get_random_spawn_location():
	var bounds = play_area.shape.size
	return Vector2(randf_range(0, bounds.x), randf_range(0, bounds.y))

func on_pattern_selected(pattern: DarkPattern) -> void:
	ui_sound_player.stream = button_click_sound
	ui_sound_player.play()

	description_container.set_labels_from_pattern(pattern)

	for button in pattern_button_container.get_children():
		if button is PatternButton:
			button.button_pressed = button.get_pattern() == pattern

	if not check_price(pattern.price):
		CurrentPatternSelection = null
		hide_current_pattern_preview()
		return

	CurrentPatternSelection = pattern

	create_pattern_preview()

	input_state = InputState.PLACING_PATTERN

func create_pattern_preview():
	if current_pattern_preview_instance != null:
		current_pattern_preview_instance.queue_free()

	current_pattern_preview_instance = pattern_preview_scene.instantiate()
	current_pattern_preview_instance.global_position = get_viewport().get_mouse_position()
	current_pattern_preview_instance.dark_pattern = CurrentPatternSelection
	%patterns.add_child(current_pattern_preview_instance)

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
	var figure_name = figure.get_figure_name()
	var message = ""
	print(figure_name)
	match new_state:
		Figure.FigureState.HAPPY:
			message = happiness_messages[randi() % happiness_messages.size()] % figure_name
		Figure.FigureState.SAD:
			message = depression_messages[randi() % depression_messages.size()] % figure_name
		Figure.FigureState.DIED:
			message = death_messages[randi() % death_messages.size()] % figure_name

	ticker_controller.add_ticker_message(message)

func get_text_file_lines(filePath) -> PackedStringArray:
	var file = FileAccess.open(filePath, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	var lines : Array = content.split("\n")
	return lines.filter(func(s): return s != "")

func on_pattern_timeout(pattern: PlacedPattern) -> void:
	if pattern in CreatedPatterns:
		print("Pattern timed out: ", pattern.dark_pattern.name)
		CreatedPatterns.erase(pattern)
