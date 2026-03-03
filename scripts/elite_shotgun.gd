extends "res://scripts/elite_enemy.gd"

var Laser = preload("res://scenes/laser.tscn")

func _ready() -> void:
    super._ready()
    sprite.modulate = Color(1.0, 0.0, 0.5) # PINK-RED

func _on_fire_timer_timeout() -> void:
    var player = get_tree().current_scene.get_node_or_null("Player")
    if player and not player.is_dead:
        for i in range(-2, 3):
            var laser = Laser.instantiate()
            laser.global_position = global_position
            laser.speed = 250.0 
            
            var base_dir = global_position.direction_to(player.global_position)
            laser.rotation = base_dir.angle() + (i * 0.2) + PI/2
            
            laser.collision_layer = 8 
            laser.collision_mask = 1 
            get_tree().current_scene.add_child(laser)
