extends Area2D
class_name Powerup

enum PowerupType { SPREAD, RAPID, SHIELD, SPEED, PIERCE, HEAL }

@export var speed: float = 100.0
@export var type: PowerupType = PowerupType.SPREAD

@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label

func _ready() -> void:
    # Randomize powerup type if not specifically set
    type = randi() % PowerupType.size()
    
    match type:
        PowerupType.SPREAD:
            sprite.self_modulate = Color.GREEN
            label.text = "S"
        PowerupType.RAPID:
            sprite.self_modulate = Color.YELLOW
            label.text = "R"
        PowerupType.SHIELD:
            sprite.self_modulate = Color.CYAN
            label.text = "H"
        PowerupType.SPEED:
            sprite.self_modulate = Color.ORANGE
            label.text = "V"
        PowerupType.PIERCE:
            sprite.self_modulate = Color.MAGENTA
            label.text = "P"
        PowerupType.HEAL:
            sprite.self_modulate = Color.HOT_PINK
            label.text = "+"
            
    var notifier = VisibleOnScreenNotifier2D.new()
    notifier.screen_exited.connect(_on_screen_exited)
    add_child(notifier)
    
    body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
    position.y += speed * delta

func _on_screen_exited() -> void:
    queue_free()

func _on_body_entered(body: Node2D) -> void:
    if body is Player:
        body.apply_powerup(type)
        queue_free()
