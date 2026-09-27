-- ==============================================================
-- MZANSI ROLEPLAY: MINIBUS TAXI SIMULATION SYSTEM
-- Angel: Minibus Taxi Transit Dispatcher & Route Orchestrator
-- ==============================================================

Mzansi = Mzansi or {}
Mzansi.Taxi = {}
Mzansi.Taxi._taxis = {}
Mzansi.Taxi._passengerFares = 15 -- R15 standard township fare

-- South African Minibus Taxi Hubs
local TAXI_RANKS = {
    { id = "commerce",  name = "Commerce Main Taxi Rank",   x = 1785.0, y = -1700.0, z = 13.5, rot = 180 },
    { id = "idlewood",  name = "Idlewood Corner Rank",       x = 1955.0, y = -1750.0, z = 13.5, rot = 90  },
    { id = "soweto",    name = "Soweto / Ganton Station",   x = 2240.0, y = -1665.0, z = 15.0, rot = 270 },
    { id = "cbd",       name = "Joburg CBD Market Street",  x = 1485.0, y = -1660.0, z = 13.5, rot = 0   },
    { id = "hospital",  name = "All Saints Hospital Stop",  x = 1180.0, y = -1340.0, z = 13.5, rot = 90  },
}

-- Predefined taxi circuit waypoints
local TAXI_ROUTES = {
    [1] = {
        driverName = "Bra Vusi (Taxi Operator)",
        driverSkin = 143,
        vehicleModel = 420, -- Cabby / Minibus Taxi
        color = { 255, 255, 255 }, -- Traditional White Quantum
        stops = {
            { x = 1785.0, y = -1700.0, z = 13.5, name = "Commerce Rank" },
            { x = 1955.0, y = -1750.0, z = 13.5, name = "Idlewood Corner" },
            { x = 2240.0, y = -1665.0, z = 15.0, name = "Soweto / Ganton" },
            { x = 2050.0, y = -1600.0, z = 13.5, name = "East LS Strip" },
            { x = 1785.0, y = -1700.0, z = 13.5, name = "Commerce Rank" },
        }
    },
    [2] = {
        driverName = "Malume Jabu (Quantum Driver)",
        driverSkin = 142,
        vehicleModel = 438, -- Cabbie
        color = { 255, 255, 255 },
        stops = {
            { x = 1485.0, y = -1660.0, z = 13.5, name = "Joburg CBD Market" },
            { x = 1180.0, y = -1340.0, z = 13.5, name = "All Saints Hospital" },
            { x = 1485.0, y = -1660.0, z = 13.5, name = "Joburg CBD Market" },
            { x = 1785.0, y = -1700.0, z = 13.5, name = "Commerce Rank" },
        }
    }
}

