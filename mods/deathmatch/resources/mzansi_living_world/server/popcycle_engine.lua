-- ==============================================================
-- MZANSI LIVING WORLD — SERVER POPCYCLE & BUBBLE ENGINE
-- High-Performance 2D Spatial Grid, Burst Spawning & Ambient Traffic
-- ==============================================================
MzansiLiving = MzansiLiving or {}
MzansiLiving.Popcycle = {}

local _popcycleTimer = nil
local GRID_CELL = 80.0 -- 80m spatial hash cell size

local MzansiSpatialGrid = {}
local MzansiRoadSpatialGrid = {}

-- Builds 2D Spatial Hash Grids for O(1) instantaneous spatial queries
function MzansiLiving.Popcycle.buildSpatialGrids()
    MzansiSpatialGrid = {}
    MzansiRoadSpatialGrid = {}

    -- Merge all province node tables into the main tables
    if MzansiNodesSF then
        for k, v in pairs(MzansiNodesSF) do MzansiNodes[k] = v end
    end
    if MzansiNodesLV then
        for k, v in pairs(MzansiNodesLV) do MzansiNodes[k] = v end
    end
    if MzansiRoadNodesSF then
        for k, v in pairs(MzansiRoadNodesSF) do MzansiRoadNodes[k] = v end
    end
    if MzansiRoadNodesLV then
        for k, v in pairs(MzansiRoadNodesLV) do MzansiRoadNodes[k] = v end
    end

    -- 1. Index Pedestrian Nodes
    if MzansiNodes then
        local count = 0
        for nodeId, data in pairs(MzansiNodes) do
            local cx = math.floor(data[1] / GRID_CELL)
            local cy = math.floor(data[2] / GRID_CELL)
            local key = cx .. ":" .. cy
            if not MzansiSpatialGrid[key] then MzansiSpatialGrid[key] = {} end
            table.insert(MzansiSpatialGrid[key], nodeId)
            count = count + 1
        end
        outputDebugString("[Mzansi-LivingWorld] Spatial Grid: Indexed " .. count .. " pedestrian nodes.")
    end

    -- 2. Index Road Nodes
    if MzansiRoadNodes then
        local count = 0
        for nodeId, data in pairs(MzansiRoadNodes) do
            local cx = math.floor(data[1] / GRID_CELL)
            local cy = math.floor(data[2] / GRID_CELL)
            local key = cx .. ":" .. cy
            if not MzansiRoadSpatialGrid[key] then MzansiRoadSpatialGrid[key] = {} end
            table.insert(MzansiRoadSpatialGrid[key], nodeId)
            count = count + 1
        end
        outputDebugString("[Mzansi-LivingWorld] Spatial Grid: Indexed " .. count .. " roadway nodes.")
    end
end

-- Determines zone classification from world coordinates
function MzansiLiving.Popcycle.getZoneType(x, y, z)
    -- Durban / KZN Province (San Fierro area: x -2800 to -1400, y -300 to 1800)
    if x >= -2800 and x <= -1400 and y >= -300 and y <= 1800 then
        -- Durban Harbour / Industrial
        if x >= -1800 and x <= -1400 and y >= -200 and y <= 400 then
            return MzansiLiving.Enums.Zone.DURBAN  -- harbour sub-zone
        -- Durban Beachfront / Florida Road
        elseif y >= 800 and y <= 1400 then
            return MzansiLiving.Enums.Zone.BEACHFRONT
        else
            return MzansiLiving.Enums.Zone.DURBAN
        end
    -- Johannesburg / GP Province (Las Venturas area: x 1400 to 2900, y 300 to 2000)
    elseif x >= 1400 and x <= 2900 and y >= 300 and y <= 2000 then
        -- Sandton / Northern Johannesburg (wealthy suburban)
        if y >= 1400 then
            return MzansiLiving.Enums.Zone.SUBURBAN
        -- CBD / Downtown Jozi
        elseif x >= 1800 and x <= 2400 and y >= 600 and y <= 1200 then
            return MzansiLiving.Enums.Zone.COMMERCE
        -- Soweto / Township areas
        elseif x >= 1400 and x <= 1800 and y >= 300 and y <= 700 then
            return MzansiLiving.Enums.Zone.TOWNSHIP
        else
            return MzansiLiving.Enums.Zone.JOHANNESBURG
        end
    -- Los Santos / Cape Town Province (existing zones)
    -- Ocean Docks & Industrial
    elseif x >= 1800 and x <= 2800 and y >= -2700 and y <= -2100 then
        return MzansiLiving.Enums.Zone.DOCKS
    -- Beachfront / Santa Maria
    elseif x >= 200 and x <= 1000 and y >= -2200 and y <= -1800 then
        return MzansiLiving.Enums.Zone.BEACHFRONT
    -- Township / Gangland (Ganton, Idlewood, East Los Santos)
    elseif x >= 1800 and x <= 2600 and y >= -1900 and y <= -1300 then
        return MzansiLiving.Enums.Zone.TOWNSHIP
    -- Commerce / Financial / City Hall / Downtown LS (Default)
    else
        return MzansiLiving.Enums.Zone.COMMERCE
    end
