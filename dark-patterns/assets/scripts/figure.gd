class_name Figure
extends CharacterBody2D

var happiness = 100
var affected = false

var play_area = null

var move_counter = 0
var move_target: Vector2 = Vector2.ZERO

@onready
var happy_ui_value = $debug_ui/happy/happy_value
@onready 
var death_timer = $death_timer


func _ready():
	happy_ui_value.text = str(happiness)

func _process(_delta) -> void:
	if happiness > 50:
		$AnimatedSprite2D.animation = "smile"
	elif happiness > 0:
		$AnimatedSprite2D.animation = "sad"
	else:
		$AnimatedSprite2D.animation = "died"
		if death_timer.is_stopped():
			death_timer.start()

func _physics_process(_delta: float) -> void:
	if move_target != Vector2.ZERO:
		var move_vector: Vector2 = move_target - position
		velocity = move_vector.normalized() * 100
		move_and_slide()

func get_random_move_location():
	var bounds = play_area.shape.size
	return Vector2(randf_range(0, bounds.x), randf_range(0, bounds.y))

func apply_effect(effect_type: String):
	match effect_type:
		"addictive_design":
			happiness -= 2
	if happiness > 100:
		happiness = 100
	if happiness < 0:
		happiness = 0

func _on_tick_timeout() -> void:
	if move_counter == 5:
		move_target = get_random_move_location()
		move_counter = 0
	else:
		move_counter += 1
	happy_ui_value.text = str(happiness)


func _on_death_timer_timeout() -> void:
	print("ded")
	queue_free()
