extends Control
class_name GameOverScreen

@export var game_over_sound: AudioStream
@export var game_over_sound_player: AudioStreamPlayer

func run_game_over() -> void:
	game_over_sound_player.stream = game_over_sound
	game_over_sound_player.play()
