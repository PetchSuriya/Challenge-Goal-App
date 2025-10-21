#!/usr/bin/env pwsh
# Android Emulator Helper Script with Black Screen Fix
# Usage: .\run_emulator.ps1

Write-Host "🚀 Starting Android Emulator Pixel_9_API_35..." -ForegroundColor Green
Write-Host "⏰ Please wait, this may take 30-60 seconds..." -ForegroundColor Yellow
Write-Host ""

# Try to detect Android SDK path from environment variables
$sdkPath = $env:ANDROID_SDK_ROOT
if (-not $sdkPath) { $sdkPath = $env:ANDROID_HOME }

if (-not $sdkPath) {
    Write-Host "❌ Android SDK path not set (ANDROID_SDK_ROOT / ANDROID_HOME)." -ForegroundColor Red
    Write-Host "Please set your Android SDK path at the top of this script or set the ANDROID_SDK_ROOT environment variable." -ForegroundColor Yellow
    Write-Host "Typical SDK path: C:\Users\<YourUser>\AppData\Local\Android\sdk" -ForegroundColor Gray
    Write-Host "Press any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

# Add Android tools to PATH for this session
$env:PATH += ";$sdkPath\emulator;$sdkPath\platform-tools"

try {
    # Kill any existing emulator processes first
    Write-Host "🔄 Stopping any existing emulator processes..." -ForegroundColor Yellow
    taskkill /F /IM emulator.exe 2>$null
    Start-Sleep 3

    # Start the emulator with specific settings to avoid black screen
    Write-Host "📱 Launching Pixel_9_API_35 emulator with optimized settings..." -ForegroundColor Cyan
    Write-Host "⚙️  Using: GPU host, no audio, no snapshot, writable system" -ForegroundColor Gray
    & "$sdkPath\emulator\emulator.exe" -avd Pixel_9_API_35 -gpu host -no-audio -no-snapshot-save -writable-system -qemu -enable-whpx

    Write-Host ""
    Write-Host "✅ Emulator process launched (or returned)." -ForegroundColor Green
} catch {
    Write-Host "❌ Error starting emulator: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "🔧 Trying alternative method (software GPU)..." -ForegroundColor Yellow

    try {
        # Try with software rendering if hardware acceleration fails
        & "$sdkPath\emulator\emulator.exe" -avd Pixel_9_API_35 -gpu swiftshader_indirect -no-audio -no-snapshot-save
    } catch {
        Write-Host "❌ Alternative method also failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Press any key to continue..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")