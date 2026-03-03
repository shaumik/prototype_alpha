extends Node
class_name GameManager

@export var initial_spawn_rate: float = 2.0
@export var minimum_spawn_rate: float = 0.5
@export var spawn_rate_decrease: float = 0.05

var score: int = 0
var current_spawn_rate: float
var current_loop: int = 1

var boss_spawned: bool = false
@export var base_score_for_boss: int = 1500
var score_to_next_boss: int

@onready var score_label: Label = $HUD/ScoreLabel
@onready var health_label: Label = $HUD/HealthLabel
@onready var powerup_label: Label = $HUD/PowerupLabel
@onready var boss_health_bar: ProgressBar = $HUD/BossHealthBar
@onready var spawn_timer: Timer = $SpawnTimer

var standard_enemies: Array = [
	preload("res://scenes/enemy.tscn"),
	preload("res://scenes/sine_enemy.tscn"),
	preload("res://scenes/chaser_enemy.tscn"),
	preload("res://scenes/tank_enemy.tscn")
]
var elite_enemies: Array = [
	preload("res://scenes/elite_sniper.tscn"),
	preload("res://scenes/elite_shotgun.tscn"),
	preload("res://scenes/elite_summoner.tscn")
]
var boss_variants: Array = [
	preload("res://scenes/boss_bomber.tscn"),
	preload("res://scenes/boss_sweeper.tscn"),
	preload("res://scenes/boss_ring.tscn"),
	preload("res://scenes/boss_twin.tscn")
]

func _ready() -> void:
	current_spawn_rate = initial_spawn_rate
	score_to_next_boss = base_score_for_boss
	
	spawn_timer.wait_time = current_spawn_rate
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()
	
	update_score(0)
	
	# Connect player signals
	var player = $Player
	if player:
		player.died.connect(_on_player_died)
		player.health_changed.connect(_on_player_health_changed)
		if player.has_signal("stats_changed"):
			player.stats_changed.connect(_on_player_stats_changed)
		health_label.text = "Health: " + str(player.current_health)

func _process(_delta: float) -> void:
	var player = get_node_or_null("Player")
	if player and player.powerup_timer and not player.powerup_timer.is_stopped():
		var powerup_name = ""
		match player.current_powerup:
			0: powerup_name = "Spread"
			1: powerup_name = "Rapid"
			2: powerup_name = "Shield"
			3: powerup_name = "Speed"
			4: powerup_name = "Pierce"
		powerup_label.text = powerup_name + " : " + str(int(player.powerup_timer.time_left))
	else:
		powerup_label.text = ""

func _on_spawn_timer_timeout() -> void:
	spawn_enemy()
	
	# Decrease spawn rate slightly (increase difficulty)
	current_spawn_rate = max(minimum_spawn_rate, current_spawn_rate - spawn_rate_decrease)
	spawn_timer.wait_time = current_spawn_rate

func spawn_enemy() -> void:
	var enemy: Node2D
	# Elite chance increases up to 40% (0.05 * loop)
	var elite_chance = min(0.4, 0.05 * current_loop)
	
	if randf() < elite_chance:
		var random_index = randi() % elite_enemies.size()
		enemy = elite_enemies[random_index].instantiate()
	else:
		var random_index = randi() % standard_enemies.size()
		enemy = standard_enemies[random_index].instantiate()
		
	var screen_size = get_viewport().get_visible_rect().size
	
	if enemy.has_method("setup_difficulty"):
		enemy.setup_difficulty(current_loop)
		
	# Random x position along the top
	var spawn_x = randf_range(32, screen_size.x - 32)
	enemy.position = Vector2(spawn_x, -50)
	
	enemy.died.connect(_on_enemy_died)
	add_child(enemy)

func _on_enemy_died(points: int) -> void:
	update_score(points)

func update_score(points: int) -> void:
	score += points
	update_hud()
	
	if score >= score_to_next_boss and not boss_spawned:
		spawn_boss()

func update_hud() -> void:
	score_label.text = "Loop: " + str(current_loop) + "\nScore: " + str(score)

func spawn_boss() -> void:
	boss_spawned = true
	spawn_timer.stop() # Stop normal spawns
	
	var random_index = randi() % boss_variants.size()
	var boss = boss_variants[random_index].instantiate()
	if boss.has_method("setup_difficulty"):
		boss.setup_difficulty(current_loop)
		
	boss.position = Vector2(get_viewport().get_visible_rect().size.x / 2.0, -100)
	boss.died.connect(_on_boss_died)
	boss.health_changed.connect(_on_boss_health_changed)
	add_child(boss)
	
	# Wait a frame for boss _ready to finish scaling its health before we read it
	await get_tree().process_frame
	boss_health_bar.max_value = boss.max_health
	boss_health_bar.value = boss.max_health
	boss_health_bar.visible = true

func _on_boss_health_changed(current: int, maximum: int) -> void:
	boss_health_bar.max_value = maximum
	boss_health_bar.value = current

func _on_boss_died(points: int) -> void:
	boss_health_bar.visible = false
	update_score(points)
	score_label.text = "Loop " + str(current_loop) + " Cleared!"
	
	# Wait, then start next loop
	await get_tree().create_timer(3.0).timeout
	start_next_loop()

func start_next_loop() -> void:
	current_loop += 1
	boss_spawned = false
	
	# Scale difficulty multipliers
	# Spawn rate decreases (faster spawns), floor at 0.1s
	initial_spawn_rate = max(0.1, initial_spawn_rate * 0.8)
	current_spawn_rate = initial_spawn_rate
	spawn_timer.wait_time = current_spawn_rate
	spawn_timer.start()
	
	# Next boss requires more score difference
	score_to_next_boss = score + (base_score_for_boss * current_loop)
	update_hud()

func _on_player_died() -> void:
	# Game Over logic
	spawn_timer.stop()
	score_label.text = "Game Over!\nFinal Score: " + str(score)
	health_label.text = "Health: 0"
	powerup_label.text = ""
	# Give a moment before restarting
	await get_tree().create_timer(3.0).timeout
	get_tree().reload_current_scene()

func _on_player_health_changed(new_health: int) -> void:
	var player = get_node_or_null("Player")
	if player:
		health_label.text = "HP: %d | PWR: %d | SPD: %d" % [max(0, new_health), player.base_damage + player.perm_damage_bonus, int(player.speed)]
	else:
		health_label.text = "Health: " + str(max(0, new_health))

func _on_player_stats_changed(hp: int, pwr: int, spd: float) -> void:
	health_label.text = "HP: %d | PWR: %d | SPD: %d" % [max(0, hp), pwr, int(spd)]
