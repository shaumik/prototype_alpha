extends Enemy

@export var chase_speed: float = 80.0

func _ready() -> void:
    super._ready()
    sprite.modulate = Color(0.7, 0.7, 1.0) # Slightly blue

func _process(delta: float) -> void:
    position.y += speed * delta
    
    var player = null
    var main = get_tree().current_scene
    if main and main.has_node("Player"):
        player = main.get_node("Player")
        
    if player and not player.is_dead:
        if player.position.x > position.x:
            position.x += chase_speed * delta
        elif player.position.x < position.x:
            position.x -= chase_speed * delta
