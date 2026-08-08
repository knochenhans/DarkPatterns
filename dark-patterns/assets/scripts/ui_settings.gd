extends Control
@export var fullscreen_btn: Button
@export var volume: VSlider

func _ready():
	fullscreen_btn.toggled.connect(fullscreen_toggled)
	volume.value_changed.connect(volume_changed)
	volume.value = AudioServer.get_bus_volume_linear(0)
	fullscreen_btn.button_pressed = true if DisplayServer.window_get_mode(0) == DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN else false

func fullscreen_toggled(toggled_on: bool) -> void:
	var mode := DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN if toggled_on else DisplayServer.WindowMode.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(mode)


func volume_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(0,value)
