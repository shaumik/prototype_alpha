import os
from PIL import Image

def remove_white_bg(image_path, output_path):
    print(f"Processing {image_path}...")
    try:
        img = Image.open(image_path).convert("RGBA")
        width, height = img.size
        pixels = img.load()

        visited = set()
        queue = []
        
        # Add all border pixels to queue
        for x in range(width):
            queue.append((x, 0))
            queue.append((x, height - 1))
        for y in range(height):
            queue.append((0, y))
            queue.append((width - 1, y))

        threshold = 240 # Very close to white
        fringe_threshold = 180 # Lighter than this might be edge anti-aliasing
        
        def is_white(r, g, b):
            return r > threshold and g > threshold and b > threshold

        # First pass: pure flood fill for the solid white
        while queue:
            x, y = queue.pop(0)
            if (x, y) in visited:
                continue
            
            visited.add((x, y))
            r, g, b, a = pixels[x, y]
            
            # If it's very white or it's my old transparent white
            if (is_white(r, g, b) or a == 0) and (r,g,b,a) != (0,0,0,0):
                pixels[x, y] = (0, 0, 0, 0)
                if x > 0: queue.append((x - 1, y))
                if x < width - 1: queue.append((x + 1, y))
                if y > 0: queue.append((x, y - 1))
                if y < height - 1: queue.append((x, y + 1))

        # Second pass: fringe removal (make off-white pixels near transparent ones slightly transparent)
        # For simplicity, we just make any pixel > 150 partially transparent if it's not part of the core colors (which are usually blue/neon)
        # But player ships have blue and grey.
        # Let's just do a simple luminosity to alpha mapping for very light greys
        for y in range(height):
            for x in range(width):
                r, g, b, a = pixels[x, y]
                if a == 0: continue
                # if pixel is grey-ish and light
                if r > 150 and g > 150 and b > 150 and abs(r-g) < 20 and abs(g-b) < 20 and abs(r-b) < 20: 
                    # Drop alpha based on how close to white it is
                    avg = (r+g+b)/3
                    new_a = int(255 * (255 - avg) / (255 - 150))
                    pixels[x, y] = (r, g, b, max(0, min(255, new_a)))

        img.save(output_path)
        print(f"Saved to {output_path}")
    except Exception as e:
        print(f"Error: {e}")

assets_dir = "/Users/shaumikmondal/programming/prototype_alpha/assets"
for prefix in ["player_base", "player_spread", "player_pierce", "player_full"]:
    path = os.path.join(assets_dir, f"{prefix}.png")
    remove_white_bg(path, path)

