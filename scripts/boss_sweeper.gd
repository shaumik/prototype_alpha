extends "res://scripts/boss.gd"

var sweep_angle: float = -0.6
var sweeping_right: bool = true

func _ready() -> void:
    super._ready()
    sprite.modulate = Color(0.4, 1.0, 1.0) # Cyan

func _setup_attack_patterns() -> void:
    fire_timer.wait_time = max(0.05, 0.1 * pow(0.9, current_loop - 1)) # Very fast
    fire_timer.timeout.connect(_on_fire_timer_timeout)

func _on_fire_timer_timeout() -> void:
    var laser = Laser.instantiate()
    laser.position = global_position
    laser.position.y += 32 
    laser.speed = 400.0 
    laser.rotation = sweep_angle + PI
    laser.collision_layer = 8
    laser.collision_mask = 1 
    laser.set_color(Color.RED)
    get_tree().current_scene.add_child(laser)
    
    if sweeping_right:
        sweep_angle += 0.08
        if sweep_angle > 0.6:
            sweeping_right = false
    else:
        sweep_angle -= 0.08
        if sweep_angle < -0.6:
            sweeping_right = true
