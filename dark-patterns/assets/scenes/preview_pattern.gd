extends Node2D
class_name PatternPreview

var dark_pattern: DarkPattern

@export var polygon_2d: Polygon2D

func _ready() -> void:
    set_polygon_2d()

func set_polygon_2d():
    PatternHelper.set_polygon_2d(polygon_2d, dark_pattern)