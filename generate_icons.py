#!/usr/bin/env python3

from PIL import Image, ImageDraw, ImageFont
import os

def create_app_icon(size, output_path):
    # Create a new image with the specified size
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Background with gradient effect (simplified as solid color)
    corner_radius = size // 6
    background_color = (33, 150, 243)  # Material Blue
    
    # Draw rounded rectangle background
    draw.rounded_rectangle(
        [(0, 0), (size, size)], 
        radius=corner_radius, 
        fill=background_color
    )
    
    # Calculate proportions
    center = size // 2
    plate_radius = size // 3
    
    # Draw plate/bowl
    plate_color = (255, 255, 255)
    draw.ellipse(
        [(center - plate_radius, center - plate_radius), 
         (center + plate_radius, center + plate_radius)],
        fill=plate_color,
        outline=(25, 118, 210),
        width=max(1, size // 128)
    )
    
    # Draw food items on the plate
    food_size = size // 20
    
    # Green vegetables (left side)
    green_color = (76, 175, 80)
    for i, (x_offset, y_offset) in enumerate([(-20, -15), (-10, 0), (-25, 10)]):
        x = center + (x_offset * size // 100)
        y = center + (y_offset * size // 100)
        draw.ellipse(
            [(x - food_size, y - food_size//2), 
             (x + food_size, y + food_size//2)],
            fill=green_color
        )
    
    # Red vegetables (right side)
    red_color = (244, 67, 54)
    for i, (x_offset, y_offset) in enumerate([(15, -20), (20, 0), (25, 15)]):
        x = center + (x_offset * size // 100)
        y = center + (y_offset * size // 100)
        draw.ellipse(
            [(x - food_size//2, y - food_size//2), 
             (x + food_size//2, y + food_size//2)],
            fill=red_color
        )
    
    # Yellow protein (bottom)
    yellow_color = (255, 193, 7)
    for i, (x_offset, y_offset) in enumerate([(0, 20), (-8, 25)]):
        x = center + (x_offset * size // 100)
        y = center + (y_offset * size // 100)
        draw.ellipse(
            [(x - food_size, y - food_size//2), 
             (x + food_size, y + food_size//2)],
            fill=yellow_color
        )
    
    # Save the image
    img.save(output_path, 'PNG')
    print(f"Generated {output_path} ({size}x{size})")

def generate_ios_icons():
    ios_sizes = [
        (20, "Icon-App-20x20@1x.png"),
        (40, "Icon-App-20x20@2x.png"),
        (60, "Icon-App-20x20@3x.png"),
        (29, "Icon-App-29x29@1x.png"),
        (58, "Icon-App-29x29@2x.png"),
        (87, "Icon-App-29x29@3x.png"),
        (40, "Icon-App-40x40@1x.png"),
        (80, "Icon-App-40x40@2x.png"),
        (120, "Icon-App-40x40@3x.png"),
        (120, "Icon-App-60x60@2x.png"),
        (180, "Icon-App-60x60@3x.png"),
        (76, "Icon-App-76x76@1x.png"),
        (152, "Icon-App-76x76@2x.png"),
        (167, "Icon-App-83.5x83.5@2x.png"),
        (1024, "Icon-App-1024x1024@1x.png"),
    ]
    
    ios_path = "ios/Runner/Assets.xcassets/AppIcon.appiconset/"
    for size, filename in ios_sizes:
        create_app_icon(size, os.path.join(ios_path, filename))

def generate_android_icons():
    android_sizes = [
        (36, "android/app/src/main/res/mipmap-ldpi/ic_launcher.png"),
        (48, "android/app/src/main/res/mipmap-mdpi/ic_launcher.png"),
        (72, "android/app/src/main/res/mipmap-hdpi/ic_launcher.png"),
        (96, "android/app/src/main/res/mipmap-xhdpi/ic_launcher.png"),
        (144, "android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png"),
        (192, "android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png"),
    ]
    
    for size, path in android_sizes:
        # Create directory if it doesn't exist
        os.makedirs(os.path.dirname(path), exist_ok=True)
        create_app_icon(size, path)

if __name__ == "__main__":
    print("Generating iOS app icons...")
    generate_ios_icons()
    
    print("\nGenerating Android app icons...")
    generate_android_icons()
    
    print("\nApp icons generated successfully!") 