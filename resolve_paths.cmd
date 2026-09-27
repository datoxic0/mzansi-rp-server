@echo off
:: ============================================================
:: resolve_paths.cmd - Portable path resolution for Mzansi RP
:: CALL this from START_SERVER.bat / restart_server.bat
:: Sets: ROOT INSTALL VOLROOT CLIENT LOG MYSQL_EXE MYSQL_DATADIR
:: No hardcoded drive letters for portable assets.
:: ============================================================
set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"

:: INSTALL = parent of server\
for %%I in ("%ROOT%\..") do set "INSTALL=%%~fI"
:: VOLROOT = volume root two levels above install
:: e.g. E:\Games Library\GTA SA MP - Copy -> E:\Games Library -> E:\
for %%I in ("%INSTALL%\..\..") do set "VOLROOT=%%~fI"
if not "%VOLROOT:~-1%"=="\" set "VOLROOT=%VOLROOT%\"

set "LOG=%ROOT%\mods\deathmatch\logs\server.log"
set "CLIENT=%INSTALL%\Multi Theft Auto.exe"

:: MariaDB data lives at volume root (portable with the drive)
set "MYSQL_DATADIR=%VOLROOT%mariadb-11.4.5-winx64\data"

:: Resolve mysqld.exe: volume-root first, then fixed local candidates, then drive scan
set "MYSQL_EXE="
if exist "%VOLROOT%mariadb-11.4.5-winx64\bin\mysqld.exe" set "MYSQL_EXE=%VOLROOT%mariadb-11.4.5-winx64\bin\mysqld.exe"
if defined MYSQL_EXE goto :mysql_ok
if exist "D:\mariadb-11.4.5-winx64\bin\mysqld.exe" set "MYSQL_EXE=D:\mariadb-11.4.5-winx64\bin\mysqld.exe"
if defined MYSQL_EXE goto :mysql_ok
if exist "C:\mariadb-11.4.5-winx64\bin\mysqld.exe" set "MYSQL_EXE=C:\mariadb-11.4.5-winx64\bin\mysqld.exe"
if defined MYSQL_EXE goto :mysql_ok
for %%L in (D E F G C H I J) do (
    if not defined MYSQL_EXE if exist "%%L:\mariadb-11.4.5-winx64\bin\mysqld.exe" set "MYSQL_EXE=%%L:\mariadb-11.4.5-winx64\bin\mysqld.exe"
)
:mysql_ok

:: MTA server binary next to this script
set "MTA_EXE=%ROOT%\MTA Server.exe"
exit /b 0
