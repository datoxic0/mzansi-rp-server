-- ==============================================================
-- MZANSI LIVING WORLD — SERVER TRAFFIC ENGINE
-- Roadway vehicle population & authentic GTA SA vehicle traffic
-- ==============================================================
MzansiLiving = MzansiLiving or {}
MzansiLiving.Traffic = {}

local _activeVehicles = {}

-- Authentic civilian vehicle model pool
local TRAFFIC_VEHICLES = {
    400, -- Landstalker (SUV)
    401, -- Bravura
    404, -- Perennial (Station Wagon)
    405, -- Sentinel (Executive Sedan)
    410, -- Manana (Compact)
    418, -- Moonbeam (Minivan)
    420, -- Taxi (Los Santos Cabs)
    421, -- Washington (Luxury Sedan)
    422, -- Bobcat (Pickup Truck)
    426, -- Premier (Standard Sedan)
    436, -- Previon
    458, -- Solair (Estate)
    466, -- Glendale
    467, -- Oceanic
    479, -- Regina
    492, -- Greenwood
    516, -- Nebula
    526, -- Fortune
    527, -- Cadrona
    529, -- Willard
    540, -- Vincent
    542, -- Clover
    546, -- Intruder
    550, -- Sunrise
    560, -- Sultan (Sport Sedan)
    579, -- Huntley (Luxury SUV)
    580, -- Stafford (Vintage Sedan)
    585  -- Emperor
}

local DRIVER_SKINS = {
    7, 14, 17, 19, 21, 28, 29, 40, 59, 60, 98, 102, 141, 147, 150, 186, 187, 216, 227, 228, 240, 295
}

