@echo off
REM Database Export Script for CampusLearn (Windows)
REM This script exports your local PostgreSQL database to a file
REM that can be imported into Railway or other hosting platforms

echo ===================================
echo CampusLearn Database Export Script
echo ===================================
echo.

REM Database connection details (from appsettings.json)
set DB_HOST=localhost
set DB_PORT=5432
set DB_NAME=campuslearn
set DB_USER=postgres
set DB_PASSWORD=@sp3l1nG

REM Output file with timestamp
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /format:list') do set datetime=%%I
set OUTPUT_FILE=campuslearn_export_%datetime:~0,8%_%datetime:~8,6%.sql

echo Exporting database: %DB_NAME%
echo Output file: %OUTPUT_FILE%
echo.

REM Set password environment variable to avoid prompt
set PGPASSWORD=%DB_PASSWORD%

REM Export database using pg_dump
REM Make sure PostgreSQL bin folder is in PATH or use full path:
REM "C:\Program Files\PostgreSQL\15\bin\pg_dump.exe"
pg_dump -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d %DB_NAME% --clean --if-exists --no-owner --no-acl -f %OUTPUT_FILE%

if %ERRORLEVEL% EQU 0 (
    echo.
    echo [32m✓ Database exported successfully![0m
    echo File: %OUTPUT_FILE%
    echo.
    echo Next steps:
    echo 1. Upload this file to Railway PostgreSQL
    echo 2. Run: psql [your-railway-connection-string] ^< %OUTPUT_FILE%
) else (
    echo.
    echo [31m✗ Export failed.[0m
    echo Make sure PostgreSQL is running and pg_dump is in your PATH.
    echo Try adding PostgreSQL bin folder to PATH or use full path.
    pause
    exit /b 1
)

REM Clear password variable
set PGPASSWORD=

pause
