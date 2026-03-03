extends Area2D
class_name Enemy

@export var speed: float = 150.0
@export var max_health: int = 2
@export var score_value: int = 100

var current_health: int
var current_loop: int = 1

signal died(score)

@onready var sprite: Sprite2D = $Sprite2D

var PowerupScene = preload("res://scenes/powerup.tscn")

func setup_difficulty(loop: int) -> void:
    current_loop = loop

func _ready() -> void:
    max_health += (current_loop - 1)
    speed *= (1.0 + (current_loop - 1) * 0.2)
    score_value *= current_loop
    
    current_health = max_health
    
    var notifier = VisibleOnScreenNotifier2D.new()
    notifier.screen_exited.connect(_on_screen_exited)
    add_child(notifier)
    
    body_entered.connect(_on_body_entered)
    area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
    position.y += speed * delta

func _on_screen_exited() -> void:
    # Despawn if leaving the bottom of the screen
    if position.y > 0:
        queue_free()

func _on_body_entered(body: Node2D) -> void:
    if body is Player:
        body.take_damage(1)
        die() # Destroy self upon crashing into player

func _on_area_entered(area: Area2D) -> void:
    # Handle overlap with other Area2Ds if necessary, 
    # but laser handles its own damage output when entering an area.
    pass

func take_damage(amount: int) -> void:
    current_health -= amount
    
    sprite.modulate = Color.RED
    await get_tree().create_timer(0.1).timeout
    if is_instance_valid(sprite): # Might have died and freed within await
        sprite.modulate = Color.WHITE
    
    if current_health <= 0:
        die()

func die() -> void:
    died.emit(score_value)
    
    # 10% chance to drop powerup
    if randf() < 0.1:
        var powerup = PowerupScene.instantiate()
        powerup.global_position = global_position
        get_tree().current_scene.call_deferred("add_child", powerup)
        
    queue_free()
