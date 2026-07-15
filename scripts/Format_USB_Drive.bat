@echo off
:: Check for Admin Rights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ========================================================
    echo ERROR: You MUST right-click this file and choose 
    echo        "RUN AS ADMINISTRATOR" to format the drive!
    echo ========================================================
    echo.
    pause
    exit /b
)

echo ========================================================
echo   Formatting USB PenDrive (Drive E:) to exFAT
echo ========================================================
echo.
echo Forcing dismount and formatting drive E:...
echo.

:: Close Windows Explorer to release locks
taskkill /f /im explorer.exe >nul 2>&1

:: Run direct format with force dismount switch (/X)
format E: /FS:exFAT /Q /X /V:PenDrive /y

:: Restart Windows Explorer
echo.
echo Restarting Windows Explorer...
start explorer.exe

echo.
echo ========================================================
echo   Process finished. Check if drive E: is now accessible!
echo ========================================================
echo.
pause
