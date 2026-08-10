extends Control
@export var fullscreen_btn: BaseButton
@export var volume: Slider
@export var fullscreen_light_on: TextureRect

func _ready():
	fullscreen_btn.pressed.connect(toggle_fullscreen)
	volume.value_changed.connect(volume_changed)
	volume.value = AudioServer.get_bus_volume_linear(0)
	fullscreen_btn.button_pressed = true if DisplayServer.window_get_mode(0) == DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN else false
	
func toggle_fullscreen() -> void:
	var mode := DisplayServer.WindowMode.WINDOW_MODE_WINDOWED if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN else DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN
	DisplayServer.window_set_mode(mode)
	change_light()
	
func change_light():
	fullscreen_light_on.visible = true if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN else false
	

func volume_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(0,value)
