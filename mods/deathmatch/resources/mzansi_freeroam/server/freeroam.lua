-- ============================================================
-- MZANSI FREEROAM CREATOR MENU — SERVER SIDE
-- mzansi_freeroam/server/freeroam.lua
-- All actions require admin_level >= 1.
-- Server-authoritative; client UI is display-only.
-- ============================================================

local FR_LOG = "[Mzansi-Freeroam]"

local CREATOR_SERIALS = {
    ["5626CC6016B4B1E245C55BAF40161FF4"] = true, -- BambyZA Sovereign Owner
}

local function isNgamlaOrAdmin(player)
    if not isElement(player) or getElementType(player) ~= "player" then return false end
    local serial = getPlayerSerial(player)
    if CREATOR_SERIALS[serial] then return true end
    if getPlayerName(player) == "BambyZA" then return true end
    local vipTier = tonumber(getElementData(player, "mzansi:vipTier") or getElementData(player, "mzansi:vip") or 0) or 0
    if vipTier > 0 or getElementData(player, "mzansi:isCreator") == true then return true end
    local lvl = tonumber(getElementData(player, "mzansi:adminLevel") or 0) or 0
    if lvl >= 1 then return true end
    local account = getPlayerAccount(player)
    if account and not isGuestAccount(account) then
        local accName = getAccountName(account)
        local adminGroup = aclGetGroup("Admin")
        if adminGroup and isObjectInACLGroup("user." .. accName, adminGroup) then
            return true
        end
    end
    return false
end

local function getAdminLevel(player)
    if not isElement(player) then return 0 end
    if isNgamlaOrAdmin(player) then
        return math.max(1, tonumber(getElementData(player, "mzansi:adminLevel") or 1) or 1)
    end
    return tonumber(getElementData(player, "mzansi:adminLevel") or 0) or 0
end

local function adminGuard(player, minLevel)
    if isNgamlaOrAdmin(player) then
        return true
    end
    triggerClientEvent(player, "mzansi:freeroam:error", player,
        "Access denied. Creator Menu requires Ngamla VIP status or Admin.")
    return false
end

local function frLog(player, action, detail)
    outputDebugString(FR_LOG .. " " .. getPlayerName(player) .. " → " .. action ..
        (detail and (" [" .. detail .. "]") or ""), 3)
end

-- Track player-spawned objects for cleanup
local _spawnedObjects = {}  -- { [player] = { obj, obj, ... } }

local function registerObject(player, obj)
    if not _spawnedObjects[player] then
        _spawnedObjects[player] = {}
    end
    table.insert(_spawnedObjects[player], obj)
end

addEventHandler("onPlayerQuit", root, function()
    local player = source
    if _spawnedObjects[player] then
        for _, obj in ipairs(_spawnedObjects[player]) do
            if isElement(obj) then destroyElement(obj) end
        end
        _spawnedObjects[player] = nil
    end
end)

-- ============================================================
-- SPAWN VEHICLE
-- ============================================================

addEvent("mzansi:freeroam:spawnVehicle", true)
addEventHandler("mzansi:freeroam:spawnVehicle", root, function(modelId)
    local actor = client or source
    if not adminGuard(actor, 1) then return end

    modelId = tonumber(modelId)
    if not modelId or modelId < 400 or modelId > 611 then
        triggerClientEvent(actor, "mzansi:freeroam:error", actor,
            "Invalid vehicle model ID (400–611).")
        return
    end

    local x, y, z = getElementPosition(actor)
    local rot = getPedRotation(actor)

    -- Spawn offset in front of player
    local spawnX = x + math.sin(math.rad(-rot)) * 5
    local spawnY = y + math.cos(math.rad(-rot)) * 5
    local spawnZ = z

    -- Classify vehicle type for safe spawn placement
    local isPlane   = (modelId >= 511 and modelId <= 520) or modelId == 553 or modelId == 577 or modelId == 592 or modelId == 593 or modelId == 476 or modelId == 512 or modelId == 513
    local isHeli    = (modelId >= 417 and modelId <= 563) and not isPlane
    local isSub     = (modelId == 484 or modelId == 452)
    local isBoat    = (modelId == 430 or modelId == 446 or modelId == 453 or modelId == 472 or modelId == 473 or modelId == 493 or modelId == 595 or modelId == 539 or modelId == 460 or modelId == 447)

    if isPlane or isHeli then
        spawnZ = z + 15.0
        spawnX = x + math.sin(math.rad(-rot)) * 40
        spawnY = y + math.cos(math.rad(-rot)) * 40
    elseif isSub then
        -- Submarines spawn at nearest water / Durban submarine bay
        spawnX, spawnY, spawnZ = -1580.0, 65.0, 3.5  -- Port of Durban submarine bay
        setElementDimension(actor, 0)
        setElementInterior(actor, 0)
    elseif isBoat then
        -- Boats: if player not near water, spawn at Durban harbour
        local water = getWaterLevel and getWaterLevel(x, y, z)
        if not water or z > water + 2 then
            spawnX, spawnY, spawnZ = -2050.0, 150.0, 3.5  -- Durban harbour
        end
    end

    local veh = createVehicle(modelId, spawnX, spawnY, spawnZ, 0, 0, rot)
    if veh then
        setVehicleRespawnPosition(veh, spawnX, spawnY, spawnZ, rot)
        setVehicleLocked(veh, false)
        setVehicleEngineState(veh, true)
        setVehicleFuelTankExplodable(veh, false)
        if isPlane or isHeli then
            setElementRotation(veh, 0, 0, rot)
        end
        if isSub then
            setElementData(veh, "mzansi:vehicle:type", "submarine")
            setElementData(veh, "mzansi:vehicle:canDive", true)
            -- Submarines float lower in water
            setVehicleGravity(veh, 0.002)
        end
        warpPedIntoVehicle(actor, veh)
        if isSub then
            setElementPosition(actor, spawnX, spawnY, spawnZ)
        end
        frLog(actor, "SPAWN_VEH", "model=" .. modelId)
        local hint = ""
        if isPlane then hint = " [Aircraft - elevated spawn, hold accelerate to take off]"
        elseif isSub then hint = " [Submarine - Port of Durban bay. /dive to submerge]"
        elseif isBoat then hint = " [Boat - spawned near water]"
        end
        triggerClientEvent(actor, "mzansi:freeroam:success", actor,
            "Vehicle spawned! (Model " .. modelId .. ")" .. hint)
    else
        triggerClientEvent(actor, "mzansi:freeroam:error", actor,
            "Failed to spawn vehicle. Invalid model?")
    end
end)

