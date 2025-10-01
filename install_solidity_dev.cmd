@echo off
setlocal

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
    echo Node.js is not installed or in PATH.
    timeout /t 10 /nobreak
    exit /b 1
)

where npm >nul 2>&1
if %errorlevel% neq 0 (
    echo npm is not installed or in PATH.
    timeout /t 10 /nobreak
    exit /b 1
)

echo Installing/Upgrading Hardhat...
call npm install -g hardhat

echo Installing/Upgrading Foundry...
where foundryup >nul 2>&1
if %errorlevel% neq 0 (
    echo Foundry not found. Installing via foundryup...
    powershell -Command "iex (iwr -useb https://raw.githubusercontent.com/foundry-rs/foundry/master/foundryup/foundryup.ps1)"
    if %errorlevel% neq 0 (
        echo Warning: Foundry installation failed. You may need to install manually.
    ) else (
        echo Running foundryup to install Foundry tools...
        call foundryup
    )
) else (
    echo Foundry found. Updating...
    call foundryup
)

echo Installing/Upgrading Ganache CLI...
call npm install -g ganache

echo Installing/Upgrading Solidity Compiler...
call npm install -g solc

echo Installing/Upgrading Slither...
%PYTHON_CMD% -m pip install --upgrade slither-analyzer

echo Installing/Upgrading Mythril...
%PYTHON_CMD% -m pip install --upgrade mythril

echo Installing/Upgrading OpenZeppelin CLI...
call npm install -g @openzeppelin/cli

echo Installing/Upgrading Web3.js...
call npm install -g web3

echo Installing/Upgrading Ethers.js...
call npm install -g ethers

echo Installing/Upgrading Prettier Solidity Plugin...
call npm install -g prettier prettier-plugin-solidity

echo Installing/Upgrading Solhint...
call npm install -g solhint

echo Installing/Upgrading Waffle...
call npm install -g ethereum-waffle

echo Cleaning npm cache...
call npm cache clean --force

echo.
echo Installation complete!

timeout /t 10 /nobreak
endlocal
exit /b 0
