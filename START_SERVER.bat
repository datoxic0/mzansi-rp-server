@echo off
title Mzansi RP - Server Launcher
color 0A
setlocal
call "%~dp0resolve_paths.cmd"
echo.
echo  ============================================
echo   MZANSI RP - South African Roleplay Server
echo  ============================================
echo  Install : %INSTALL%
echo  Volume  : %VOLROOT%
echo.

:: ---- STEP 1: Start MariaDB if not running ----
echo [1/3] Checking MariaDB...
if not exist "%MYSQL_EXE%" (
    echo [ERROR] mysqld.exe not found.
    echo [ERROR] Expected portable: %VOLROOT%mariadb-11.4.5-winx64\bin\mysqld.exe
    echo [ERROR] Or fixed: D:\mariadb-11.4.5-winx64\bin\mysqld.exe
    echo.
    pause
    exit /b 1
)
if not exist "%MYSQL_DATADIR%" (
    echo [ERROR] MariaDB data dir missing: %MYSQL_DATADIR%
    echo.
    pause
    exit /b 1
)
netstat -an | findstr :3306 | findstr LISTENING >nul 2>&1
if %errorlevel%==0 (
    echo [OK] MariaDB already running on port 3306
    goto :mariadb_ready
)

echo [INFO] Starting MariaDB...
echo        exe  : %MYSQL_EXE%
echo        data : %MYSQL_DATADIR%
start /b "" "%MYSQL_EXE%" --datadir="%MYSQL_DATADIR%" --port=3306 --bind-address=127.0.0.1

set /a count=0
:wait_db
timeout /t 1 >nul
netstat -an | findstr :3306 | findstr LISTENING >nul 2>&1
if %errorlevel%==0 (
    echo [OK] MariaDB started successfully on port 3306
    goto :mariadb_ready
)
set /a count+=1
if %count% GEQ 15 (
    echo [ERROR] MariaDB failed to start within 15 seconds!
    echo [ERROR] Check %MYSQL_EXE%
    echo.
    pause
    exit /b 1
)
echo [WAIT] Waiting for MariaDB... (%count%/15)
goto :wait_db

:mariadb_ready
echo.

:: ---- STEP 2: Start MTA Server ----
echo [2/3] Starting MTA Server...
if not exist "%MTA_EXE%" (
    echo [ERROR] MTA Server.exe missing: %MTA_EXE%
    echo.
    pause
    exit /b 1
)
cd /d "%ROOT%"
start "" "%MTA_EXE%"
echo [OK] MTA Server launched!

:: ---- STEP 3: Wait until server.log shows ready (after this start), then client ----
echo [3/3] Waiting for server ready signal in server.log (up to 10 min)...
echo       Game port is UDP 22003 (not TCP LISTENING). Full load ~5-7 min.
set "BOOT_STAMP=%TEMP%\mzansi_boot_stamp.txt"
powershell -NoProfile -Command "Get-Date -Format o" > "%BOOT_STAMP%"
set /a scount=0
:wait_srv
timeout /t 2 >nul
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$log='%LOG%';" ^
  "$stamp=Get-Content -LiteralPath '%BOOT_STAMP%' -ErrorAction SilentlyContinue | Select-Object -First 1;" ^
  "$t0=if($stamp){[datetime]::Parse($stamp,[cultureinfo]::InvariantCulture)}else{[datetime]::MinValue};" ^
  "$line=Select-String -LiteralPath $log -Pattern 'ready to accept connections' | Select-Object -Last 1;" ^
  "if(-not $line){ exit 1 };" ^
  "if($line.Line -match '\[(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})\]'){" ^
  "  $ts=[datetime]::ParseExact($Matches[1],'yyyy-MM-dd HH:mm:ss',$null);" ^
  "  if($ts -ge $t0){ exit 0 }" ^
  "};" ^
  "exit 1"
if %errorlevel%==0 (
    echo [OK] Server is ready to accept connections!
    goto :client_ready
)
set /a scount+=1
if %scount% GEQ 300 (
    echo [WARN] Ready line not seen after 600s - launching client anyway...
    echo [WARN] Check the server window for errors.
    goto :client_ready
)
set /a rem=%scount% %% 30
if %rem%==0 echo [WAIT] Still loading... %scount% x2s / 300 x2s
goto :wait_srv

:client_ready
echo.
if exist "%CLIENT%" (
    echo [OK] Launching Multi Theft Auto client...
    start "" "%CLIENT%"
) else (
    echo [WARN] Client not found: %CLIENT%
)
echo.
echo  ============================================
echo   Server + Client are running.
echo   Close this window freely.
echo   MariaDB stays running in background.
echo  ============================================
echo.
timeout /t 5 >nul
