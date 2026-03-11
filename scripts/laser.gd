extends Area2D
class_name Laser

@export var speed: float = 600.0
@export var damage: int = 1

var is_piercing: bool = false
var custom_color: Color = Color.WHITE

@onready var sprite: Sprite2D = $Sprite2D

func set_color(color: Color) -> void:
    custom_color = color
    if sprite:
        sprite.modulate = custom_color

func _ready() -> void:
    if sprite and custom_color != Color.WHITE:
        sprite.modulate = custom_color
        
    # Destroy laser when it exits the screen
    var notifier = VisibleOnScreenNotifier2D.new()
    notifier.screen_exited.connect(_on_screen_exited)
    add_child(notifier)
    
    # Connect signals for handling damage
    body_entered.connect(_on_body_entered)
    area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
    var direction = Vector2.UP.rotated(rotation)
    position += direction * speed * delta

func _on_screen_exited() -> void:
    queue_free()

func _on_body_entered(body: Node2D) -> void:
    if body.has_method("take_damage"):
        body.take_damage(damage)
        if not is_piercing:
            queue_free()

func _on_area_entered(area: Area2D) -> void:
    if area.has_method("take_damage"):
        area.take_damage(damage)
        if not is_piercing:
            queue_free()
