extends "res://scripts/elite_enemy.gd"

var BasicEnemy = preload("res://scenes/enemy.tscn")

func _ready() -> void:
    super._ready()
    sprite.modulate = Color(0.5, 0.0, 1.0) # PURPLE
    max_health += 20 # Extra tanky since it only summons

func _on_fire_timer_timeout() -> void:
    var enemy = BasicEnemy.instantiate()
    enemy.global_position = global_position
    enemy.global_position.y += 40
    
    if enemy.has_method("setup_difficulty"):
        enemy.setup_difficulty(current_loop)
        
    get_tree().current_scene.add_child(enemy)
