class_name Figure
extends CharacterBody2D

var happiness = 100
var affected = false

var play_area = null

var move_target: Vector2 = Vector2.ZERO
var alive = true

@export var community = 0
@export var area_2d: Area2D
@export var speed_scale: float = 1.0

@onready
var happy_ui_value = $debug_ui/happy/happy_value
@onready
var community_ui_value = $debug_ui/community/community_value
@onready 
var death_timer = $death_timer


func _ready():
	happy_ui_value.text = str(happiness)

func _process(_delta) -> void:
	if happiness > 50:
		change_animation_state("smile")
	elif happiness > 0:
		change_animation_state("sad")
	else:
		change_animation_state("died")
		alive = false
		if death_timer.is_stopped():
			death_timer.start()

func change_animation_state(state: String) -> void:
	$AnimatedSprite2D.play(state)

func _physics_process(_delta: float) -> void:
	if not alive:
		return

	$AnimatedSprite2D.speed_scale = velocity.length() * speed_scale

	if move_target != Vector2.ZERO:
		var move_vector: Vector2 = move_target - position
		velocity = move_vector.normalized() * 100

		move_and_slide()
		
		if abs(velocity.x) > 50:
			if velocity.x > 0:
				$AnimatedSprite2D.flip_h = true
			else:
				$AnimatedSprite2D.flip_h = false


func get_random_move_location():
	var bounds = play_area.shape.size
	var bodies = []
	for body in area_2d.get_overlapping_bodies():
		if body == self:
			continue
		bodies.append(body)
	if !bodies.is_empty():
		var target = bodies.pick_random() as Figure
		var target_pos = target.move_target if target.move_target != Vector2.ZERO else target.position
		var random_pos := Vector2(randf_range(0, bounds.x), randf_range(0, bounds.y))
		var bias = community/100
		bias = bias * bias * bias # cubic bias
		if community > 50:	
			return lerp(random_pos,target_pos,bias)
		else:
			return lerp(target_pos * -1, random_pos,bias)
	return Vector2(randf_range(0, bounds.x), randf_range(0, bounds.y))

func apply_happiness_effect(amount: int):
	happiness += amount
	print("happiness: ", happiness)
	if happiness > 100:
		happiness = 100
	if happiness < 0:
		happiness = 0

func apply_community_effect(amount: int):
	community += amount
	print("community: ", community)
	if community > 100:
		community = 100
	if community < 0:
		community = 0

func _on_tick_timeout() -> void:
	apply_happiness_effect(len(area_2d.get_overlapping_bodies()))
	apply_community_effect(5)
	move_target = get_random_move_location()
	happy_ui_value.text = str(happiness)
	community_ui_value.text = str(community)


func _on_death_timer_timeout() -> void:
	print("ded")
	queue_free()
