@echo off
setlocal enabledelayedexpansion

set "TEMP_FILE=%TEMP%\pip_outdated_%RANDOM%_%RANDOM%.txt"

cd /d "%SystemDrive%" >nul 2>&1
if %errorlevel% neq 0 (
    echo Failed to change to %SystemDrive%.  Error code: %errorlevel%
)

echo +===========================+
echo + Updating All Pip Packages +
echo +===========================+
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

echo Updating pip...
%PYTHON_CMD% -m pip install --upgrade pip >nul 2>&1
if %errorlevel% neq 0 (
    echo WARNING: Failed to update pip.  Error code: %errorlevel%
)



echo Updating setuptools...
%PYTHON_CMD% -m pip install --upgrade setuptools >nul 2>&1
if %errorlevel% neq 0 (
    echo WARNING: Failed to update setuptools.  Error code: %errorlevel%
)

echo Updating wheel...
%PYTHON_CMD% -m pip install --upgrade wheel >nul 2>&1
if %errorlevel% neq 0 (
    echo WARNING: Failed to update wheel.  Error code: %errorlevel%
)

set /a pass=0
set /a max_passes=10
set /a total_updated=0
set /a total_failed=0

:update_loop
set /a pass+=1

echo.
echo +====================================+
echo +        Update Pass !pass! of !max_passes!         +
echo +====================================+
echo.

echo Getting list of outdated packages...

%PYTHON_CMD% -m pip list --outdated > "%TEMP_FILE%" 2>&1
if %errorlevel% neq 0 (
    echo WARNING: Failed to get list of outdated packages.  Error code: %errorlevel%
    if exist "%TEMP_FILE%" del "%TEMP_FILE%" >nul 2>&1
    timeout /t 10 /nobreak
    exit /b 1
)

if not exist "%TEMP_FILE%" (
    echo No outdated packages found.
    goto final_summary
)

set /a count=0
for /f "skip=2 tokens=1 delims= " %%i in ('type "%TEMP_FILE%"') do (
    if not "%%i"=="" (
        if not "%%i"=="Package" (
            if not "%%i"=="----------" (
                set /a count+=1
            )
        )
    )
)

if !count! equ 0 (
    echo All packages are already up to date.
    del "%TEMP_FILE%" >nul 2>&1
    goto final_summary
)

echo Found !count! outdated package(s).
echo.

echo Outdated packages:
echo ==================
for /f "skip=2 tokens=1 delims= " %%i in ('type "%TEMP_FILE%"') do (
    if not "%%i"=="" (
        if not "%%i"=="Package" (
            if not "%%i"=="----------" (
                echo %%i
            )
        )
    )
)

echo.
echo Starting package updates...
echo ===========================

set /a updated=0
set /a failed=0

for /f "skip=2 tokens=1 delims= " %%i in ('type "%TEMP_FILE%"') do (
    if not "%%i"=="" (
        if not "%%i"=="Package" (
            if not "%%i"=="----------" (
                echo.
                echo Updating %%i...
                %PYTHON_CMD% -m pip install --upgrade %%i >nul 2>&1
                if %errorlevel% neq 0 (
                    echo ERROR: Failed to update %%i.  Error code: %errorlevel%
                    set /a failed+=1
                    set /a total_failed+=1
                ) else (
                    echo SUCCESS: Updated %%i
                    set /a updated+=1
                    set /a total_updated+=1
                )
            )
        )
    )
)

del "%TEMP_FILE%" >nul 2>&1
if %errorlevel% neq 0 (
    echo Failed to delete temporary file: %TEMP_FILE%.  Error code: %errorlevel%
)

echo.
echo Pass !pass! Summary:
echo ====================
echo Successfully updated: !updated! packages.
echo Failed to update: !failed! packages.

if !pass! geq !max_passes! (
    echo.
    echo Maximum number of passes ^(!max_passes!^) reached.
    echo Some packages may still be outdated due to complex dependencies.
    goto final_summary
)

if !updated! gtr 0 (
    echo.
    echo Some packages were updated. Checking for more outdated packages...
    goto update_loop
)

:final_summary
echo.
echo +======================+
echo + Final Update Summary +
echo +======================+
echo Total passes completed: !pass!
echo Total packages updated: !total_updated!
echo Total packages failed: !total_failed!
echo.

if !total_failed! neq 0 (
    echo Some packages failed to update. This could be due to:
    echo - Permission issues ^(try running as administrator^)
    echo - Package conflicts or dependencies
    echo - Network connectivity issues
    echo.
)

echo Update process completed.

timeout /t 10 /nobreak
exit /b 0
