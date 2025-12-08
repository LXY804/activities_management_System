@echo off
cd /d "%~dp0"
title Campus Activity Dev

echo.
echo ========================================
echo Starting Development Environment
echo ========================================
echo.

if not exist "backend" (
    echo ERROR: Backend directory not found
    pause
    exit /b 1
)

if not exist "校园活动管理系统" (
    echo ERROR: Frontend directory not found
    pause
    exit /b 1
)

echo Starting Backend Server...
start "Backend Server" cmd /k "cd /d %~dp0backend && npm run dev"

ping 127.0.0.1 -n 3 >nul

echo Starting Frontend Server...
start "Frontend Server" cmd /k "cd /d %~dp0校园活动管理系统 && npm run dev"

echo.
echo ========================================
echo Both servers are starting in separate windows
echo Please do not close these windows
echo ========================================
echo.
echo Backend:  http://localhost:3000
echo Frontend: http://localhost:5173
echo.
pause
