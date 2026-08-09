extends Control

@export var head_label: Label
@export var desc_label: Label

func set_labels_from_pattern(pattern : DarkPattern) -> void:
	head_label.text = pattern.name
	desc_label.text = pattern.description
	
func clear_labels() -> void:
	head_label.text = ""
	desc_label.text = ""
