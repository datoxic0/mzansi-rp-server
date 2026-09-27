Mzansi = Mzansi or {}
Mzansi.Characters = {}
Mzansi.Characters._cache = {}

addEvent("mzansi:characters:create", true)
addEvent("mzansi:characters:select", true)
addEvent("mzansi:characters:spawn", true)
addEvent("mzansi:characters:unfreeze", true)

addEventHandler("mzansi:characters:unfreeze", root, function()
    local player = client or source
    if isElement(player) then
        setElementFrozen(player, false)
    end
end)

function Mzansi.Characters.loadCharacter(source, charData)
    if not source or not charData then return false end

    local fullName = tostring(charData.first_name or "") .. " " .. tostring(charData.last_name or "")
    local character = {
        id = charData.id,
        characterId = charData.id,
        accountId = charData.account_id,
        first_name = charData.first_name,
        firstName = charData.first_name,
        last_name = charData.last_name,
        lastName = charData.last_name,
        name = fullName,
        age = charData.age,
        gender = charData.gender,
        job = charData.job,
        faction = charData.faction,
        factionRank = charData.faction_rank,
        cash = charData.cash,
        bank = charData.bank,
        health = charData.health,
        armor = charData.armor,
        level = charData.level,
        xp = charData.xp,
        jailTime = charData.jail_time,
        driverLicense = charData.driver_license == 1,
        weaponLicense = charData.weapon_license == 1,
        fishLicense = charData.fish_license == 1,
        spawnX = charData.spawn_x,
        spawnY = charData.spawn_y,
        spawnZ = charData.spawn_z,
        spawnRot = charData.spawn_rot,
        skin = tonumber(charData.skin) or -1,
        wantedLevel = tonumber(charData.wanted_level) or 0,
    }

    setElementData(source, "mzansi:character", character)
    setElementData(source, "mzansi:characterId", character.id)
    setElementData(source, "mzansi:charName", fullName)
    setElementData(source, "mzansi:cash", character.cash)
    setElementData(source, "mzansi:bank", character.bank)
    setElementData(source, "mzansi:job", character.job)
    setElementData(source, "mzansi:faction", character.faction)
    setElementData(source, "mzansi:level", character.level)
    setElementData(source, "mzansi:skin", character.skin)
    setElementData(source, "mzansi:wantedLevel", character.wantedLevel)

    Mzansi.Characters._cache[source] = character

    triggerClientEvent(source, "mzansi:characters:loaded", source, character)
    return true
end

function Mzansi.Characters.createCharacter(source, firstName, lastName, age, gender)
    if not source then return false, "Invalid source." end

    local accountId = Mzansi.Accounts.getAccountId(source)
    if not accountId then return false, "Not logged in." end

    firstName = Mzansi.Util.sanitizeInput(firstName)
    lastName = Mzansi.Util.sanitizeInput(lastName)

    if #firstName < 2 or #firstName > 32 then
        return false, "First name must be 2-32 characters."
    end

    if #lastName < 2 or #lastName > 32 then
        return false, "Last name must be 2-32 characters."
    end

    age = tonumber(age) or 25
    if age < 16 or age > 80 then
        return false, "Age must be between 16 and 80."
    end

    gender = tonumber(gender) or 0

    local charId = Mzansi.Database.createCharacter(accountId, firstName, lastName, age, gender)
    if charId then
        local charData = Mzansi.Database.getCharacter(accountId)
        if charData then
            Mzansi.Characters.loadCharacter(source, charData)
            Mzansi.Characters.spawnPlayer(source)
            Mzansi.Database.logAction("CHARACTER", accountId, firstName .. " " .. lastName, "Character created", "", getPlayerIP(source))
            return true, "Character created successfully."
        end
    end
    return false, "Failed to create character."
end

function Mzansi.Characters.saveCharacter(source)
    local character = Mzansi.Characters._cache[source]
    if not character then return false end

    local x, y, z = getElementPosition(source)
    local rot = getPedRotation(source)
    local health = getElementHealth(source)
    local armor = getPedArmor(source)

    character.spawnX = x
    character.spawnY = y
    character.spawnZ = z
    character.spawnRot = rot
    character.health = health
    character.armor = armor

    Mzansi.Database.saveCharacter(character.id, {
        first_name = character.firstName,
        last_name = character.lastName,
        age = character.age,
        gender = character.gender,
        job = character.job,
        faction = character.faction,
        faction_rank = character.factionRank,
        cash = character.cash,
        bank = character.bank,
        health = health,
        armor = armor,
        level = character.level,
        xp = character.xp,
        jail_time = character.jailTime,
        driver_license = character.driverLicense and 1 or 0,
        weapon_license = character.weaponLicense and 1 or 0,
        fish_license = character.fishLicense and 1 or 0,
        skin = tonumber(character.skin) or -1,
        wanted_level = tonumber(getElementData(source, "mzansi:wantedLevel")) or character.wantedLevel or 0,
        spawn_x = x,
        spawn_y = y,
        spawn_z = z,
        spawn_rot = rot,
    })

    return true
