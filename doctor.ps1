#Requires -Version 5.1
<#
.SYNOPSIS
  Mzansi RP environment doctor - checks portable install health.
.DESCRIPTION
  Exit code 0 = healthy (warnings allowed). Exit 1 = critical failure.
#>
[CmdletBinding()]
param(
    [switch]$Json
)

$ErrorActionPreference = 'SilentlyContinue'
$checks = @()

function Add-Check {
    param([string]$Name, [string]$Status, [string]$Detail)
    $script:checks += [pscustomobject]@{ name = $Name; status = $Status; detail = $Detail }
    $color = switch ($Status) {
        'OK'       { 'Green' }
        'WARNING'  { 'Yellow' }
        'CRITICAL' { 'Red' }
        default    { 'Gray' }
    }
    Write-Host ("[{0,-8}] {1} - {2}" -f $Status, $Name, $Detail) -ForegroundColor $color
}

# --- Locate install root (this script lives in server\) ---
$ServerRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $ServerRoot) { $ServerRoot = $PSScriptRoot }
$InstallRoot = Split-Path -Parent $ServerRoot
$VolRoot = Split-Path -Parent (Split-Path -Parent $InstallRoot)
if ($VolRoot -and -not $VolRoot.EndsWith('\')) { $VolRoot += '\' }

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host " MZANSI RP - SENTIENT DOCTOR" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host " Install : $InstallRoot"
Write-Host " Server  : $ServerRoot"
Write-Host " Volume  : $VolRoot"
Write-Host ""

# 1. Drive identity
$marker = Join-Path $InstallRoot '.drive_identity'
if (Test-Path $marker) {
    $id = Get-Content $marker -Raw
    Add-Check 'Drive identity' 'OK' ".drive_identity present"
} else {
    Add-Check 'Drive identity' 'WARNING' '.drive_identity missing at install root'
}

# 2. Drive config
$cfg = Join-Path $InstallRoot 'drive_config.json'
if (Test-Path $cfg) {
    try {
        $null = Get-Content $cfg -Raw | ConvertFrom-Json
        Add-Check 'drive_config.json' 'OK' 'valid JSON'
    } catch {
        Add-Check 'drive_config.json' 'CRITICAL' "invalid JSON: $($_.Exception.Message)"
    }
} else {
    Add-Check 'drive_config.json' 'CRITICAL' 'missing at install root'
}

# 3. MTA Server.exe
$mta = Join-Path $ServerRoot 'MTA Server.exe'
if (Test-Path $mta) {
    $v = (Get-Item $mta).VersionInfo.FileVersion
    Add-Check 'MTA Server.exe' 'OK' "version $v"
} else {
    Add-Check 'MTA Server.exe' 'CRITICAL' "missing: $mta"
}

# 4. Client
$client = Join-Path $InstallRoot 'Multi Theft Auto.exe'
if (Test-Path $client) {
    $v = (Get-Item $client).VersionInfo.FileVersion
    Add-Check 'MTA Client' 'OK' "version $v"
} else {
    Add-Check 'MTA Client' 'WARNING' "missing: $client"
}

# 5. Critical server binaries version consistency
# MTA Server.exe uses FileVersion 1.24139.0.0 for build 24149; core/net use 1.6.0.24149
foreach ($f in @('core.dll', 'net.dll', 'MTA Server.exe')) {
    $p = Join-Path $ServerRoot $f
    if (-not (Test-Path $p)) {
        Add-Check $f 'CRITICAL' 'missing from server root'
        continue
    }
    $ver = (Get-Item $p).VersionInfo.FileVersion
    $ok = $false
    if ($f -eq 'MTA Server.exe') {
        $ok = ($ver -match '1\.24139') -or ($ver -match '24149')
    } else {
        $ok = $ver -match '24149'
    }
    if ($ok) {
        Add-Check $f 'OK' "version $ver"
    } else {
        Add-Check $f 'WARNING' "version $ver (expected 24149 build)"
    }
}

# 6. client.dll / pcre3 / libwow64 on client side
$dm = Join-Path (Split-Path -Parent $InstallRoot) (Split-Path -Leaf $InstallRoot)
$deathmatch = Join-Path $InstallRoot 'mods\deathmatch'
foreach ($f in @('client.dll', 'pcre3.dll')) {
    $p = Join-Path $deathmatch $f
    if (Test-Path $p) {
        $ver = (Get-Item $p).VersionInfo.FileVersion
        if ($ver -and $ver -notmatch '24149') {
            Add-Check "mods\$f" 'WARNING' "version $ver (expected 24149)"
        } else {
            Add-Check "mods\$f" 'OK' "version $ver"
        }
    } else {
        Add-Check "mods\$f" 'WARNING' 'missing'
    }
}
$libwow = Join-Path $InstallRoot 'MTA\libwow64.dll'
if (Test-Path $libwow) {
    $ver = (Get-Item $libwow).VersionInfo.FileVersion
    if ($ver -and $ver -notmatch '24149') {
        Add-Check 'MTA\libwow64.dll' 'WARNING' "version $ver (expected 24149)"
    } else {
        Add-Check 'MTA\libwow64.dll' 'OK' "version $ver"
    }
} else {
    Add-Check 'MTA\libwow64.dll' 'WARNING' 'missing'
}

# 7. mtaserver.conf + resources
$conf = Join-Path $ServerRoot 'mods\deathmatch\mtaserver.conf'
if (Test-Path $conf) {
    $raw = Get-Content $conf -Raw
    Add-Check 'mtaserver.conf' 'OK' 'present'
    if ($raw -match 'src="freeroam" startup="1"') {
        Add-Check 'freeroam disabled' 'WARNING' 'freeroam startup=1 (spawn map may leak)'
    } else {
        Add-Check 'freeroam disabled' 'OK' 'freeroam not auto-started'
    }
    if ($raw -match 'src="spawnmanager" startup="1"') {
        Add-Check 'spawnmanager disabled' 'WARNING' 'spawnmanager startup=1'
    } else {
        Add-Check 'spawnmanager disabled' 'OK' 'spawnmanager not auto-started'
    }
    if ($raw -match 'src="play" startup="1"') {
        Add-Check 'play gamemode disabled' 'WARNING' 'play startup=1'
    } else {
        Add-Check 'play gamemode disabled' 'OK' 'play not auto-started'
    }
} else {
    Add-Check 'mtaserver.conf' 'CRITICAL' 'missing'
}

$resourcesDir = Join-Path $ServerRoot 'mods\deathmatch\resources'
if (Test-Path $resourcesDir) {
    $resCount = (Get-ChildItem $resourcesDir -Directory -ErrorAction SilentlyContinue).Count
    Add-Check 'resources folder' 'OK' "$resCount resource folders"
    # spot-check mzansi_core
    $coreMeta = Join-Path $resourcesDir 'mzansi_core\meta.xml'
    if (Test-Path $coreMeta) { Add-Check 'mzansi_core meta' 'OK' 'present' }
    else { Add-Check 'mzansi_core meta' 'CRITICAL' 'missing' }
} else {
    Add-Check 'resources folder' 'CRITICAL' 'missing'
}

# 8. Launch scripts portable (no hardcoded E:\ or D:\ for portable assets)
foreach ($bat in @('START_SERVER.bat', 'restart_server.bat')) {
    $p = Join-Path $ServerRoot $bat
    if (-not (Test-Path $p)) {
        Add-Check $bat 'CRITICAL' 'missing'
        continue
    }
    $raw = Get-Content $p -Raw
    # Flag only real hardcoded assignments / start lines, not echo help text
    if ($raw -match 'set\s+"CLIENT=[A-Za-z]:' -or $raw -match 'start\s+/b\s+""\s+"[A-Za-z]:\\mariadb') {
        Add-Check $bat 'WARNING' 'still contains hardcoded drive letter assignment'
    } elseif ($raw -match 'resolve_paths\.cmd') {
        Add-Check $bat 'OK' 'uses resolve_paths.cmd'
    } else {
        Add-Check $bat 'WARNING' 'portable resolution not detected'
    }
}

# 9. MariaDB binary
$mysqlCandidates = @(
    (Join-Path $VolRoot 'mariadb-11.4.5-winx64\bin\mysqld.exe'),
    'D:\mariadb-11.4.5-winx64\bin\mysqld.exe',
    'C:\mariadb-11.4.5-winx64\bin\mysqld.exe'
)
$mysqlExe = $mysqlCandidates | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
if ($mysqlExe) {
    Add-Check 'mysqld.exe' 'OK' $mysqlExe
} else {
    Add-Check 'mysqld.exe' 'CRITICAL' 'not found on volume root or D:/C:'
}

# 10. MariaDB data dir
$mysqlData = Join-Path $VolRoot 'mariadb-11.4.5-winx64\data'
if (Test-Path $mysqlData) {
    Add-Check 'MariaDB data' 'OK' $mysqlData
} else {
    Add-Check 'MariaDB data' 'CRITICAL' "missing: $mysqlData"
}

# 11. Port 3306
$listening = $false
try {
    $conns = Get-NetTCPConnection -LocalPort 3306 -State Listen -ErrorAction Stop
    if ($conns) { $listening = $true }
} catch {
    $netstat = netstat -an | Select-String ':3306.*LISTENING'
    if ($netstat) { $listening = $true }
}
if ($listening) {
    Add-Check 'Port 3306' 'OK' 'MariaDB listening'
} else {
    Add-Check 'Port 3306' 'WARNING' 'not listening (will start on next boot)'
}

# 12. Port 22003 / server process
$mtaProc = Get-Process -Name 'MTA Server' -ErrorAction SilentlyContinue
if ($mtaProc) {
    Add-Check 'MTA Server process' 'OK' "PID $($mtaProc.Id -join ',')"
} else {
    Add-Check 'MTA Server process' 'WARNING' 'not running'
}

# 13. GTA SA install (client dependency)
$gtaCandidates = @(
    (Join-Path $VolRoot 'Games Library\Grand Theft Auto San Andreas\gta_sa.exe'),
    (Join-Path $InstallRoot 'GTA San Andreas\gta_sa.exe')
)
$gta = $gtaCandidates | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
if ($gta) {
    Add-Check 'GTA San Andreas' 'OK' $gta
} else {
    # MTA may use ProgramData copy
    $pd = 'C:\ProgramData\MTA San Andreas All\1.6\GTA San Andreas\gta_sa.exe'
    if (Test-Path $pd) {
        Add-Check 'GTA San Andreas' 'OK' "MTA ProgramData copy: $pd"
    } else {
        Add-Check 'GTA San Andreas' 'WARNING' 'gta_sa.exe not found'
    }
}

# 14. Disk free on install volume
try {
    $drv = (Get-Item $InstallRoot).PSDrive
    $freeGB = [math]::Round($drv.Free / 1GB, 2)
    $usedPct = [math]::Round(100 - ($freeGB / ($drv.Free / 1GB + ($drv.Used / 1GB)) * 100), 1)
    if ($freeGB -lt 1) {
        Add-Check 'Disk space' 'CRITICAL' "$freeGB GB free on $($drv.Name):"
    } elseif ($freeGB -lt 5) {
        Add-Check 'Disk space' 'WARNING' "$freeGB GB free on $($drv.Name):"
    } else {
        Add-Check 'Disk space' 'OK' "$freeGB GB free on $($drv.Name):"
    }
} catch {
    Add-Check 'Disk space' 'WARNING' "could not measure: $($_.Exception.Message)"
}

# 15. Server log freshness
if (Test-Path $conf) {
    $log = Join-Path $ServerRoot 'mods\deathmatch\logs\server.log'
    if (Test-Path $log) {
        $age = (Get-Date) - (Get-Item $log).LastWriteTime
        if ($age.TotalHours -lt 24) {
            Add-Check 'server.log' 'OK' "last write $([math]::Round($age.TotalMinutes,0)) min ago"
        } else {
            Add-Check 'server.log' 'WARNING' "stale: $([math]::Round($age.TotalDays,1)) days old"
        }
    } else {
        Add-Check 'server.log' 'WARNING' 'not found yet'
    }
}

# Summary
$crit = @($checks | Where-Object status -eq 'CRITICAL').Count
$warn = @($checks | Where-Object status -eq 'WARNING').Count
$ok   = @($checks | Where-Object status -eq 'OK').Count

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host " SUMMARY: $ok OK | $warn WARNING | $crit CRITICAL" -ForegroundColor $(if ($crit -gt 0) { 'Red' } elseif ($warn -gt 0) { 'Yellow' } else { 'Green' })
Write-Host "============================================" -ForegroundColor Cyan

if ($Json) {
    $checks | ConvertTo-Json -Depth 3
}

if ($crit -gt 0) { exit 1 }
exit 0
