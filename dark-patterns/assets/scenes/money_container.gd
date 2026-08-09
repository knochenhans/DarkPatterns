extends Control
class_name MoneyContainer

@export var money_label: Label

var off_theme = preload("res://resources/small_screen_off_theme.tres") as Theme

func _process(_delta: float) -> void:
	money_label.text = humanize_number(str(Global.money, "")) + "$"

# gratefully taken from
# https://forum.godotengine.org/t/humanize-numbers/88273/3
func humanize_number(number : String) -> String:
	var to_return : String
	var decimals : String
	if "." in number:
		decimals = "." + number.split(".", false, 0)[1]
	if len(number.replace(decimals, "")) < 4:
		return number
	else:
		var i : int = 0
		for item in number.replace(decimals, "").reverse():
			if i == 3:
				item += "."
				i = 0
			to_return = item + to_return
			i += 1
		return to_return + decimals

func clear() -> void:
	money_label.text = ""
	theme = off_theme
	
