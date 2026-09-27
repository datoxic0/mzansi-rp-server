$srcRoot = "e:\Games Library\GTA SA MP - Copy\server"
$dstRoot = "e:\Games Library\GTA SA MP\server"

# 1. Sync all resources
$srcRes = Join-Path $srcRoot "mods\deathmatch\resources"
$dstRes = Join-Path $dstRoot "mods\deathmatch\resources"

$resources = @(
    "mzansi_core",
    "mzansi_phone",
    "mzansi_saps",
    "mzansi_ems",
    "mzansi_jobs",
    "mzansi_gangs",
    "mzansi_crime",
    "mzansi_hud",
    "mzansi_inventory",
    "mzansi_housing",
    "mzansi_vehicles",
    "mzansi_illegalmarket",
    "mzansi_drugs",
    "mzansi_anticheat",
    "mzansi_utils",
    "mzansi_maps"
)

foreach ($res in $resources) {
    $s = Join-Path $srcRes $res
    $d = Join-Path $dstRes $res
    Write-Host "Syncing $res..."
    robocopy $s $d /E /NP /NFL /NDL /R:1 /W:1 | Out-Null
}

# 2. Copy mtaserver.conf
$srcConf = Join-Path $srcRoot "mods\deathmatch\mtaserver.conf"
$dstConf = Join-Path $dstRoot "mods\deathmatch\mtaserver.conf"
Copy-Item -Path $srcConf -Destination $dstConf -Force
Write-Host "Copied mtaserver.conf!"

# 3. Copy acl.xml
$srcAcl = Join-Path $srcRoot "mods\deathmatch\acl.xml"
$dstAcl = Join-Path $dstRoot "mods\deathmatch\acl.xml"
Copy-Item -Path $srcAcl -Destination $dstAcl -Force
Write-Host "Copied acl.xml!"

# 4. Copy START_SERVER.bat
$srcBat = Join-Path $srcRoot "START_SERVER.bat"
$dstBat = Join-Path $dstRoot "START_SERVER.bat"
if (Test-Path $srcBat) {
    Copy-Item -Path $srcBat -Destination $dstBat -Force
    Write-Host "Copied START_SERVER.bat!"
}

Write-Host "Everything successfully copied and synchronized to GTA SA MP\server!"
