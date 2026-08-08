extends Area2D
class_name PlacedPattern
var dark_pattern : DarkPattern
@export var collision_polygon_2d: CollisionPolygon2D
@export var polygon_2d: Polygon2D
var ticks_remaining : int

func _ready() -> void:
	if dark_pattern == null:
		push_warning(self," has no darkpattern")
		queue_free()
		return
	Global.tick_timer.timeout.connect(on_tick)
	ticks_remaining = dark_pattern.duration
	var points : PackedVector2Array = []
	for i in range(16):
		var angle = i * PI/8
		points.append(dark_pattern.size*Vector2.from_angle(angle))
		polygon_2d.polygon = points
		collision_polygon_2d.polygon = points
		
func on_tick():
	for b in get_overlapping_bodies():
		if b.is_in_group("Person"):
			Global.money += 1
			apply_effect(b, dark_pattern.effect)
			print("money: ", Global.money)
			
			
	ticks_remaining -= 1
	if ticks_remaining < 0:
		queue_free()

func apply_effect(figure: Figure, effect_type: String):
	match effect_type:
		"addictive_design":
			figure.apply_happiness_effect(-2)
