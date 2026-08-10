extends Control
class_name GlobalClass
@export var tick_timer: Timer

var money := 100
@export var cursor_bad_place: Texture2D
@export var cursor_no_money: Texture2D
@export var cursor_custom_offset := Vector2(30,30)
enum cursors {normal,no_money,bad_placement}
var current_cursor : cursors
var cursor_override : bool = false
func change_mouse_cursor(cursor : cursors):
	if cursor_override:
		if current_cursor != cursor:
			current_cursor = cursor
			set_cursor(cursor)

func change_cursor_override(override : bool):
	if cursor_override == override:
		return
	cursor_override = override
	if override == false:
		set_cursor(cursors.normal)
	else:
		set_cursor(current_cursor)
	
func set_cursor(cursor : cursors):
	match cursor:
		cursors.bad_placement:
			Input.set_custom_mouse_cursor(cursor_bad_place,Input.CursorShape.CURSOR_ARROW,cursor_custom_offset)
		cursors.no_money:
			Input.set_custom_mouse_cursor(cursor_no_money,Input.CursorShape.CURSOR_ARROW,cursor_custom_offset)
		_:
			Input.set_custom_mouse_cursor(null,Input.CursorShape.CURSOR_ARROW)
