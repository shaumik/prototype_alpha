extends Area2D
class_name Laser

@export var speed: float = 600.0
@export var damage: int = 1

var is_piercing: bool = false
var custom_color: Color = Color.WHITE
var lifespan: float = -1.0
var bounces_left: int = 0

@onready var sprite: Sprite2D = $Sprite2D

func set_color(color: Color) -> void:
    if collision_layer == 8:
        custom_color = Color(1.0, 0.2, 0.2) # Very bright red for enemy projectiles
        if sprite:
            sprite.hide()
        queue_redraw()
    else:
        custom_color = color
        if sprite:
            sprite.modulate = custom_color

func _ready() -> void:
    if sprite:
        sprite.modulate = custom_color
        
    if collision_layer == 8:
        # Hide the default sprite and use _draw instead
        if sprite:
            sprite.hide()
        scale = Vector2(1, 1) # Reset scale completely
        queue_redraw()

    # Destroy laser when it exits the screen
    var notifier = VisibleOnScreenNotifier2D.new()
    notifier.screen_exited.connect(_on_screen_exited)
    add_child(notifier)
    
    # Connect signals for handling damage
    body_entered.connect(_on_body_entered)
    area_entered.connect(_on_area_entered)

func _draw() -> void:
    if collision_layer == 8:
        # Draw a perfect bright red circle with radius 12
        draw_circle(Vector2.ZERO, 12.0, Color(1.0, 0.2, 0.2))
        # Draw a smaller white core to make it look bright/glowing
        draw_circle(Vector2.ZERO, 6.0, Color.WHITE)

func _process(delta: float) -> void:
    if lifespan > 0.0:
        lifespan -= delta
        if lifespan <= 0.0:
            queue_free()
            
    var direction = Vector2.UP.rotated(rotation)
    
    if bounces_left > 0:
        var screen_rect = get_viewport_rect()
        var next_pos = global_position + direction * speed * delta
        var bounced = false
        
        if next_pos.x < 0 or next_pos.x > screen_rect.size.x:
            direction.x *= -1
            bounced = true
        elif next_pos.y < 0 or next_pos.y > screen_rect.size.y:
            direction.y *= -1
            bounced = true
            
        if bounced:
            rotation = direction.angle() - PI/2
            bounces_left -= 1
            
    position += Vector2.UP.rotated(rotation) * speed * delta

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
