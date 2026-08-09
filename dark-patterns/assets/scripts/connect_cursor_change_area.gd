extends CollisionShape2D

func _process(delta: float) -> void:
	var m = get_global_mouse_position() - global_position
	if abs(m.x) < shape.size.x/2 and abs(m.y) < shape.size.y/2:
		Global.change_cursor_override(true)
	else:
		Global.change_cursor_override(false)
