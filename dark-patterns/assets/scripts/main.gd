extends Node

var ingame = true

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass
	


func _on_tick_timeout() -> void:
	if ingame:
		spawn_figure()
		pass

func spawn_figure():
	pass
