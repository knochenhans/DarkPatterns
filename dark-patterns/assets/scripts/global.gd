extends Control
class_name GlobalClass
@export var tick_timer: Timer

var money := 100
@export var cursor_bad_place: Texture2D
@export var cursor_no_money: Texture2D
enum cursors {normal,no_money,bad_placement}
var current_cursor : cursors
var cursor_override : bool = false
func change_mouse_cursor(cursor : cursors):
	if cursor_override and current_cursor != cursor:
		current_cursor = cursor
		match cursor:
			cursors.bad_placement:
				Input.set_custom_mouse_cursor(cursor_bad_place,0)
			cursors.no_money:
				Input.set_custom_mouse_cursor(cursor_no_money,0)
			_:
				Input.set_custom_mouse_cursor(null,0)

func change_cursor_override(override : bool):
	cursor_override = override
	if override == false:
		#print("c:override:",override)
		change_mouse_cursor(Global.cursors.normal)
