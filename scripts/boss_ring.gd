extends "res://scripts/boss.gd"

func _ready() -> void:
    super._ready()
    sprite.modulate = Color(1.0, 1.0, 0.4) # Yellow

func _setup_attack_patterns() -> void:
    fire_timer.wait_time = max(0.5, 2.0 * pow(0.8, current_loop - 1))
    fire_timer.timeout.connect(_on_fire_timer_timeout)

func _on_fire_timer_timeout() -> void:
    var num_shots = min(36, 12 + current_loop * 4)
    var angle_step = (PI * 2.0) / num_shots
    
    for i in range(num_shots):
        var laser = Laser.instantiate()
        laser.position = global_position
        laser.speed = 200.0 
        laser.rotation = i * angle_step
        laser.collision_layer = 8
        laser.collision_mask = 1 
        get_tree().current_scene.add_child(laser)
