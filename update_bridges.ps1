$src = "e:\Games Library\GTA SA MP - Copy\server\mods\deathmatch\resources\mzansi_jobs\server\characters.lua"
$targets = @("mzansi_saps", "mzansi_ems", "mzansi_gangs", "mzansi_crime", "mzansi_vehicles", "mzansi_housing", "mzansi_inventory", "mzansi_drugs", "mzansi_illegalmarket")

foreach ($t in $targets) {
    $dst = "e:\Games Library\GTA SA MP - Copy\server\mods\deathmatch\resources\$t\server\characters.lua"
    Copy-Item -Path $src -Destination $dst -Force
    Write-Host "Updated characters.lua bridge for $t"
}
