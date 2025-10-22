@echo off
echo ========================================
echo  CampusLearn Backend Starter
echo ========================================
echo.

REM Check if running as administrator
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Running with administrator privileges...
) else (
    echo Note: Not running as administrator. Some features may be limited.
)

echo.
echo Starting backends...
echo.

REM Start ASP.NET Backend (Port 5000)
echo [1/2] Starting ASP.NET Backend on port 5000...
cd /d "%~dp0backend"
start "CampusLearn - ASP.NET Backend" cmd /k "echo ASP.NET Backend (Port 5000) && echo. && dotnet run"

REM Wait a moment
timeout /t 2 /nobreak >nul

REM Start Python Chatbot (Port 5001)
echo [2/2] Starting Python Chatbot on port 5001...
cd /d "%~dp0CHATBOT TEMP"
start "CampusLearn - AI Chatbot" cmd /k "echo AI Chatbot Backend (Port 5001) && echo. && set GEMINI_API_KEY=AIzaSyBMgbtcIqCQnDuFZbZVNnYp1IqGPajXSTQ && python app.py"

echo.
echo ========================================
echo  Both backends starting in new windows!
echo ========================================
echo.
echo ASP.NET Backend: http://localhost:5000
echo AI Chatbot:      http://localhost:5001
echo.
echo Press any key to close this window...
pause >nul