end

-- Resolves an archetype from demographic probability weights
function MzansiLiving.Popcycle.selectArchetype(zoneName)
    local zoneConfig = MzansiLiving.Config.ModelPools[zoneName] or MzansiLiving.Config.ModelPools.commerce
    local archetypes = zoneConfig.archetypes
    local roll = math.random(1, 100)
    local cumulative = 0

    for arch, weight in pairs(archetypes) do
        cumulative = cumulative + weight
        if roll <= cumulative then
            return arch
        end
    end
    return MzansiLiving.Enums.Archetype.CIVILIAN_NORMAL
end

-- Fast spatial grid query for nodes near (px, py, pz) within [minDist, maxDist]
function MzansiLiving.Popcycle.findNodesNear(px, py, pz, minDist, maxDist, isRoad, maxCandidates)
    local grid = isRoad and MzansiRoadSpatialGrid or MzansiSpatialGrid
    local nodeSource = isRoad and MzansiRoadNodes or MzansiNodes
    if not grid or not nodeSource then return {} end

    maxCandidates = maxCandidates or 20
    local candidates = {}

    local minCX = math.floor((px - maxDist) / GRID_CELL)
    local maxCX = math.floor((px + maxDist) / GRID_CELL)
    local minCY = math.floor((py - maxDist) / GRID_CELL)
    local maxCY = math.floor((py + maxDist) / GRID_CELL)

    for cx = minCX, maxCX do
        for cy = minCY, maxCY do
            local key = cx .. ":" .. cy
            local bucket = grid[key]
            if bucket then
                for _, nodeId in ipairs(bucket) do
                    local node = nodeSource[nodeId]
                    if node then
                        local dist = getDistanceBetweenPoints3D(px, py, pz, node[1], node[2], node[3])
                        if dist >= minDist and dist <= maxDist then
                            table.insert(candidates, nodeId)
                            if #candidates >= maxCandidates then
                                return candidates
                            end
                        end
                    end
                end
            end
        end
    end

    return candidates
end

