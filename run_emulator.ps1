# Android Emulator Helper Script with Black Screen Fix
# Usage: .\run_emulator.ps1

Write-Host "🚀 Starting Android Emulator Pixel_9_API_35..." -ForegroundColor Green
Write-Host "⏰ Please wait, this may take 30-60 seconds..." -ForegroundColor Yellow
Write-Host ""

# Set environment variables for Android SDK
$env:ANDROID_SDK_ROOT = "C:\Users\user\AppData\Local\Android\sdk"
$env:ANDROID_HOME = "C:\Users\user\AppData\Local\Android\sdk"

# Add Android tools to PATH for this session
$env:PATH += ";$env:ANDROID_SDK_ROOT\emulator;$env:ANDROID_SDK_ROOT\platform-tools"

try {
    # Kill any existing emulator processes first
    Write-Host "🔄 Stopping any existing emulator processes..." -ForegroundColor Yellow
    taskkill /F /IM emulator.exe 2>$null
    Start-Sleep 3
} catch {
    # Ignore if no processes to kill
}

    # Start the emulator with specific settings to avoid black screen
    Write-Host "📱 Launching Pixel 9 API 35 emulator with optimized settings..." -ForegroundColor Cyan
    Write-Host "⚙️  Using: GPU host, no audio, writable system" -ForegroundColor Gray
    
    & "$env:ANDROID_SDK_ROOT\emulator\emulator.exe" -avd Pixel_9_API_35 -gpu host -no-audio -no-snapshot-save -writable-system -qemu -enable-whpx
    
    Write-Host ""
    Write-Host "✅ Emulator process has finished." -ForegroundColor Green
} catch {
    Write-Host "❌ Error starting emulator: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "🔧 Trying alternative method..." -ForegroundColor Yellow
    
    try {
        # Try with software rendering if hardware acceleration fails
        & "$env:ANDROID_SDK_ROOT\emulator\emulator.exe" -avd Pixel_9_API_35 -gpu swiftshader_indirect -no-audio -no-snapshot-save
    } catch {
        Write-Host "❌ Alternative method also failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Press any key to continue..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")