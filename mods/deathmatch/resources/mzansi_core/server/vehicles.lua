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

function Mzansi.Vehicles.respawnVehicle(source)
    local char = Mzansi.Characters.getCharacter(source)
    if not char then return false end

    local vehicle = getPedOccupiedVehicle(source)
    if not vehicle then return false, "You must be in a vehicle." end

    local dbData = Mzansi.Vehicles._byElement[vehicle]
    if not dbData then return false, "Invalid vehicle." end

    if dbData.owner_id ~= char.id then
        return false, "You don't own this vehicle."
    end

    local spawnX, spawnY, spawnZ = getElementPosition(source)
    setElementPosition(vehicle, spawnX, spawnY + 5, spawnZ)
    setElementHealth(vehicle, 1000)
    fixVehicle(vehicle)
    setElementData(vehicle, "mzansi:fuel", 100)

    Mzansi.Util.sendNotification(source, "Vehicle respawned.", "success")
    return true
end

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

addEventHandler("onResourceStart", resourceRoot, function()
    outputDebugString("[Mzansi-Vehicles] Vehicle system loaded.")
end)

addEventHandler("onPlayerQuit", root, function()
    Mzansi.Vehicles.savePlayerVehicles(source)
end)