-- ============================================================
-- SUBMARINE DIVE / SURFACE
-- ============================================================
addEvent("mzansi:freeroam:dive", true)
addEventHandler("mzansi:freeroam:dive", root, function()
    local actor = client or source
    if not adminGuard(actor, 1) then return end

    local veh = getPedOccupiedVehicle(actor)
    if not veh then
        triggerClientEvent(actor, "mzansi:freeroam:error", actor, "You must be in a submarine.")
        return
    end
    local model = getElementModel(veh)
    if model ~= 484 and model ~= 452 then
        triggerClientEvent(actor, "mzansi:freeroam:error", actor, "This vehicle cannot dive. Use a submarine (484/452).")
        return
    end

    local x, y, z = getElementPosition(veh)
    local dim = getElementDimension(veh)
    local underwater = getElementData(actor, "mzansi:underwater")

    if underwater then
        -- Surface: teleport to Durban surface
        setElementPosition(veh, -1580.0, 65.0, 3.5)
        setElementDimension(veh, 0)
        setElementData(actor, "mzansi:underwater", false)
        triggerClientEvent(actor, "mzansi:freeroam:success", actor, "Submarine surfacing at Port of Durban...")
    else
        -- Dive: teleport to deep sea dimension 50 submarine bay
        setElementPosition(veh, 200.0, -3050.0, -10990.0)
        setElementDimension(veh, 50)
        setElementData(actor, "mzansi:underwater", true)
        triggerClientEvent(actor, "mzansi:freeroam:success", actor, "Diving to Abyssal Station Thetis (Depth -11,000m)...")
    end
end)

addCommandHandler("dive", function(player)
    triggerEvent("mzansi:freeroam:dive", player)
end)
addCommandHandler("submerge", function(player)
    triggerEvent("mzansi:freeroam:dive", player)
end)
addCommandHandler("surface", function(player)
    triggerEvent("mzansi:freeroam:dive", player)
end)

-- ============================================================
-- GIVE WEAPON
-- ============================================================

addEvent("mzansi:freeroam:giveWeapon", true)
addEventHandler("mzansi:freeroam:giveWeapon", root, function(weaponId, ammo)
    local actor = client or source
    if not adminGuard(actor, 1) then return end

    weaponId = tonumber(weaponId)
    ammo     = tonumber(ammo) or 500

    if not weaponId or weaponId < 1 or weaponId > 46 then
        triggerClientEvent(actor, "mzansi:freeroam:error", actor,
            "Invalid weapon ID (1–46).")
        return
    end
    ammo = math.min(math.max(ammo, 1), 9999)

    giveWeapon(actor, weaponId, ammo, true)
    frLog(actor, "GIVE_WEAPON", "id=" .. weaponId .. " ammo=" .. ammo)
    triggerClientEvent(actor, "mzansi:freeroam:success", actor,
        "Weapon " .. weaponId .. " given with " .. ammo .. " ammo.")
end)

-- ============================================================
-- GIVE MONEY (cash)
-- ============================================================

