import os

base_dir = "/Users/shaumikmondal/programming/prototype_alpha"
scenes_dir = os.path.join(base_dir, "scenes")
scripts_dir = os.path.join(base_dir, "scripts")

# 1. Create explosion.gd
explosion_gd_content = """extends CPUParticles2D

func _ready() -> void:
    emitting = true
    await get_tree().create_timer(lifetime).timeout
    queue_free()
"""
with open(os.path.join(scripts_dir, "explosion.gd"), "w") as f:
    f.write(explosion_gd_content)

# 2. Create explosion.tscn
explosion_tscn_content = """[gd_scene load_steps=2 format=3 uid="uid://cxexplodescene123"]

[ext_resource type="Script" path="res://scripts/explosion.gd" id="1_expl"]

[node name="Explosion" type="CPUParticles2D"]
emitting = false
amount = 40
lifetime = 0.5
one_shot = true
explosiveness = 1.0
spread = 180.0
gravity = Vector2(0, 0)
initial_velocity_min = 50.0
initial_velocity_max = 200.0
scale_amount_min = 4.0
scale_amount_max = 8.0
color = Color(1, 0.4, 0, 1)
script = ExtResource("1_expl")
"""
with open(os.path.join(scenes_dir, "explosion.tscn"), "w") as f:
    f.write(explosion_tscn_content)

# 3. Add WorldEnvironment to Main.tscn
main_tscn_path = os.path.join(scenes_dir, "Main.tscn")
with open(main_tscn_path, "r") as f:
    main_content = f.read()

env_subresource = """
[sub_resource type="Environment" id="Environment_glow123"]
background_mode = 3
glow_enabled = true
glow_intensity = 1.5
glow_strength = 1.2
glow_bloom = 0.2
glow_blend_mode = 0
"""

env_node = """
[node name="WorldEnvironment" type="WorldEnvironment" parent="."]
environment = SubResource("Environment_glow123")
"""

if "WorldEnvironment" not in main_content:
    # Insert subresource near top
    idx = main_content.find("\\n[node")
    main_content = main_content[:idx] + "\\n" + env_subresource + main_content[idx:]
    # Insert node at bottom
    main_content += "\\n" + env_node
    
    with open(main_tscn_path, "w") as f:
        f.write(main_content)

# 4. Add Engine Trail to Player.tscn
player_tscn_path = os.path.join(scenes_dir, "player.tscn")
with open(player_tscn_path, "r") as f:
    player_content = f.read()

trail_node = """
[node name="EngineTrail" type="CPUParticles2D" parent="."]
position = Vector2(0, 20)
amount = 30
lifetime = 0.4
gravity = Vector2(0, 980)
initial_velocity_min = 50.0
initial_velocity_max = 100.0
scale_amount_min = 2.0
scale_amount_max = 5.0
color = Color(0, 0.8, 1, 1)
"""
if "EngineTrail" not in player_content:
    player_content += "\\n" + trail_node
    with open(player_tscn_path, "w") as f:
        f.write(player_content)

# 5. Modify enemy.gd to spawn explosions
enemy_gd_path = os.path.join(scripts_dir, "enemy.gd")
with open(enemy_gd_path, "r") as f:
    enemy_lines = f.readlines()

new_enemy_lines = []
for line in enemy_lines:
    if "var PowerupScene =" in line:
        new_enemy_lines.append(line)
        new_enemy_lines.append("var ExplosionScene = preload(\\\"res://scenes/explosion.tscn\\\")\\n")
    elif "func die() -> void:" in line:
        new_enemy_lines.append(line)
        new_enemy_lines.append("    var expl = ExplosionScene.instantiate()\\n")
        new_enemy_lines.append("    expl.global_position = global_position\\n")
        new_enemy_lines.append("    get_tree().current_scene.call_deferred(\\\"add_child\\\", expl)\\n")
    else:
        new_enemy_lines.append(line)

with open(enemy_gd_path, "w") as f:
    f.writelines(new_enemy_lines)

print("Added visual effects!")