-- Initialize Minibus Taxis
function Mzansi.Taxi.init()
    outputDebugString("[Mzansi-Taxi] Angel: Minibus Taxi Transit Dispatcher initializing...")

    for i, route in ipairs(TAXI_ROUTES) do
        local start = route.stops[1]
        local veh = createVehicle(route.vehicleModel, start.x, start.y, start.z, 0, 0, 0, "MZ-TAXI" .. i)
        if veh then
            setVehicleColor(veh, route.color[1], route.color[2], route.color[3], 0, 0, 0)
            setElementData(veh, "mzansi:fuel", 100)
            setElementData(veh, "mzansi:isTaxi", true)
            setElementData(veh, "mzansi:taxiRouteId", i)
            setElementData(veh, "mzansi:currentStop", 1)

            -- Spawn the authentic SA Taxi Driver NPC
            local driver = createPed(route.driverSkin, start.x, start.y, start.z + 1)
            if driver then
                warpPedIntoVehicle(driver, veh, 0)
                setElementData(driver, "mzansi:isNPC", true)
                setElementData(driver, "mzansi:npcName", route.driverName)
                setElementData(driver, "mzansi:isTaxiDriver", true)
                setElementData(veh, "mzansi:taxiDriver", driver)
                addEventHandler("onPedDamage", driver, cancelEvent)
            end

            table.insert(Mzansi.Taxi._taxis, {
                vehicle = veh,
                driver = driver,
                route = route,
                currentStop = 1,
                isStopped = false,
                waitTime = 0
            })
        end
    end

    -- Angel: Route Progression Tick Loop (runs every 3 seconds)
    setTimer(Mzansi.Taxi.updateRoutes, 3000, 0)
    outputDebugString("[Mzansi-Taxi] Minibus Taxi System operational with " .. #Mzansi.Taxi._taxis .. " active routes.")
end

-- Progress taxi along circuit waypoints
function Mzansi.Taxi.updateRoutes()
    for _, taxiData in ipairs(Mzansi.Taxi._taxis) do
        local veh = taxiData.vehicle
        local driver = taxiData.driver

        if isElement(veh) and isElement(driver) and getVehicleOccupant(veh, 0) == driver then
            local currentStop = taxiData.route.stops[taxiData.currentStop]
            local vx, vy, vz = getElementPosition(veh)
            local dist = getDistanceBetweenPoints3D(vx, vy, vz, currentStop.x, currentStop.y, currentStop.z)

            if dist < 12 then
                -- Reached stop: wait 15 seconds to let passengers embark/disembark
                if not taxiData.isStopped then
                    taxiData.isStopped = true
                    taxiData.waitTime = getTickCount() + 15000
                    setVehicleEngineState(veh, false)
                    setElementVelocity(veh, 0, 0, 0)

                    -- Taxi driver callout at rank
                    local callouts = {
                        "Bree! Noord! Soweto! Ngena lapho!",
                        "Short left available! R15 to town!",
                        "Two more spaces in the front! Asambeni!",
                        "Pass the change forward, please!"
                    }
                    local shout = callouts[math.random(1, #callouts)]
                    for _, player in ipairs(getElementsByType("player")) do
                        local px, py, pz = getElementPosition(player)
                        if getDistanceBetweenPoints3D(px, py, pz, vx, vy, vz) < 35 then
                            outputChatBox("[Taxi Rank] " .. taxiData.route.driverName .. ": \"" .. shout .. "\"", player, 255, 180, 50)
                        end
                    end
                elseif getTickCount() >= taxiData.waitTime then
                    -- Resume driving to next waypoint
                    taxiData.isStopped = false
                    taxiData.currentStop = (taxiData.currentStop % #taxiData.route.stops) + 1
                    setVehicleEngineState(veh, true)
                end
            else
                -- Drive towards target waypoint
                setVehicleEngineState(veh, true)
                local targetX = currentStop.x
                local targetY = currentStop.y
                local angle = (360 - math.deg(math.atan2(targetX - vx, targetY - vy))) % 360
                setElementRotation(veh, 0, 0, angle)
                local rad = math.rad(angle)
                local driveSpeed = 0.22 -- ~40 km/h in MTA velocity units
                setElementVelocity(veh, -math.sin(rad) * driveSpeed, math.cos(rad) * driveSpeed, 0)
            end
        end
    end
end

-- Passenger entry handler (Player enters minibus taxi)
addEventHandler("onPlayerVehicleEnter", root, function(veh, seat)
    if seat > 0 and getElementData(veh, "mzansi:isTaxi") then
        local driver = getElementData(veh, "mzansi:taxiDriver")
        local driverName = isElement(driver) and (getElementData(driver, "mzansi:npcName") or "Bra Vusi") or "Taxi Operator"

        outputChatBox("═══════════════════════════════════════════════════════", source, 255, 180, 0)
        outputChatBox("[Taxi] " .. driverName .. ": \"Sho! Welcome aboard the Quantum!\"", source, 255, 220, 100)
        outputChatBox("[Taxi] Standard fare: R " .. Mzansi.Taxi._passengerFares .. ". Type /shortleft or /afterrobot to hop off.", source, 200, 200, 200)
        outputChatBox("═══════════════════════════════════════════════════════", source, 255, 180, 0)

        -- Deduct fare if player has money
        if exports.mzansi_core and exports.mzansi_core.removeCash then
            local paid = exports.mzansi_core:removeCash(source, Mzansi.Taxi._passengerFares)
            if paid then
                outputChatBox("[Taxi] Paid R " .. Mzansi.Taxi._passengerFares .. " fare to driver.", source, 100, 255, 100)
            else
                outputChatBox("[Taxi] " .. driverName .. ": \"Eish, no cash? Don't stress mfowethu, ride on!\"", source, 255, 150, 50)
            end
        end
    end
end)

-- Command: /shortleft or /afterrobot to disembark
addCommandHandler("shortleft", function(player)
    local veh = getPedOccupiedVehicle(player)
    if veh and getElementData(veh, "mzansi:isTaxi") then
        removePedFromVehicle(player)
        local vx, vy, vz = getElementPosition(player)
        setElementPosition(player, vx + 2, vy + 2, vz)
        outputChatBox("[Taxi] Driver: \"Sho! Short left right here. Sharp fowethu!\"", player, 255, 200, 50)
    else
        outputChatBox("You must be riding inside a Minibus Taxi to request a short left.", player, 255, 100, 100)
    end
end)

addCommandHandler("afterrobot", function(player)
    executeCommandHandler("shortleft", player)
end)

-- Start taxi transit system on core startup
addEventHandler("onResourceStart", resourceRoot, function()
    setTimer(Mzansi.Taxi.init, 2000, 1)
end)
