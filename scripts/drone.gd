extends Area2D
class_name Drone

var orbit_radius: float = 60.0
var orbit_speed: float = 2.0
var orbit_angle: float = 0.0
var player: Node2D = null

var Laser = preload("res://scenes/laser.tscn")
var fire_color: Color = Color.WHITE
var has_pierce: bool = false
var base_damage: int = 1

func _ready() -> void:
    # 1 for player layer, 8 for enemy projectiles
    collision_layer = 1 
    collision_mask = 8  
    area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
    if player and is_instance_valid(player):
        orbit_angle += orbit_speed * delta
        position = player.position + Vector2(cos(orbit_angle), sin(orbit_angle)) * orbit_radius
        
        # Inherit player powers
        if "fire_color" in player:
            fire_color = player.fire_color
            if has_node("Sprite2D"):
                $Sprite2D.modulate = fire_color
        if "has_pierce" in player:
            has_pierce = player.has_pierce
        if "base_damage" in player:
            base_damage = player.base_damage
    else:
        # Player is dead or gone
        queue_free()

func fire() -> void:
    var laser = Laser.instantiate()
    laser.position = global_position
    laser.custom_color = fire_color
    if has_pierce:
        laser.is_piercing = true
    laser.damage = base_damage
    get_tree().current_scene.add_child(laser)

func _on_area_entered(area: Area2D) -> void:
    # Check if hit by enemy projectile (layer 8, typically area)
    if area.collision_layer == 8:
        area.queue_free() # Destroy enemy bullet
        queue_free() # Destroy drone
