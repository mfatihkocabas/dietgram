#!/usr/bin/env python3

# Simple icon creation using built-in libraries
import os

def create_svg_icon(size, filename):
    svg_content = f'''<svg width="{size}" height="{size}" viewBox="0 0 {size} {size}" xmlns="http://www.w3.org/2000/svg">
  <!-- Background -->
  <rect width="{size}" height="{size}" rx="{size//6}" fill="#2196F3"/>
  
  <!-- Plate -->
  <circle cx="{size//2}" cy="{size//2}" r="{size//3}" fill="#FFFFFF" stroke="#1976D2" stroke-width="{max(2, size//128)}"/>
  
  <!-- Food items -->
  <!-- Green vegetables -->
  <ellipse cx="{size//2 - size//8}" cy="{size//2 - size//12}" rx="{size//15}" ry="{size//20}" fill="#4CAF50"/>
  <ellipse cx="{size//2 - size//10}" cy="{size//2}" rx="{size//18}" ry="{size//25}" fill="#66BB6A"/>
  <ellipse cx="{size//2 - size//6}" cy="{size//2 + size//15}" rx="{size//20}" ry="{size//28}" fill="#4CAF50"/>
  
  <!-- Red vegetables -->
  <circle cx="{size//2 + size//8}" cy="{size//2 - size//10}" r="{size//25}" fill="#FF5722"/>
  <circle cx="{size//2 + size//7}" cy="{size//2}" r="{size//30}" fill="#FF7043"/>
  <circle cx="{size//2 + size//6}" cy="{size//2 + size//12}" r="{size//35}" fill="#FF8A65"/>
  
  <!-- Yellow protein -->
  <ellipse cx="{size//2}" cy="{size//2 + size//8}" rx="{size//15}" ry="{size//20}" fill="#FFC107"/>
  <ellipse cx="{size//2 - size//15}" cy="{size//2 + size//6}" rx="{size//18}" ry="{size//25}" fill="#FFD54F"/>
  
  <!-- Brown carbs -->
  <rect x="{size//2 + size//20}" y="{size//2 + size//12}" width="{size//20}" height="{size//35}" rx="{size//60}" fill="#795548"/>
</svg>'''
    
    with open(filename, 'w') as f:
        f.write(svg_content)
    print(f"Created {filename}")

if __name__ == "__main__":
    # Create different sized SVG icons
    os.makedirs("assets/icon", exist_ok=True)
    
    create_svg_icon(1024, "assets/icon/app_icon.svg")
    create_svg_icon(512, "assets/icon/app_icon_512.svg")
    create_svg_icon(256, "assets/icon/app_icon_256.svg")
    
    print("SVG icons created! You can convert these to PNG using online converters.")
    print("For now, let's create a simple text-based placeholder...") 