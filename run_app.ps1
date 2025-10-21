# Flutter App Runner Script
# Automatically detects available devices and runs the app

Write-Host "🎯 Flutter App Auto-Runner" -ForegroundColor Magenta
Write-Host "=========================" -ForegroundColor Magenta
Write-Host ""

# Check available devices
Write-Host "🔍 Checking available devices..." -ForegroundColor Yellow
$flutterCmd = Get-Command flutter -ErrorAction SilentlyContinue
if (-not $flutterCmd) {
    Write-Host "❌ Flutter CLI not found on PATH." -ForegroundColor Red
    Write-Host "Please install Flutter and add 'flutter\bin' to your PATH, then re-open PowerShell." -ForegroundColor Yellow
    Write-Host "See README_RUN.md in the project root for step-by-step instructions." -ForegroundColor Gray
    Write-Host "Press any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

try {
    $devicesOutput = flutter devices 2>&1
} catch {
    Write-Host "❌ Error running 'flutter devices': $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Parse devices output to find available options
if ($devicesOutput -match "emulator-\d+") {
    Write-Host "📱 Android Emulator detected! Running on Android (first emulator) ..." -ForegroundColor Green
    # pick the first emulator id if available
    $match = Select-String -InputObject $devicesOutput -Pattern "(emulator-\d+)" | Select-Object -First 1
    $deviceId = if ($match) { $match.Matches[0].Groups[1].Value } else { 'emulator-5554' }
    flutter run -d $deviceId
} elseif ($devicesOutput -match "Chrome") {
    Write-Host "🌐 Running on Chrome browser..." -ForegroundColor Cyan
    flutter run -d chrome
} elseif ($devicesOutput -match "Windows") {
    Write-Host "🖥️ Running on Windows desktop..." -ForegroundColor Blue
    flutter run -d windows
} else {
    Write-Host "❌ No suitable devices found. Here are available devices:" -ForegroundColor Red
    flutter devices
    Write-Host ""
    Write-Host "💡 Try running one of these commands manually:" -ForegroundColor Yellow
    Write-Host "   flutter pub get" -ForegroundColor Gray
    Write-Host "   flutter run -d chrome    (for web browser)" -ForegroundColor Gray
    Write-Host "   flutter run -d windows   (for desktop app)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")