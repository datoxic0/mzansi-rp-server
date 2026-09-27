Mzansi = Mzansi or {}
Mzansi.Spawn = Mzansi.Spawn or {}

local spawnLocations = {
    city = Mzansi.Enums.Spawn.CITY,
    hospital = Mzansi.Enums.Spawn.HOSPITAL,
    police = Mzansi.Enums.Spawn.POLICE,
}

function Mzansi.Spawn.init()
    outputDebugString("[Mzansi-ZA] Spawn system initialized.", 3)
end

function Mzansi.Spawn.spawnPlayer(player, spawnKey)
    local location = spawnLocations[spawnKey] or spawnLocations.city
    spawnPlayer(player, location.x, location.y, location.z, location.rotation, 0, 0, 0)
    setCameraTarget(player, player)
    fadeCamera(player, true)
    return true
end

function Mzansi.Spawn.spawnPlayerFromProfile(player, profile)
    local x = tonumber(profile and profile.x or 0)
    local y = tonumber(profile and profile.y or 0)
    local z = tonumber(profile and profile.z or 0)
    local rotation = tonumber(profile and profile.rotation or 0)

    if x ~= 0 and y ~= 0 and z ~= 0 then
        spawnPlayer(player, x, y, z, rotation, 0, 0, 0)
    else
        Mzansi.Spawn.spawnPlayer(player, "city")
    end

    setCameraTarget(player, player)
    fadeCamera(player, true)
end
