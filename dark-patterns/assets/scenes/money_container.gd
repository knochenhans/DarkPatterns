extends Control

@export var money_label: Label

func _process(_delta: float) -> void:
	money_label.text = str(Global.money, "") + "$"
