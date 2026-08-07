extends CharacterBody2D

var happyness = 100
var affected = true
var play_area = null


var move_counter = 0
var move_target: Vector2 = Vector2.ZERO

func _ready():
	pass

func _process(_delta) -> void:
	if happyness > 50:
		$AnimatedSprite2D.animation = "smile"
	else:
		$AnimatedSprite2D.animation = "sad"


func _physics_process(_delta: float) -> void:
	if move_target != Vector2.ZERO:
		var move_vector: Vector2 = move_target - position
		velocity = move_vector.normalized() * 100
		move_and_slide()

func get_random_move_location():
	var bounds = play_area.shape.size
	return Vector2(randf_range(0, bounds.x), randf_range(0, bounds.y))

func _on_tick_timeout() -> void:
	if move_counter == 5:
		move_target = get_random_move_location()
		move_counter = 0
	else:
		move_counter += 1
	if affected:
		happyness -= 2
		if happyness > 100:
			happyness = 100
		if happyness < 0:
			happyness = 0
	print(happyness)
