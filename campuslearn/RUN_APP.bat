@echo off
echo ========================================
echo  CampusLearn - Complete Startup
echo ========================================
echo.

REM Start the backends
echo Starting backends...
call start-backends.bat

REM Wait for backends to start
echo.
echo Waiting for backends to initialize...
timeout /t 8 /nobreak

REM Start the Flutter app
echo.
echo Starting CampusLearn application...
cd /d "%~dp0"

REM Check if release build exists
if exist "build\windows\x64\runner\Release\campuslearn.exe" (
    echo Running release build...
    start "" "build\windows\x64\runner\Release\campuslearn.exe"
) else (
    echo Release build not found. Running in debug mode...
    echo This will take a moment...
    start "CampusLearn - Flutter App" cmd /k "flutter run -d windows"
)

echo.
echo ========================================
echo  CampusLearn is starting!
echo ========================================
echo.
echo Backend windows are running in the background.
echo Close those windows to stop the backends.
echo.
pause