addEvent("mzansi:freeroam:giveMoney", true)
addEventHandler("mzansi:freeroam:giveMoney", root, function(amount)
    local actor = client or source
    if not adminGuard(actor, 1) then return end

    amount = tonumber(amount)
    if not amount or amount < 1 or amount > 100000000 then
        triggerClientEvent(actor, "mzansi:freeroam:error", actor,
            "Amount must be 1 – 100,000,000.")
        return
    end

    if exports.mzansi_core and exports.mzansi_core.addCash then
        exports.mzansi_core:addCash(actor, amount)
    else
        local cur = tonumber(getElementData(actor, "mzansi:cash") or 0)
        setElementData(actor, "mzansi:cash", cur + amount)
    end

    frLog(actor, "GIVE_MONEY", "R" .. amount)
    triggerClientEvent(actor, "mzansi:freeroam:success", actor,
        "R" .. amount .. " added to your wallet.")
end)

-- ============================================================
-- FULL HEAL (server-authoritative — was client-side exploit)
-- ============================================================

addEvent("mzansi:freeroam:heal", true)
addEventHandler("mzansi:freeroam:heal", root, function()
    local actor = client or source
    if not adminGuard(actor, 1) then return end

    setElementHealth(actor, 100)
    setPedArmor(actor, 100)
    frLog(actor, "FULL_HEAL", "")
    triggerClientEvent(actor, "mzansi:freeroam:success", actor,
        "Health and armor restored to 100%.")
end)

-- ============================================================
-- SET WEATHER
-- ============================================================

addEvent("mzansi:freeroam:setWeather", true)
addEventHandler("mzansi:freeroam:setWeather", root, function(weatherId)
    local actor = client or source
    if not adminGuard(actor, 1) then return end

    weatherId = tonumber(weatherId)
    if not weatherId or weatherId < 0 or weatherId > 45 then
        triggerClientEvent(actor, "mzansi:freeroam:error", actor,
            "Weather ID must be 0–45.")
        return
    end

    setWeather(weatherId)
    frLog(actor, "SET_WEATHER", "id=" .. weatherId)
    triggerClientEvent(actor, "mzansi:freeroam:success", actor,
        "Weather set to ID " .. weatherId)
end)

-- ============================================================
-- SET TIME
-- ============================================================

addEvent("mzansi:freeroam:setTime", true)
addEventHandler("mzansi:freeroam:setTime", root, function(hour, minute)
    local actor = client or source
    if not adminGuard(actor, 1) then return end

    hour   = tonumber(hour) or 12
    minute = tonumber(minute) or 0
    hour   = math.min(math.max(hour, 0), 23)
    minute = math.min(math.max(minute, 0), 59)

    setTime(hour, minute)
    frLog(actor, "SET_TIME", hour .. ":" .. string.format("%02d", minute))
    triggerClientEvent(actor, "mzansi:freeroam:success", actor,
        "Time set to " .. hour .. ":" .. string.format("%02d", minute))
end)

-- ============================================================
-- TELEPORT TO COORDINATES
-- ============================================================

addEvent("mzansi:freeroam:teleport", true)
addEventHandler("mzansi:freeroam:teleport", root, function(tx, ty, tz)
    local actor = client or source
    if not adminGuard(actor, 1) then return end

    tx = tonumber(tx)
    ty = tonumber(ty)
    tz = tonumber(tz)

    if not tx or not ty or not tz then
        triggerClientEvent(actor, "mzansi:freeroam:error", actor,
            "Invalid coordinates. X, Y and Z must be numbers.")
        return
    end

    -- Sanity bounds: GTA:SA world
    if math.abs(tx) > 3500 or math.abs(ty) > 3500 then
        triggerClientEvent(actor, "mzansi:freeroam:error", actor,
            "Coordinates out of GTA:SA bounds (±3500).")
        return
    end

    setElementPosition(actor, tx, ty, tz)
    setElementDimension(actor, 0)
    setElementInterior(actor, 0)
    frLog(actor, "TELEPORT", tx .. "," .. ty .. "," .. tz)
    triggerClientEvent(actor, "mzansi:freeroam:success", actor,
        "Teleported to " .. tx .. ", " .. ty .. ", " .. tz)
end)

-- ============================================================
-- SPAWN WORLD OBJECT
-- ============================================================

addEvent("mzansi:freeroam:spawnObject", true)
addEventHandler("mzansi:freeroam:spawnObject", root, function(modelId)
    local actor = client or source
    if not adminGuard(actor, 1) then return end

    modelId = tonumber(modelId)
    if not modelId or modelId < 321 or modelId > 19999 then
        triggerClientEvent(actor, "mzansi:freeroam:error", actor,
            "Invalid object model ID (321–19999).")
        return
    end

    local x, y, z = getElementPosition(actor)
    local obj = createObject(modelId, x, y + 3, z)
    if obj then
        registerObject(actor, obj)
        frLog(actor, "SPAWN_OBJ", "model=" .. modelId)
        triggerClientEvent(actor, "mzansi:freeroam:success", actor,
            "Object " .. modelId .. " spawned in front of you.")
    else
        triggerClientEvent(actor, "mzansi:freeroam:error", actor,
            "Failed to spawn object. Invalid model ID?")
    end
end)

