extends Enemy

func _ready() -> void:
    max_health += 8 # Bonus base health
    speed *= 0.4 # Slower
    super._ready()
    
    # Dark gray and bigger
    sprite.modulate = Color(0.4, 0.4, 0.4)
    scale = Vector2(1.5, 1.5)
