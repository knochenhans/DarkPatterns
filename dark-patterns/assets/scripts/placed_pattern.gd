extends Area2D
class_name PlacedPattern
var dark_pattern : DarkPattern
var ticks_remaining : int

var current_figures : Array = []

@export var collision_polygon_2d: CollisionPolygon2D
@export var polygon_2d: Polygon2D
@export var placement_sound_player: AudioStreamPlayer2D
@export var time_out_sound: AudioStream

signal apply_artificial_scarcity(pattern: PlacedPattern)
signal time_out(pattern: PlacedPattern)

func _ready() -> void:
	if dark_pattern == null:
		push_warning(self," has no darkpattern")
		queue_free()
		return
	Global.tick_timer.timeout.connect(on_tick)
	ticks_remaining = dark_pattern.duration
	
	set_polygon_2d()
	
	placement_sound_player.stream = dark_pattern.placement_sound
	placement_sound_player.play()

	body_entered.connect(func(body: Node) -> void:
		if body is Figure:
			on_figure_entered(body)
	)
	body_exited.connect(func(body: Node) -> void:
		if body is Figure:
			on_figure_exited(body)
	)

func set_polygon_2d():
	var points : PackedVector2Array = []
	for i in range(16):
		var angle = i * PI/8
		points.append(dark_pattern.size*Vector2.from_angle(angle))
	polygon_2d.polygon = points
	collision_polygon_2d.polygon = points
	polygon_2d.color = dark_pattern.color
	placement_sound_player.stream = dark_pattern.placement_sound
	placement_sound_player.play()
	if dark_pattern.effect == "artificial_scarcity":
		apply_artificial_scarcity.emit(self)

func on_tick():			
	for figure in current_figures:
		if figure == null or figure.is_queued_for_deletion():
			continue
		
		print("applying effects to figure: ", figure.get_figure_name())

		figure.apply_happiness_effect(-dark_pattern.depression_effect)
		figure.apply_community_effect(-dark_pattern.community_effect)

	ticks_remaining -= 1
	if ticks_remaining < 0:
		print("playing time out sound: ", time_out_sound)
		visible = false
		placement_sound_player.stream = time_out_sound
		placement_sound_player.play()
		await placement_sound_player.finished
		emit_signal("time_out", self)
		queue_free()

func on_figure_entered(figure: Figure) -> void:
	if figure == null or figure.is_queued_for_deletion():
		return
	if dark_pattern == null:
		return

	current_figures.append(figure)
	figure.affected = true

func on_figure_exited(figure: Figure) -> void:
	if figure == null or figure.is_queued_for_deletion():
		return
	if dark_pattern == null:
		return

	figure.affected = false
	current_figures.erase(figure)
