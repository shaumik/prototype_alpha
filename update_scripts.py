import re

with open("scripts/player.gd", "r") as f:
    text = f.read()

# 1. Update signals
text = text.replace("signal stats_changed(hp, pwr, spd)", "signal stats_changed(hp, pwr, spd, fir)")

# 2. Update variables
text = text.replace("var current_powerup: int = -1", "var has_spread: bool = false\nvar has_pierce: bool = false")
text = re.sub(r"var powerup_timer: Timer\n", "", text)

# 3. Update _ready (remove timer)
ready_pattern = r"    powerup_timer = Timer\.new\(\).*?add_child\(powerup_timer\)\n\n"
text = re.sub(ready_pattern, "", text, flags=re.DOTALL)

# 4. _emit_stats_changed
text = text.replace("stats_changed.emit(current_health, base_damage + perm_damage_bonus, speed)", "stats_changed.emit(current_health, base_damage + perm_damage_bonus, speed, default_fire_rate)")

# 5. fire_weapon
fire_code_old = """    if current_powerup == Powerup.PowerupType.SPREAD:
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
        get_tree().current_scene.add_child(laser)"""

fire_code_new = """    if has_spread:
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
        get_tree().current_scene.add_child(laser)"""
text = text.replace(fire_code_old, fire_code_new)

# 6. apply_powerup (replace everything from `func apply_powerup` to the end of the file)
apply_pattern = r"func apply_powerup\(type: int\) -> void:.*"
new_apply = """func apply_powerup(type: int) -> void:
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
"""
text = re.sub(apply_pattern, new_apply, text, flags=re.DOTALL)

with open("scripts/player.gd", "w") as f:
    f.write(text)

with open("scripts/Main.gd", "r") as f:
    main_text = f.read()

# Replace _process
old_process = """func _process(_delta: float) -> void:
\tvar player = get_node_or_null("Player")
\tif player and player.get("powerup_timer") and not player.powerup_timer.is_stopped():""" # might have diff so we use regex.

process_pattern = r"func _process\(_delta: float\) -> void:\n(.*?)(?=func _on_spawn_timer_timeout)"
new_process = """func _process(_delta: float) -> void:
\tvar player = get_node_or_null("Player")
\tif player:
\t\tvar active_perks = ""
\t\tif player.has_spread:
\t\t\tactive_perks += "[SPREAD] "
\t\tif player.has_pierce:
\t\t\tactive_perks += "[PIERCE] "
\t\tif player.is_shielded:
\t\t\tactive_perks += "[SHIELD] "
\t\tpowerup_label.text = active_perks
\telse:
\t\tpowerup_label.text = ""

"""
main_text = re.sub(process_pattern, new_process, main_text, flags=re.DOTALL)

# Fix signature
main_text = main_text.replace("func _on_player_stats_changed(hp: int, pwr: int, spd: float) -> void:", "func _on_player_stats_changed(hp: int, pwr: int, spd: float, fir: float) -> void:")
main_text = main_text.replace('health_label.text = "HP: %d | PWR: %d | SPD: %d" % [max(0, hp), pwr, int(spd)]', 'health_label.text = "HP: %d | PWR: %d | SPD: %d | FIR: %.2fs" % [max(0, hp), pwr, int(spd), fir]')

with open("scripts/Main.gd", "w") as f:
    f.write(main_text)

