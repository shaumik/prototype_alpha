import os
from PIL import Image

assets_dir = "/Users/shaumikmondal/programming/prototype_alpha/assets"

sizes = {
    "player_base.png": (64, 64),
    "player_spread.png": (64, 64),
    "player_pierce.png": (64, 64),
    "player_full.png": (64, 64),
    "enemy_basic.png": (64, 64),
    "enemy_boss.png": (128, 128),
    "powerup.png": (32, 32),
    "laser.png": (16, 64),
    "background.png": (1024, 1024)
}

for filename, size in sizes.items():
    path = os.path.join(assets_dir, filename)
    if os.path.exists(path):
        try:
            img = Image.open(path)
            # Use LANCZOS for smooth downscaling
            img = img.resize(size, Image.Resampling.LANCZOS)
            img.save(path)
            print(f"Resized {filename} to {size}")
        except Exception as e:
            print(f"Failed to resize {filename}: {e}")
    else:
        print(f"File not found: {filename}")
