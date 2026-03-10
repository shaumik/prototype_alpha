import re

with open("scenes/Main.tscn", "r") as f:
    content = f.read()

# Replace ScoreLabel
score_label_replacement = """[node name="HUDContainer" type="VBoxContainer" parent="HUD"]
offset_left = 16.0
offset_top = 16.0
offset_right = 300.0
offset_bottom = 120.0
theme_override_constants/separation = 8

[node name="ScoreLabel" type="Label" parent="HUD/HUDContainer"]
layout_mode = 2
theme_override_colors/font_shadow_color = Color(0, 0, 0, 1)
theme_override_colors/font_outline_color = Color(0, 0, 0, 1)
theme_override_constants/shadow_offset_x = 2
theme_override_constants/shadow_offset_y = 2
theme_override_constants/outline_size = 2
theme_override_font_sizes/font_size = 28
text = "Score: 0"
"""
content = re.sub(
    r'\[node name="ScoreLabel" type="Label" parent="HUD"\].*?text = "Score: 0"\n',
    score_label_replacement,
    content,
    flags=re.DOTALL
)

# Replace HealthLabel
health_label_replacement = """[node name="HealthLabel" type="Label" parent="HUD/HUDContainer"]
layout_mode = 2
theme_override_colors/font_color = Color(1, 0.4, 0.4, 1)
theme_override_colors/font_shadow_color = Color(0, 0, 0, 1)
theme_override_colors/font_outline_color = Color(0, 0, 0, 1)
theme_override_constants/shadow_offset_x = 2
theme_override_constants/shadow_offset_y = 2
theme_override_constants/outline_size = 2
theme_override_font_sizes/font_size = 20
text = "Health: 3"
"""
content = re.sub(
    r'\[node name="HealthLabel" type="Label" parent="HUD"\].*?text = "Health: 3"\n',
    health_label_replacement,
    content,
    flags=re.DOTALL
)

# Replace PowerupLabel
powerup_label_replacement = """[node name="PowerupLabel" type="Label" parent="HUD/HUDContainer"]
layout_mode = 2
theme_override_colors/font_color = Color(0.4, 1, 0.4, 1)
theme_override_colors/font_shadow_color = Color(0, 0, 0, 1)
theme_override_colors/font_outline_color = Color(0, 0, 0, 1)
theme_override_constants/shadow_offset_x = 2
theme_override_constants/shadow_offset_y = 2
theme_override_constants/outline_size = 2
theme_override_font_sizes/font_size = 20
text = ""
"""
content = re.sub(
    r'\[node name="PowerupLabel" type="Label" parent="HUD"\].*?text = ""\n',
    powerup_label_replacement,
    content,
    flags=re.DOTALL
)

# Replace BossHealthBar
boss_health_bar_replacement = """[node name="BossHealthBar" type="ProgressBar" parent="HUD"]
visible = false
anchors_preset = 5
anchor_left = 0.5
anchor_right = 0.5
offset_left = -200.0
offset_top = 24.0
offset_right = 200.0
offset_bottom = 40.0
grow_horizontal = 2
theme_override_styles/background = SubResource("StyleBoxFlat_bg")
theme_override_styles/fill = SubResource("StyleBoxFlat_fill")
show_percentage = false

[node name="GameOverScreen" type="Control" parent="HUD"]
visible = false
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2

[node name="ColorRect" type="ColorRect" parent="HUD/GameOverScreen"]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
color = Color(0, 0, 0, 0.705882)

[node name="VBoxContainer" type="VBoxContainer" parent="HUD/GameOverScreen"]
layout_mode = 1
anchors_preset = 8
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
offset_left = -150.0
offset_top = -60.0
offset_right = 150.0
offset_bottom = 60.0
grow_horizontal = 2
grow_vertical = 2
theme_override_constants/separation = 16

[node name="Title" type="Label" parent="HUD/GameOverScreen/VBoxContainer"]
layout_mode = 2
theme_override_colors/font_color = Color(1, 0.2, 0.2, 1)
theme_override_colors/font_shadow_color = Color(0.5, 0, 0, 1)
theme_override_constants/shadow_offset_x = 3
theme_override_constants/shadow_offset_y = 3
theme_override_font_sizes/font_size = 48
text = "GAME OVER"
horizontal_alignment = 1

[node name="FinalScoreLabel" type="Label" parent="HUD/GameOverScreen/VBoxContainer"]
layout_mode = 2
theme_override_font_sizes/font_size = 24
text = "Final Score: 0"
horizontal_alignment = 1

[node name="RestartLabel" type="Label" parent="HUD/GameOverScreen/VBoxContainer"]
layout_mode = 2
theme_override_colors/font_color = Color(0.7, 0.7, 0.7, 1)
theme_override_font_sizes/font_size = 16
text = "Restarting..."
horizontal_alignment = 1
"""
content = re.sub(
    r'\[node name="BossHealthBar" type="ProgressBar" parent="HUD"\].*?show_percentage = false\n',
    boss_health_bar_replacement,
    content,
    flags=re.DOTALL
)

# Add SubResources for the generic flat styles at the very top (right after ext_resource declarations)
sub_resources = """
[sub_resource type="StyleBoxFlat" id="StyleBoxFlat_bg"]
bg_color = Color(0.1, 0.1, 0.1, 0.8)
corner_radius_top_left = 8
corner_radius_top_right = 8
corner_radius_bottom_right = 8
corner_radius_bottom_left = 8

[sub_resource type="StyleBoxFlat" id="StyleBoxFlat_fill"]
bg_color = Color(0.8, 0.1, 0.1, 1)
corner_radius_top_left = 8
corner_radius_top_right = 8
corner_radius_bottom_right = 8
corner_radius_bottom_left = 8
"""
# Insert after [ext_resource] lines
ext_res_end = content.rfind('[ext_resource')
if ext_res_end != -1:
    next_newline = content.find('\\n', ext_res_end)
    content = content[:next_newline+1] + sub_resources + content[next_newline+1:]
else:
    # If no ext_resource, insert after gd_scene
    gd_scene_end = content.find('\\n')
    content = content[:gd_scene_end+1] + sub_resources + content[gd_scene_end+1:]

with open("scenes/Main.tscn", "w") as f:
    f.write(content)

