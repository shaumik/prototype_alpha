import os
from PIL import Image

def remove_bg(img_path):
    img = Image.open(img_path).convert("RGBA")
    width, height = img.size
    pixels = img.load()
    
    queue = []
    visited = set()
    
    # Start flood fill from any transparent pixel AND the borders
    for y in range(height):
        for x in range(width):
            r, g, b, a = pixels[x, y]
            if a == 0 or x == 0 or x == width - 1 or y == 0 or y == height - 1:
                queue.append((x, y))
                
    while queue:
        x, y = queue.pop(0)
        if (x, y) in visited:
            continue
        visited.add((x, y))
        
        r, g, b, a = pixels[x, y]
        
        # We want to clear this pixel if it's already a=0, OR if it's whitish
        is_bg = False
        if a == 0:
            is_bg = True
        elif r > 200 and g > 200 and b > 200: # Whitish backgrounds
            is_bg = True
            pixels[x, y] = (0, 0, 0, 0) # Make it transparent
            
        if is_bg:
            # Add neighbors
            for dx, dy in [(0, 1), (0, -1), (1, 0), (-1, 0)]:
                nx, ny = x + dx, y + dy
                if 0 <= nx < width and 0 <= ny < height and (nx, ny) not in visited:
                    queue.append((nx, ny))
                    
    # Anti-aliasing fringe removal: any pixel next to a transparent pixel that is light-colored gets its alpha reduced
    for y in range(height):
        for x in range(width):
            r, g, b, a = pixels[x, y]
            if a > 0 and r > 150 and g > 150 and b > 150:
                # Check if it has a transparent neighbor
                has_trans_neighbor = False
                for dx, dy in [(0, 1), (0, -1), (1, 0), (-1, 0)]:
                    nx, ny = x + dx, y + dy
                    if 0 <= nx < width and 0 <= ny < height:
                        if pixels[nx, ny][3] == 0:
                            has_trans_neighbor = True
                            break
                if has_trans_neighbor:
                    # Soften it
                    pixels[x, y] = (r, g, b, int(a * 0.1))
                        
    img.save(img_path)

assets_dir = "/Users/shaumikmondal/programming/prototype_alpha/assets"
for prefix in ["player_base", "player_spread", "player_pierce", "player_full"]:
    path = os.path.join(assets_dir, f"{prefix}.png")
    if os.path.exists(path):
        remove_bg(path)
        print(f"Cleaned {path}")