-- Finds a single suitable sidewalk node near player
function MzansiLiving.Popcycle.findSpawnNodeNear(player, minDist, maxDist)
    local px, py, pz = getElementPosition(player)
    local candidates = MzansiLiving.Popcycle.findNodesNear(px, py, pz, minDist, maxDist, false, 20)
    if #candidates > 0 then
        return candidates[math.random(1, #candidates)]
    end
    return nil
end

-- Finds a single suitable road node near player
function MzansiLiving.Popcycle.findRoadNodeNear(player, minDist, maxDist)
    local px, py, pz = getElementPosition(player)
    local candidates = MzansiLiving.Popcycle.findNodesNear(px, py, pz, minDist, maxDist, true, 20)
    if #candidates > 0 then
        return candidates[math.random(1, #candidates)]
    end
    return nil
end

-- Immediate Burst Population when a player spawns or enters a new area
function MzansiLiving.Popcycle.burstPopulate(player)
    if not isElement(player) or isPedDead(player) or getElementDimension(player) ~= 0 then return end
    local px, py, pz = getElementPosition(player)
    local zone = MzansiLiving.Popcycle.getZoneType(px, py, pz)

    -- 1. Burst Pedestrians (15m - 65m)
    local pedCandidates = MzansiLiving.Popcycle.findNodesNear(px, py, pz, 15.0, 65.0, false, 30)
    local pedsToSpawn = math.min(#pedCandidates, MzansiLiving.Config.BURST_INITIAL_PEDS or 10)
    for i = 1, pedsToSpawn do
        local randIdx = math.random(1, #pedCandidates)
        local nodeId = pedCandidates[randIdx]
        table.remove(pedCandidates, randIdx)
        local archetype = MzansiLiving.Popcycle.selectArchetype(zone)
        MzansiLiving.Spawner.spawnPedAtNode(nodeId, nil, archetype, zone)
    end

    -- 2. Burst Vehicles (20m - 75m)
    if MzansiLiving.Traffic and MzansiLiving.Traffic.spawnVehicleAtRoadNode then
        local roadCandidates = MzansiLiving.Popcycle.findNodesNear(px, py, pz, 20.0, 75.0, true, 20)
        local vehsToSpawn = math.min(#roadCandidates, MzansiLiving.Config.BURST_INITIAL_VEHICLES or 4)
        for i = 1, vehsToSpawn do
            local randIdx = math.random(1, #roadCandidates)
            local roadNodeId = roadCandidates[randIdx]
            table.remove(roadCandidates, randIdx)
            MzansiLiving.Traffic.spawnVehicleAtRoadNode(roadNodeId)
        end
    end

    outputDebugString("[Mzansi-LivingWorld] Burst populated bubble for " .. getPlayerName(player) .. " (" .. pedsToSpawn .. " peds, " .. zone .. ")")
end

-- Core periodic update loop for player virtual bubbles
function MzansiLiving.Popcycle.updateBubbles()
    local players = getElementsByType("player")
    if #players == 0 then return end

    local activePeds = MzansiLiving.Spawner.getActivePeds()
    local totalPedCount = #activePeds

    local activeVehs = (MzansiLiving.Traffic and MzansiLiving.Traffic.getActiveVehicles) and MzansiLiving.Traffic.getActiveVehicles() or {}
    local totalVehCount = #activeVehs

    -- Step 1: Recycle distant peds (> DESPAWN_RADIUS from ALL players)
    for i = #activePeds, 1, -1 do
        local ped = activePeds[i]
        if isElement(ped) then
            -- Skip stationary indoor staff and permanent landmarks
            local isStaff = getElementData(ped, "mzansi:ai:interiorStaff")
            local isLandmark = getElementData(ped, "mzansi:ai:landmark")
            if not isStaff and not isLandmark then
                local pedX, pedY, pedZ = getElementPosition(ped)
                local isNearAnyPlayer = false

                for _, player in ipairs(players) do
                    local px, py, pz = getElementPosition(player)
                    if getDistanceBetweenPoints3D(px, py, pz, pedX, pedY, pedZ) <= MzansiLiving.Config.DESPAWN_RADIUS then
                        isNearAnyPlayer = true
                        break
                    end
                end

                if not isNearAnyPlayer then
                    MzansiLiving.Spawner.recyclePed(ped)
                    totalPedCount = totalPedCount - 1
                end
            end
        end
    end

    -- Step 2: Recycle distant traffic vehicles (> DESPAWN_RADIUS from ALL players)
    if MzansiLiving.Traffic and MzansiLiving.Traffic.recycleVehicle then
        for i = #activeVehs, 1, -1 do
            local veh = activeVehs[i]
            if isElement(veh) then
                local vx, vy, vz = getElementPosition(veh)
                local isNearAnyPlayer = false

                for _, player in ipairs(players) do
                    local px, py, pz = getElementPosition(player)
                    if getDistanceBetweenPoints3D(px, py, pz, vx, vy, vz) <= MzansiLiving.Config.DESPAWN_RADIUS then
                        isNearAnyPlayer = true
                        break
                    end
                end

                if not isNearAnyPlayer then
                    MzansiLiving.Traffic.recycleVehicle(veh)
                    totalVehCount = totalVehCount - 1
                end
            end
        end
    end

    -- Step 3: Evaluate bubble quota per active player
    for _, player in ipairs(players) do
        if not isPedDead(player) and getElementDimension(player) == 0 then
            local px, py, pz = getElementPosition(player)
            local zone = MzansiLiving.Popcycle.getZoneType(px, py, pz)

            -- Count local peds inside player's bubble
            local localPedCount = 0
            for _, ped in ipairs(activePeds) do
                if isElement(ped) then
                    local pedX, pedY, pedZ = getElementPosition(ped)
                    if getDistanceBetweenPoints3D(px, py, pz, pedX, pedY, pedZ) <= MzansiLiving.Config.BUBBLE_RADIUS then
                        localPedCount = localPedCount + 1
                    end
                end
            end

            -- Determine target quota
            local targetPedQuota = MzansiLiving.Config.MAX_PEDS_PER_PLAYER or 16
            local hour = getTime()
            if hour >= 23 or hour <= 4 then
                targetPedQuota = math.floor(targetPedQuota * 0.6)
            end

            -- Spawn peds if below quota (up to 2 per tick for smooth replenishment)
            if localPedCount < targetPedQuota and totalPedCount < MzansiLiving.Config.MAX_SERVER_PEDS then
                local spawns = math.min(2, targetPedQuota - localPedCount)
                for s = 1, spawns do
                    local spawnNodeId = MzansiLiving.Popcycle.findSpawnNodeNear(
                        player,
                        MzansiLiving.Config.SPAWN_MIN_RADIUS,
                        MzansiLiving.Config.SPAWN_MAX_RADIUS
                    )
                    if spawnNodeId then
                        local archetype = MzansiLiving.Popcycle.selectArchetype(zone)
                        local newPed = MzansiLiving.Spawner.spawnPedAtNode(spawnNodeId, nil, archetype, zone)
                        if newPed then
                            totalPedCount = totalPedCount + 1
                        end
                    end
                end
            end

            -- Count local traffic vehicles
            if MzansiLiving.Traffic and MzansiLiving.Traffic.spawnVehicleAtRoadNode then
                local localVehCount = 0
                for _, veh in ipairs(activeVehs) do
                    if isElement(veh) then
                        local vx, vy, vz = getElementPosition(veh)
                        if getDistanceBetweenPoints3D(px, py, pz, vx, vy, vz) <= MzansiLiving.Config.BUBBLE_RADIUS then
                            localVehCount = localVehCount + 1
                        end
                    end
                end

                local targetVehQuota = MzansiLiving.Config.MAX_VEHICLES_PER_PLAYER or 6
                if localVehCount < targetVehQuota and totalVehCount < MzansiLiving.Config.MAX_SERVER_VEHICLES then
                    local roadNodeId = MzansiLiving.Popcycle.findRoadNodeNear(
                        player,
                        25.0,
                        MzansiLiving.Config.SPAWN_MAX_RADIUS
                    )
                    if roadNodeId then
                        local newVeh = MzansiLiving.Traffic.spawnVehicleAtRoadNode(roadNodeId)
                        if newVeh then
                            totalVehCount = totalVehCount + 1
                        end
                    end
                end
            end
        end
    end
end

-- Initialize popcycle loop
function MzansiLiving.Popcycle.start()
    MzansiLiving.Popcycle.buildSpatialGrids()

    if isTimer(_popcycleTimer) then killTimer(_popcycleTimer) end
    _popcycleTimer = setTimer(MzansiLiving.Popcycle.updateBubbles, MzansiLiving.Config.TICK_INTERVAL_SERVER, 0)
    outputDebugString("[Mzansi-LivingWorld] Popcycle engine started. Ticker: " .. MzansiLiving.Config.TICK_INTERVAL_SERVER .. "ms")

    -- Initial burst for any players already connected
    for _, p in ipairs(getElementsByType("player")) do
        MzansiLiving.Popcycle.burstPopulate(p)
    end
end

addEventHandler("onResourceStart", resourceRoot, function()
    MzansiLiving.Popcycle.start()
end)

addEventHandler("onPlayerSpawn", root, function()
    local p = source
    -- Slight delay to ensure player coordinate sync is final
    -- MZANSI PATCH: delay 8s so spawn world is stable before ped burst (crash mitigation).
    setTimer(function()
        if isElement(p) then
            MzansiLiving.Popcycle.burstPopulate(p)
        end
    end, 8000, 1)
end)

addEventHandler("onResourceStop", resourceRoot, function()
    if isTimer(_popcycleTimer) then killTimer(_popcycleTimer) end
end)

-- ==============================================================
-- NPC INTELLIGENCE ENGINE — Pedestrian AI (Server-Side)
-- Wander timers, gang-ped awareness, danger-flee response
-- Covers ALL provinces: LS (Cape Town), SF (Durban), LV (Jozi)
-- ==============================================================

-- Gang turf zone definitions — matching provincial gang_config.lua
local GANG_TURF_ZONES = {
    -- Western Cape (Cape Town / LS)
    { x = 2244.5, y = -1665.5, radius = 150, gangId = "ssk",  province = "WC" },
    { x = 1950.0, y = -1450.0, radius = 150, gangId = "28s",  province = "WC" },
    { x = 1920.5, y = -1760.5, radius = 150, gangId = "cd",   province = "WC" },
    -- KwaZulu-Natal (Durban / SF)
    { x = -2160.0, y = -235.5, radius = 150, gangId = "zw",   province = "KZN" },
    { x = -1600.0, y = 150.0,  radius = 175, gangId = "zw",   province = "KZN" },
    { x = -2720.0, y = -320.0, radius = 160, gangId = "zw",   province = "KZN" },
    -- Gauteng (Jozi / LV)
    { x = 2270.5, y = 1430.5,  radius = 150, gangId = "bm",   province = "GP" },
    { x = 2480.5, y = 2110.5,  radius = 150, gangId = "ndc",  province = "GP" },
    { x = 2028.0, y = 1008.0,  radius = 160, gangId = "ndc",  province = "GP" },
}

-- Wander interval: each ambient ped gets a random idle-walk destination every N seconds
local PED_WANDER_INTERVAL_MIN = 8000   -- 8 seconds minimum
local PED_WANDER_INTERVAL_MAX = 20000  -- 20 seconds maximum
local _pedWanderTimers = {}

-- Idle animations for peds who are not walking — selected by zone type
local IDLE_ANIMS = {
    civilian = {
        { "ped", "idle_chat" },
        { "ped", "seat_idle" },
        { "SMOKING", "M_smk_loop" },
        { "DEALER", "DEALER_IDLE" },
    },
    gang = {
        { "GANGS", "prtial_gngtlkA" },
        { "GANGS", "prtial_gngtlkB" },
        { "SMOKING", "M_smk_loop" },
        { "GANGS", "gng_plyr" },
    },
}

-- Check if a world position is inside a gang turf zone
local function getGangZoneAtPos(x, y)
    for _, zone in ipairs(GANG_TURF_ZONES) do
        local dist = getDistanceBetweenPoints2D(x, y, zone.x, zone.y)
        if dist <= zone.radius then
            return zone
        end
    end
    return nil
end

-- Schedule a ped's next wander to a nearby node
local function scheduleWander(ped)
    if not isElement(ped) or getElementData(ped, "mzansi:ai:landmark") then return end

    local delay = math.random(PED_WANDER_INTERVAL_MIN, PED_WANDER_INTERVAL_MAX)
    _pedWanderTimers[ped] = setTimer(function()
        if not isElement(ped) or isPedDead(ped) then
            _pedWanderTimers[ped] = nil
            return
        end
        if getElementData(ped, "mzansi:ai:fleeing") then
            -- Still fleeing, don't interfere — reschedule after it calms down
            scheduleWander(ped)
            return
        end

        local px, py, pz = getElementPosition(ped)
        local gangZone = getGangZoneAtPos(px, py)

        if gangZone then
            -- Gang turf ped: pick a random idle menacing animation
            local anim = IDLE_ANIMS.gang[math.random(1, #IDLE_ANIMS.gang)]
            setPedAnimation(ped, anim[1], anim[2], -1, true, false, false)
            -- Face a random direction to simulate watchful patrolling
            local randomRot = math.random(0, 359)
            setElementRotation(ped, 0, 0, randomRot)
        else
            -- Civilian ped: walk to a nearby sidewalk node
            local candidates = MzansiNodes and MzansiLiving.Popcycle.findNodesNear(px, py, pz, 5.0, 35.0, false, 10) or {}
            if #candidates > 0 then
                local targetNodeId = candidates[math.random(1, #candidates)]
                local targetNode = MzansiNodes[targetNodeId]
                if targetNode then
                    -- MTA has no movePed — face target and walk with control state
                    local angle = math.deg(math.atan2(targetNode[2] - py, targetNode[1] - px))
                    setElementRotation(ped, 0, 0, angle)
                    setPedAnimation(ped, "PED", "WALK_player", -1, true, false, false)
                    setTimer(function()
                        if isElement(ped) and not isPedDead(ped) then
                            setPedAnimation(ped)
                        end
                    end, math.random(2500, 4500), 1)
                end
            else
                -- No nearby nodes: just play a civilian idle animation
                local anim = IDLE_ANIMS.civilian[math.random(1, #IDLE_ANIMS.civilian)]
                setPedAnimation(ped, anim[1], anim[2], -1, true, false, false)
            end
        end

        scheduleWander(ped)
    end, delay, 1)
end

-- Hook into ped spawning to attach wander AI
local _originalSpawnPedAtNode = MzansiLiving.Spawner and MzansiLiving.Spawner.spawnPedAtNode
if _originalSpawnPedAtNode then
    MzansiLiving.Spawner.spawnPedAtNode = function(nodeId, model, archetype, zone)
        local ped = _originalSpawnPedAtNode(nodeId, model, archetype, zone)
        if ped then
            -- Attach wander timer to all ambient (non-landmark) peds
            if not getElementData(ped, "mzansi:ai:landmark") then
                setElementData(ped, "mzansi:ai:wander", true)
                scheduleWander(ped)
            end
        end
        return ped
    end
end

-- ==============================================================
-- DANGER AWARENESS: Peds flee explosions and nearby gunfire
-- Monitors onExplosion events — any ped within 30m flees for 15s
-- ==============================================================
addEventHandler("onExplosion", root, function(x, y, z, type)
    local allPeds = getElementsByType("ped", root, true)
    for _, ped in ipairs(allPeds) do
        if isElement(ped) and not isPedDead(ped) and not getElementData(ped, "mzansi:ai:landmark") then
            local px, py, pz = getElementPosition(ped)
            local dist = getDistanceBetweenPoints3D(x, y, z, px, py, pz)
            if dist <= 30.0 then
                -- Mark ped as fleeing; AI wander will not override until cleared
                setElementData(ped, "mzansi:ai:fleeing", true)
                -- MTA has no setPedFleeing — face away from blast and sprint
                local awayAngle = math.deg(math.atan2(py - y, px - x))
                setElementRotation(ped, 0, 0, awayAngle)
                setPedAnimation(ped, "PED", "run_civi", -1, true, false, false)

                -- Auto-recover after 15 seconds
                setTimer(function()
                    if isElement(ped) and not isPedDead(ped) then
                        setElementData(ped, "mzansi:ai:fleeing", false)
                        -- Resume idle animation
                        local anim = IDLE_ANIMS.civilian[math.random(1, #IDLE_ANIMS.civilian)]
                        setPedAnimation(ped, anim[1], anim[2], -1, true, false, false)
                    end
                end, 15000, 1)
            end
        end
    end
end)

-- Peds within 20m of a weapon discharge also scatter (fear response)
addEventHandler("onPlayerWeaponFire", root, function(weapon, ammo, ammoInClip, hitX, hitY, hitZ, hitElement)
    local sx, sy, sz = getElementPosition(source)
    local allPeds = getElementsByType("ped", root, true)
    for _, ped in ipairs(allPeds) do
        if isElement(ped) and not isPedDead(ped) and not getElementData(ped, "mzansi:ai:landmark") then
            local px, py, pz = getElementPosition(ped)
            -- Only civilians panic (not gang peds in their turf)
            local gangZone = getGangZoneAtPos(px, py)
            if not gangZone then
                local dist = getDistanceBetweenPoints3D(sx, sy, sz, px, py, pz)
                if dist <= 20.0 and not getElementData(ped, "mzansi:ai:fleeing") then
                    setElementData(ped, "mzansi:ai:fleeing", true)
                    -- MTA has no setPedFleeing — face away from shooter and sprint
                    local sx2, sy2, sz2 = sx, sy, sz
                    local awayAngle = math.deg(math.atan2(py - sy2, px - sx2))
                    setElementRotation(ped, 0, 0, awayAngle)
                    setPedAnimation(ped, "PED", "run_civi", -1, true, false, false)
                    setTimer(function()
                        if isElement(ped) and not isPedDead(ped) then
                            setElementData(ped, "mzansi:ai:fleeing", false)
                        end
                    end, 10000, 1)
                end
            end
        end
    end
end)

-- Gang peds in turf react to players entering their zone — they face and watch
addEventHandler("onPlayerSpawn", root, function()
    local player = source
    setTimer(function()
        if not isElement(player) then return end
        local px, py, pz = getElementPosition(player)
        local gangZone = getGangZoneAtPos(px, py)
        if gangZone then
            -- Notify gang peds nearby that a player has entered
            local allPeds = getElementsByType("ped", root, true)
            for _, ped in ipairs(allPeds) do
                if isElement(ped) and not isPedDead(ped) and not getElementData(ped, "mzansi:ai:landmark") then
                    local epx, epy, epz = getElementPosition(ped)
                    if getDistanceBetweenPoints3D(px, py, pz, epx, epy, epz) <= 12.0 then
                        -- Face the player
                        local angle = math.deg(math.atan2(px - epx, py - epy))
                        if angle < 0 then angle = angle + 360 end
                        setElementRotation(ped, 0, 0, angle)
                        -- Play watchful animation
                        setPedAnimation(ped, "GANGS", "prtial_gngtlkA", 3000, false, false, false)
                    end
                end
            end
        end
    end, 1200, 1)
end)

outputDebugString("[Mzansi-LivingWorld] NPC Intelligence Engine loaded: wander AI, gang awareness, explosion/gunfire flee response.")
