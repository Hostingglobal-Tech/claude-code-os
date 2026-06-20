@echo off
setlocal
title AICODE-OS USB Maker

if "%AICODE_OS_CMD_TEST%"=="1" exit /b 0

echo.
echo ==========================================
echo   AICODE-OS USB Maker
echo ==========================================
echo.
echo This helper starts the Windows USB installer.
echo.
echo Important:
echo - Ventoy install can erase the selected USB.
echo - The installer blocks the Windows system disk and C: disk.
echo - Select USB flash drive only.
echo.
pause

net session >nul 2>&1
if %errorlevel% neq 0 (
  echo.
  echo Requesting administrator permission...
  powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
  exit /b
)

cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install-cco-on-ventoy.ps1"

echo.
echo Finished. Press any key to close this window.
pause >nul
