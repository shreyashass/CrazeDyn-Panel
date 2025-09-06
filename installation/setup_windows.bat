@echo off
echo ================================================
echo    CrazeDyn Panel - Windows Setup Script
echo    Minecraft Server Manager Installation
echo ================================================
echo.

:: Check if script is running as administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: This script must be run as Administrator!
    echo Right-click on this file and select "Run as administrator"
    pause
    exit /b 1
)

echo [1/6] Checking system requirements...
echo.

:: Check Windows version
for /f "tokens=4-5 delims=. " %%i in ('ver') do set VERSION=%%i.%%j
echo Windows Version: %VERSION%
if %VERSION% lss 10.0 (
    echo WARNING: Windows 10 or newer is recommended
)

echo.
echo [2/6] Installing Python 3.11...
echo.

:: Download and install Python 3.11 if not exists
python --version >nul 2>&1
if %errorLevel% neq 0 (
    echo Python not found. Downloading Python 3.11...
    powershell -Command "Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.11.8/python-3.11.8-amd64.exe' -OutFile 'python-installer.exe'"
    
    echo Installing Python 3.11...
    python-installer.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
    
    :: Wait for installation to complete
    timeout /t 30 /nobreak >nul
    
    :: Clean up installer
    del python-installer.exe
    
    echo Python installation completed. Please restart this script in a new command prompt.
    pause
    exit /b 0
) else (
    echo Python is already installed.
    python --version
)

echo.
echo [3/6] Installing Java 17...
echo.

:: Check if Java is installed
java -version >nul 2>&1
if %errorLevel% neq 0 (
    echo Java not found. Downloading OpenJDK 17...
    powershell -Command "Invoke-WebRequest -Uri 'https://download.java.net/java/GA/jdk17.0.2/dfd4a8d0985749f896bed50d7138ee7f/8/GPL/openjdk-17.0.2_windows-x64_bin.zip' -OutFile 'openjdk-17.zip'"
    
    echo Extracting Java...
    powershell -Command "Expand-Archive -Path 'openjdk-17.zip' -DestinationPath 'C:\Program Files\Java\' -Force"
    
    :: Set JAVA_HOME environment variable
    setx JAVA_HOME "C:\Program Files\Java\jdk-17.0.2" /M
    setx PATH "%PATH%;C:\Program Files\Java\jdk-17.0.2\bin" /M
    
    :: Clean up
    del openjdk-17.zip
    
    echo Java 17 installed successfully.
) else (
    echo Java is already installed.
    java -version
)

echo.
echo [4/6] Installing Python dependencies...
echo.

:: Upgrade pip
python -m pip install --upgrade pip

:: Install required packages
echo Installing PyQt6...
python -m pip install PyQt6

echo Installing system monitoring tools...
python -m pip install psutil

echo Installing network tools...
python -m pip install requests

echo Installing build tools...
python -m pip install pyinstaller

echo Installing UPnP support...
python -m pip install miniupnpc

echo.
echo [5/6] Setting up Windows Firewall rules...
echo.

:: Add firewall rules for common Minecraft ports
echo Adding firewall rule for Minecraft servers (port range 25565-25575)...
netsh advfirewall firewall add rule name="Minecraft Servers - TCP" dir=in action=allow protocol=TCP localport=25565-25575
netsh advfirewall firewall add rule name="Minecraft Servers - UDP" dir=in action=allow protocol=UDP localport=25565-25575

echo Adding firewall rule for Playit.gg tunnels...
netsh advfirewall firewall add rule name="Playit.gg Tunnel - TCP" dir=in action=allow protocol=TCP localport=2000-2100
netsh advfirewall firewall add rule name="Playit.gg Tunnel - UDP" dir=in action=allow protocol=UDP localport=2000-2100

echo.
echo [6/6] Creating desktop shortcut...
echo.

:: Create desktop shortcut
set DESKTOP=%USERPROFILE%\Desktop
set SCRIPT_DIR=%~dp0

powershell -Command "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%DESKTOP%\CrazeDyn Panel.lnk'); $Shortcut.TargetPath = 'python'; $Shortcut.Arguments = '%SCRIPT_DIR%Main\app\__main__.py'; $Shortcut.WorkingDirectory = '%SCRIPT_DIR%'; $Shortcut.IconLocation = 'python.exe'; $Shortcut.Description = 'CrazeDyn Panel - Minecraft Server Manager'; $Shortcut.Save()"

echo.
echo ================================================
echo           INSTALLATION COMPLETED!
echo ================================================
echo.
echo Setup Summary:
echo ✓ Python 3.11 installed
echo ✓ Java 17 installed  
echo ✓ PyQt6 GUI framework installed
echo ✓ System monitoring tools installed
echo ✓ Network and UPnP tools installed
echo ✓ Windows Firewall configured
echo ✓ Desktop shortcut created
echo.
echo You can now run CrazeDyn Panel by:
echo 1. Double-clicking the desktop shortcut, OR
echo 2. Running: python "%~dp0Main\app\__main__.py"
echo.
echo Press any key to launch the application now...
pause >nul

:: Launch the application
cd /d "%~dp0"
python Main\app\__main__.py