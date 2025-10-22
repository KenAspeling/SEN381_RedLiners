@echo off
REM Build Windows Desktop App for CampusLearn
REM This script builds a production Windows executable that connects to your hosted backend

echo ==========================================
echo CampusLearn - Windows Desktop Builder
echo ==========================================
echo.

REM Check if Railway URL is provided
if "%1"=="" (
    echo ERROR: Please provide your Railway backend URL
    echo.
    echo Usage: build_windows.bat YOUR_RAILWAY_URL
    echo Example: build_windows.bat https://campuslearn-production.up.railway.app
    echo.
    pause
    exit /b 1
)

set API_URL=%1

echo Building Windows Desktop app with production backend...
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

REM Build Windows
echo.
echo [3/3] Building Windows app (this may take a few minutes)...
call flutter build windows --release --dart-define=API_URL=%API_URL%
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Build failed
    pause
    exit /b 1
)

REM Create distribution folder
echo.
echo [Bonus] Creating distribution package...
set DIST_FOLDER=CampusLearn-Windows-v1.0.0
if exist %DIST_FOLDER% (
    echo Removing old distribution folder...
    rmdir /s /q %DIST_FOLDER%
)

mkdir %DIST_FOLDER%

echo Copying files...
xcopy /E /I /Y build\windows\x64\runner\Release %DIST_FOLDER%

echo.
echo ==========================================
echo [32m✓ Windows Build Completed Successfully![0m
echo ==========================================
echo.
echo Distribution Folder:
echo %DIST_FOLDER%\
echo.
echo Contents:
dir /b %DIST_FOLDER%
echo.
echo Next Steps:
echo 1. Test campuslearn.exe in the %DIST_FOLDER% folder
echo 2. Zip the %DIST_FOLDER% folder
echo 3. Upload to GitHub Releases
echo 4. Share with your users!
echo.
echo To create a ZIP:
echo Right-click %DIST_FOLDER% folder ^> Send to ^> Compressed (zipped) folder
echo.
pause
