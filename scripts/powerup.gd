extends Area2D
class_name Powerup

enum PowerupType { SPREAD, RAPID, SHIELD, SPEED, PIERCE, HEAL, PERM_DMG, PERM_SPEED, PERM_HP }

@export var speed: float = 100.0
@export var type: PowerupType = PowerupType.SPREAD
@export var randomize_type: bool = true

@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label

func _ready() -> void:
    # Randomize powerup type if not specifically set
    if randomize_type:
        type = randi() % 6 # Only 0 to 5 are standard temporary powerups/heals
    
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
        PowerupType.PERM_DMG:
            sprite.self_modulate = Color.RED
            label.text = "PWR"
        PowerupType.PERM_SPEED:
            sprite.self_modulate = Color.DEEP_SKY_BLUE
            label.text = "SPD"
        PowerupType.PERM_HP:
            sprite.self_modulate = Color.CRIMSON
            label.text = "+HP"
            
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
