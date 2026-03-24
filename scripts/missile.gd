extends Area2D
class_name Missile

var speed: float = 400.0
var damage: int = 3
var turn_speed: float = 4.0
var target: Node2D = null

func _ready() -> void:
    collision_layer = 4 # Player projectiles
    collision_mask = 2  # Enemies
    area_entered.connect(_on_area_entered)
    body_entered.connect(_on_body_entered)
    
    # Destroys outside screen
    var notifier = VisibleOnScreenNotifier2D.new()
    notifier.screen_exited.connect(queue_free)
    add_child(notifier)

func _process(delta: float) -> void:
    # Find target if we don't have one or if it's dead
    if not is_instance_valid(target):
        target = _find_nearest_enemy()
        
    if is_instance_valid(target):
        var direction_to_target = global_position.direction_to(target.global_position)
        var desired_rotation = direction_to_target.angle() + PI/2 # Adjusting for UP being 0 rotation usually
        # Smoothly rotate towards target
        rotation = lerp_angle(rotation, desired_rotation, turn_speed * delta)
    
    # Always move forward in direction we are facing
    var direction = Vector2.UP.rotated(rotation)
    position += direction * speed * delta

func _draw() -> void:
    # A sleek white-orange missile
    draw_rect(Rect2(-4, -12, 8, 24), Color.GHOST_WHITE)
    draw_rect(Rect2(-2, 8, 4, 6), Color.ORANGE)

func _find_nearest_enemy() -> Node2D:
    var enemies = get_tree().get_nodes_in_group("enemies") # Assumes enemies are in "enemies" group
    var nearest = null
    var min_dist = INF
    
    for enemy in enemies:
        if is_instance_valid(enemy):
            var dist = global_position.distance_squared_to(enemy.global_position)
            if dist < min_dist:
                min_dist = dist
                nearest = enemy
                
    return nearest

func _on_area_entered(area: Area2D) -> void:
    if area.has_method("take_damage"):
        area.take_damage(damage)
        queue_free()

func _on_body_entered(body: Node2D) -> void:
    if body.has_method("take_damage"):
        body.take_damage(damage)
        queue_free()
