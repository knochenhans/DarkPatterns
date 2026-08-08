class_name Figure
extends CharacterBody2D

var happiness = 100
var affected = false

var play_area = null

var move_target: Vector2 = Vector2.ZERO
var alive = true

var first_name = ""
var last_name = ""
var artificial_scarcity_pattern: PlacedPattern = null

@export var community = 0
@export var area_2d: Area2D
@export var speed_scale: float = 1.0

@onready var debug_name_label = $debug_ui/DebugContainer/NameLabel
@onready var debug_happy_label = $debug_ui/DebugContainer/HappyLabel
@onready var debug_community_label = $debug_ui/DebugContainer/CommunityLabel
@onready var death_timer = $death_timer

signal figure_died(figure: Figure)


func _ready():
	debug_name_label.text = get_figure_name()
	debug_happy_label.text = str(happiness)

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
	
	if artificial_scarcity_pattern != null:
		if (artificial_scarcity_pattern.position - position).length() < 20:
			set_collision_mask_value(1, true)
			artificial_scarcity_pattern.queue_free()
			artificial_scarcity_pattern = null
			

func change_animation_state(state: String) -> void:
	$AnimatedSprite2D.play(state)

func _physics_process(_delta: float) -> void:
	if not alive:
		return

	$AnimatedSprite2D.speed_scale = velocity.length() * speed_scale
	
	if artificial_scarcity_pattern != null:
		var move_vector: Vector2 = artificial_scarcity_pattern.position - position
		velocity = move_vector.normalized() * 1000
		move_and_slide()
		
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

func apply_artificial_scarcity(pattern: PlacedPattern):
	set_collision_mask_value(1, false)
	artificial_scarcity_pattern = pattern

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
	debug_happy_label.text = str(happiness)
	debug_community_label.text = str(community)


func _on_death_timer_timeout() -> void:
	print("ded")
	emit_signal("figure_died", self)
	queue_free()

func get_figure_name() -> String:
	return first_name + " " + last_name

func set_sprite_frames(sprite_frames: SpriteFrames) -> void:
	$AnimatedSprite2D.frames = sprite_frames
