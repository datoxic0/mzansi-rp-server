Mzansi = Mzansi or {}
Mzansi.Vehicles = {}
Mzansi.Vehicles._spawned = {}
Mzansi.Vehicles._byPlate = {}
Mzansi.Vehicles._byElement = {}

addEvent("mzansi:vehicles:requestKeys", true)
addEvent("mzansi:vehicles:lock", true)
addEvent("mzansi:vehicles:engine", true)
addEvent("mzansi:vehicles:spawn", true)
addEvent("mzansi:vehicles:despawn", true)
addEvent("mzansi:vehicles:respawn", true)
addEvent("mzansi:vehicles:refuel", true)

function Mzansi.Vehicles.spawnVehicle(dbData)
    if not dbData then return nil end

    local x, y, z = dbData.x, dbData.y, dbData.z
    if x == 0 and y == 0 and z == 0 then
        x, y, z = 1500 + math.random(-200, 200), -1600 + math.random(-200, 200), 14
    end

    local vehicle = createVehicle(
        dbData.model_id,
        x, y, z,
        0, 0, dbData.rotation or 0,
        dbData.plate
    )

    if not vehicle then return nil end

    setElementHealth(vehicle, dbData.health or 1000)
    setElementData(vehicle, "mzansi:vehicleId", dbData.id)
    setElementData(vehicle, "mzansi:plate", dbData.plate)
    setElementData(vehicle, "mzansi:ownerId", dbData.owner_id)
    setElementData(vehicle, "mzansi:fuel", dbData.fuel or 100)
    setElementData(vehicle, "mzansi:mileage", dbData.mileage or 0)
    setElementData(vehicle, "mzansi:locked", dbData.locked == 1)
    setElementData(vehicle, "mzansi:factionId", dbData.faction_id or 0)

    if dbData.color1 and dbData.color2 then
        setVehicleColor(vehicle, dbData.color1, dbData.color2, dbData.color1, dbData.color2)
    end

    if dbData.upgrades and dbData.upgrades ~= "" then
        local upgrades = fromJSON(dbData.upgrades)
        if upgrades then
            for _, upgrade in ipairs(upgrades) do
                addVehicleUpgrade(vehicle, upgrade)
            end
        end
    end

    Mzansi.Vehicles._spawned[dbData.id] = vehicle
    Mzansi.Vehicles._byPlate[dbData.plate] = vehicle
    Mzansi.Vehicles._byElement[vehicle] = dbData

    return vehicle
end

function Mzansi.Vehicles.createPlayerVehicle(source, modelId, x, y, z)
    local char = Mzansi.Characters.getCharacter(source)
    if not char then return nil, "Not logged in." end

    local vehicleCount = #Mzansi.Database.getPlayerVehicles(char.id)
    if vehicleCount >= Mzansi.Config.Server.maxVehiclesPerPlayer then
        return nil, "You already own the maximum number of vehicles."
    end

    local plate = Mzansi.Util.generatePlate()
    while Mzansi.Database.getVehicle(plate) do
        plate = Mzansi.Util.generatePlate()
    end

    local charX, charY, charZ = getElementPosition(source)
    local vehicleId = Mzansi.Database.createVehicle(
        char.id, modelId, plate,
        x or charX, y or charY, z or charZ, 0, 0, 0
    )

    if vehicleId then
        local dbData = {
            id = vehicleId,
            owner_id = char.id,
            model_id = modelId,
            plate = plate,
            x = x or charX,
            y = y or charY,
            z = z or charZ,
            rotation = 0,
            health = 1000,
            fuel = 100,
            mileage = 0,
            color1 = 0,
            color2 = 0,
            locked = 1,
            faction_id = 0,
        }
        local vehicle = Mzansi.Vehicles.spawnVehicle(dbData)
        if vehicle then
            Mzansi.Util.sendNotification(source, "Vehicle spawned: " .. getVehicleName(vehicle) .. " [" .. plate .. "]", "success")
            return vehicle
        end
    end
    return nil, "Failed to create vehicle."
end

function Mzansi.Vehicles.loadPlayerVehicles(source)
    local char = Mzansi.Characters.getCharacter(source)
    if not char then return end

    local vehicles = Mzansi.Database.getPlayerVehicles(char.id)
    for _, vData in ipairs(vehicles) do
        Mzansi.Vehicles.spawnVehicle(vData)
    end
end

