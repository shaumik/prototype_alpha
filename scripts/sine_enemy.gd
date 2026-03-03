extends Enemy

@export var amplitude: float = 120.0
@export var frequency: float = 3.0

var time_passed: float = 0.0
var start_x: float

func _ready() -> void:
    super._ready()
    start_x = position.x
    sprite.modulate = Color(1.0, 0.7, 0.7) # Slightly pink

func _process(delta: float) -> void:
    time_passed += delta
    position.y += speed * delta
    position.x = start_x + sin(time_passed * frequency) * amplitude
