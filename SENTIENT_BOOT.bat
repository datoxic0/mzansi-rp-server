@echo off
title Mzansi RP - Sentient Boot
color 0B
setlocal EnableDelayedExpansion
set "HERE=%~dp0"
if "%HERE:~-1%"=="\" set "HERE=%HERE:~0,-1%"

:menu
cls
echo  ============================================
echo   MZANSI RP - SENTIENT BOOT MENU
echo  ============================================
echo   Install : %HERE%\..
echo   Server  : %HERE%
echo  --------------------------------------------
echo   [1] Start Server + Client
echo   [2] Full Restart (DB + Server + Client)
echo   [3] Run Doctor (health checks)
echo   [4] Sync Newest (dry-run)
echo   [5] Sync Newest (live)
echo   [6] Exit
echo  ============================================
set /p CHOICE=Select option [1-6]:

if "%CHOICE%"=="1" goto :start
if "%CHOICE%"=="2" goto :restart
if "%CHOICE%"=="3" goto :doctor
if "%CHOICE%"=="4" goto :sync_dry
if "%CHOICE%"=="5" goto :sync_live
if "%CHOICE%"=="6" goto :end
echo [WARN] Invalid option.
timeout /t 2 >nul
goto :menu

:start
echo.
echo [INFO] Launching START_SERVER.bat ...
call "%HERE%\START_SERVER.bat"
goto :menu

:restart
echo.
echo [INFO] Launching restart_server.bat ...
call "%HERE%\restart_server.bat"
goto :menu

:doctor
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%HERE%\doctor.ps1"
echo.
pause
goto :menu

:sync_dry
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%HERE%\sync_newest.ps1" -DryRun
echo.
pause
goto :menu

:sync_live
echo.
echo [WARN] Live sync copies newer files both ways between peers.
powershell -NoProfile -ExecutionPolicy Bypass -File "%HERE%\sync_newest.ps1"
echo.
pause
goto :menu

:end
exit /b 0
