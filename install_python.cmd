@echo off
setlocal EnableDelayedExpansion

REM Environment setup for unattended operation
set "PYTHON_MANAGER_CONFIRM=false"
set "PYTHON_MANAGER_FIRST_RUN_ENABLED=false"
set "PYTHON_MANAGER_FIRST_RUN_CHECK_LATEST_INSTALL=false"

REM Script configuration
set "SCRIPT_NAME=%~nx0"
set "PYMANAGER_ID=Python.PythonInstallManager"
set "DEFAULT_VERSION=default"

REM Parse command line arguments
set "COMMAND=%~1"

if "%COMMAND%"=="" goto show_help
if /i "%COMMAND%"=="help" goto show_help
if /i "%COMMAND%"=="-h" goto show_help
if /i "%COMMAND%"=="--help" goto show_help
if /i "%COMMAND%"=="/?" goto show_help
if /i "%COMMAND%"=="default" goto install_default
if /i "%COMMAND%"=="install" goto install_version
if /i "%COMMAND%"=="install-multiple" goto install_multiple
if /i "%COMMAND%"=="update" goto update_versions
if /i "%COMMAND%"=="list" goto list_versions
if /i "%COMMAND%"=="list-online" goto list_online
if /i "%COMMAND%"=="uninstall" goto uninstall_version
if /i "%COMMAND%"=="refresh" goto refresh_shortcuts
if /i "%COMMAND%"=="purge" goto purge_all
if /i "%COMMAND%"=="download" goto download_offline
if /i "%COMMAND%"=="setup" goto setup_only

REM Unknown command
echo ERROR: Unknown command '%COMMAND%'
echo.
echo Run '%SCRIPT_NAME% help' for usage information.
exit /b 1

:show_help
echo.
echo +=============================================================+
echo + Python Installation Manager - Automated Installation Script +
echo +=============================================================+
echo.
echo USAGE:
echo   %SCRIPT_NAME% [command] [arguments]
echo.
echo COMMANDS:
echo   default                    Install pymanager and latest Python (recommended)
echo   install ^<version^>          Install specific Python version
echo   install-multiple ^<vers...^> Install multiple Python versions
echo   update [version]           Update Python version(s) (all if no version)
echo   list                       List installed Python versions
echo   list-online                List available Python versions for install
echo   uninstall ^<version^>        Uninstall specific Python version
echo   refresh                    Refresh all shortcuts and aliases
echo   purge                      Remove all Python installations and cache
echo   download ^<version^> [path]  Download Python packages for offline install
echo   setup                      Install pymanager only (no Python)
echo   help                       Show this help message
echo.
echo VERSION FORMATS:
echo   3.13                       Latest Python 3.13.x (64-bit)
echo   3.12                       Latest Python 3.12.x (64-bit)
echo   3.11-arm64                 Latest Python 3.11.x (ARM64)
echo   3.13-32                    Latest Python 3.13.x (32-bit)
echo   default                    Latest recommended Python 3.x
echo.
echo EXAMPLES:
echo   %SCRIPT_NAME% default
echo       Install pymanager and latest Python 3.x
echo.
echo   %SCRIPT_NAME% install 3.13
echo       Install Python 3.13 (latest 3.13.x)
echo.
echo   %SCRIPT_NAME% install 3.12-arm64
echo       Install Python 3.12 for ARM64 processors
echo.
echo   %SCRIPT_NAME% install-multiple 3.13 3.12 3.11
echo       Install Python 3.13, 3.12, and 3.11
echo.
echo   %SCRIPT_NAME% update
echo       Update all installed Python versions
echo.
echo   %SCRIPT_NAME% update 3.13
echo       Update only Python 3.13
echo.
echo   %SCRIPT_NAME% list
echo       Show all installed Python versions
echo.
echo   %SCRIPT_NAME% list-online
echo       Show available Python versions from online repository
echo.
echo   %SCRIPT_NAME% uninstall 3.12
echo       Uninstall Python 3.12
echo.
echo   %SCRIPT_NAME% refresh
echo       Refresh all Python shortcuts and PATH aliases
echo.
echo   %SCRIPT_NAME% purge
echo       Remove all Python installations and cached files
echo.
echo   %SCRIPT_NAME% download 3.13 .\offline-packages
echo       Download Python 3.13 for offline installation
echo.
echo ENVIRONMENT VARIABLES:
echo   PYTHON_MANAGER_SOURCE_URL  Custom package repository URL
echo   PYTHON_MANAGER_CONFIRM     Set to 'false' for full automation
echo   PYTHON_MANAGER_DEBUG       Set to 'true' for debug output
echo.
echo EXIT CODES:
echo   0  Success
echo   1  General error
echo   2  PyManager installation failed
echo   3  Python installation failed
echo   4  Version not specified when required
echo.
echo For more information, visit:
echo   https://docs.python.org/using/windows
echo.
exit /b 0

