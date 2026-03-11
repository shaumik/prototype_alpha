import os
import re

assets_dir = "/Users/shaumikmondal/programming/prototype_alpha/assets"
scenes_dir = "/Users/shaumikmondal/programming/prototype_alpha/scenes"

# 1. Gather all UIDs from .import files
file_to_uid = {}
for f in os.listdir(assets_dir):
    if f.endswith(".import"):
        orig_file = f.replace(".import", "")
        with open(os.path.join(assets_dir, f), "r") as imp:
            content = imp.read()
            # uid="uid://uo3si0x1t5s3"
            match = re.search(r'uid="(uid://[^"]+)"', content)
            if match:
                file_to_uid[f"res://assets/{orig_file}"] = match.group(1)

# 2. Update .tscn files
for f in os.listdir(scenes_dir):
    if f.endswith(".tscn"):
        scene_path = os.path.join(scenes_dir, f)
        with open(scene_path, "r") as sf:
            content = sf.read()
        
        changed = False
        # [ext_resource type="Texture2D" uid="uid://ddxxeyveyyeyy" path="res://assets/player_base.png" id="2_efgh"]
        # We need to replace uid="..." if path matches
        
        def replacer(match):
            prefix = match.group(1)
            uid_str = match.group(2)
            path_str = match.group(3)
            suffix = match.group(4)
            
            if path_str in file_to_uid and uid_str != file_to_uid[path_str]:
                global changed
                changed = True
                return f'{prefix}uid="{file_to_uid[path_str]}" path="{path_str}"{suffix}'
            return match.group(0)

        # Regex to match ext_resource line
        pattern = r'(\[ext_resource.*?)\s*uid="([^"]+)"\s*path="([^"]+)"(.*\])'
        new_content = re.sub(pattern, replacer, content)
        
        if changed:
            with open(scene_path, "w") as sf:
                sf.write(new_content)
            print(f"Updated UIDs in {f}")

print("Done fixing UIDs.")
