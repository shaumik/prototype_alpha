extends CharacterBody2D
class_name Player

@export var speed: float = 300.0
@export var max_health: int = 3
@export var fire_rate: float = 0.2

var current_health: int
var can_fire: bool = true
var is_dead: bool = false
var screen_size: Vector2
var fire_timer: Timer

var has_spread: bool = false
var has_pierce: bool = false
var is_shielded: bool = false
var default_fire_rate: float
var base_speed: float
var base_damage: int = 1
var perm_damage_bonus: int = 0
var perm_speed_bonus: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var muzzle: Marker2D = $Muzzle

var Laser = preload("res://scenes/laser.tscn")

signal health_changed(new_health)
signal stats_changed(hp, pwr, spd, fir)
signal died

func _ready() -> void:
    screen_size = get_viewport_rect().size
    current_health = max_health
    default_fire_rate = fire_rate
    base_speed = speed
    
    fire_timer = Timer.new()
    fire_timer.wait_time = fire_rate
    fire_timer.one_shot = true
    fire_timer.timeout.connect(_on_fire_timer_timeout)
    add_child(fire_timer)

    
    call_deferred("emit_stats_changed")

func emit_stats_changed() -> void:
    stats_changed.emit(current_health, base_damage + perm_damage_bonus, speed, default_fire_rate)

func _physics_process(_delta: float) -> void:
    if is_dead:
        return
        
    var input_vector := Vector2.ZERO
    input_vector.x = Input.get_axis("ui_left", "ui_right")
    input_vector.y = Input.get_axis("ui_up", "ui_down")
    
    velocity = input_vector.normalized() * speed
    move_and_slide()
    
    # Clamp to screen
    position.x = clamp(position.x, 0, screen_size.x)
    position.y = clamp(position.y, 0, screen_size.y)
    
    if Input.is_action_pressed("ui_accept") and can_fire:
        fire_weapon()

func fire_weapon() -> void:
    can_fire = false
    fire_timer.start()
    
    if has_spread:
        for i in range(-1, 2):
            var laser = Laser.instantiate()
            laser.position = muzzle.global_position
            # Angle offset is enough now that laser respects rotation
            laser.rotation = i * 0.2
            laser.damage = base_damage + perm_damage_bonus
            if has_pierce:
                laser.is_piercing = true
            get_tree().current_scene.add_child(laser)
    else:
        var laser = Laser.instantiate()
        laser.position = muzzle.global_position
        if has_pierce:
            laser.is_piercing = true
        laser.damage = base_damage + perm_damage_bonus
        get_tree().current_scene.add_child(laser)

func _on_fire_timer_timeout() -> void:
    can_fire = true

func take_damage(amount: int) -> void:
    if is_dead: return
    
    if is_shielded:
        is_shielded = false
        sprite.modulate = Color.WHITE
        return
        
    current_health -= amount
    health_changed.emit(current_health)
    emit_stats_changed()
    
    # Simple flash effect
    sprite.modulate = Color.RED
    await get_tree().create_timer(0.1).timeout
    sprite.modulate = Color.WHITE
    
    if current_health <= 0:
        die()

func die() -> void:
    is_dead = true
    died.emit()
    queue_free()

func apply_powerup(type: int) -> void:
    match type:
        Powerup.PowerupType.PERM_DMG:
            perm_damage_bonus += 1
            sprite.modulate = Color.RED
            await get_tree().create_timer(0.2).timeout
        Powerup.PowerupType.PERM_SPEED:
            perm_speed_bonus += 20.0
            base_speed += 20.0
            speed += 20.0
            sprite.modulate = Color.DEEP_SKY_BLUE
            await get_tree().create_timer(0.2).timeout
        Powerup.PowerupType.SPEED:
            perm_speed_bonus += 10.0
            base_speed += 10.0
            speed += 10.0
            sprite.modulate = Color.ORANGE
            await get_tree().create_timer(0.2).timeout
        Powerup.PowerupType.PERM_HP:
            max_health += 1
            current_health += 1
            health_changed.emit(current_health)
            sprite.modulate = Color.CRIMSON
            await get_tree().create_timer(0.2).timeout
        Powerup.PowerupType.HEAL:
            current_health = min(max_health, current_health + 1)
            health_changed.emit(current_health)
            sprite.modulate = Color.GREEN
            await get_tree().create_timer(0.2).timeout
        Powerup.PowerupType.RAPID:
            default_fire_rate = max(0.05, default_fire_rate * 0.8)
            fire_timer.wait_time = default_fire_rate
            sprite.modulate = Color.YELLOW
            await get_tree().create_timer(0.2).timeout
        Powerup.PowerupType.SHIELD:
            if not is_shielded:
                is_shielded = true
            sprite.modulate = Color.AQUA
            await get_tree().create_timer(0.2).timeout
        Powerup.PowerupType.SPREAD:
            has_spread = true
            sprite.modulate = Color.GREEN
            await get_tree().create_timer(0.2).timeout
        Powerup.PowerupType.PIERCE:
            has_pierce = true
            sprite.modulate = Color.MAGENTA
            await get_tree().create_timer(0.2).timeout
            
    emit_stats_changed()
    
    if is_instance_valid(sprite):
        if is_shielded:
            sprite.modulate = Color.AQUA
        else:
            sprite.modulate = Color.WHITE
