extends Area2D
class_name PlacedPattern
var dark_pattern : DarkPattern
@export var collision_polygon_2d: CollisionPolygon2D
@export var polygon_2d: Polygon2D
@export var placement_sound_player: AudioStreamPlayer2D
@export var time_out_sound: AudioStream
var ticks_remaining : int

signal figure_entered(figure: Figure)

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

func set_polygon_2d():
	var points : PackedVector2Array = []
	for i in range(16):
		var angle = i * PI/8
		points.append(dark_pattern.size*Vector2.from_angle(angle))
	polygon_2d.polygon = points
	collision_polygon_2d.polygon = points
	polygon_2d.color = dark_pattern.color
		
func on_tick():
	for b in get_overlapping_bodies():
		if b.is_in_group("Person"):
			apply_effect(b, dark_pattern.effect)
			figure_entered.emit(b)
			
	ticks_remaining -= 1
	if ticks_remaining < 0:
		print("playing time out sound: ", time_out_sound)
		visible = false
		placement_sound_player.stream = time_out_sound
		placement_sound_player.play()
		await placement_sound_player.finished
		queue_free()

func apply_effect(figure: Figure, effect: String):
	match effect:
		"addictive_design":
			figure.apply_happiness_effect(-2)
			figure.apply_community_effect(-10)
		"lootboxes":
			figure.apply_happiness_effect(-10)
			figure.apply_community_effect(-2)
