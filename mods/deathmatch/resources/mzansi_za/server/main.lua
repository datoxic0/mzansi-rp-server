Mzansi = Mzansi or {}

local function initResource()
    outputDebugString("[Mzansi-ZA] Resource initialized.", 3)
end

addEventHandler("onResourceStart", resourceRoot, function()
    initResource()
end)

addEventHandler("onPlayerSpawn", root, function()
    local character = Mzansi.Player.getCharacter(source)
    if character then
        setElementData(source, "mzansi:character", character)
    end
end)

function getPlayerCharacter(player)
    return Mzansi.Player.getCharacter(player)
end

function savePlayerCharacter(player, data)
    return Mzansi.Player.saveCharacter(player, data)
end

function spawnPlayerAtLocation(player, spawnKey)
    return Mzansi.Spawn.spawnPlayer(player, spawnKey)
end
