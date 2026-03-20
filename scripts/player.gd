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

# Dash mechanics
@export var dash_speed_multiplier: float = 3.0
@export var dash_duration: float = 0.15
@export var dash_cooldown: float = 1.0
@export var double_tap_window: float = 0.25

var is_dashing: bool = false
var dash_time_left: float = 0.0
var dash_cooldown_left: float = 0.0
var dash_direction: float = 0.0

var is_dragging: bool = false
var drag_touch_index: int = -1

var last_left_press_time: float = 0.0
var last_right_press_time: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var muzzle: Marker2D = $Muzzle

var Laser = preload("res://scenes/laser.tscn")

var tex_base = preload("res://assets/player_base.png")
var tex_spread = preload("res://assets/player_spread.png")
var tex_pierce = preload("res://assets/player_pierce.png")
var tex_full = preload("res://assets/player_full.png")

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
    update_ship_visuals()

func update_ship_visuals() -> void:
    if has_spread and has_pierce:
        sprite.texture = tex_full
    elif has_spread:
        sprite.texture = tex_spread
    elif has_pierce:
        sprite.texture = tex_pierce
    else:
        sprite.texture = tex_base

func emit_stats_changed() -> void:
    stats_changed.emit(current_health, base_damage + perm_damage_bonus, speed, default_fire_rate)

func _physics_process(delta: float) -> void:
    if is_dead:
        return
        
    # Update cooldowns
    if dash_cooldown_left > 0:
        dash_cooldown_left -= delta
        
    if is_dashing:
        dash_time_left -= delta
        if dash_time_left <= 0:
            is_dashing = false
            sprite.modulate.a = 1.0 # Restore visibility
        else:
            # Create a simple ghosting blink effect
            sprite.modulate.a = 0.5 if Engine.get_frames_drawn() % 4 < 2 else 0.8
            velocity = Vector2(dash_direction, 0) * (speed * dash_speed_multiplier)
            move_and_slide()
            # Clamp to screen
            position.x = clamp(position.x, 0, screen_size.x)
            position.y = clamp(position.y, 0, screen_size.y)
            return # Skip normal movement and shooting while dashing

    # Detect Double Taps for Dash
    if Input.is_action_just_pressed("ui_left"):
        var current_time = Time.get_ticks_msec() / 1000.0
        if current_time - last_left_press_time <= double_tap_window and dash_cooldown_left <= 0:
            start_dash(-1.0)
        last_left_press_time = current_time
        
    if Input.is_action_just_pressed("ui_right"):
        var current_time = Time.get_ticks_msec() / 1000.0
        if current_time - last_right_press_time <= double_tap_window and dash_cooldown_left <= 0:
            start_dash(1.0)
        last_right_press_time = current_time
        
    var input_vector := Vector2.ZERO
    if not is_dragging:
        input_vector.x = Input.get_axis("ui_left", "ui_right")
        input_vector.y = Input.get_axis("ui_up", "ui_down")
        velocity = input_vector.normalized() * speed
    else:
        velocity = Vector2.ZERO
        
    move_and_slide()
    
    # Clamp to screen
    position.x = clamp(position.x, 0, screen_size.x)
    position.y = clamp(position.y, 0, screen_size.y)
    
    if (Input.is_action_pressed("ui_accept") or is_dragging) and can_fire:
        fire_weapon()
func _input(event: InputEvent) -> void:
    if is_dead or is_dashing:
        return
        
    if event is InputEventScreenTouch:
        if event.pressed and not is_dragging:
            is_dragging = true
            drag_touch_index = event.index
            
            var current_time = Time.get_ticks_msec() / 1000.0
            if event.position.x < screen_size.x / 2.0:
                if current_time - last_left_press_time <= double_tap_window and dash_cooldown_left <= 0:
                    start_dash(-1.0)
                last_left_press_time = current_time
            else:
                if current_time - last_right_press_time <= double_tap_window and dash_cooldown_left <= 0:
                    start_dash(1.0)
                last_right_press_time = current_time
        elif not event.pressed and event.index == drag_touch_index:
            is_dragging = false
            drag_touch_index = -1
            
    elif event is InputEventScreenDrag and is_dragging and event.index == drag_touch_index:
        position += event.relative

func start_dash(direction: float) -> void:
    is_dashing = true
    dash_direction = direction
    dash_time_left = dash_duration
    dash_cooldown_left = dash_cooldown

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
            update_ship_visuals()
            sprite.modulate = Color.GREEN
            await get_tree().create_timer(0.2).timeout
        Powerup.PowerupType.PIERCE:
            has_pierce = true
            update_ship_visuals()
            sprite.modulate = Color.MAGENTA
            await get_tree().create_timer(0.2).timeout
            
    emit_stats_changed()
    
    if is_instance_valid(sprite):
        if is_shielded:
            sprite.modulate = Color.AQUA
        else:
            sprite.modulate = Color.WHITE
