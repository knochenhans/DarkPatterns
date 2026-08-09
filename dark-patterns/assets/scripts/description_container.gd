extends Control
class_name DescriptionContainer

@export var head_label: Label
@export var desc_label: Label

var off_theme = preload("res://resources/small_screen_off_theme.tres") as Theme

func set_labels_from_pattern(pattern : DarkPattern) -> void:
	head_label.text = pattern.name + " (" + str(pattern.price) + "$)"
	desc_label.text = pattern.description
	
func clear() -> void:
	head_label.text = ""
	desc_label.text = ""
	theme = off_theme