REM Command: default - Install pymanager and latest Python
:install_default
echo Installing Python Install Manager and latest Python...
echo.
call :ensure_pymanager
if !ERRORLEVEL! neq 0 exit /b !ERRORLEVEL!

echo.
echo Installing latest Python version...
py install -y -qq %DEFAULT_VERSION%
if !ERRORLEVEL! neq 0 (
    echo ERROR: Failed to install Python
    echo Run 'py install -vv default' for detailed error information
    exit /b 3
)

echo.
echo +======================================================================+
echo + SUCCESS: Python Install Manager and latest Python are now installed! +
echo +======================================================================+
echo.
echo You can now use 'py' or 'python' to run Python.
echo Run 'py list' to see installed versions.
echo Run 'py --help' for more commands.
echo.
exit /b 0

REM Command: install - Install specific Python version
:install_version
set "VERSION=%~2"

if "%VERSION%"=="" (
    echo ERROR: Version not specified
    echo.
    echo Usage: %SCRIPT_NAME% install ^<version^>
    echo Example: %SCRIPT_NAME% install 3.13
    exit /b 4
)

echo Installing Python %VERSION%...
echo.
call :ensure_pymanager
if !ERRORLEVEL! neq 0 exit /b !ERRORLEVEL!

echo.
echo Installing Python %VERSION%...
py install -y -qq "%VERSION%"
if !ERRORLEVEL! neq 0 (
    echo ERROR: Failed to install Python %VERSION%
    echo Run 'py install -vv %VERSION%' for detailed error information
    exit /b 3
)

echo.
echo +===============================================+
echo + SUCCESS: Python %VERSION% has been installed! +
echo +===============================================+
echo.
echo Run 'py -V:%VERSION%' to use this version specifically.
echo Run 'py list' to see all installed versions.
echo.
exit /b 0

REM Command: install-multiple - Install multiple Python versions
:install_multiple
shift
set "VERSIONS="
set "VERSION_COUNT=0"

:parse_versions
if "%~1"=="" goto install_all_versions
set "VERSIONS=!VERSIONS! %~1"
set /a VERSION_COUNT+=1
shift
goto parse_versions

:install_all_versions
if %VERSION_COUNT%==0 (
    echo ERROR: No versions specified
    echo.
    echo Usage: %SCRIPT_NAME% install-multiple ^<version1^> ^<version2^> ...
    echo Example: %SCRIPT_NAME% install-multiple 3.13 3.12 3.11
    exit /b 4
)

echo Installing %VERSION_COUNT% Python version(s)...
echo.
call :ensure_pymanager
if !ERRORLEVEL! neq 0 exit /b !ERRORLEVEL!

echo.
echo Installing multiple Python versions:%VERSIONS%
py install -y -qq%VERSIONS%
if !ERRORLEVEL! neq 0 (
    echo ERROR: Failed to install one or more Python versions
    echo Run 'py install -vv%VERSIONS%' for detailed error information
    exit /b 3
)

