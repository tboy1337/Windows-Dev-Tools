@echo off
setlocal enabledelayedexpansion

cd /d "%SystemDrive%" >nul 2>&1
if %errorlevel% neq 0 (
    echo Failed to change to %SystemDrive%.  Error code: %errorlevel%
)

net session >nul 2>&1
if %errorlevel% equ 0 (
    echo This script is intended to be run as a user. Please run without administrator privileges.
    timeout /t 10 /nobreak
    exit /b 1
)

echo ========================================
echo Modern Solidity Development Tools
echo ========================================
echo.

set PYTHON_CMD=
py --version >nul 2>&1
if %errorlevel% equ 0 (
    set PYTHON_CMD=py
) else (
    python --version >nul 2>&1
    if %errorlevel% equ 0 (
        set PYTHON_CMD=python
    ) else (
        echo ERROR: Python is not installed or not in PATH.
        echo Please install Python and ensure it's added to your PATH.
        timeout /t 10 /nobreak
        exit /b 1
    )
)

%PYTHON_CMD% -m pip --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Pip is not installed or not in PATH.
    timeout /t 10 /nobreak
    exit /b 1
)

where node >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Node.js is not installed or in PATH.
    timeout /t 10 /nobreak
    exit /b 1
)

where npm >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: npm is not installed or in PATH.
    timeout /t 10 /nobreak
    exit /b 1
)

echo [1/6] Installing Foundry...
echo.
echo Detecting latest Foundry version...
set FOUNDRY_VERSION=
for /f "delims=" %%i in ('curl -Ls -o nul -w "%%{url_effective}" https://github.com/foundry-rs/foundry/releases/latest') do set FOUNDRY_LATEST_URL=%%i
if %errorlevel% neq 0 (
    echo ERROR: Failed to detect latest Foundry version.
    echo Please check your internet connection and try again.
    goto :skip_foundry
)

for %%a in ("!FOUNDRY_LATEST_URL!") do set FOUNDRY_VERSION=%%~nxa
if "!FOUNDRY_VERSION!"=="" (
    echo ERROR: Failed to parse Foundry version from URL.
    goto :skip_foundry
)

echo Latest Foundry version: !FOUNDRY_VERSION!
echo.

set FOUNDRY_URL=https://github.com/foundry-rs/foundry/releases/download/!FOUNDRY_VERSION!/foundry_!FOUNDRY_VERSION!_win32_amd64.zip
set FOUNDRY_DIR=%LOCALAPPDATA%\Programs\Foundry
set FOUNDRY_BIN=%FOUNDRY_DIR%\bin
set FOUNDRY_TEMP=%TEMP%\foundry_install_%RANDOM%_%RANDOM%

if not exist "%FOUNDRY_BIN%" mkdir "%FOUNDRY_BIN%" >nul 2>&1

set CURRENT_VERSION=
if exist "%FOUNDRY_BIN%\forge.exe" (
    set "VERSION_TEMP=%TEMP%\foundry_version_%RANDOM%.txt"
    "%FOUNDRY_BIN%\forge.exe" --version > "!VERSION_TEMP!" 2>&1
    if %errorlevel% equ 0 (
        for /f "tokens=3 delims= " %%v in ('findstr /C:"forge Version:" "!VERSION_TEMP!"') do set CURRENT_VERSION=%%v
        del /F /Q "!VERSION_TEMP!" >nul 2>&1
        if not "!CURRENT_VERSION!"=="" (
            for /f "tokens=2 delims=-" %%t in ("!CURRENT_VERSION!") do set CURRENT_VERSION_TAG=%%t
            if "!CURRENT_VERSION_TAG!"=="" set CURRENT_VERSION_TAG=!CURRENT_VERSION!
            echo Current installed version: !CURRENT_VERSION_TAG!
            echo.
            if "!CURRENT_VERSION_TAG!"=="!FOUNDRY_VERSION!" (
                echo Foundry !FOUNDRY_VERSION! is already up to date.
                goto :skip_foundry
            )
            echo Upgrading from !CURRENT_VERSION_TAG! to !FOUNDRY_VERSION!...
            echo.
        )
    ) else (
        if exist "!VERSION_TEMP!" del /F /Q "!VERSION_TEMP!" >nul 2>&1
    )
    if exist "%FOUNDRY_BIN%\anvil.exe" del /F /Q "%FOUNDRY_BIN%\anvil.exe" >nul 2>&1
    if exist "%FOUNDRY_BIN%\cast.exe" del /F /Q "%FOUNDRY_BIN%\cast.exe" >nul 2>&1
    if exist "%FOUNDRY_BIN%\chisel.exe" del /F /Q "%FOUNDRY_BIN%\chisel.exe" >nul 2>&1
    if exist "%FOUNDRY_BIN%\forge.exe" del /F /Q "%FOUNDRY_BIN%\forge.exe" >nul 2>&1
) else (
    echo Installing Foundry !FOUNDRY_VERSION!...
    echo.
)

