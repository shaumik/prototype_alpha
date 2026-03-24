extends Area2D
class_name Powerup

enum PowerupType { SPREAD, RAPID, SHIELD, SPEED, PIERCE, HEAL, PERM_DMG, PERM_SPEED, PERM_HP, NOVA, HOMING, BEAM, SHOTGUN, RICOCHET, DRONE }

@export var speed: float = 100.0
@export var type: PowerupType = PowerupType.SPREAD
@export var randomize_type: bool = true

@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label

func _ready() -> void:
    # Randomize powerup type if not specifically set
        # Let all weapons drop too (0 to 14)
        type = randi() % 15
    
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
        PowerupType.NOVA:
            sprite.self_modulate = Color.ORANGE_RED
            label.text = "O"
        PowerupType.HOMING:
            sprite.self_modulate = Color.GHOST_WHITE
            label.text = "M"
        PowerupType.BEAM:
            sprite.self_modulate = Color.CORNFLOWER_BLUE
            label.text = "I"
        PowerupType.SHOTGUN:
            sprite.self_modulate = Color.DARK_RED
            label.text = "W"
        PowerupType.RICOCHET:
            sprite.self_modulate = Color.PLUM
            label.text = "X"
        PowerupType.DRONE:
            sprite.self_modulate = Color.SLATE_BLUE
            label.text = "D"
            
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
