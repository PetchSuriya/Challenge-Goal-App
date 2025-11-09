#!/bin/bash

# 🚀 Quick Start Script สำหรับ Appium Testing
# ใช้รัน Appium tests อัตโนมัติ

echo "📱 Challenge Goal App - Appium Testing"
echo "======================================"
echo ""

# Check if Appium is installed
if ! command -v appium &> /dev/null
then
    echo "❌ Appium is not installed!"
    echo "Please install: npm install -g appium"
    exit 1
fi

# Check if emulator is running
echo "🔍 Checking for Android emulator..."
EMULATOR=$(adb devices | grep -w "emulator" | awk '{print $1}')

if [ -z "$EMULATOR" ]; then
    echo "❌ No Android emulator found!"
    echo "Please start emulator first:"
    echo "  flutter emulators --launch Pixel_9_Pro"
    exit 1
fi

echo "✅ Found emulator: $EMULATOR"
echo ""

# Build APK if not exists
APK_PATH="../build/app/outputs/flutter-apk/app-debug.apk"
if [ ! -f "$APK_PATH" ]; then
    echo "📦 Building Flutter APK..."
    cd ..
    flutter build apk --debug
    cd appium-tests
    echo "✅ APK built successfully"
else
    echo "✅ APK already exists"
fi

echo ""
echo "🚀 Starting Appium Server..."
# Start Appium in background
appium &
APPIUM_PID=$!

# Wait for Appium to start
echo "⏳ Waiting for Appium to start..."
sleep 5

echo ""
echo "🧪 Running Tests..."
npm test

# Kill Appium server
echo ""
echo "🛑 Stopping Appium Server..."
kill $APPIUM_PID

echo ""
echo "✅ Done!"