echo.
echo +===================================================+
echo + SUCCESS: All Python versions have been installed! +
echo +===================================================+
echo.
echo Run 'py list' to see all installed versions.
echo.
exit /b 0

REM Command: update - Update Python version(s)
:update_versions
set "VERSION=%~2"

call :ensure_pymanager
if !ERRORLEVEL! neq 0 exit /b !ERRORLEVEL!

if "%VERSION%"=="" (
    echo Updating all installed Python versions...
    echo.
    py install -y -qq --update
    if !ERRORLEVEL! neq 0 (
        echo ERROR: Failed to update Python versions
        echo Run 'py install -vv --update' for detailed error information
        exit /b 3
    )
    echo.
    echo +=================================================+
    echo + SUCCESS: All Python versions have been updated! +
    echo +=================================================+
    echo.
) else (
    echo Updating Python %VERSION%...
    echo.
    py install -y -qq --update "%VERSION%"
    if !ERRORLEVEL! neq 0 (
        echo ERROR: Failed to update Python %VERSION%
        echo Run 'py install -vv --update %VERSION%' for detailed error information
        exit /b 3
    )
    echo.
    echo +=============================================+
    echo + SUCCESS: Python %VERSION% has been updated! +
    echo +=============================================+
    echo.
)

echo Run 'py list' to see all installed versions.
echo.
exit /b 0

REM Command: list - List installed Python versions
:list_versions
call :ensure_pymanager
if !ERRORLEVEL! neq 0 exit /b !ERRORLEVEL!

echo.
echo Installed Python versions:
echo.
py list
exit /b 0

REM Command: list-online - List available Python versions
:list_online
call :ensure_pymanager
if !ERRORLEVEL! neq 0 exit /b !ERRORLEVEL!

echo.
echo Available Python versions for installation:
echo.
py list --online
exit /b 0

REM Command: uninstall - Uninstall specific Python version
:uninstall_version
set "VERSION=%~2"

if "%VERSION%"=="" (
    echo ERROR: Version not specified
    echo.
    echo Usage: %SCRIPT_NAME% uninstall ^<version^>
    echo Example: %SCRIPT_NAME% uninstall 3.12
    exit /b 4
)

call :ensure_pymanager
if !ERRORLEVEL! neq 0 exit /b !ERRORLEVEL!

echo.
echo Uninstalling Python %VERSION%...
echo.
py uninstall -y -qq "%VERSION%"
if !ERRORLEVEL! neq 0 (
    echo ERROR: Failed to uninstall Python %VERSION%
    echo Run 'py uninstall -vv %VERSION%' for detailed error information
    exit /b 3
)

echo.
echo +=================================================+
echo + SUCCESS: Python %VERSION% has been uninstalled! +
echo +=================================================+
echo.
exit /b 0

REM Command: refresh - Refresh shortcuts and aliases
:refresh_shortcuts
call :ensure_pymanager
if !ERRORLEVEL! neq 0 exit /b !ERRORLEVEL!

echo.
echo Refreshing Python shortcuts and aliases...
echo.
py install --refresh -y -qq
if !ERRORLEVEL! neq 0 (
    echo ERROR: Failed to refresh shortcuts
    echo Run 'py install --refresh -vv' for detailed error information
    exit /b 3
)

echo.
echo +=========================================================+
echo + SUCCESS: All shortcuts and aliases have been refreshed! +
echo +=========================================================+
echo.
exit /b 0

REM Command: purge - Remove all Python installations
:purge_all
call :ensure_pymanager
if !ERRORLEVEL! neq 0 exit /b !ERRORLEVEL!

echo.
echo WARNING: This will remove ALL Python installations and cached files!
echo.
py uninstall --purge -y
if !ERRORLEVEL! neq 0 (
    echo ERROR: Failed to purge Python installations
    echo Run 'py uninstall --purge -vv' for detailed error information
    exit /b 3
)

