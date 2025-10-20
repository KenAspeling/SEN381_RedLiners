# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

CampusLearn is a Flutter application that supports multiple platforms (Android, iOS, Web, Windows, macOS, Linux). The project is currently using the default Flutter counter app template.

## Development Commands

### Running the Application
```bash
flutter run                    # Run on connected device/emulator
flutter run -d chrome          # Run on Chrome (web)
flutter run -d windows         # Run on Windows desktop
flutter run -d macos           # Run on macOS desktop
flutter run -d linux           # Run on Linux desktop
```

### Building
```bash
flutter build apk              # Build Android APK
flutter build appbundle        # Build Android App Bundle
flutter build ios              # Build iOS app (macOS only)
flutter build web              # Build for web deployment
flutter build windows          # Build Windows executable
flutter build macos            # Build macOS app
flutter build linux            # Build Linux executable
```

### Testing & Code Quality
```bash
flutter test                   # Run all tests
flutter test test/widget_test.dart  # Run specific test file
flutter analyze                # Analyze code for issues
dart format .                  # Format all Dart files
```

### Package Management
```bash
flutter pub get                # Install dependencies
flutter pub upgrade            # Upgrade dependencies
flutter pub outdated           # Check for outdated packages
```

### Cleaning & Troubleshooting
```bash
flutter clean                  # Clean build artifacts
flutter pub cache clean        # Clean pub cache
flutter doctor                 # Check Flutter installation
```

## Project Architecture

### Directory Structure
- `/lib/` - Main Dart source code
  - `main.dart` - Application entry point with MyApp widget
- `/android/` - Android platform-specific code
- `/ios/` - iOS platform-specific code  
- `/web/` - Web platform files
- `/windows/`, `/linux/`, `/macos/` - Desktop platform files
- `/test/` - Unit and widget tests
- `/build/` - Build outputs (gitignored)

### Key Configuration Files
- `pubspec.yaml` - Flutter project configuration and dependencies
- `analysis_options.yaml` - Dart linting rules (uses flutter_lints ^5.0.0)

### Flutter Version
The project uses Flutter SDK ^3.9.2 as specified in pubspec.yaml.

## Hot Reload During Development
While `flutter run` is active:
- Press `r` for hot reload (preserves app state)
- Press `R` for hot restart (resets app state)
- Press `q` to quit

## Platform-Specific Notes

### Android
- Minimum SDK version and target SDK are configured in `android/app/build.gradle.kts`
- Package name: `com.example.campuslearn`

### iOS
- Requires Xcode on macOS for building
- Bundle identifier configured in iOS project settings

### Web
- Static files served from `/build/web/` after building
- Supports PWA features out of the box

### Desktop (Windows/macOS/Linux)
- Each platform has its own runner implementation
- Windows uses Win32 API, macOS uses Swift, Linux uses GTK