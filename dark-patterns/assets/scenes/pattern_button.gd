extends TextureButton
class_name PatternButton

signal pattern_selected(pattern: DarkPattern)

@export var pattern_icon: TextureRect

var pattern: DarkPattern

func _ready() -> void:
    connect("pressed", Callable(self, "_on_pressed"))

func set_pattern(p: DarkPattern) -> void:
    pattern = p
    # self.texture_normal = pattern.icon
    self.modulate = pattern.color
    self.pattern_icon.texture = pattern.icon

func _on_pressed() -> void:
    emit_signal("pattern_selected", pattern)