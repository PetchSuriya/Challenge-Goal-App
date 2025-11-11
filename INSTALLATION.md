# Installation Guide

Complete step-by-step guide to set up and run the Challenge Goal App on your local machine.

## Table of Contents
- [System Requirements](#system-requirements)
- [Backend Setup](#backend-setup)
- [Frontend Setup](#frontend-setup)
- [Running the Application](#running-the-application)
- [Troubleshooting](#troubleshooting)

## System Requirements

### Required Software
- **Flutter SDK**: 3.35.6 or higher
- **Dart SDK**: Included with Flutter
- **Node.js**: 16.x or higher
- **npm**: 8.x or higher (comes with Node.js)
- **Git**: Latest version

### Development Tools (Choose one)
- **Android Studio** (recommended for Android development)
- **VS Code** with Flutter extensions
- **Xcode** (for iOS development on macOS)

### Device/Emulator
- Android Emulator (API 36 or higher recommended)
- iOS Simulator (macOS only)
- Physical device with USB debugging enabled

## Backend Setup

### Step 1: Navigate to Server Directory

```bash
cd Challenge-Goal-App/Server
```

### Step 2: Install Dependencies

```bash
npm install
```

This will install:
- express (4.18.2)
- sqlite3 (5.1.6)
- bcrypt (5.1.0)
- cors (2.8.5)
- body-parser (1.20.2)
- express-session (1.17.3)

### Step 3: Verify Installation

```bash
npm list --depth=0
```

You should see all dependencies listed without errors.

### Step 4: Start the Server

```bash
node index.js
```

**Expected Output:**
```
Server listening on http://localhost:3000
```

The server will automatically:
- Create `data.db` SQLite database
- Initialize tables (users, goals, friends, items, etc.)
- Seed demo data
- Start listening on port 3000

### Backend File Structure

```
Server/
├── index.js              # Main server file
├── db.js                 # Database configuration
├── package.json          # Dependencies
├── data.db              # SQLite database (auto-created)
└── public/              # Static files
```

## Frontend Setup

### Step 1: Return to Project Root

```bash
cd ..  # Go back to Challenge-Goal-App directory
```

### Step 2: Verify Flutter Installation

```bash
flutter doctor
```

Fix any issues shown (e.g., Android licenses, missing tools).

### Step 3: Get Flutter Dependencies

```bash
flutter pub get
```

This will install all dependencies from `pubspec.yaml`:
- dio (5.3.2) - HTTP client
- flutter_riverpod (2.6.1) - State management
- go_router (12.1.3) - Navigation
- shared_preferences (2.3.3) - Local storage
- image_picker (1.1.2) - Profile pictures

### Step 4: Configure API Endpoint

**For Android Emulator** (default):
- The app is already configured to use `http://10.0.2.2:3000`
- No changes needed

**For iOS Simulator**:
```dart
// lib/core/config/api_config.dart
static const String baseUrl = 'http://localhost:3000';
```

**For Physical Device**:
```dart
// lib/core/config/api_config.dart
static const String baseUrl = 'http://YOUR_COMPUTER_IP:3000';
// Find your IP: Windows (ipconfig), Mac/Linux (ifconfig)
```

### Step 5: List Available Devices

```bash
flutter devices
```

Or launch an emulator:
```bash
flutter emulators
flutter emulators --launch <emulator-id>
```

## Running the Application

### Method 1: Run in Development Mode

1. **Start Backend** (in one terminal):
   ```bash
   cd Server
   node index.js
   ```

2. **Run Flutter App** (in another terminal):
   ```bash
   flutter run -d <device-id>
   ```

### Method 2: Run in Background

1. **Start Backend in Background**:
   ```bash
   cd Server
   nohup node index.js > server.log 2>&1 &
   ```

2. **Run Flutter App**:
   ```bash
   flutter run -d emulator-5554
   ```

### Test Login

Use these demo credentials:
- **Email**: `JohnDoe@gmail.com`
- **Password**: `Bento2025!`

Or create a new account through the Register page.

## Troubleshooting

### Backend Issues

**Problem**: Port 3000 already in use
```bash
# Find and kill the process
lsof -i :3000
kill -9 <PID>
```

**Problem**: SQLite database locked
```bash
cd Server
rm data.db  # Delete and let it recreate
node index.js
```

**Problem**: Cannot find module errors
```bash
rm -rf node_modules package-lock.json
npm install
```

### Frontend Issues

**Problem**: Flutter app can't connect to backend
- Check backend is running: `curl http://localhost:3000`
- Verify API endpoint in `api_config.dart`
- For Android Emulator, use `10.0.2.2:3000` not `localhost:3000`
- Disable firewall temporarily to test

**Problem**: Build errors
```bash
flutter clean
flutter pub get
flutter run
```

**Problem**: Gradle errors (Android)
```bash
cd android
./gradlew clean
cd ..
flutter run
```

**Problem**: Keyboard not working in emulator
```bash
adb -s <emulator-id> shell settings put secure show_ime_with_hard_keyboard 1
```

### Common Issues

**Problem**: Packages have newer versions warning
- This is just a warning, the app will still work
- To update: `flutter pub outdated` then `flutter pub upgrade`

**Problem**: Hot reload not working
- Press `R` (capital R) for hot restart
- Or restart: `flutter run` again

**Problem**: Database seeding errors
- These are usually non-fatal
- The app will still work, just without demo data
- Check `Server/scripts/seed_*.js` files

## Verification Checklist

After setup, verify everything works:

- [ ] Backend server running on http://localhost:3000
- [ ] Flutter app builds without errors
- [ ] Can login with demo credentials
- [ ] Can register new user
- [ ] Can create a goal
- [ ] Can view profile
- [ ] Can add friends
- [ ] Avatar displays correctly

## Next Steps

- Read [README.md](README.md) for feature overview
- Check [API_DOCUMENTATION.md](API_DOCUMENTATION.md) for API details
- See [DEVELOPMENT_GUIDE.dart](DEVELOPMENT_GUIDE.dart) for coding guidelines

## Support

If you encounter issues not covered here:
1. Check existing GitHub Issues
2. Create a new issue with:
   - Steps to reproduce
   - Error messages
   - Your environment (OS, Flutter version, Node version)
   - Screenshots if applicable
