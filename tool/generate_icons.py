import os
from PIL import Image

def generate():
    root = "/home/levi9111/Desktop/Rentezzi-v2"
    mobile = os.path.join(root, "Rentezzi-mobile")
    frontend_public = os.path.join(root, "Rentezzi-frontend-v2", "public")
    
    favicon_src = os.path.join(frontend_public, "favicon.png")
    logo_src = os.path.join(frontend_public, "logo.png")
    
    print(f"Loading icons from:\n  favicon: {favicon_src}\n  logo: {logo_src}")
    
    fav_img = Image.open(favicon_src).convert("RGBA")
    logo_img = Image.open(logo_src).convert("RGBA")
    
    # 1. Assets directory
    assets_dir = os.path.join(mobile, "assets", "images")
    os.makedirs(assets_dir, exist_ok=True)
    
    fav_img.save(os.path.join(assets_dir, "app_icon.png"), "PNG")
    logo_img.save(os.path.join(assets_dir, "logo.png"), "PNG")
    print(f"Saved in-app assets to {assets_dir}")
    
    # 2. Android Mipmaps
    android_res = os.path.join(mobile, "android", "app", "src", "main", "res")
    android_sizes = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192,
    }
    
    for folder, size in android_sizes.items():
        folder_path = os.path.join(android_res, folder)
        os.makedirs(folder_path, exist_ok=True)
        resized = fav_img.resize((size, size), Image.Resampling.LANCZOS)
        out_path = os.path.join(folder_path, "ic_launcher.png")
        resized.save(out_path, "PNG")
        print(f"Saved {out_path} ({size}x{size})")
        
    # 3. Web icons
    web_dir = os.path.join(mobile, "web")
    web_icons = os.path.join(web_dir, "icons")
    os.makedirs(web_icons, exist_ok=True)
    fav_img.resize((192, 192), Image.Resampling.LANCZOS).save(os.path.join(web_icons, "Icon-192.png"), "PNG")
    fav_img.resize((512, 512), Image.Resampling.LANCZOS).save(os.path.join(web_icons, "Icon-512.png"), "PNG")
    fav_img.resize((192, 192), Image.Resampling.LANCZOS).save(os.path.join(web_icons, "Icon-maskable-192.png"), "PNG")
    fav_img.resize((512, 512), Image.Resampling.LANCZOS).save(os.path.join(web_icons, "Icon-maskable-512.png"), "PNG")
    fav_img.resize((64, 64), Image.Resampling.LANCZOS).save(os.path.join(web_dir, "favicon.png"), "PNG")
    print("Saved Web icons")
    
    # 4. iOS AppIcon set
    ios_icons = os.path.join(mobile, "ios", "Runner", "Assets.xcassets", "AppIcon.appiconset")
    if os.path.exists(ios_icons):
        ios_sizes = {
            "Icon-App-20x20@1x.png": 20,
            "Icon-App-20x20@2x.png": 40,
            "Icon-App-20x20@3x.png": 60,
            "Icon-App-29x29@1x.png": 29,
            "Icon-App-29x29@2x.png": 58,
            "Icon-App-29x29@3x.png": 87,
            "Icon-App-40x40@1x.png": 40,
            "Icon-App-40x40@2x.png": 80,
            "Icon-App-40x40@3x.png": 120,
            "Icon-App-60x60@2x.png": 120,
            "Icon-App-60x60@3x.png": 180,
            "Icon-App-76x76@1x.png": 76,
            "Icon-App-76x76@2x.png": 152,
            "Icon-App-83.5x83.5@2x.png": 167,
            "Icon-App-1024x1024@1x.png": 1024,
        }
        for filename, size in ios_sizes.items():
            out_file = os.path.join(ios_icons, filename)
            fav_img.resize((size, size), Image.Resampling.LANCZOS).save(out_file, "PNG")
        print("Saved iOS icons")
        
    print("Icon generation completed successfully!")

if __name__ == "__main__":
    generate()