function Mzansi.Vehicles.savePlayerVehicles(source)
    local char = Mzansi.Characters.getCharacter(source)
    if not char then return end

    for plate, vehicle in pairs(Mzansi.Vehicles._byPlate) do
        local dbData = Mzansi.Vehicles._byElement[vehicle]
        if dbData and dbData.owner_id == char.id and isElement(vehicle) then
            local x, y, z = getElementPosition(vehicle)
            local rx, ry, rz = getElementRotation(vehicle)
            local health = getElementHealth(vehicle)
            local fuel = getElementData(vehicle, "mzansi:fuel") or 100
            local mileage = getElementData(vehicle, "mzansi:mileage") or dbData.mileage or 0
            Mzansi.Database.saveVehicle(dbData.id, {
                x = x, y = y, z = z,
                rotation = rz,
                health = health,
                fuel = fuel,
                mileage = mileage,
            })
        end
    end
end

function createPlayerVehicle(source, modelId, x, y, z)
    return Mzansi.Vehicles.createPlayerVehicle(source, modelId, x, y, z)
end

function loadPlayerVehicles(source)
    return Mzansi.Vehicles.loadPlayerVehicles(source)
end

function savePlayerVehicles(source)
    return Mzansi.Vehicles.savePlayerVehicles(source)
end

function Mzansi.Vehicles.toggleLock(source)
    local vehicle = getPedOccupiedVehicle(source)
    if not vehicle then
        local px, py, pz = getElementPosition(source)
        local closestDist = 6.0
        for _, veh in ipairs(getElementsByType("vehicle")) do
            local vx, vy, vz = getElementPosition(veh)
            local dist = getDistanceBetweenPoints3D(px, py, pz, vx, vy, vz)
            if dist < closestDist then
                vehicle = veh
                closestDist = dist
            end
        end
    end

    if not vehicle then
        Mzansi.Util.sendNotification(source, "No vehicle nearby to lock/unlock.", "error")
        return false
    end

    local locked = isVehicleLocked(vehicle)
    setVehicleLocked(vehicle, not locked)
    setElementData(vehicle, "mzansi:locked", not locked)

    if not locked then
        Mzansi.Util.sendNotification(source, "Vehicle doors locked.", "info")
    else
        Mzansi.Util.sendNotification(source, "Vehicle doors unlocked.", "success")
    end
    return true
end

function Mzansi.Vehicles.toggleEngine(source)
    local vehicle = getPedOccupiedVehicle(source)
    if not vehicle then
        Mzansi.Util.sendNotification(source, "You must be inside a vehicle to toggle the engine.", "error")
        return false
    end

    local fuel = getElementData(vehicle, "mzansi:fuel")
    if fuel == nil then
        fuel = 100
        setElementData(vehicle, "mzansi:fuel", 100)
    end

    if fuel <= 0 then
        setVehicleEngineState(vehicle, false)
        Mzansi.Util.sendNotification(source, "Fuel tank empty! Refuel at a petrol station (/refuel).", "error")
        return false
    end

    local engineRunning = getVehicleEngineState(vehicle)
    setVehicleEngineState(vehicle, not engineRunning)

    if not engineRunning then
        Mzansi.Util.sendNotification(source, "Engine started.", "success")
    else
        Mzansi.Util.sendNotification(source, "Engine stopped.", "info")
    end
    return true
end

function Mzansi.Vehicles.refuelVehicle(source)
    local vehicle = getPedOccupiedVehicle(source)
    if not vehicle then
        Mzansi.Util.sendNotification(source, "You must be inside a vehicle to refuel.", "error")
        return
    end

    local fuel = getElementData(vehicle, "mzansi:fuel") or 0
    if fuel >= 100 then
        Mzansi.Util.sendNotification(source, "Fuel tank is already full.", "info")
        return
    end

    local cost = math.ceil((100 - fuel) * 5)
    local char = Mzansi.Characters.getCharacter(source)
    if char and char.cash and char.cash < cost then
        Mzansi.Util.sendNotification(source, "You need " .. Mzansi.Util.formatMoney(cost) .. " cash to refuel.", "error")
        return
    end

    if char then Mzansi.Characters.removeCash(source, cost) end
    setElementData(vehicle, "mzansi:fuel", 100)
    Mzansi.Util.sendNotification(source, "Refueled tank to 100%! Cost: " .. Mzansi.Util.formatMoney(cost), "success")
end

