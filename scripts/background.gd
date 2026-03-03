extends ParallaxBackground
class_name ScrollingBackground

@export var scroll_speed: float = 100.0

func _process(delta: float) -> void:
    scroll_offset.y += scroll_speed * delta
