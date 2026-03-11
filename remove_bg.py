import os
import sys
from PIL import Image

def remove_black_background(image_path, output_path):
    print(f"Processing {image_path}...")
    try:
        img = Image.open(image_path).convert("RGBA")
        width, height = img.size
        pixels = img.load()

        # We'll do a simple flood fill from the edges (0,0) and some other edges
        # using a threshold to detect near-black colors
        visited = set()
        queue = []
        
        # Add all border pixels to queue
        for x in range(width):
            queue.append((x, 0))
            queue.append((x, height - 1))
        for y in range(height):
            queue.append((0, y))
            queue.append((width - 1, y))

        threshold = 25 # tolerance for black
        
        def is_black(r, g, b):
            return r < threshold and g < threshold and b < threshold

        # Flood fill
        while queue:
            x, y = queue.pop(0)
            if (x, y) in visited:
                continue
            
            visited.add((x, y))
            r, g, b, a = pixels[x, y]
            
            if is_black(r, g, b) and a > 0:
                pixels[x, y] = (0, 0, 0, 0) # Make transparent
                # Add neighbors
                if x > 0: queue.append((x - 1, y))
                if x < width - 1: queue.append((x + 1, y))
                if y > 0: queue.append((x, y - 1))
                if y < height - 1: queue.append((x, y + 1))
                
        img.save(output_path)
        print(f"Saved to {output_path}")
    except Exception as e:
        print(f"Error processing {image_path}: {e}")

artifact_dir = "/Users/shaumikmondal/.gemini/antigravity/brain/864afacd-916a-4e1c-ac3b-c554e0d3ac47"
assets_dir = "/Users/shaumikmondal/programming/prototype_alpha/assets"

files_to_process = [
    "player_base", "player_spread", "player_pierce", "player_full",
    "enemy_basic", "enemy_boss", "powerup", "laser"
]

# Find the newest file for each prefix in the artifact dir
generated_files = os.listdir(artifact_dir)

for prefix in files_to_process:
    matching_files = [f for f in generated_files if f.startswith(prefix) and f.endswith(".png")]
    if not matching_files:
        print(f"No file found for {prefix}")
        continue
        
    # Get the newest one based on timestamp in filename (or just modification time)
    newest_file = max(matching_files, key=lambda f: os.path.getmtime(os.path.join(artifact_dir, f)))
    source_path = os.path.join(artifact_dir, newest_file)
    target_path = os.path.join(assets_dir, f"{prefix}.png")
    
    remove_black_background(source_path, target_path)

# Special case for background: just copy it as is
try:
    bg_files = [f for f in generated_files if f.startswith("background_space") and f.endswith(".png")]
    if bg_files:
        newest_bg = max(bg_files, key=lambda f: os.path.getmtime(os.path.join(artifact_dir, f)))
        source_path = os.path.join(artifact_dir, newest_bg)
        target_path = os.path.join(assets_dir, "background.png")
        Image.open(source_path).save(target_path)
        print(f"Copied background to {target_path}")
except Exception as e:
    print(f"Error copying background: {e}")
