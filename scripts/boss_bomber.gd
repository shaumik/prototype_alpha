extends "res://scripts/boss.gd"

func _ready() -> void:
    super._ready()
    sprite.modulate = Color(1.0, 0.4, 0.4) # Light Red

func _setup_attack_patterns() -> void:
    fire_timer.wait_time = max(0.2, 1.0 * pow(0.8, current_loop - 1))
    fire_timer.timeout.connect(_on_fire_timer_timeout)

func _on_fire_timer_timeout() -> void:
    var num_shots = min(7, 3 + current_loop / 2)
    var spread_arc = 1.0 # radians
    var start_angle = -spread_arc / 2.0
    var angle_step = spread_arc / max(1, num_shots - 1)
    
    for i in range(num_shots):
        var laser = Laser.instantiate()
        laser.position = global_position
        laser.position.y += 32 
        laser.speed = 300.0 
        laser.rotation = start_angle + (i * angle_step) + PI
        laser.collision_layer = 8
        laser.collision_mask = 1 
        get_tree().current_scene.add_child(laser)