echo.
echo +======================================================+
echo + SUCCESS: All Python installations have been removed! +
echo +======================================================+
echo.
exit /b 0

REM Command: download - Download Python for offline installation
:download_offline
set "VERSION=%~2"
set "DOWNLOAD_PATH=%~3"

if "%VERSION%"=="" (
    echo ERROR: Version not specified
    echo.
    echo Usage: %SCRIPT_NAME% download ^<version^> [path]
    echo Example: %SCRIPT_NAME% download 3.13 .\offline-packages
    exit /b 4
)

if "%DOWNLOAD_PATH%"=="" set "DOWNLOAD_PATH=.\python-offline-packages"

call :ensure_pymanager
if !ERRORLEVEL! neq 0 exit /b !ERRORLEVEL!

echo.
echo Downloading Python %VERSION% to %DOWNLOAD_PATH%...
echo.
py install -y --download="%DOWNLOAD_PATH%" "%VERSION%"
if !ERRORLEVEL! neq 0 (
    echo ERROR: Failed to download Python %VERSION%
    echo Run 'py install -vv --download="%DOWNLOAD_PATH%" %VERSION%' for details
    exit /b 3
)

echo.
echo +================================================+
echo + SUCCESS: Python %VERSION% has been downloaded! +
echo +================================================+
echo.
echo Offline package location: %DOWNLOAD_PATH%
echo To install offline, use: py install -s %DOWNLOAD_PATH% %VERSION%
echo.
exit /b 0

REM Command: setup - Install pymanager only
:setup_only
echo Installing Python Install Manager only...
echo.
call :ensure_pymanager
if !ERRORLEVEL! neq 0 exit /b !ERRORLEVEL!

echo.
echo +===================================================+
echo + SUCCESS: Python Install Manager is now installed! +
echo +===================================================+
echo.
echo Run '%SCRIPT_NAME% install ^<version^>' to install Python.
echo Run '%SCRIPT_NAME% help' for all available commands.
echo.
exit /b 0

REM Internal Function: ensure_pymanager
REM Ensures Python Install Manager is installed via winget
:ensure_pymanager
echo Checking for Python Install Manager...

REM Check if py.exe is already available
where py.exe >nul 2>&1
if !ERRORLEVEL! equ 0 (
    echo Python Install Manager is already installed.
    
    REM Suppress first-run by running a simple command
    py -y list >nul 2>&1
    
    exit /b 0
)

echo Python Install Manager not found. Installing via winget...
echo.

REM Check if winget is available
where winget.exe >nul 2>&1
if !ERRORLEVEL! neq 0 (
    echo ERROR: winget is not installed or not in PATH
    echo.
    echo Please install the App Installer from the Microsoft Store:
    echo https://www.microsoft.com/p/app-installer/9nblggh4nns1
    exit /b 2
)

REM Install pymanager via winget
echo Installing %PYMANAGER_ID%...
winget install --id %PYMANAGER_ID% --silent --accept-package-agreements --accept-source-agreements
if !ERRORLEVEL! neq 0 (
    echo ERROR: Failed to install Python Install Manager via winget
    echo.
    echo Please try installing manually:
    echo   winget install --id %PYMANAGER_ID%
    exit /b 2
)

REM Verify installation
where py.exe >nul 2>&1
if !ERRORLEVEL! neq 0 (
    echo WARNING: py.exe not found in PATH after installation
    echo You may need to restart your terminal or add it to PATH manually.
    echo.
    echo Try closing and reopening this terminal, then run:
    echo   %SCRIPT_NAME% %COMMAND%
    exit /b 2
)

echo Python Install Manager installed successfully!

REM Suppress first-run by running a simple command with -y flag
echo Initializing Python Install Manager...
py -y list >nul 2>&1

exit /b 0
