extends Node2D

var happyness = 100

var affected = true

func _ready():
	pass
	
func _process(delta: float) -> void:
	if happyness > 50:
		$AnimatedSprite2D.animation = "smile"
	else:
		$AnimatedSprite2D.animation = "sad"
	pass


func _on_tick_timeout() -> void:
	if affected:
		happyness = happyness - 2
		
		if happyness > 100:
			happyness = 100
		if happyness < 0:
			happyness = 0
	print(happyness)
