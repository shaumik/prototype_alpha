extends "res://scripts/boss.gd"

func _ready() -> void:
    super._ready()
    sprite.modulate = Color(0.8, 0.3, 1.0) # Purple

func _setup_attack_patterns() -> void:
    fire_timer.wait_time = max(0.5, 1.5 * pow(0.8, current_loop - 1))
    fire_timer.timeout.connect(_on_fire_timer_timeout)

func _on_fire_timer_timeout() -> void:
    for x_offset in [-80, 80]:
        var laser = Laser.instantiate()
        laser.position = global_position
        laser.position.x += x_offset
        laser.position.y += 32 
        laser.speed = 500.0 
        laser.rotation = PI
        laser.scale = Vector2(2.5, 2.5) # Massive laser
        laser.collision_layer = 8
        laser.collision_mask = 1 
        get_tree().current_scene.add_child(laser)
