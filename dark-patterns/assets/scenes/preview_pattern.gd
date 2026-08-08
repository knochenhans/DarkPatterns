extends Node2D
class_name PatternPreview

var dark_pattern: DarkPattern

@export var polygon_2d: Polygon2D
# @export var collision_polygon_2d: CollisionPolygon2D

func _ready() -> void:
    set_polygon_2d()

func set_polygon_2d():
    print("Setting polygon for pattern: ", dark_pattern.name)
    var points : PackedVector2Array = []
    for i in range(16):
        var angle = i * PI/8
        points.append(dark_pattern.size*Vector2.from_angle(angle))
    polygon_2d.polygon = points
    # collision_polygon_2d.polygon = points
    polygon_2d.color = dark_pattern.color