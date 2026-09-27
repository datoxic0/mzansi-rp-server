Mzansi = Mzansi or {}
Mzansi.World = Mzansi.World or {}

local ambientPeds = {
    { model = 7, x = 1520.3, y = -1668.0, z = 13.4, rot = 180, role = "civilian" },
    { model = 20, x = 1503.6, y = -1668.0, z = 13.4, rot = 225, role = "civilian" },
    { model = 50, x = 1509.1, y = -1656.5, z = 13.4, rot = 90, role = "mechanic" },
    { model = 68, x = 1540.8, y = -1688.0, z = 13.4, rot = 180, role = "business" },
    { model = 54, x = 1177.8, y = -1323.5, z = 13.4, rot = 0, role = "ems" },
    { model = 17, x = 1517.0, y = -1663.4, z = 13.4, rot = 60, role = "civilian" },
    { model = 21, x = 1513.7, y = -1671.0, z = 13.4, rot = 210, role = "civilian" },
    { model = 24, x = 1498.2, y = -1658.8, z = 13.4, rot = 140, role = "civilian" },
    { model = 141, x = 1530.3, y = -1650.0, z = 13.4, rot = 320, role = "civilian" },
    { model = 154, x = 1538.1, y = -1674.4, z = 13.4, rot = 220, role = "business" },
    { model = 43, x = 1485.0, y = -1640.4, z = 13.4, rot = 0, role = "civilian" },
    { model = 31, x = 1478.4, y = -1679.0, z = 13.4, rot = 10, role = "civilian" },
    { model = 57, x = 1510.6, y = -1690.1, z = 13.4, rot = 180, role = "civilian" },
    { model = 116, x = 1545.8, y = -1638.0, z = 13.4, rot = 90, role = "civilian" },
    { model = 71, x = 1574.6, y = -1650.1, z = 13.4, rot = 270, role = "civilian" },
    { model = 45, x = 1700.9, y = -1499.1, z = 13.4, rot = 90, role = "civilian" },
    { model = 113, x = 1705.6, y = -1481.9, z = 13.4, rot = 180, role = "business" },
    { model = 211, x = 1712.0, y = -1468.3, z = 13.4, rot = 90, role = "government" },
    { model = 70, x = 2449.7, y = -1959.8, z = 13.4, rot = 180, role = "civilian" },
    { model = 69, x = 2455.0, y = -1954.5, z = 13.4, rot = 90, role = "civilian" },
    { model = 14, x = 2335.4, y = -1670.6, z = 13.4, rot = 0, role = "civilian" },
    { model = 18, x = 2255.4, y = -1967.1, z = 13.4, rot = 0, role = "civilian" },
    { model = 79, x = 1699.0, y = -2131.0, z = 13.4, rot = 180, role = "airport" },
    { model = 57, x = 1710.7, y = -2142.6, z = 13.4, rot = 90, role = "airport" },
    { model = 106, x = 1725.4, y = -2160.0, z = 13.4, rot = 270, role = "airport" },
    { model = 128, x = 1746.3, y = -2184.0, z = 13.4, rot = 35, role = "airport" },
}

local trafficVehicles = {
    { model = 562, x = 1512.0, y = -1661.4, z = 13.6, rot = 270, role = "traffic" },
    { model = 496, x = 1501.0, y = -1670.9, z = 13.6, rot = 90, role = "traffic" },
    { model = 415, x = 1492.0, y = -1660.5, z = 13.6, rot = 180, role = "traffic" },
    { model = 480, x = 1530.0, y = -1663.0, z = 13.6, rot = 90, role = "traffic" },
    { model = 421, x = 1548.0, y = -1668.0, z = 13.6, rot = 0, role = "traffic" },
    { model = 402, x = 1705.0, y = -1490.0, z = 13.6, rot = 180, role = "traffic" },
    { model = 579, x = 1700.0, y = -1480.0, z = 13.6, rot = 270, role = "traffic" },
    { model = 589, x = 1715.0, y = -1472.0, z = 13.6, rot = 0, role = "traffic" },
    { model = 411, x = 1740.0, y = -2166.0, z = 13.6, rot = 90, role = "airport" },
    { model = 417, x = 1763.0, y = -2160.0, z = 13.6, rot = 0, role = "airport" },
    { model = 487, x = 1720.0, y = -2130.0, z = 13.6, rot = 90, role = "airport" },
}