addCommandHandler("engine", function(p) Mzansi.Vehicles.toggleEngine(p) end)
addCommandHandler("lock", function(p) Mzansi.Vehicles.toggleLock(p) end)
addCommandHandler("refuel", function(p) Mzansi.Vehicles.refuelVehicle(p) end)

-- ==============================================================
-- VEHICLE OWNERSHIP & SPAWNING MANAGEMENT
-- ==============================================================

function Mzansi.Vehicles.listPlayerVehicles(source)
    local char = Mzansi.Characters.getCharacter(source)
    if not char then return end

    local vehicles = Mzansi.Database.getPlayerVehicles(char.id)
    if not vehicles or #vehicles == 0 then
        Mzansi.Util.sendNotification(source, "You do not own any vehicles. Visit the dealership to purchase one.", "info")
        return
    end

    outputChatBox("🚗 --- YOUR OWNED VEHICLES (" .. #vehicles .. ") ---", source, 255, 215, 0)
    for i, vData in ipairs(vehicles) do
        local spawnedVeh = Mzansi.Vehicles._spawned[vData.id]
        local isSpawned = spawnedVeh and isElement(spawnedVeh)
        local statusText = isSpawned and "#00FF00[SPAWNED IN WORLD]#FFFFFF" or "#00CCFF[STORED IN GARAGE]#FFFFFF"
        local vehName = getVehicleNameFromModel(vData.model_id) or "Vehicle"
        outputChatBox("  #" .. i .. " " .. vehName .. " | Plate: " .. vData.plate .. " | " .. statusText, source, 255, 255, 255, true)
    end
    outputChatBox("  Type /spawncar <number or plate> to summon your vehicle!", source, 200, 200, 200)
end

function Mzansi.Vehicles.summonVehicle(source, query)
    local char = Mzansi.Characters.getCharacter(source)
    if not char then return false end

    local vehicles = Mzansi.Database.getPlayerVehicles(char.id)
    if not vehicles or #vehicles == 0 then
        Mzansi.Util.sendNotification(source, "You do not own any vehicles.", "error")
        return false
    end

    local selectedData = nil
    if not query or query == "" then
        selectedData = vehicles[1]
    else
        local idx = tonumber(query)
        if idx and vehicles[idx] then
            selectedData = vehicles[idx]
        else
            for _, v in ipairs(vehicles) do
                if string.upper(v.plate) == string.upper(query) then
                    selectedData = v
                    break
                end
            end
        end
    end

    if not selectedData then
        Mzansi.Util.sendNotification(source, "Vehicle not found. Use /mycars to see your vehicles.", "error")
        return false
    end

    local px, py, pz = getElementPosition(source)
    local rotZ = getPedRotation(source)
    local rad = math.rad(rotZ)
    local spawnX = px - math.sin(rad) * 4.0
    local spawnY = py + math.cos(rad) * 4.0
    local spawnZ = pz + 0.5

    -- If already spawned, warp it near the player
    local existingVeh = Mzansi.Vehicles._spawned[selectedData.id]
    if existingVeh and isElement(existingVeh) then
        setElementPosition(existingVeh, spawnX, spawnY, spawnZ)
        setElementRotation(existingVeh, 0, 0, rotZ)
        fixVehicle(existingVeh)
        setVehicleLocked(existingVeh, false)
        setElementData(existingVeh, "mzansi:fuel", math.max(20, getElementData(existingVeh, "mzansi:fuel") or 100))
        setVehicleEngineState(existingVeh, true)
        Mzansi.Util.sendNotification(source, "Your " .. getVehicleName(existingVeh) .. " [" .. selectedData.plate .. "] has arrived!", "success")
        return true
    end

    -- If stored, spawn from database
    selectedData.x = spawnX
    selectedData.y = spawnY
    selectedData.z = spawnZ
    selectedData.rotation = rotZ
    local veh = Mzansi.Vehicles.spawnVehicle(selectedData)
    if veh then
        setVehicleLocked(veh, false)
        setElementData(veh, "mzansi:fuel", selectedData.fuel or 100)
        setVehicleEngineState(veh, true)
        Mzansi.Util.sendNotification(source, "Spawned " .. getVehicleName(veh) .. " [" .. selectedData.plate .. "]!", "success")
        return true
    end

    Mzansi.Util.sendNotification(source, "Failed to spawn vehicle.", "error")
    return false
end

function Mzansi.Vehicles.despawnPlayerVehicle(source)
    local char = Mzansi.Characters.getCharacter(source)
    if not char then return false end

    local veh = getPedOccupiedVehicle(source)
    if not veh then
        for _, v in pairs(Mzansi.Vehicles._byPlate) do
            local d = Mzansi.Vehicles._byElement[v]
            if d and d.owner_id == char.id and isElement(v) then
                veh = v
                break
            end
        end
    end

    if not veh or not isElement(veh) then
        Mzansi.Util.sendNotification(source, "No spawned vehicle found to store.", "error")
        return false
    end

    local dbData = Mzansi.Vehicles._byElement[veh]
    if not dbData or dbData.owner_id ~= char.id then
        Mzansi.Util.sendNotification(source, "You do not own this vehicle.", "error")
        return false
    end

    local x, y, z = getElementPosition(veh)
    local _, _, rz = getElementRotation(veh)
    local health = getElementHealth(veh)
    local fuel = getElementData(veh, "mzansi:fuel") or 100

    Mzansi.Database.saveVehicle(dbData.id, {
        x = x, y = y, z = z, rotation = rz, health = health, fuel = fuel, locked = 1
    })

    if isPedInVehicle(source) then
        removePedFromVehicle(source)
    end
    destroyElement(veh)
    if Mzansi.Vehicles._spawned then Mzansi.Vehicles._spawned[dbData.id] = nil end
    if Mzansi.Vehicles._byPlate then Mzansi.Vehicles._byPlate[dbData.plate] = nil end

    Mzansi.Util.sendNotification(source, "Vehicle stored safely in garage.", "success")
    return true
end

function Mzansi.Vehicles.parkVehicle(source)
    local char = Mzansi.Characters.getCharacter(source)
    if not char then return false end

    local veh = getPedOccupiedVehicle(source)
    if not veh then
        Mzansi.Util.sendNotification(source, "You must be inside your vehicle to park it.", "error")
        return false
    end

    local dbData = Mzansi.Vehicles._byElement[veh]
    if not dbData or dbData.owner_id ~= char.id then
        Mzansi.Util.sendNotification(source, "You do not own this vehicle.", "error")
        return false
    end

    local x, y, z = getElementPosition(veh)
    local _, _, rz = getElementRotation(veh)
    local health = getElementHealth(veh)
    local fuel = getElementData(veh, "mzansi:fuel") or 100

    Mzansi.Database.saveVehicle(dbData.id, {
        x = x, y = y, z = z, rotation = rz, health = health, fuel = fuel, locked = 1
    })

    dbData.x = x
    dbData.y = y
    dbData.z = z
    dbData.rotation = rz

    Mzansi.Util.sendNotification(source, "Vehicle parked! This location is now its permanent home.", "success")
    return true
end

function Mzansi.Vehicles.respawnVehicle(source)
    return Mzansi.Vehicles.summonVehicle(source)
end

addCommandHandler("mycars", function(p) Mzansi.Vehicles.listPlayerVehicles(p) end)
addCommandHandler("myvehicles", function(p) Mzansi.Vehicles.listPlayerVehicles(p) end)
addCommandHandler("spawncar", function(p, cmd, arg) Mzansi.Vehicles.summonVehicle(p, arg) end)
addCommandHandler("despawncar", function(p) Mzansi.Vehicles.despawnPlayerVehicle(p) end)
addCommandHandler("park", function(p) Mzansi.Vehicles.parkVehicle(p) end)

addEventHandler("mzansi:vehicles:lock", root, function()
    local source = client or source
    Mzansi.Vehicles.toggleLock(source)
end)

addEventHandler("mzansi:vehicles:engine", root, function()
    local source = client or source
    Mzansi.Vehicles.toggleEngine(source)
end)

addEventHandler("mzansi:vehicles:respawn", root, function()
    local source = client or source
    Mzansi.Vehicles.respawnVehicle(source)
end)

addEventHandler("mzansi:vehicles:refuel", root, function()
    local source = client or source
    Mzansi.Vehicles.refuelVehicle(source)
end)

addEventHandler("mzansi:characters:loaded", root, function(char)
    local source = source
    if isElement(source) then
        setTimer(function()
            if isElement(source) then
                Mzansi.Vehicles.loadPlayerVehicles(source)
            end
        end, 1500, 1)
    end
end)

addEventHandler("onResourceStart", resourceRoot, function()
    outputDebugString("[Mzansi-Vehicles] Vehicle system loaded.")
end)

addEventHandler("onPlayerQuit", root, function()
    Mzansi.Vehicles.savePlayerVehicles(source)
end)
