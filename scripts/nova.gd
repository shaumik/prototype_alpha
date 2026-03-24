extends Area2D
class_name Nova

var damage: int = 5
var max_radius: float = 300.0
var expansion_speed: float = 600.0
var current_radius: float = 10.0
var thickness: float = 20.0

func _ready() -> void:
    collision_layer = 4 # Player projectiles
    collision_mask = 2  # Enemies
    area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
    current_radius += expansion_speed * delta
    $CollisionShape2D.shape.radius = current_radius
    queue_redraw()
    
    if current_radius >= max_radius:
        queue_free()

func _draw() -> void:
    var alpha = 1.0 - (current_radius / max_radius)
    var color = Color(1.0, 0.4, 0.0, alpha) # Bright orange/red
    
    # Draw a bold growing ring
    draw_arc(Vector2.ZERO, current_radius, 0, TAU, 64, color, thickness)
    # Draw a faint inner fill
    draw_circle(Vector2.ZERO, current_radius, Color(1.0, 0.4, 0.0, alpha * 0.2))

func _on_area_entered(area: Area2D) -> void:
    if area.has_method("take_damage"):
        area.take_damage(damage)
