import os

scenes_dir = "/Users/shaumikmondal/programming/prototype_alpha/scenes"

for filename in os.listdir(scenes_dir):
    if not filename.endswith(".tscn"):
        continue
    
    filepath = os.path.join(scenes_dir, filename)
    with open(filepath, "r") as f:
        content = f.read()
        
    # Replace .svg references with .png
    # Also remove uid so Godot generates a new one on load, reducing errors.
    # To do this safely, we can just replace .svg with .png. If Godot complains about UID mismatch,
    # it usually just recovers. But let's strip uid temporarily if we see .svg.
    # Actually, replacing .svg with .png is enough, Godot 4 auto-reimports and links if UID fails but path matches.
    new_content = content.replace(".svg", ".png")
    
    if new_content != content:
        with open(filepath, "w") as f:
            f.write(new_content)
        print(f"Updated {filename}")

# Note: background.tscn has mirroring hardcoded. Let's adjust to 1024 to match our background.
with open(os.path.join(scenes_dir, "background.tscn"), "r") as f:
    bg_content = f.read()
    bg_content = bg_content.replace("motion_mirroring = Vector2(0, 960)", "motion_mirroring = Vector2(0, 1024)")
with open(os.path.join(scenes_dir, "background.tscn"), "w") as f:
    f.write(bg_content)
print("Updated background.tscn mirroring")
