@echo off
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "Restore_USB_Drive.ps1"
