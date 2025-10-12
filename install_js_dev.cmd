@echo off

cd /d "%SystemDrive%" >nul 2>&1
if %errorlevel% neq 0 (
    echo Failed to change to %SystemDrive%.  Error code: %errorlevel%
)

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo This script requires administrator privileges.
    echo Please right-click and select "Run as administrator".
    timeout /t 10 /nobreak
    exit /b 1
)

bun --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Bun is not installed or in PATH.
    echo Install from: https://bun.com
    timeout /t 10 /nobreak
    exit /b 1
)

echo Updating Bun...
bun upgrade

echo Installing and/or updating global development tools...
bun add -g eslint
bun add -g prettier
bun add -g jest
bun add -g live-server
bun update -g --latest eslint
bun update -g --latest prettier
bun update -g --latest jest
bun update -g --latest live-server

timeout /t 10 /nobreak
exit /b 0
