@echo off
echo ===================================================
echo   Android Emulator Black Screen Fix Script
echo ===================================================
echo.

REM Set Android environment variables
echo Setting Android environment variables...
set ANDROID_SDK_ROOT=C:\Users\user\AppData\Local\Android\sdk
set ANDROID_HOME=C:\Users\user\AppData\Local\Android\sdk
set PATH=%PATH%;%ANDROID_SDK_ROOT%\emulator;%ANDROID_SDK_ROOT%\platform-tools

echo.
echo Killing any existing emulator processes...
taskkill /F /IM emulator.exe >nul 2>&1
taskkill /F /IM qemu-system-x86_64.exe >nul 2>&1

echo.
echo Waiting 3 seconds...
timeout /t 3 >nul

echo.
echo Starting Android Emulator with black screen fixes...
echo Method 1: Hardware GPU with specific settings
echo.

REM Try method 1: Hardware GPU with compatibility settings
"%ANDROID_SDK_ROOT%\emulator\emulator.exe" -avd Pixel_9_API_35 -gpu host -no-audio -no-snapshot-save -no-boot-anim -memory 4096 -partition-size 2048

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Method 1 failed. Trying Method 2: Software rendering...
    echo.
    
    REM Try method 2: Software rendering
    "%ANDROID_SDK_ROOT%\emulator\emulator.exe" -avd Pixel_9_API_35 -gpu swiftshader_indirect -no-audio -no-snapshot-save -no-boot-anim -memory 4096
    
    if %ERRORLEVEL% NEQ 0 (
        echo.
        echo Method 2 failed. Trying Method 3: Legacy mode...
        echo.
        
        REM Try method 3: Legacy compatibility mode
        "%ANDROID_SDK_ROOT%\emulator\emulator.exe" -avd Pixel_9_API_35 -gpu angle_indirect -no-audio -no-snapshot-save -memory 2048
    )
)

echo.
echo Emulator process finished.
pause