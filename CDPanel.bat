@echo off
echo Starting CrazeDyn Panel...
if exist "crazeDynPanel.exe" (
    echo [INFO] Running executable version...
    start "" "crazeDynPanel.exe"
) else (
    echo [INFO] Running Python version...
    python app\__main__.py
)
pause