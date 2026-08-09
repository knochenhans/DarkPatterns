extends Control
class_name StartScreen

@export var start_button: TextureButton
@export var audio_stream_player: AudioStreamPlayer

signal start_game_requested()

func _ready() -> void:
	start_button.connect("pressed", Callable(self, "_on_start_button_pressed"))

func _on_start_button_pressed() -> void:
	audio_stream_player.play()
	emit_signal("start_game_requested")