local serviceZones = {
    {
        name = "Johannesburg Repair Bay",
        type = "repair",
        x = 1505.8,
        y = -1664.2,
        z = 13.4,
        blip = 32,
        upgrade = nil,
    },
    {
        name = "Cape Town Mod Shop",
        type = "mod",
        x = 1520.0,
        y = -1676.9,
        z = 13.4,
        blip = 27,
        upgrade = 1000,
    },
    {
        name = "Pretoria Government Hub",
        type = "service",
        x = 1704.0,
        y = -1491.2,
        z = 13.4,
        blip = 41,
        upgrade = nil,
    },
    {
        name = "Los Santos Airport Terminal",
        type = "airport",
        x = 1730.0,
        y = -2142.0,
        z = 13.4,
        blip = 37,
        upgrade = nil,
    },
    {
        name = "Central Taxi Rank",
        type = "taxi",
        x = 1490.8,
        y = -1662.3,
        z = 13.4,
        blip = 56,
        upgrade = nil,
    },
}

local function safeCreatePed(pedConfig)
    local ped = createPed(pedConfig.model, pedConfig.x, pedConfig.y, pedConfig.z, pedConfig.rot)
    if ped then
        setElementFrozen(ped, true)
        setElementData(ped, "mzansi:pedRole", pedConfig.role)
        setElementData(ped, "mzansi:pedAmbient", true)
        setPedAnimation(ped, "COP_AMBIENT", "Coplook_loop", -1, true, false, false)
        return ped
    end
    return nil
end

local function safeCreateVehicle(vehicleConfig)
    local vehicle = createVehicle(vehicleConfig.model, vehicleConfig.x, vehicleConfig.y, vehicleConfig.z, 0, 0, vehicleConfig.rot)
    if vehicle then
        setVehicleDamageProof(vehicle, true)
        setElementFrozen(vehicle, false)
        setElementData(vehicle, "mzansi:vehicleRole", vehicleConfig.role)
        setElementData(vehicle, "mzansi:vehicleAmbient", true)
        return vehicle
    end
    return nil
end

local function spawnAmbientPeds()
    for _, pedConfig in ipairs(ambientPeds) do
        safeCreatePed(pedConfig)
    end
end

local function spawnTrafficVehicles()
    for _, vehicleConfig in ipairs(trafficVehicles) do
        safeCreateVehicle(vehicleConfig)
    end
end

local function createServiceZone(zone)
    local marker = createMarker(zone.x, zone.y, zone.z - 1, "cylinder", 2.8, 255, 170, 0, 180)
    if marker then
        setElementData(marker, "mzansi:serviceType", zone.type)
        setElementData(marker, "mzansi:serviceName", zone.name)
        createBlip(zone.x, zone.y, zone.z, zone.blip or 32, 2, 255, 170, 0, 255, 0, 99999.0)

        addEventHandler("onMarkerHit", marker, function(hitPlayer, matchingDimension)
            if not matchingDimension or getElementType(hitPlayer) ~= "player" then
                return
            end

            if zone.type == "repair" then
                if isPedInVehicle(hitPlayer) then
                    local vehicle = getPedOccupiedVehicle(hitPlayer)
                    if vehicle then
                        fixVehicle(vehicle)
                        outputChatBox("[Mzansi-ZA] " .. zone.name .. " repaired your vehicle.", hitPlayer, 0, 255, 120)
                    end
                else
                    outputChatBox("[Mzansi-ZA] Enter a vehicle before using the repair bay.", hitPlayer, 255, 200, 0)
                end
            elseif zone.type == "mod" then
                if isPedInVehicle(hitPlayer) then
                    local vehicle = getPedOccupiedVehicle(hitPlayer)
                    if vehicle then
                        local upgrade = zone.upgrade or 1000
                        addVehicleUpgrade(vehicle, upgrade)
                        outputChatBox("[Mzansi-ZA] " .. zone.name .. " applied a performance upgrade.", hitPlayer, 0, 255, 120)
                    end
                else
                    outputChatBox("[Mzansi-ZA] Enter a vehicle before using the mod shop.", hitPlayer, 255, 200, 0)
                end
            elseif zone.type == "airport" then
                outputChatBox("[Mzansi-ZA] " .. zone.name .. " is active. Nearby flights, arrivals, and terminals are open for roleplay travel.", hitPlayer, 195, 225, 255)
            elseif zone.type == "taxi" then
                outputChatBox("[Mzansi-ZA] Taxi dispatch is active at " .. zone.name .. ". Use your vehicle to transport citizens around town.", hitPlayer, 255, 225, 120)
            elseif zone.type == "service" then
                outputChatBox("[Mzansi-ZA] " .. zone.name .. " is available for business, faction, and civic roleplay operations.", hitPlayer, 120, 255, 190)
            end
        end)
    end
end

local function createServiceZones()
    for _, zone in ipairs(serviceZones) do
        createServiceZone(zone)
    end
end

local function bootstrapWorld()
    spawnAmbientPeds()
    spawnTrafficVehicles()
    createServiceZones()
end

addEventHandler("onResourceStart", resourceRoot, function()
    bootstrapWorld()
end)
