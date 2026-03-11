extends "res://scripts/elite_enemy.gd"

var Laser = preload("res://scenes/laser.tscn")

func _on_fire_timer_timeout() -> void:
    var player = get_tree().current_scene.get_node_or_null("Player")
    if player and not player.is_dead:
        var laser = Laser.instantiate()
        laser.global_position = global_position
        laser.speed = 400.0 # Fast shot
        
        # Calculate angle to player
        var dir = global_position.direction_to(player.global_position)
        # Vector2.UP rotated by angle
        laser.rotation = dir.angle() + PI/2
        
        laser.collision_layer = 8 # EnemyProjectile
        laser.collision_mask = 1 # Player
        laser.set_color(Color.RED)
        get_tree().current_scene.add_child(laser)
