class_name PatternHelper

static func set_polygon_2d(polygon_2d: Polygon2D, dark_pattern: DarkPattern) -> PackedVector2Array: 
    var points : PackedVector2Array = []
    for i in range(16):
        var angle = i * PI/8
        points.append(dark_pattern.size*Vector2.from_angle(angle))
    polygon_2d.polygon = points
    polygon_2d.color = dark_pattern.color
    return points