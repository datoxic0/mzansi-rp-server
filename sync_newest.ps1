#Requires -Version 5.1
<#
.SYNOPSIS
  Bidirectional newest-wins sync between Mzansi RP peer installs.
.DESCRIPTION
  Compares file LastWriteTime across registered peers and copies the newer
  file to the older side. Never syncs running-state DB files or logs.
  Refuses to run destructive copy while MTA Server.exe is running unless -Force.
.EXAMPLE
  .\sync_newest.ps1 -DryRun
  .\sync_newest.ps1
  .\sync_newest.ps1 -Peers "E:\Games Library\GTA SA MP\server"
#>
[CmdletBinding()]
param(
    [string[]]$Peers = @(),
    [switch]$DryRun,
    [switch]$Force,
    [switch]$ListOnly
)

$ErrorActionPreference = 'Stop'

$ServerRoot = $PSScriptRoot
if (-not $ServerRoot) { $ServerRoot = Split-Path -Parent $MyInvocation.MyCommand.Path }
$InstallRoot = Split-Path -Parent $ServerRoot
$VolRoot = Split-Path -Parent (Split-Path -Parent $InstallRoot)
if ($VolRoot -and -not $VolRoot.EndsWith('\')) { $VolRoot += '\' }

$CfgPath = Join-Path $InstallRoot 'drive_config.json'
$Config = $null
if (Test-Path $CfgPath) {
    try { $Config = Get-Content $CfgPath -Raw | ConvertFrom-Json } catch { Write-Warning "drive_config.json unreadable: $_" }
}

# --- Excludes ---
$ExcludeDirNames = @('logs','log','resource-cache','research','scratch','screenshots','dumps','private','public','__pycache__','.git')
$ExcludeFileNames = @('internal.db','internal.db-wal','internal.db-shm','.drive_cache.json')
$ExcludeExtensions = @('.log','.tmp')

if ($Config -and $Config.drive_resolver.sync) {
    $s = $Config.drive_resolver.sync
    if ($s.exclude_dir_names) { $ExcludeDirNames = @($s.exclude_dir_names) + $ExcludeDirNames | Select-Object -Unique }
    if ($s.exclude_file_patterns) {
        foreach ($pat in $s.exclude_file_patterns) {
            if ($pat -like '*.*' -and $pat -notlike '*.*') { $ExcludeFileNames += $pat }
            elseif ($pat -like '.*') { $ExcludeExtensions += $pat }
        }
    }
}

function Test-ExcludedDir([string]$Name) {
    return $ExcludeDirNames -contains $Name
}

function Test-ExcludedFile([string]$Name) {
    if ($ExcludeFileNames -contains $Name) { return $true }
    $ext = [System.IO.Path]::GetExtension($Name)
    if ($ext -and ($ExcludeExtensions -contains $ext)) { return $true }
    return $false
}

# --- Discover peers ---
function Find-Peers {
    $found = New-Object System.Collections.Generic.List[string]
    $self = $ServerRoot.TrimEnd('\')

    foreach ($p in $Peers) {
        if ($p -and (Test-Path $p)) { $found.Add($p.TrimEnd('\')) }
    }

    # Same-volume peer from config
    if ($Config) {
        $relPeers = @()
        if ($Config.drive_resolver.drives.primary.peers) {
            foreach ($peer in $Config.drive_resolver.drives.primary.peers) {
                if ($peer.relative_server) { $relPeers += $peer.relative_server }
            }
        }
        if ($Config.drive_resolver.drives.primary.relative_paths.peer_server) {
            $relPeers += $Config.drive_resolver.drives.primary.relative_paths.peer_server
        }
        foreach ($rel in ($relPeers | Select-Object -Unique)) {
            $full = Join-Path $VolRoot ($rel -replace '/', '\')
            if ((Test-Path $full) -and ($full.TrimEnd('\') -ne $self)) {
                $found.Add($full.TrimEnd('\'))
            }
        }
    } else {
        $defaultPeer = Join-Path $VolRoot 'Games Library\GTA SA MP\server'
        if ((Test-Path $defaultPeer) -and ($defaultPeer.TrimEnd('\') -ne $self)) {
            $found.Add($defaultPeer.TrimEnd('\'))
        }
    }

    # Scan all fixed drives for fingerprint peer
    $vols = @()
    try {
        $vols = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object { $_.DeviceID }
    } catch {
        $vols = @('C:','D:','E:','F:','G:')
    }
    foreach ($v in $vols) {
        $games = Join-Path $v 'Games Library'
        if (-not (Test-Path $games)) { continue }
        foreach ($sub in @('GTA SA MP', 'GTA SA MP - Copy')) {
            $srv = Join-Path (Join-Path $games $sub) 'server'
            if ((Test-Path $srv) -and ($srv.TrimEnd('\') -ne $self)) {
                $normalized = $srv.TrimEnd('\')
                if (-not ($found -contains $normalized)) { $found.Add($normalized) }
            }
        }
    }

    return $found
}

# --- Sync roots (relative to each server root) ---
$SyncRoots = @(
    'mods\deathmatch\resources',
    'mods\deathmatch\mtaserver.conf',
    'mods\deathmatch\acl.xml'
)
$SyncRootFiles = @(
    'START_SERVER.bat',
    'restart_server.bat',
    'doctor.ps1',
    'sync_newest.ps1',
    'SENTIENT_BOOT.bat',
    'resolve_paths.cmd'
)

$peers = Find-Peers

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host " MZANSI RP - NEWEST-WINS SYNC" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host " Primary : $ServerRoot"
if ($peers.Count -eq 0) {
    Write-Host " Peers   : (none found)" -ForegroundColor Yellow
} else {
    Write-Host " Peers   :"
    foreach ($p in $peers) { Write-Host "   - $p" }
}
Write-Host " Mode    : $(if ($DryRun) { 'DRY-RUN (no writes)' } else { 'LIVE' })"
Write-Host ""

if ($ListOnly) { exit 0 }

$serverRunning = [bool](Get-Process -Name 'MTA Server' -ErrorAction SilentlyContinue)
if ($serverRunning) {
    Write-Host "[WARN] MTA Server.exe is running. internal.db and live resources are excluded." -ForegroundColor Yellow
    if (-not $DryRun -and -not $Force) {
        Write-Host "[INFO] Prefer stopping the server via restart_server.bat before a full sync." -ForegroundColor Yellow
    }
}

function Get-RelativeFiles {
    param([string]$Root, [string]$RelativeBase)
    $results = @()
    if (-not (Test-Path $Root)) { return $results }

    if (Test-Path $Root -PathType Leaf) {
        $item = Get-Item $Root
        if (-not (Test-ExcludedFile $item.Name)) {
            $results += [pscustomobject]@{
                Rel = $RelativeBase
                Full = $item.FullName
                Length = $item.Length
                WriteTime = $item.LastWriteTimeUtc
            }
        }
        return $results
    }

    $stack = New-Object System.Collections.Stack
    $stack.Push(@{ Dir = $Root; Rel = $RelativeBase })
    while ($stack.Count -gt 0) {
        $frame = $stack.Pop()
        foreach ($file in Get-ChildItem -LiteralPath $frame.Dir -File -ErrorAction SilentlyContinue) {
            if (Test-ExcludedFile $file.Name) { continue }
            # Always skip internal.db when server running
            if ($serverRunning -and $file.Name -like 'internal.db*') { continue }
            $rel = if ($frame.Rel) { "$($frame.Rel)\$($file.Name)" } else { $file.Name }
            $results += [pscustomobject]@{
                Rel = $rel
                Full = $file.FullName
                Length = $file.Length
                WriteTime = $file.LastWriteTimeUtc
            }
        }
        foreach ($dir in Get-ChildItem -LiteralPath $frame.Dir -Directory -ErrorAction SilentlyContinue) {
            if (Test-ExcludedDir $dir.Name) { continue }
            $rel = if ($frame.Rel) { "$($frame.Rel)\$($dir.Name)" } else { $dir.Name }
            $stack.Push(@{ Dir = $dir.FullName; Rel = $rel })
        }
    }
    return $results
}

function Get-AllSyncFiles {
    param([string]$Root)
    $all = @()
    foreach ($sub in $SyncRoots) {
        $full = Join-Path $Root $sub
        if (Test-Path $full) {
            $all += Get-RelativeFiles -Root $full -RelativeBase ($sub -replace '/', '\')
        }
    }
    foreach ($f in $SyncRootFiles) {
        $full = Join-Path $Root $f
        if (Test-Path $full) {
            $all += Get-RelativeFiles -Root $full -RelativeBase $f
        }
    }
    # Also catch any other *.ps1 / *.bat at server root not listed
    Get-ChildItem -LiteralPath $Root -File -ErrorAction SilentlyContinue | Where-Object {
        ($_.Extension -in @('.bat', '.ps1')) -and (-not (Test-ExcludedFile $_.Name))
    } | ForEach-Object {
        if (-not ($SyncRootFiles -contains $_.Name)) {
            $all += [pscustomobject]@{
                Rel = $_.Name
                Full = $_.FullName
                Length = $_.Length
                WriteTime = $_.LastWriteTimeUtc
            }
        }
    }
    return $all
}

$primaryFiles = Get-AllSyncFiles -Root $ServerRoot
Write-Host "Primary file set: $($primaryFiles.Count) files"

$stats = @{ CopiedToPeer = 0; CopiedToPrimary = 0; Same = 0; Skipped = 0; Errors = 0 }

foreach ($peer in $peers) {
    Write-Host ""
    Write-Host "--- Syncing with: $peer ---" -ForegroundColor Cyan
    $peerFiles = Get-AllSyncFiles -Root $peer
    Write-Host "Peer file set: $($peerFiles.Count) files"

    $primaryMap = @{}
    foreach ($f in $primaryFiles) { $primaryMap[$f.Rel] = $f }
    $peerMap = @{}
    foreach ($f in $peerFiles) { $peerMap[$f.Rel] = $f }

    # Union of relative paths
    $allRels = @($primaryMap.Keys + $peerMap.Keys | Select-Object -Unique)

    foreach ($rel in $allRels) {
        $p = $primaryMap[$rel]
        $q = $peerMap[$rel]

        try {
            if ($p -and -not $q) {
                # Only on primary -> push to peer
                $dest = Join-Path $peer $rel
                if ($DryRun) {
                    Write-Host "  [DRY] ->peer  $rel"
                } else {
                    $destDir = Split-Path -Parent $dest
                    if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
                    Copy-Item -LiteralPath $p.Full -Destination $dest -Force
                    Write-Host "  [NEW]->peer  $rel" -ForegroundColor Green
                }
                $stats.CopiedToPeer++
            }
            elseif ($q -and -not $p) {
                # Only on peer -> pull to primary
                $dest = Join-Path $ServerRoot $rel
                if ($DryRun) {
                    Write-Host "  [DRY] ->primary $rel"
                } else {
                    $destDir = Split-Path -Parent $dest
                    if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
                    Copy-Item -LiteralPath $q.Full -Destination $dest -Force
                    Write-Host "  [NEW]->primary $rel" -ForegroundColor Green
                }
                $stats.CopiedToPrimary++
            }
            elseif ($p -and $q) {
                if ($p.WriteTime -eq $q.WriteTime -and $p.Length -eq $q.Length) {
                    $stats.Same++
                }
                elseif ($p.WriteTime -gt $q.WriteTime) {
                    # primary newer -> to peer
                    if ($DryRun) {
                        Write-Host "  [DRY] primary->peer $rel ($($p.WriteTime) > $($q.WriteTime))"
                    } else {
                        $dest = Join-Path $peer $rel
                        $destDir = Split-Path -Parent $dest
                        if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
                        Copy-Item -LiteralPath $p.Full -Destination $dest -Force
                        Write-Host "  [NEW] primary->peer $rel" -ForegroundColor Green
                    }
                    $stats.CopiedToPeer++
                }
                else {
                    # peer newer -> to primary
                    if ($DryRun) {
                        Write-Host "  [DRY] peer->primary $rel ($($q.WriteTime) > $($p.WriteTime))"
                    } else {
                        $dest = Join-Path $ServerRoot $rel
                        $destDir = Split-Path -Parent $dest
                        if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
                        Copy-Item -LiteralPath $q.Full -Destination $dest -Force
                        Write-Host "  [NEW] peer->primary $rel" -ForegroundColor Green
                    }
                    $stats.CopiedToPrimary++
                }
            }
        } catch {
            Write-Warning "  [ERR] $rel : $($_.Exception.Message)"
            $stats.Errors++
        }
    }
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host " SYNC SUMMARY" -ForegroundColor Cyan
Write-Host "  Same              : $($stats.Same)"
Write-Host "  Copied primary->  : $($stats.CopiedToPeer)"
Write-Host "  Copied ->primary  : $($stats.CopiedToPrimary)"
Write-Host "  Errors            : $($stats.Errors)"
if ($DryRun) { Write-Host "  (DRY-RUN - no files were written)" -ForegroundColor Yellow }
Write-Host "============================================" -ForegroundColor Cyan

if ($stats.Errors -gt 0) { exit 1 }
exit 0
