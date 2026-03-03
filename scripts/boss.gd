extends Area2D
class_name Boss

@export var max_health: int = 50
@export var speed: float = 100.0
@export var score_value: int = 1000

var current_health: int
var current_loop: int = 1

var is_in_position: bool = false
var move_direction: int = 1

@onready var sprite: Sprite2D = $Sprite2D
@onready var fire_timer: Timer = $FireTimer

var Laser = preload("res://scenes/laser.tscn")
signal died(score)
signal health_changed(current, maximum)

func setup_difficulty(loop: int) -> void:
    current_loop = loop

func _ready() -> void:
    max_health += (current_loop - 1) * 20
    speed *= (1.0 + (current_loop - 1) * 0.1)
    score_value *= current_loop
    
    current_health = max_health
    
    body_entered.connect(_on_body_entered)
    area_entered.connect(_on_area_entered)
    
    _setup_attack_patterns()

func _setup_attack_patterns() -> void:
    pass

func _process(delta: float) -> void:
    if not is_in_position:
        position.y += speed * delta
        if position.y > 150:
            is_in_position = true
            _start_attacks()
    else:
        _process_movement(delta)

func _start_attacks() -> void:
    if fire_timer:
        fire_timer.start()

func _process_movement(delta: float) -> void:
    position.x += speed * move_direction * delta
    var screen_w = get_viewport_rect().size.x
    if position.x < 64:
        position.x = 64
        move_direction = 1
    elif position.x > screen_w - 64:
        position.x = screen_w - 64
        move_direction = -1

func _on_body_entered(body: Node2D) -> void:
    if body.has_method("take_damage") and "Player" in body.name:
        body.take_damage(2)

func _on_area_entered(_area: Area2D) -> void:
    pass

func take_damage(amount: int) -> void:
    current_health -= amount
    health_changed.emit(current_health, max_health)
    
    sprite.modulate = Color.RED
    await get_tree().create_timer(0.05).timeout
    if is_instance_valid(sprite):
        sprite.modulate = Color.WHITE
        
    if current_health <= 0:
        die()

func die() -> void:
    died.emit(score_value)
    var powerup = preload("res://scenes/powerup.tscn").instantiate()
    powerup.global_position = global_position
    powerup.randomize_type = true
    get_tree().current_scene.call_deferred("add_child", powerup)
    queue_free()
