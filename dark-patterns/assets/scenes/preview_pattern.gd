extends Node2D
class_name PatternPreview

var dark_pattern: DarkPattern

@export var polygon_2d: Polygon2D
@export var icon_sprite: Sprite2D

func _ready() -> void:
    set_polygon_2d()
    icon_sprite.texture = dark_pattern.icon
    icon_sprite.scale = Vector2(dark_pattern.size/75, dark_pattern.size/75)

func set_polygon_2d():
    PatternHelper.set_polygon_2d(polygon_2d, dark_pattern)