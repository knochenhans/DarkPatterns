extends CharacterBody2D
class_name Figure

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

@export var walking_sound_player: AudioStreamPlayer2D
@export var state_sound_player: AudioStreamPlayer2D

@onready var debug_name_label = $debug_ui/DebugContainer/NameLabel
@onready var debug_happy_label = $debug_ui/DebugContainer/HappyLabel
@onready var debug_community_label = $debug_ui/DebugContainer/CommunityLabel

@export var death_timer: Timer
@export var idle_sound_timer: Timer

var character_set: CharacterSet = null

var moving = false

signal figure_died(figure: Figure)
signal figure_state_changed(figure: Figure, new_state: FigureState)

enum FigureState {
	HAPPY,
	SAD,
	DIED
}

var current_state: FigureState = FigureState.HAPPY

func _ready():
	debug_name_label.text = get_figure_name()
	debug_happy_label.text = "Happiness: " + str(happiness)
	debug_community_label.text = "Community: " + str(community)

	var rand_pitch = randf_range(0.8, 1.2)
	var rand_volume = randf_range(-6, 0)

	walking_sound_player.pitch_scale = rand_pitch
	walking_sound_player.volume_db = rand_volume

	state_sound_player.pitch_scale = rand_pitch
	state_sound_player.volume_db = rand_volume

	idle_sound_timer.connect("timeout", Callable(self, "on_idle_sound_timer_timeout"))

	set_random_idle_sound_timer()

func set_character_set(new_character_set: CharacterSet) -> void:
	character_set = new_character_set
	$AnimatedSprite2D.frames = character_set.sprite_frames

func _process(_delta) -> void:
	if happiness > 50:
		change_animation_state("smile")
		set_state(FigureState.HAPPY)
	elif happiness > 0:
		change_animation_state("sad")
		set_state(FigureState.SAD)
	else:
		change_animation_state("died")
		set_state(FigureState.DIED)
		alive = false
		if death_timer.is_stopped():
			death_timer.start()
	
	if artificial_scarcity_pattern != null:
		if (artificial_scarcity_pattern.position - position).length() < 20:
			set_collision_mask_value(1, true)
			artificial_scarcity_pattern.queue_free()
			artificial_scarcity_pattern = null

func set_state(new_state: FigureState) -> void:
	if new_state != current_state:
		current_state = new_state
		emit_signal("figure_state_changed", self, new_state)

		if character_set != null:
			match current_state:
				FigureState.HAPPY: state_sound_player.stream = character_set.sound_happy
				FigureState.SAD: state_sound_player.stream = character_set.sound_sad
				FigureState.DIED: state_sound_player.stream = character_set.sound_dying
			state_sound_player.play()

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
		set_moving_state(true)
		
	if move_target != Vector2.ZERO:
		var move_vector: Vector2 = move_target - position
		velocity = move_vector.normalized() * 100
		move_and_slide()
		set_moving_state(true)
	else:
		velocity = Vector2.ZERO
		set_moving_state(false)
		
	if abs(velocity.x) > 50:
		if velocity.x > 0:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false

func set_moving_state(new_state: bool) -> void:
	if moving != new_state:
		if new_state:
			walking_sound_player.play()
		else:
			walking_sound_player.stop()

	moving = new_state

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
	print("helooooooo")
	set_collision_mask_value(1, false)
	artificial_scarcity_pattern = pattern

func apply_happiness_effect(amount: int):
	print(first_name + " " + last_name + " applying happiness effect: ", amount)
	happiness += amount
	print(first_name + " " + last_name + " happiness: ", happiness)
	if happiness > 100:
		happiness = 100
	if happiness < 0:
		happiness = 0

func apply_community_effect(amount: int):
	community += amount
	# print("community: ", community)
	if community > 100:
		community = 100
	if community < 0:
		community = 0

func _on_tick_timeout() -> void:
	# apply_happiness_effect(len(area_2d.get_overlapping_bodies()) / 10)
	# apply_community_effect(5)
	move_target = get_random_move_location()
	debug_happy_label.text = "Happiness: " + str(happiness)
	debug_community_label.text = "Community: " + str(community)

func _on_death_timer_timeout() -> void:
	print("ded")
	emit_signal("figure_died", self)
	queue_free()

func get_figure_name() -> String:
	return first_name + " " + last_name

func on_idle_sound_timer_timeout() -> void:
	print("idle sound timer timeout")
	if character_set != null and alive:
		state_sound_player.stream = character_set.sound_idle
		state_sound_player.play()

	set_random_idle_sound_timer()

func set_random_idle_sound_timer() -> void:
	var random_timeout = randf_range(5.0, 20.0)
	idle_sound_timer.start(random_timeout)