end

function Mzansi.Characters.spawnPlayer(source)
    local player = source
    if not isElement(player) then return end

    local character = Mzansi.Characters._cache[player]
    if not character then
        outputDebugString("[Mzansi-Spawn] No character in cache for " .. getPlayerName(player), 1)
        return
    end

    local spawn = Mzansi.Enums.Spawn.LS_AIRPORT
    if character.faction == Mzansi.Enums.Faction.SAPS then
        spawn = Mzansi.Enums.Spawn.LS_PDS
    elseif character.faction == Mzansi.Enums.Faction.EMS then
        spawn = Mzansi.Enums.Spawn.LS_HOSPITAL
    elseif character.spawnX and character.spawnX ~= 0 and character.spawnY and character.spawnY ~= 0 then
        local sz = tonumber(character.spawnZ) or 13.5
        -- Reject broken/out-of-world saved spawns (prevents endless falling)
        if sz > 5 and sz < 180 and character.spawnX > -3000 and character.spawnX < 3000
           and character.spawnY > -3000 and character.spawnY < 3000 then
            spawn = { x = character.spawnX, y = character.spawnY, z = sz, rot = character.spawnRot or 0 }
        else
            outputDebugString("[Mzansi-Spawn] Invalid saved spawn for " .. getPlayerName(player) .. " — using LS Airport", 2)
        end
    end

    local skin = tonumber(character.skin)
    if not skin or skin < 0 then
        skin = (character.gender == 1) and 12 or 0
    end

    outputDebugString("[Mzansi-Spawn] Spawning " .. getPlayerName(player) .. " (Skin: " .. skin .. ") at " .. spawn.x .. ", " .. spawn.y .. ", " .. spawn.z, 3)

    -- Spawn player into world (interior 0, dimension 0)
    spawnPlayer(player, spawn.x, spawn.y, spawn.z, spawn.rot or 0, skin, 0, 0)
    setElementInterior(player, 0)
    setElementDimension(player, 0)
    setCameraInterior(player, 0)

    -- Set health & armor
    setElementHealth(player, character.health or 100)
    setPedArmor(player, character.armor or 0)
    -- Keep frozen until client cutscene onDone / fallback unfreezes (prevents mid-air fall)
    setElementFrozen(player, true)

    -- Lock camera to player and smoothly fade in
    setCameraTarget(player, player)
    fadeCamera(player, true, 1.5)

    -- Notify client that spawn is complete
    triggerClientEvent(player, "mzansi:characters:spawnComplete", player, spawn.x, spawn.y, spawn.z)

    -- Load owned vehicles into world after spawn settles
    setTimer(function()
        if isElement(player) and Mzansi.Vehicles and Mzansi.Vehicles.loadPlayerVehicles then
            Mzansi.Vehicles.loadPlayerVehicles(player)
        end
        if isElement(player) then
            triggerEvent("mzansi:characters:spawned", player, player)
        end
    end, 2500, 1)

    -- Skippable spawn intro cutscene (client-owned; no server advance)
    local charName = ""
    if character.firstName then
        charName = tostring(character.firstName or "")
        if character.lastName then
            charName = charName .. " " .. tostring(character.lastName or "")
        end
    end
    if charName == "" then
        charName = getPlayerName(player) or "Citizen"
    end
    setTimer(function()
        if isElement(player) then
            triggerClientEvent(player, "mzansi:cutscene:scene", resourceRoot, {
                kind = "spawn",
                phase = "intro",
                data = { x = spawn.x, y = spawn.y, z = spawn.z, name = charName },
            })
        end
    end, 400, 1)

    -- Fallback: if cutscene never starts, restore gameplay camera + unfreeze
    setTimer(function()
        if isElement(player) then
            fadeCamera(player, true, 0.5)
            setElementFrozen(player, false)
        end
    end, 12000, 1)
end

function Mzansi.Characters.getCharacter(source)
    return Mzansi.Characters._cache[source]
end

function Mzansi.Characters.getCharacterField(source, field)
    local char = Mzansi.Characters._cache[source]
    if char then
        return char[field]
    end
    return nil
