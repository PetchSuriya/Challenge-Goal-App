# Flutter App Runner Script
# Automatically detects available devices and runs the app

Write-Host "🎯 Flutter App Auto-Runner" -ForegroundColor Magenta
Write-Host "=========================" -ForegroundColor Magenta
Write-Host ""

# Check available devices
Write-Host "🔍 Checking available devices..." -ForegroundColor Yellow
$devices = flutter devices

# Parse devices output to find available options
if ($devices -match "emulator-\d+") {
    Write-Host "📱 Android Emulator detected! Running on Android..." -ForegroundColor Green
    flutter run -d emulator-5554
} elseif ($devices -match "Chrome") {
    Write-Host "🌐 Running on Chrome browser..." -ForegroundColor Cyan
    flutter run -d chrome
} elseif ($devices -match "Windows") {
    Write-Host "🖥️ Running on Windows desktop..." -ForegroundColor Blue
    flutter run -d windows
} else {
    Write-Host "❌ No suitable devices found. Here are available devices:" -ForegroundColor Red
    flutter devices
    Write-Host ""
    Write-Host "💡 Try running one of these commands manually:" -ForegroundColor Yellow
    Write-Host "   flutter run -d chrome    (for web browser)" -ForegroundColor Gray
    Write-Host "   flutter run -d windows   (for desktop app)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")