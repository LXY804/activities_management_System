# PowerShell script to start development servers
Write-Host ""
Write-Host "========================================"
Write-Host "Starting Development Environment"
Write-Host "========================================"
Write-Host ""

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$backendDir = Join-Path $scriptPath "backend"
$frontendDir = Join-Path $scriptPath "校园活动管理系统"

if (-not (Test-Path $backendDir)) {
    Write-Host "ERROR: Backend directory not found: $backendDir" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

if (-not (Test-Path $frontendDir)) {
    Write-Host "ERROR: Frontend directory not found: $frontendDir" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Starting Backend Server..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$backendDir'; npm run dev" -WindowStyle Normal

Start-Sleep -Seconds 2

Write-Host "Starting Frontend Server..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$frontendDir'; npm run dev" -WindowStyle Normal

Write-Host ""
Write-Host "========================================"
Write-Host "Both servers are starting in separate windows"
Write-Host "Please do not close these windows"
Write-Host "========================================"
Write-Host ""
Write-Host "Backend:  http://localhost:3000" -ForegroundColor Cyan
Write-Host "Frontend: http://localhost:5173" -ForegroundColor Cyan
Write-Host ""
Read-Host "Press Enter to exit"

