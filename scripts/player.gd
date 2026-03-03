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
var powerup_timer: Timer

var current_powerup: int = -1
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
signal stats_changed(hp, pwr, spd)
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
    
    powerup_timer = Timer.new()
    powerup_timer.wait_time = 5.0
    powerup_timer.one_shot = true
    powerup_timer.timeout.connect(_on_powerup_timeout)
    add_child(powerup_timer)
    
    call_deferred("emit_stats_changed")

func emit_stats_changed() -> void:
    stats_changed.emit(current_health, base_damage + perm_damage_bonus, speed)

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
    
    if current_powerup == Powerup.PowerupType.SPREAD:
        for i in range(-1, 2):
            var laser = Laser.instantiate()
            laser.position = muzzle.global_position
            # Angle offset is enough now that laser respects rotation
            laser.rotation = i * 0.2
            laser.damage = base_damage + perm_damage_bonus
            get_tree().current_scene.add_child(laser)
    else:
        var laser = Laser.instantiate()
        laser.position = muzzle.global_position
        if current_powerup == Powerup.PowerupType.PIERCE:
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
    if type == Powerup.PowerupType.PERM_DMG:
        perm_damage_bonus += 1
        emit_stats_changed()
        
        sprite.modulate = Color.RED
        await get_tree().create_timer(0.2).timeout
        if not is_shielded:
            sprite.modulate = Color.WHITE
        else:
            sprite.modulate = Color.AQUA
        return
    elif type == Powerup.PowerupType.PERM_SPEED:
        perm_speed_bonus += 20.0
        base_speed += 20.0
        speed += 20.0
        emit_stats_changed()
        
        sprite.modulate = Color.DEEP_SKY_BLUE
        await get_tree().create_timer(0.2).timeout
        if not is_shielded:
            sprite.modulate = Color.WHITE
        else:
            sprite.modulate = Color.AQUA
        return
    elif type == Powerup.PowerupType.PERM_HP:
        max_health += 1
        current_health += 1
        health_changed.emit(current_health)
        emit_stats_changed()
        
        sprite.modulate = Color.CRIMSON
        await get_tree().create_timer(0.2).timeout
        if not is_shielded:
            sprite.modulate = Color.WHITE
        else:
            sprite.modulate = Color.AQUA
        return

    if type == Powerup.PowerupType.HEAL:
        current_health = min(max_health, current_health + 1)
        health_changed.emit(current_health)
        emit_stats_changed()
        
        # Flash green
        sprite.modulate = Color.GREEN
        await get_tree().create_timer(0.2).timeout
        if not is_shielded:
            sprite.modulate = Color.WHITE
        else:
            sprite.modulate = Color.AQUA
        return
        
    current_powerup = type
    
    # Reset modifications
    fire_timer.wait_time = default_fire_rate
    speed = base_speed
    is_shielded = false
    sprite.modulate = Color.WHITE
    
    match type:
        Powerup.PowerupType.RAPID:
            fire_timer.wait_time = default_fire_rate * 0.4
        Powerup.PowerupType.SHIELD:
            is_shielded = true
            sprite.modulate = Color.AQUA
        Powerup.PowerupType.SPEED:
            speed = base_speed * 1.5
            
    powerup_timer.start()

func _on_powerup_timeout() -> void:
    current_powerup = -1
    fire_timer.wait_time = default_fire_rate
    speed = base_speed
    if not is_shielded:
        sprite.modulate = Color.WHITE