end

function Mzansi.Characters.setCharacterField(source, field, value)
    local char = Mzansi.Characters._cache[source]
    if char then
        char[field] = value
        return true
    end
    return false
end

function Mzansi.Characters.addCash(source, amount)
    local char = Mzansi.Characters._cache[source]
    if not char then return false end
    char.cash = char.cash + amount
    setElementData(source, "mzansi:cash", char.cash)
    return true
end

function Mzansi.Characters.removeCash(source, amount)
    local char = Mzansi.Characters._cache[source]
    if not char then return false end
    if char.cash < amount then return false end
    char.cash = char.cash - amount
    setElementData(source, "mzansi:cash", char.cash)
    return true
end

function Mzansi.Characters.addBank(source, amount)
    local char = Mzansi.Characters._cache[source]
    if not char then return false end
    char.bank = char.bank + amount
    setElementData(source, "mzansi:bank", char.bank)
    return true
end

function Mzansi.Characters.removeBank(source, amount)
    local char = Mzansi.Characters._cache[source]
    if not char then return false end
    if char.bank < amount then return false end
    char.bank = char.bank - amount
    setElementData(source, "mzansi:bank", char.bank)
    return true
end

function Mzansi.Characters.addXP(source, amount)
    local char = Mzansi.Characters._cache[source]
    if not char then return false end
    char.xp = char.xp + amount
    local xpNeeded = Mzansi.Config.Server.xpPerLevel * char.level
    while char.xp >= xpNeeded do
        char.xp = char.xp - xpNeeded
        char.level = char.level + 1
        setElementData(source, "mzansi:level", char.level)
        Mzansi.Util.sendNotification(source, "Level up! You are now level " .. char.level .. "!", "success")
        xpNeeded = Mzansi.Config.Server.xpPerLevel * char.level
    end
    return true
end

function Mzansi.Characters.setJob(source, jobId)
    local char = Mzansi.Characters._cache[source]
    if not char then return false end
    char.job = jobId
    setElementData(source, "mzansi:job", jobId)
    local jobConfig = Mzansi.Config.Jobs[jobId]
    if jobConfig then
        Mzansi.Util.sendNotification(source, "You are now working as: " .. jobConfig.name, "info")
    end
    return true
end

function Mzansi.Characters.setFaction(source, factionId, rank)
    local char = Mzansi.Characters._cache[source]
    if not char then return false end
    char.faction = factionId
    char.factionRank = rank or 0
    setElementData(source, "mzansi:faction", factionId)
    setElementData(source, "mzansi:factionRank", char.factionRank)
    local factionConfig = Mzansi.Config.Factions[factionId]
    if factionConfig then
        Mzansi.Util.sendNotification(source, "Welcome to " .. factionConfig.name .. "!", "success")
    end
    return true
end

addEventHandler("mzansi:characters:create", root, function(firstName, lastName, age, gender)
    local source = client or source
    local success, message = Mzansi.Characters.createCharacter(source, firstName, lastName, age, gender)
    triggerClientEvent(source, "mzansi:characters:createResult", source, success, message)
end)

addEventHandler("mzansi:characters:spawn", root, function()
    local source = client or source
    Mzansi.Characters.spawnPlayer(source)
end)

-- ============================================================
-- DEATH & RESPAWN SYSTEM
-- ============================================================
local RESPAWN_DELAY_MS = 8000   -- 8 seconds before respawn
local HOSPITAL_FEE     = 500    -- R500 medical bill
local HOSPITAL_SPAWN   = Mzansi.Enums.Spawn.LS_HOSPITAL
local SAPS_SPAWN       = Mzansi.Enums.Spawn.LS_PDS

-- Spawn-immunity table: players in here are protected from onPlayerWasted
-- for 3 seconds after a spawnPlayer() call to stop the spawn→die→loop.
local _spawnImmune = {}

local function setSpawnImmune(player)
    _spawnImmune[player] = true
    setTimer(function()
        _spawnImmune[player] = nil
    end, 3000, 1)
end

-- Map faction → their respawn hospital / base
local function getRespawnPoint(player)
    local char = Mzansi.Characters._cache[player]
    if not char then return HOSPITAL_SPAWN end
    if char.faction == Mzansi.Enums.Faction.SAPS then return SAPS_SPAWN    end
    if char.faction == Mzansi.Enums.Faction.EMS  then return HOSPITAL_SPAWN end
    return HOSPITAL_SPAWN
end