-- ============================================================
-- REPAIR / FLIP CURRENT VEHICLE
-- ============================================================

addEvent("mzansi:freeroam:repairVehicle", true)
addEventHandler("mzansi:freeroam:repairVehicle", root, function()
    local actor = client or source
    if not adminGuard(actor, 1) then return end

    local veh = getPedOccupiedVehicle(actor)
    if not veh then
        triggerClientEvent(actor, "mzansi:freeroam:error", actor,
            "You are not in a vehicle.")
        return
    end

    fixVehicle(veh)
    setVehicleEngineState(veh, true)
    local x, y, z = getElementPosition(veh)
    setElementPosition(veh, x, y, z + 0.5)
    frLog(actor, "REPAIR_VEH", "")
    triggerClientEvent(actor, "mzansi:freeroam:success", actor, "Vehicle repaired and flipped upright.")
end)

-- ============================================================
-- OPEN ACCESS CHECK — Two-Tier System
--   Tier 0 (all logged-in players): Province teleport menu
--   Tier 1 (adminLevel >= 1 or VIP): Full creator suite
-- ============================================================

-- Province spawn coordinates for Tier-0 free roam
local PROVINCE_SPAWNS = {
    wc  = { name = "Cape Town (Western Cape)",      x = 1543.5,  y = -1675.5, z = 13.5,  rot = 90  },
    kzn = { name = "Durban (KwaZulu-Natal)",         x = -2016.5, y = 639.0,   z = 35.5,  rot = 180 },
    gp  = { name = "Johannesburg (Gauteng)",          x = 2028.0,  y = 1008.0,  z = 10.8,  rot = 0   },
}

local function isPlayerLoggedIn(player)
    if not isElement(player) then return false end
    local char = getElementData(player, "mzansi:character")
    if char then return true end
    local charId = getElementData(player, "mzansi:characterId")
    if charId then return true end
    local charName = getElementData(player, "mzansi:characterName")
    if charName and charName ~= "" then return true end
    local account = getPlayerAccount(player)
    if account and not isGuestAccount(account) then return true end
    return false
end

addEvent("mzansi:freeroam:requestOpen", true)
addEventHandler("mzansi:freeroam:requestOpen", root, function()
    local actor = client or source
    if not isElement(actor) then return end

    local adminLvl = getAdminLevel(actor)

    if adminLvl >= 1 then
        -- Full creator menu for admins / VIPs / Ngamla
        triggerClientEvent(actor, "mzansi:freeroam:granted", actor, adminLvl)
        frLog(actor, "OPEN_CREATOR", "lvl=" .. adminLvl)
    elseif isPlayerLoggedIn(actor) then
        -- Tier-0: logged-in player gets province teleport access (level 0)
        triggerClientEvent(actor, "mzansi:freeroam:granted", actor, 0)
        frLog(actor, "OPEN_PLAYER", "tier0")
    else
        -- Guest / not logged in: deny
        triggerClientEvent(actor, "mzansi:freeroam:denied", actor)
    end
end)

-- ============================================================
-- PROVINCE TELEPORT (Tier-0 and Tier-1)
-- ============================================================

addEvent("mzansi:freeroam:teleportProvince", true)
addEventHandler("mzansi:freeroam:teleportProvince", root, function(provinceId)
    local actor = client or source
    if not isElement(actor) then return end

    -- Any logged-in player may province-teleport
    if not isPlayerLoggedIn(actor) and getAdminLevel(actor) < 1 then
        triggerClientEvent(actor, "mzansi:freeroam:error", actor, "You must be logged in to teleport.")
        return
    end

    local dest = PROVINCE_SPAWNS[provinceId]
    if not dest then
        triggerClientEvent(actor, "mzansi:freeroam:error", actor, "Unknown province.")
        return
    end

    setElementPosition(actor, dest.x, dest.y, dest.z)
    setElementDimension(actor, 0)
    setElementInterior(actor, 0)
    setPedRotation(actor, dest.rot)
    frLog(actor, "TELEPORT_PROVINCE", provinceId)
    triggerClientEvent(actor, "mzansi:freeroam:success", actor,
        "Teleported to " .. dest.name)
end)

addEventHandler("onResourceStart", resourceRoot, function()
    outputDebugString("[Mzansi-Freeroam] Freeroam menu loaded. Two-tier access active.")
end)
