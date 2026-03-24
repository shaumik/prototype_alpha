extends RayCast2D
class_name Beam

var is_firing: bool = false
var damage: int = 1
var tick_rate: float = 0.1
var tick_timer: float = 0.0

@onready var line: Line2D = $Line2D

func _ready() -> void:
    enabled = false
    set_physics_process(true)

func _physics_process(delta: float) -> void:
    enabled = is_firing
    line.visible = is_firing
    
    if not is_firing:
        return
        
    tick_timer -= delta
    
    var cast_point = target_position
    force_raycast_update()
    
    if is_colliding():
        cast_point = to_local(get_collision_point())
        if tick_timer <= 0:
            var collider = get_collider()
            if collider and collider.has_method("take_damage"):
                var total_damage = damage
                var player = get_parent().get_parent() # Muzzle -> Player
                if player and "base_damage" in player:
                    total_damage = player.base_damage + player.perm_damage_bonus
                collider.take_damage(total_damage)
            tick_timer = tick_rate
            
    line.set_point_position(1, cast_point)
