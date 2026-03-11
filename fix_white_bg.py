import os
from PIL import Image

def remove_white(image_path: str):
    img = Image.open(image_path).convert("RGBA")
    data = img.getdata()

    new_data = []
    # Any pixel close to white gets alpha=0
    for item in data:
        if item[0] > 230 and item[1] > 230 and item[2] > 230:
            new_data.append((255, 255, 255, 0))
        else:
            new_data.append(item)

    img.putdata(new_data)
    img.save(image_path, "PNG")

assets_dir = "/Users/shaumikmondal/programming/prototype_alpha/assets"
for f in os.listdir(assets_dir):
    if f.startswith("player_") and f.endswith(".png"):
        print(f"Fixing white background for {f}")
        remove_white(os.path.join(assets_dir, f))