echo Downloading Foundry !FOUNDRY_VERSION!...
curl -L -o "%FOUNDRY_TEMP%.zip" "!FOUNDRY_URL!" >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Failed to download Foundry. Error code: %errorlevel%
    goto :skip_foundry
)

echo Extracting Foundry...
powershell -Command "Expand-Archive -Path '%FOUNDRY_TEMP%.zip' -DestinationPath '%FOUNDRY_TEMP%' -Force" >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Failed to extract Foundry archive.
    goto :cleanup_foundry
)

echo Installing Foundry executables...
copy /Y "%FOUNDRY_TEMP%\anvil.exe" "%FOUNDRY_BIN%\" >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Failed to install anvil.exe. Error code: %errorlevel%
    goto :cleanup_foundry
)
copy /Y "%FOUNDRY_TEMP%\cast.exe" "%FOUNDRY_BIN%\" >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Failed to install cast.exe. Error code: %errorlevel%
    goto :cleanup_foundry
)
copy /Y "%FOUNDRY_TEMP%\chisel.exe" "%FOUNDRY_BIN%\" >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Failed to install chisel.exe. Error code: %errorlevel%
    goto :cleanup_foundry
)
copy /Y "%FOUNDRY_TEMP%\forge.exe" "%FOUNDRY_BIN%\" >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Failed to install forge.exe. Error code: %errorlevel%
    goto :cleanup_foundry
)

echo Verifying installation...
if exist "%FOUNDRY_BIN%\forge.exe" (
    "%FOUNDRY_BIN%\forge.exe" --version
) else (
    echo ERROR: forge.exe not found after installation.
    goto :cleanup_foundry
)

echo Adding Foundry to User PATH permanently...
powershell -Command "$path = [Environment]::GetEnvironmentVariable('Path', 'User'); if ($path -notlike '*%FOUNDRY_BIN%*') { [Environment]::SetEnvironmentVariable('Path', $path + ';%FOUNDRY_BIN%', 'User'); Write-Host 'Foundry added to PATH' } else { Write-Host 'Foundry already in PATH' }" >nul 2>&1

set "PATH=%PATH%;%FOUNDRY_BIN%"

echo Foundry !FOUNDRY_VERSION! installed successfully!
echo.

:cleanup_foundry
if exist "%FOUNDRY_TEMP%.zip" del /F /Q "%FOUNDRY_TEMP%.zip" >nul 2>&1
if exist "%FOUNDRY_TEMP%" rmdir /S /Q "%FOUNDRY_TEMP%" >nul 2>&1

:skip_foundry

echo [2/7] Installing Hardhat...
call npm install -g hardhat
echo.

echo [3/7] Installing Aderyn...
%PYTHON_CMD% -m pip install --upgrade aderyn
echo.

echo [4/7] Installing solc-select...
%PYTHON_CMD% -m pip install --upgrade solc-select
echo.

echo [5/7] Installing Code Quality Tools...
call npm install -g prettier prettier-plugin-solidity
echo.

echo [6/6] Installing Solhint...
call npm install -g solhint
echo.

echo [7/7] Installing Wake...
%PYTHON_CMD% -m pip install --upgrade eth-wake
echo.

echo Cleaning npm cache...
call npm cache clean --force
echo.

echo ========================================
echo Installation Complete!
echo ========================================
echo.

timeout /t 15 /nobreak
endlocal
exit /b 0
