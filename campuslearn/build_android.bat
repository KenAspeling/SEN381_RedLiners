@echo off
REM Build Android APK for CampusLearn
REM This script builds a production APK that connects to your hosted backend

echo ==========================================
echo CampusLearn - Android APK Builder
echo ==========================================
echo.

REM Check if Railway URL is provided
if "%1"=="" (
    echo ERROR: Please provide your Railway backend URL
    echo.
    echo Usage: build_android.bat YOUR_RAILWAY_URL
    echo Example: build_android.bat https://campuslearn-production.up.railway.app
    echo.
    pause
    exit /b 1
)

set API_URL=%1

echo Building Android APK with production backend...
echo Backend URL: %API_URL%
echo.

REM Clean previous builds
echo [1/3] Cleaning previous builds...
call flutter clean
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Flutter clean failed
    pause
    exit /b 1
)

REM Get dependencies
echo.
echo [2/3] Getting dependencies...
call flutter pub get
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to get dependencies
    pause
    exit /b 1
)

REM Build APK
echo.
echo [3/3] Building APK (this may take a few minutes)...
call flutter build apk --release --dart-define=API_URL=%API_URL%
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Build failed
    pause
    exit /b 1
)

echo.
echo ==========================================
echo [32m✓ APK Built Successfully![0m
echo ==========================================
echo.
echo APK Location:
echo build\app\outputs\flutter-apk\app-release.apk
echo.
echo File Size:
for %%I in (build\app\outputs\flutter-apk\app-release.apk) do echo %%~zI bytes
echo.
echo Next Steps:
echo 1. Test the APK on your Android device
echo 2. Upload to GitHub Releases
echo 3. Share with your users!
echo.
pause