-- Shared respawn executor (used by both death handler and spawnPlayer)
local function doRespawn(player, spawn, fee)
    if not isElement(player) then return end
    local char = Mzansi.Characters._cache[player]
    if char then
        char.health = 100
        char.armor  = 0
    end
    local skin = 0
    if char then
        skin = tonumber(char.skin)
        if not skin or skin < 0 then
            skin = (char.gender == 1) and 12 or 0
        end
    end

    -- Grant immunity BEFORE calling spawnPlayer so the engine's
    -- internal wasted event during respawn is swallowed.
    setSpawnImmune(player)

    spawnPlayer(player, spawn.x, spawn.y, spawn.z, spawn.rot or 0, skin, 0, 0)
    setElementInterior(player, 0)
    setElementDimension(player, 0)
    setElementHealth(player, 100)
    setPedArmor(player, 0)
    setElementFrozen(player, false)
    setCameraTarget(player, player)
    fadeCamera(player, true, 1.5)

    triggerClientEvent(player, "mzansi:characters:spawnComplete", player, spawn.x, spawn.y, spawn.z)
    triggerClientEvent(player, "mzansi:respawn:complete", player)

    -- Hospital wake cutscene (skippable)
    setTimer(function()
        if isElement(player) then
            triggerClientEvent(player, "mzansi:cutscene:scene", resourceRoot, {
                kind = "hospital",
                phase = "wake",
                data = { x = spawn.x, y = spawn.y, z = spawn.z },
            })
        end
    end, 500, 1)

    if fee and fee > 0 then
        Mzansi.Util.sendNotification(player,
            "You were treated at the hospital. Medical fee: R" .. fee .. " deducted.", "info")
    else
        Mzansi.Util.sendNotification(player, "You were treated at the hospital.", "info")
    end
end

addEventHandler("onPlayerWasted", root, function()
    local player = source
    if not isElement(player)       then return end
    if _spawnImmune[player]        then return end  -- spawning: ignore
    local char = Mzansi.Characters._cache[player]
    if not char                    then return end  -- not in game yet

    -- 1. Deduct hospital fee (clamped — never negative)
    local fee = math.min(HOSPITAL_FEE, char.cash or 0)
    if fee > 0 then
        char.cash = char.cash - fee
        setElementData(player, "mzansi:cash", char.cash)
    end

    -- 2. Strip all weapons (correct MTA:SA API)
    takeAllWeapons(player)

    -- 3. Show client death screen + countdown
    triggerClientEvent(player, "mzansi:respawn:startDeathScreen",
        player, RESPAWN_DELAY_MS / 1000, fee)

    -- 4. Schedule respawn after countdown
    local spawn = getRespawnPoint(player)
    setTimer(function()
        doRespawn(player, spawn, fee)
        outputDebugString("[Mzansi-Respawn] " .. getPlayerName(player) ..
            " respawned at hospital. Fee: R" .. fee)
    end, RESPAWN_DELAY_MS, 1)

    outputDebugString("[Mzansi-Respawn] " .. getPlayerName(player) ..
        " died. Respawning in " .. (RESPAWN_DELAY_MS / 1000) .. "s. Fee: R" .. fee)
end)

-- Patch spawnPlayer wrapper to always grant immunity when we call it,
-- keeping the existing Mzansi.Characters.spawnPlayer clean.
local _origSpawn = Mzansi.Characters.spawnPlayer
Mzansi.Characters.spawnPlayer = function(source)
    setSpawnImmune(source)
    _origSpawn(source)
end

addEventHandler("onResourceStart", resourceRoot, function()
    outputDebugString("[Mzansi-Characters] Character system loaded.")
end)

-- Export wrapper functions for cross-resource access
function getCharacter(source)
    return Mzansi.Characters.getCharacter(source)
end

function addCash(source, amount)
    return Mzansi.Characters.addCash(source, amount)
end

function removeCash(source, amount)
    return Mzansi.Characters.removeCash(source, amount)
end

function addBank(source, amount)
    return Mzansi.Characters.addBank(source, amount)
end

function removeBank(source, amount)
    return Mzansi.Characters.removeBank(source, amount)
end

function addXP(source, amount)
    return Mzansi.Characters.addXP(source, amount)
end

function setJob(source, jobId)
    return Mzansi.Characters.setJob(source, jobId)
end

function setFaction(source, factionId, rank)
    return Mzansi.Characters.setFaction(source, factionId, rank)
end

function getCharacterField(source, field)
    return Mzansi.Characters.getCharacterField(source, field)
end

function setCharacterField(source, field, value)
    return Mzansi.Characters.setCharacterField(source, field, value)
end
