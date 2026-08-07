extends Area2D

var pattern : DarkPattern
@export var collision_polygon_2d: CollisionPolygon2D
@export var polygon_2d: Polygon2D
@export var size : int = 30
@export var ticks_remaining : int
@export var depression_effect : float
@export var money_mult : int

func _ready() -> void:
	Global.tick_timer.timeout.connect(on_tick)
	var points : PackedVector2Array = []
	for i in range(16):
		var angle = i * PI/8
		points.append(size*Vector2.from_angle(angle))
		polygon_2d.polygon = points
		collision_polygon_2d.polygon = points
		
func on_tick():
	var bodies = get_overlapping_bodies()
	Global.money += bodies.size() * money_mult
