Running the Challenge-Goal-App (Windows - PowerShell)

This file contains concise steps to run the Flutter app locally on Windows using PowerShell.

Prerequisites
- Flutter SDK (stable) installed and `flutter` on PATH. See https://flutter.dev/docs/get-started/install/windows
- Git installed (required by Flutter)
- For Android: Android Studio + SDK + AVD (or a physical device)
- For Windows desktop: Visual Studio with "Desktop development with C++" workload

Quick start (PowerShell)
1. Open PowerShell and change to the project root (where `pubspec.yaml` is):

```powershell
cd C:\Users\Admin\Desktop\Project\Challenge-Goal-App
```

2. Verify Flutter is available:

```powershell
flutter --version
flutter doctor -v
```

3. Install dependencies:

```powershell
flutter pub get
```

4. List available devices:

```powershell
flutter devices
```

5. Run the app (choose the target):

- First available device:
```powershell
flutter run
```

- Chrome (web):
```powershell
flutter run -d chrome
```

- Windows desktop:
```powershell
flutter run -d windows
```

- Specific Android emulator/device (example):
```powershell
flutter run -d emulator-5554
```

Helper scripts in this repo
- `run_app.ps1` — attempts to auto-detect a device and run the app. It requires `flutter` on PATH.
- `run_emulator.ps1` — starts the `Pixel_9_API_35` AVD (edit the script to set your SDK path or set `ANDROID_SDK_ROOT` in your environment).

Troubleshooting
- If `flutter` is not recognized: add `C:\src\flutter\bin` (or your install path) to your PATH and reopen PowerShell.
- Accept Android licenses:

```powershell
flutter doctor --android-licenses
```

- If desktop build for Windows is missing: enable and install required components (Visual Studio C++ workload). Run:

```powershell
flutter config --enable-windows-desktop
flutter doctor -v
```

If you run into errors, copy the output of `flutter doctor -v` and the failing `flutter run` output and paste them here so I can help diagnose.
