extends Enemy
class_name EliteEnemy

var is_in_position: bool = false
@export var stop_y: float = 150.0
var fire_timer: Timer

func _ready() -> void:
    max_health += 15 # Base elite bonus
    score_value *= 5
    super._ready()
    
    fire_timer = Timer.new()
    fire_timer.wait_time = max(0.5, 2.0 * pow(0.8, current_loop - 1))
    fire_timer.timeout.connect(_on_fire_timer_timeout)
    add_child(fire_timer)
    
    sprite.modulate = Color(1.0, 0.5, 0.0) # ORANGE
    scale = Vector2(1.2, 1.2)

func _process(delta: float) -> void:
    if not is_in_position:
        position.y += speed * delta
        if position.y >= stop_y:
            is_in_position = true
            fire_timer.start()

func _on_fire_timer_timeout() -> void:
    pass # Override this in derived classes

func _on_screen_exited() -> void:
    # Elites stop at top, so don't despawn when they first appear
    if is_in_position and position.y > stop_y + 100:
        queue_free()

func die() -> void:
    died.emit(score_value)
    
    # 50% chance to drop powerup for Elites
    if randf() < 0.5:
        var powerup = PowerupScene.instantiate()
        powerup.global_position = global_position
        get_tree().current_scene.call_deferred("add_child", powerup)
        
    queue_free()
