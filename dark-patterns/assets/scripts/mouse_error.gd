extends Control
class_name MouseError
var elapsed = 0

var label_text = ""

func _ready():
	$Label.text = label_text

func _process(delta: float) -> void:
	elapsed += delta
	self.modulate.a = 1 - elapsed

func _on_timer_timeout() -> void:
	queue_free()
