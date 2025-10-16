@echo off
echo Starting Android Emulator Pixel_9_API_35...
echo Please wait, this may take 30-60 seconds...
echo.

REM Set environment variables for Android SDK
set ANDROID_SDK_ROOT=C:\Users\user\AppData\Local\Android\sdk
set ANDROID_HOME=C:\Users\user\AppData\Local\Android\sdk
set PATH=%PATH%;%ANDROID_SDK_ROOT%\emulator;%ANDROID_SDK_ROOT%\platform-tools

REM Start the emulator
"%ANDROID_SDK_ROOT%\emulator\emulator.exe" -avd Pixel_9_API_35 -no-audio -no-boot-anim

echo.
echo Emulator has stopped.
pause