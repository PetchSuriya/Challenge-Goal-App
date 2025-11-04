# 🎨 Avatar Replacement Guide

## Quick Steps to Replace Your Avatar:

### Method 1: Replace Existing File
1. Find a new avatar image (PNG format recommended)
2. Resize it to **512x512 pixels** or larger for best quality
3. Name it exactly `Avatar.png` (with capital A)
4. Replace the file in: `assets/images/Avatar.png`
5. Run `flutter clean` and `flutter run` to see changes

### Method 2: Add Multiple Avatar Options
1. Add new avatar files to `assets/images/` like:
   - `Avatar_Hero.png`
   - `Avatar_Warrior.png`
   - `Avatar_Mage.png`
2. Modify the code to let users select different avatars

## 🎯 Recommended Avatar Specifications:

- **Format**: PNG with transparency
- **Size**: 512x512 pixels minimum
- **Style**: Simple, cartoon-like for best mobile display
- **Background**: Transparent
- **File size**: Under 50KB for optimal loading

## 🔧 Current Avatar Settings:

- **Display size**: 400x400 pixels
- **Location**: `assets/images/Avatar.png`
- **Fit**: `BoxFit.contain` (maintains aspect ratio)
- **Shadow**: 20px blur with 10px offset
- **Border radius**: 20px

## 💡 Tips for Best Results:

1. **Vector graphics**: SVG files can be converted to PNG for crisp scaling
2. **High contrast**: Ensure avatar stands out against light backgrounds
3. **Simple details**: Avoid tiny details that won't show at smaller sizes
4. **Consistent style**: Match the playful style of your app

## 🎨 Free Avatar Resources:

- **Avataaars**: https://avataaars.com/ (customizable avatars)
- **Dicebear**: https://dicebear.com/ (API-generated avatars)
- **Freepik**: https://www.freepik.com/vectors/avatar
- **Flaticon**: https://www.flaticon.com/search?word=avatar

## 🚀 Hot Reload After Changes:

After replacing the avatar file:
```bash
# In your Flutter project directory:
flutter clean
flutter pub get
flutter run
```

Your new avatar will appear immediately with the improved 400px size and shadow effects!