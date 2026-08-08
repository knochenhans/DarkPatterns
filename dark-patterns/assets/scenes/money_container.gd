extends PanelContainer

@export var money_label: Label

func _process(_delta: float) -> void:
    # Format as "000.00 $"
    money_label.text = str(Global.money, "") + " $"