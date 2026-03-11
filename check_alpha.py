import os
from PIL import Image

assets_dir = "/Users/shaumikmondal/programming/prototype_alpha/assets"

for f in os.listdir(assets_dir):
    if f.endswith(".png"):
        img = Image.open(os.path.join(assets_dir, f)).convert("RGBA")
        pixels = list(img.getdata())
        has_transparency = any(p[3] < 255 for p in pixels)
        top_left = pixels[0]
        print(f"{f}: Has Transparency? {has_transparency}, Top-left pixel: {top_left}")