-- Spawns an ambient traffic vehicle at a road node heading towards a linked node
function MzansiLiving.Traffic.spawnVehicleAtRoadNode(nodeId, model)
    if not MzansiRoadNodes then return nil end
    local node = MzansiRoadNodes[nodeId]
    if not node then return nil end

    local x, y, z = node[1], node[2], node[3]
    local links = node[4]
    if not links or #links == 0 then return nil end

    local targetNodeId = links[math.random(1, #links)]
    local targetNode = MzansiRoadNodes[targetNodeId]
    if not targetNode then return nil end

    -- Safety check: abort if any player is within 10m of spawn point
    for _, player in ipairs(getElementsByType("player")) do
        local px, py, pz = getElementPosition(player)
        if getDistanceBetweenPoints3D(x, y, z, px, py, pz) < 10.0 then
            return nil  -- too close to a player; skip this spawn
        end
    end

    -- Safety check: abort if another traffic vehicle is already within 6m
    for _, veh in ipairs(_activeVehicles) do
        if isElement(veh) then
            local vx, vy, vz = getElementPosition(veh)
            if getDistanceBetweenPoints3D(x, y, z, vx, vy, vz) < 6.0 then
                return nil
            end
        end
    end

    -- Calculate heading rotation towards target node
    local tx, ty = targetNode[1], targetNode[2]
    local headingRad = math.atan2(ty - y, tx - x)
    local rotZ = math.deg(headingRad) - 90
    if rotZ < 0 then rotZ = rotZ + 360 end

    -- Apply a lateral lane offset (1.8m to the left of the travel direction)
    -- This simulates the left lane and prevents spawning dead centre of the road
    local perpX = -math.sin(headingRad) * 1.8
    local perpY =  math.cos(headingRad) * 1.8
    local spawnX = x + perpX
    local spawnY = y + perpY

    -- Pick model
    if not model then
        model = TRAFFIC_VEHICLES[math.random(1, #TRAFFIC_VEHICLES)]
    end

    -- Create vehicle element (z + 0.6 so it settles onto road surface)
    local veh = createVehicle(model, spawnX, spawnY, z + 0.6, 0, 0, rotZ)
    if not veh then return nil end

    -- Pick random authentic color
    local r1, g1, b1 = math.random(30, 220), math.random(30, 220), math.random(30, 220)
    local r2, g2, b2 = math.random(30, 220), math.random(30, 220), math.random(30, 220)
    setVehicleColor(veh, r1, g1, b1, r2, g2, b2)

    -- Start engine after 800ms settling delay (avoids collision on spawn)
    setVehicleEngineState(veh, false)
    setTimer(function()
        if isElement(veh) then setVehicleEngineState(veh, true) end
    end, 800, 1)

    setElementData(veh, "mzansi:engine", true)
    setElementData(veh, "mzansi:fuel", 100)

    -- Create civilian driver ped
    local skin = DRIVER_SKINS[math.random(1, #DRIVER_SKINS)]
    local driver = createPed(skin, spawnX, spawnY, z + 0.5)
    if driver then
        warpPedIntoVehicle(driver, veh, 0)
        setElementData(driver, "mzansi:traffic:driver", true)
        setElementData(driver, "mzansi:ai:enabled", false)
        -- NOTE: setPedCanBeKnockedOffBike is CLIENT-ONLY — handled in traffic_controller.lua
    end

    -- Networked traffic metadata
    setElementData(veh, "mzansi:traffic:vehicle", true)
    setElementData(veh, "mzansi:traffic:driverPed", driver)
    setElementData(veh, "mzansi:traffic:currentNode", nodeId)
    setElementData(veh, "mzansi:traffic:targetNode", targetNodeId)

    table.insert(_activeVehicles, veh)
    return veh
end


-- Safely cleans up a traffic vehicle and its driver ped
function MzansiLiving.Traffic.recycleVehicle(veh)
    if not isElement(veh) then return end
    for i = #_activeVehicles, 1, -1 do
        if _activeVehicles[i] == veh then
            table.remove(_activeVehicles, i)
            break
        end
    end
    local driver = getElementData(veh, "mzansi:traffic:driverPed")
    if isElement(driver) then
        destroyElement(driver)
    end
    destroyElement(veh)
end

-- Returns valid list of active traffic vehicles
function MzansiLiving.Traffic.getActiveVehicles()
    local valid = {}
    for i = #_activeVehicles, 1, -1 do
        local v = _activeVehicles[i]
        if isElement(v) then
            table.insert(valid, v)
        else
            table.remove(_activeVehicles, i)
        end
    end
    return valid
end

-- Client reports vehicle reached road node; pick next connected link
addEvent("mzansi:traffic:nodeReached", true)
addEventHandler("mzansi:traffic:nodeReached", root, function(reachedNodeId)
    local veh = source
    if not isElement(veh) or not getElementData(veh, "mzansi:traffic:vehicle") then return end

    local node = MzansiRoadNodes[reachedNodeId]
    if not node then return end

    local links = node[4]
    if links and #links > 0 then
        local prevNode = getElementData(veh, "mzansi:traffic:currentNode")
        local candidates = {}
        for _, nId in ipairs(links) do
            if nId ~= prevNode then
                table.insert(candidates, nId)
            end
        end

        local nextNode = nil
        if #candidates > 0 then
            nextNode = candidates[math.random(1, #candidates)]
        else
            nextNode = links[math.random(1, #links)]
        end

        setElementData(veh, "mzansi:traffic:currentNode", reachedNodeId)
        setElementData(veh, "mzansi:traffic:targetNode", nextNode)
    end
end)

-- Clean up dead/wasted drivers and blown vehicles
addEventHandler("onVehicleExplode", root, function()
    local veh = source
    if getElementData(veh, "mzansi:traffic:vehicle") then
        setTimer(function()
            if isElement(veh) then
                MzansiLiving.Traffic.recycleVehicle(veh)
            end
        end, 5000, 1)
    end
end)

-- Resource stop cleanup
addEventHandler("onResourceStop", resourceRoot, function()
    for _, veh in ipairs(_activeVehicles) do
        if isElement(veh) then
            local driver = getElementData(veh, "mzansi:traffic:driverPed")
            if isElement(driver) then destroyElement(driver) end
            destroyElement(veh)
        end
    end
    _activeVehicles = {}
end)
