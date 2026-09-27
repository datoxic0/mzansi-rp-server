-- ==============================================================
-- MZANSI HOUSING & GARAGE SYSTEM
-- Full player house ownership, buy/sell, real 3D pickups, interiors,
-- garages, vehicle storage, and Free State Government & Admin estates.
-- ==============================================================

Mzansi = Mzansi or {}
Mzansi.Housing = Mzansi.Housing or {}
Mzansi.Housing._properties = {}
Mzansi.Housing._pickups = {}
Mzansi.Housing._markers = {}
Mzansi.Housing._garageMarkers = {}
Mzansi.Housing._blips = {}
Mzansi.Housing._exitMarkers = {}

addEvent("mzansi:housing:buy", true)
addEvent("mzansi:housing:sell", true)
addEvent("mzansi:housing:rent", true)
addEvent("mzansi:housing:lock", true)
addEvent("mzansi:housing:enter", true)
addEvent("mzansi:housing:exit", true)
addEvent("mzansi:housing:getProperties", true)
addEvent("mzansi:housing:parkVehicle", true)
addEvent("mzansi:housing:retrieveVehicle", true)

-- ==============================================================
-- 1. LOAD & SPAWN WORLD PROPERTIES
-- ==============================================================
function Mzansi.Housing.loadProperties()
    outputDebugString("[Mzansi-Housing] Loading properties and spawning world markers...", 3)

    -- Cleanup old elements on reload
    for _, el in pairs(Mzansi.Housing._pickups) do if isElement(el) then destroyElement(el) end end
    for _, el in pairs(Mzansi.Housing._markers) do if isElement(el) then destroyElement(el) end end
    for _, el in pairs(Mzansi.Housing._garageMarkers) do if isElement(el) then destroyElement(el) end end
    for _, el in pairs(Mzansi.Housing._blips) do if isElement(el) then destroyElement(el) end end
    for _, el in pairs(Mzansi.Housing._exitMarkers) do if isElement(el) then destroyElement(el) end end
    Mzansi.Housing._pickups = {}
    Mzansi.Housing._markers = {}
    Mzansi.Housing._garageMarkers = {}
    Mzansi.Housing._blips = {}
    Mzansi.Housing._exitMarkers = {}

    for _, prop in ipairs(Mzansi.Housing.Config.Properties) do
        local dbProp = Mzansi.Database.getProperty(prop.id)
        if not dbProp then
            Mzansi.Database.insert(
                "INSERT INTO mzansi_properties (id, owner_id, name, type, x, y, z, interior, dimension, price, rent_price, locked) VALUES (?, NULL, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1)",
                prop.id, prop.name, prop.type or 0, prop.x, prop.y, prop.z,
                prop.interior or 0, prop.dimension or prop.id, prop.price or 0, prop.rentPrice or 0
            )
            dbProp = Mzansi.Database.getProperty(prop.id)
        end

        local ownerId = dbProp and dbProp.owner_id or nil
        local locked = dbProp and (dbProp.locked == 1) or false

        Mzansi.Housing._properties[prop.id] = {
            id = prop.id,
            name = prop.name,
            type = prop.type or 0,
            zone = prop.zone or "San Andreas",
            x = prop.x,
            y = prop.y,
            z = prop.z,
            price = prop.price or 50000,
            rentPrice = prop.rentPrice or 2000,
            interior = prop.interior or 2,
            interiorX = prop.interiorX or 223.7,
            interiorY = prop.interiorY or 1287.1,
            interiorZ = prop.interiorZ or 1082.1,
            dimension = prop.dimension or prop.id,
            ownerId = ownerId,
            locked = locked,
            garageX = prop.garageX,
            garageY = prop.garageY,
            garageZ = prop.garageZ,
            garageRot = prop.garageRot or 0,
            adminRank = prop.adminRank,
        }

        -- 1. Create Physical 3D House Pickup:
        -- Model 1273 = Green house icon (For Sale)
        -- Model 1272 = Blue house icon (Owned)
        local pickupModel = ownerId and 1272 or 1273
        local pickup = createPickup(prop.x, prop.y, prop.z + 0.4, 3, pickupModel, 0)
        if pickup then
            setElementInterior(pickup, 0)
            setElementDimension(pickup, 0)
            setElementData(pickup, "mzansi:housing:propId", prop.id)
            Mzansi.Housing._pickups[prop.id] = pickup
        end

        -- 2. Entrance Cylinder Marker (1.5m radius)
        local marker = createMarker(prop.x, prop.y, prop.z - 1.0, "cylinder", 1.5, 255, 215, 0, 140)
        if marker then
            setElementInterior(marker, 0)
            setElementDimension(marker, 0)
            setElementData(marker, "mzansi:housing:propId", prop.id)
            setElementData(marker, "mzansi:housing:kind", "entrance")
            Mzansi.Housing._markers[prop.id] = marker

            addEventHandler("onMarkerHit", marker, function(hitEl, matchingDim)
                if matchingDim and isElement(hitEl) and getElementType(hitEl) == "player" and not isPedInVehicle(hitEl) then
                    local p = Mzansi.Housing._properties[prop.id]
                    local status = p.ownerId and ("Owned [ID: " .. p.id .. "]") or ("FOR SALE: " .. Mzansi.Util.formatMoney(p.price) .. " — Type /buyhouse")
                    local lockStatus = p.locked and "Locked" or "Unlocked"
                    outputChatBox("🏠 [" .. p.name .. "] • " .. status .. " • " .. lockStatus, hitEl, 255, 215, 0)
                    outputChatBox("   Commands: /enter, /buyhouse, /lockhouse, /sellhouse", hitEl, 200, 200, 200)
                end
            end)
        end

        -- 3. Radar Map Blip (House icon sprite 31)
        local blipColor = ownerId and { 50, 150, 255 } or { 50, 220, 50 }
        local blip = createBlip(prop.x, prop.y, prop.z, 31, 2, blipColor[1], blipColor[2], blipColor[3], 255, 0, 350)
        if blip then
            Mzansi.Housing._blips[prop.id] = blip
        end

        -- 4. Garage Marker (if property has garage)
        if prop.garageX then
            local gMarker = createMarker(prop.garageX, prop.garageY, prop.garageZ - 1.0, "cylinder", 3.0, 0, 200, 255, 140)
            if gMarker then
                setElementInterior(gMarker, 0)
                setElementDimension(gMarker, 0)
                setElementData(gMarker, "mzansi:housing:propId", prop.id)
                setElementData(gMarker, "mzansi:housing:kind", "garage")
                Mzansi.Housing._garageMarkers[prop.id] = gMarker

                addEventHandler("onMarkerHit", gMarker, function(hitEl, matchingDim)
                    if matchingDim and isElement(hitEl) then
                        local player = (getElementType(hitEl) == "player") and hitEl or getVehicleOccupant(hitEl, 0)
                        if player then
                            outputChatBox("🚗 [" .. prop.name .. " Garage] Type /parkhouse to store car, /garage to retrieve car.", player, 0, 200, 255)
                        end
                    end
                end)
            end
        end

        -- 5. Interior Exit Marker
        local exitMarker = createMarker(prop.interiorX, prop.interiorY, prop.interiorZ - 1.0, "cylinder", 1.5, 255, 50, 50, 140)
        if exitMarker then
            setElementInterior(exitMarker, prop.interior or 2)
            setElementDimension(exitMarker, prop.dimension or prop.id)
            setElementData(exitMarker, "mzansi:housing:propId", prop.id)
            setElementData(exitMarker, "mzansi:housing:kind", "exit")
            Mzansi.Housing._exitMarkers[prop.id] = exitMarker

            addEventHandler("onMarkerHit", exitMarker, function(hitEl, matchingDim)
                if matchingDim and isElement(hitEl) and getElementType(hitEl) == "player" then
                    outputChatBox("🚪 Type /exit to leave " .. prop.name, hitEl, 255, 100, 100)
                end
            end)
        end
    end

    outputDebugString("[Mzansi-Housing] ✓ Loaded " .. #Mzansi.Housing.Config.Properties .. " properties with pickups, markers, and garages.")
end

-- ==============================================================
-- 2. BUY PROPERTY (/buyhouse)
-- ==============================================================
function Mzansi.Housing.buyProperty(player, propertyId)
    local char = Mzansi.Characters.getCharacter(player)
    if not char then
        Mzansi.Util.sendNotification(player, "You must be logged in.", "error")
        return false
    end

    local px, py, pz = getElementPosition(player)
    local targetProp = nil

    if propertyId then
        targetProp = Mzansi.Housing._properties[tonumber(propertyId)]
    else
        for _, p in pairs(Mzansi.Housing._properties) do
            if Mzansi.Util.distance(px, py, pz, p.x, p.y, p.z) <= 4.0 then
                targetProp = p
                break
            end
        end
    end

    if not targetProp then
        Mzansi.Util.sendNotification(player, "No house nearby. Stand at a house door marker.", "error")
        return false
    end

    if targetProp.ownerId then
        Mzansi.Util.sendNotification(player, "This house is already owned.", "error")
        return false
    end

    local price = targetProp.price or 50000
    if (char.cash or 0) < price then
        Mzansi.Util.sendNotification(player, "Insufficient cash. Need " .. Mzansi.Util.formatMoney(price), "error")
        return false
    end

    local playerProps = Mzansi.Database.getPlayerProperties(char.id)
    if #playerProps >= (Mzansi.Config.Server.maxHousesPerPlayer or 5) then
        Mzansi.Util.sendNotification(player, "You already own the maximum allowed properties.", "error")
        return false
    end

    if not Mzansi.Characters.removeCash(player, price) then
        Mzansi.Util.sendNotification(player, "Transaction failed.", "error")
        return false
    end

    -- Update Database
    Mzansi.Database.update("UPDATE mzansi_properties SET owner_id = ?, locked = 1 WHERE id = ?", char.id, targetProp.id)
    targetProp.ownerId = char.id
    targetProp.locked = true

    -- Update 3D Pickup from green to blue
    if Mzansi.Housing._pickups[targetProp.id] and isElement(Mzansi.Housing._pickups[targetProp.id]) then
        destroyElement(Mzansi.Housing._pickups[targetProp.id])
    end
    local newPickup = createPickup(targetProp.x, targetProp.y, targetProp.z + 0.4, 3, 1272, 0)
    Mzansi.Housing._pickups[targetProp.id] = newPickup

    Mzansi.Util.sendNotification(player, "Congratulations! You purchased " .. targetProp.name .. " for " .. Mzansi.Util.formatMoney(price) .. "!", "success")
    outputChatBox("🏠 [Housing] You now own " .. targetProp.name .. "! Use /enter, /lockhouse, /garage.", player, 50, 255, 50)
    return true
end

-- ==============================================================
-- 3. SELL PROPERTY (/sellhouse)
-- ==============================================================
function Mzansi.Housing.sellProperty(player, propertyId)
    local char = Mzansi.Characters.getCharacter(player)
    if not char then return false end

    local px, py, pz = getElementPosition(player)
    local targetProp = nil

    if propertyId then
        targetProp = Mzansi.Housing._properties[tonumber(propertyId)]
    else
        for _, p in pairs(Mzansi.Housing._properties) do
            if Mzansi.Util.distance(px, py, pz, p.x, p.y, p.z) <= 5.0 then
                targetProp = p
                break
            end
        end
    end

    if not targetProp then
        Mzansi.Util.sendNotification(player, "Stand near the house entrance to sell it.", "error")
        return false
    end

    if targetProp.ownerId ~= char.id then
        Mzansi.Util.sendNotification(player, "You do not own this property.", "error")
        return false
    end

    local refund = math.floor((targetProp.price or 50000) * 0.70)
    Mzansi.Characters.addCash(player, refund)
    Mzansi.Database.update("UPDATE mzansi_properties SET owner_id = NULL, locked = 1 WHERE id = ?", targetProp.id)
    targetProp.ownerId = nil
    targetProp.locked = true

    -- Update Pickup back to green
    if Mzansi.Housing._pickups[targetProp.id] and isElement(Mzansi.Housing._pickups[targetProp.id]) then
        destroyElement(Mzansi.Housing._pickups[targetProp.id])
    end
    local newPickup = createPickup(targetProp.x, targetProp.y, targetProp.z + 0.4, 3, 1273, 0)
    Mzansi.Housing._pickups[targetProp.id] = newPickup

    Mzansi.Util.sendNotification(player, "Property sold! Received 70% refund of " .. Mzansi.Util.formatMoney(refund) .. ".", "success")
    return true
end

-- ==============================================================
-- 4. ENTER PROPERTY (/enter)
-- ==============================================================
function Mzansi.Housing.enterProperty(player)
    local char = Mzansi.Characters.getCharacter(player)
    if not char then return false end

    if isPedInVehicle(player) then
        Mzansi.Util.sendNotification(player, "You cannot enter a house in a vehicle.", "error")
        return false
    end

    local px, py, pz = getElementPosition(player)
    for _, prop in pairs(Mzansi.Housing._properties) do
        local dist = Mzansi.Util.distance(px, py, pz, prop.x, prop.y, prop.z)
        if dist <= 3.5 then
            local isOwner = (prop.ownerId == char.id)
            local isAdmin = (char.admin_level and char.admin_level > 0) or false

            if prop.locked and not isOwner and not isAdmin then
                Mzansi.Util.sendNotification(player, "This house is locked.", "error")
                return false
            end

            setElementInterior(player, prop.interior or 2)
            setElementDimension(player, prop.dimension or prop.id)
            setElementPosition(player, prop.interiorX, prop.interiorY, prop.interiorZ)
            setElementData(player, "mzansi:insideProperty", prop.id)

            Mzansi.Util.sendNotification(player, "Welcome inside " .. prop.name .. "!", "info")
            outputChatBox("🏠 You are inside " .. prop.name .. ". Type /exit to leave.", player, 200, 200, 255)
            return true
        end
    end

    Mzansi.Util.sendNotification(player, "You are not near any house entrance door.", "error")
    return false
end

-- ==============================================================
-- 5. EXIT PROPERTY (/exit)
-- ==============================================================
function Mzansi.Housing.exitProperty(player)
    local insidePropId = getElementData(player, "mzansi:insideProperty")
    local prop = insidePropId and Mzansi.Housing._properties[insidePropId]

    if not prop then
        -- Check proximity to any interior exit marker
        local px, py, pz = getElementPosition(player)
        for _, p in pairs(Mzansi.Housing._properties) do
            if getElementInterior(player) == p.interior and getElementDimension(player) == p.dimension then
                prop = p
                break
            end
        end
    end

    if prop then
        setElementInterior(player, 0)
        setElementDimension(player, 0)
        setElementPosition(player, prop.x, prop.y, prop.z + 0.5)
        setElementData(player, "mzansi:insideProperty", nil)
        Mzansi.Util.sendNotification(player, "Exited " .. prop.name .. ".", "info")
        return true
    end

    Mzansi.Util.sendNotification(player, "You are not inside a house.", "error")
    return false
end

-- ==============================================================
-- 6. LOCK / UNLOCK PROPERTY (/lockhouse)
-- ==============================================================
function Mzansi.Housing.toggleLock(player)
    local char = Mzansi.Characters.getCharacter(player)
    if not char then return false end

    local px, py, pz = getElementPosition(player)
    for _, prop in pairs(Mzansi.Housing._properties) do
        local dist = Mzansi.Util.distance(px, py, pz, prop.x, prop.y, prop.z)
        if dist <= 6.0 then
            if prop.ownerId ~= char.id and (not char.admin_level or char.admin_level == 0) then
                Mzansi.Util.sendNotification(player, "You do not own this property.", "error")
                return false
            end

            prop.locked = not prop.locked
            Mzansi.Database.update("UPDATE mzansi_properties SET locked = ? WHERE id = ?", prop.locked and 1 or 0, prop.id)

            local status = prop.locked and "LOCKED" or "UNLOCKED"
            Mzansi.Util.sendNotification(player, "House " .. prop.name .. " is now " .. status .. ".", "info")
            return true
        end
    end

    Mzansi.Util.sendNotification(player, "No house nearby to lock/unlock.", "error")
    return false
end

-- ==============================================================
-- 7. HOUSE GARAGE VEHICLE STORAGE & RETRIEVAL (/parkhouse & /garage)
-- ==============================================================
function Mzansi.Housing.parkVehicle(player)
    local char = Mzansi.Characters.getCharacter(player)
    if not char then return false end

    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        Mzansi.Util.sendNotification(player, "You must be inside your vehicle to park it in the garage.", "error")
        return false
    end

    local dbData = Mzansi.Vehicles and Mzansi.Vehicles._byElement and Mzansi.Vehicles._byElement[vehicle]
    if not dbData or dbData.owner_id ~= char.id then
        Mzansi.Util.sendNotification(player, "You can only store vehicles that you personally own.", "error")
        return false
    end

    local vx, vy, vz = getElementPosition(vehicle)
    local nearProp = nil
    for _, prop in pairs(Mzansi.Housing._properties) do
        if prop.garageX then
            local dist = Mzansi.Util.distance(vx, vy, vz, prop.garageX, prop.garageY, prop.garageZ)
            if dist <= 7.0 then
                if prop.ownerId == char.id or (char.admin_level and char.admin_level > 0) then
                    nearProp = prop
                    break
                end
            end
        end
    end

    if not nearProp then
        Mzansi.Util.sendNotification(player, "You must be at your house garage to park your car.", "error")
        return false
    end

    -- Save vehicle to garage location and despawn element
    Mzansi.Database.saveVehicle(dbData.id, {
        x = nearProp.garageX,
        y = nearProp.garageY,
        z = nearProp.garageZ,
        rotation = nearProp.garageRot or 0,
        health = getElementHealth(vehicle),
        fuel = getElementData(vehicle, "mzansi:fuel") or 100,
        locked = 1,
    })

    removePedFromVehicle(player)
    destroyElement(vehicle)
    if Mzansi.Vehicles._spawned then Mzansi.Vehicles._spawned[dbData.id] = nil end
    if Mzansi.Vehicles._byPlate then Mzansi.Vehicles._byPlate[dbData.plate] = nil end

    Mzansi.Util.sendNotification(player, "Vehicle stored in " .. nearProp.name .. " garage! Use /garage to retrieve it.", "success")
    return true
end

function Mzansi.Housing.retrieveVehicle(player)
    local char = Mzansi.Characters.getCharacter(player)
    if not char then return false end

    local px, py, pz = getElementPosition(player)
    local nearProp = nil
    for _, prop in pairs(Mzansi.Housing._properties) do
        if prop.garageX then
            local dist = Mzansi.Util.distance(px, py, pz, prop.garageX, prop.garageY, prop.garageZ)
            if dist <= 7.0 then
                if prop.ownerId == char.id or (char.admin_level and char.admin_level > 0) then
                    nearProp = prop
                    break
                end
            end
        end
    end

    if not nearProp then
        Mzansi.Util.sendNotification(player, "Stand at your house garage marker to retrieve your car.", "error")
        return false
    end

    local vehicles = Mzansi.Database.getPlayerVehicles(char.id)
    if #vehicles == 0 then
        Mzansi.Util.sendNotification(player, "You do not own any vehicles.", "error")
        return false
    end

    local vData = vehicles[1]
    -- If already spawned, warp it to garage
    if Mzansi.Vehicles._spawned and Mzansi.Vehicles._spawned[vData.id] and isElement(Mzansi.Vehicles._spawned[vData.id]) then
        local veh = Mzansi.Vehicles._spawned[vData.id]
        setElementPosition(veh, nearProp.garageX, nearProp.garageY, nearProp.garageZ + 0.5)
        setElementRotation(veh, 0, 0, nearProp.garageRot or 0)
        fixVehicle(veh)
        setVehicleLocked(veh, false)
        Mzansi.Util.sendNotification(player, "Vehicle retrieved to house driveway!", "success")
        return true
    end

    -- Spawn vehicle onto garage driveway
    vData.x = nearProp.garageX
    vData.y = nearProp.garageY
    vData.z = nearProp.garageZ + 0.5
    vData.rotation = nearProp.garageRot or 0
    local spawned = Mzansi.Vehicles.spawnVehicle(vData)
    if spawned then
        setVehicleLocked(spawned, false)
        Mzansi.Util.sendNotification(player, "Vehicle retrieved from garage: " .. getVehicleName(spawned) .. " [" .. vData.plate .. "]", "success")
        return true
    end

    Mzansi.Util.sendNotification(player, "Failed to retrieve vehicle.", "error")
    return false
end

-- ==============================================================
-- 8. ADMIN PROMOTION AUTO-ASSIGNMENT (FREE STATE GOV ESTATES)
-- ==============================================================
function Mzansi.Housing.assignAdminHouse(player)
    local char = Mzansi.Characters.getCharacter(player)
    if not char then return false end

    -- Check if character or account has admin permissions
    local adminLevel = char.admin_level or 0
    local acc = Mzansi.Accounts and Mzansi.Accounts.getAccount(player)
    if acc and acc.admin_level and acc.admin_level > adminLevel then
        adminLevel = acc.admin_level
    end

    if adminLevel < 1 then return false end

    -- Check if admin already owns a Free State house
    local playerProps = Mzansi.Database.getPlayerProperties(char.id)
    for _, p in ipairs(playerProps) do
        if p.id >= 101 and p.id <= 110 then
            return true -- already has Free State house
        end
    end

    -- Find next available Free State luxury house
    for id = 101, 110 do
        local prop = Mzansi.Housing._properties[id]
        if prop and not prop.ownerId then
            Mzansi.Database.update("UPDATE mzansi_properties SET owner_id = ?, locked = 1 WHERE id = ?", char.id, prop.id)
            prop.ownerId = char.id
            prop.locked = true

            -- Update pickup
            if Mzansi.Housing._pickups[prop.id] and isElement(Mzansi.Housing._pickups[prop.id]) then
                destroyElement(Mzansi.Housing._pickups[prop.id])
            end
            local newPickup = createPickup(prop.x, prop.y, prop.z + 0.4, 3, 1272, 0)
            Mzansi.Housing._pickups[prop.id] = newPickup

            outputChatBox("🏛️ [FREE STATE GOVERNMENT] Welcome Admin " .. getPlayerName(player) .. "!", player, 255, 215, 0)
            outputChatBox("   You have been allocated Presidential/Government Residence: " .. prop.name .. "!", player, 200, 230, 255)
            Mzansi.Util.sendNotification(player, "Free State Government Residence Allocated: " .. prop.name, "success")
            return true
        end
    end
    return false
end

-- ==============================================================
-- 9. CHAT COMMANDS
-- ==============================================================
addCommandHandler("buyhouse", function(p, cmd, arg)
    Mzansi.Housing.buyProperty(p, arg)
end)

addCommandHandler("sellhouse", function(p, cmd, arg)
    Mzansi.Housing.sellProperty(p, arg)
end)

addCommandHandler("enter", function(p)
    Mzansi.Housing.enterProperty(p)
end)

addCommandHandler("exit", function(p)
    Mzansi.Housing.exitProperty(p)
end)

addCommandHandler("lockhouse", function(p)
    Mzansi.Housing.toggleLock(p)
end)

addCommandHandler("parkhouse", function(p)
    Mzansi.Housing.parkVehicle(p)
end)

addCommandHandler("storecar", function(p)
    Mzansi.Housing.parkVehicle(p)
end)

addCommandHandler("garage", function(p)
    Mzansi.Housing.retrieveVehicle(p)
end)

addCommandHandler("takecar", function(p)
    Mzansi.Housing.retrieveVehicle(p)
end)

addCommandHandler("myhouses", function(p)
    local char = Mzansi.Characters.getCharacter(p)
    if not char then return end
    local props = Mzansi.Database.getPlayerProperties(char.id)
    if #props == 0 then
        Mzansi.Util.sendNotification(p, "You do not own any houses. Use /buyhouse at any house pickup.", "info")
        return
    end
    outputChatBox("🏠 --- YOUR OWNED HOUSES (" .. #props .. ") ---", p, 255, 215, 0)
    for _, pr in ipairs(props) do
        local pDef = Mzansi.Housing._properties[pr.id]
        local zone = pDef and pDef.zone or "San Andreas"
        outputChatBox("  • [ID: " .. pr.id .. "] " .. pr.name .. " (" .. zone .. ")", p, 200, 230, 255)
    end
end)

-- Auto-allocate house when promoted or joined
addEventHandler("mzansi:admin:promoted", root, function(targetPlayer)
    if isElement(targetPlayer) then
        Mzansi.Housing.assignAdminHouse(targetPlayer)
    end
end)

addEventHandler("mzansi:characters:loaded", root, function(char)
    local player = source
    if isElement(player) then
        setTimer(function()
            if isElement(player) then
                Mzansi.Housing.assignAdminHouse(player)
            end
        end, 2000, 1)
    end
end)

-- Client Event Bindings
addEventHandler("mzansi:housing:buy", root, function(propertyId)
    local s = client or source
    Mzansi.Housing.buyProperty(s, propertyId)
end)

addEventHandler("mzansi:housing:sell", root, function(propertyId)
    local s = client or source
    Mzansi.Housing.sellProperty(s, propertyId)
end)

addEventHandler("mzansi:housing:enter", root, function()
    local s = client or source
    Mzansi.Housing.enterProperty(s)
end)

addEventHandler("mzansi:housing:exit", root, function()
    local s = client or source
    Mzansi.Housing.exitProperty(s)
end)

addEventHandler("mzansi:housing:lock", root, function()
    local s = client or source
    Mzansi.Housing.toggleLock(s)
end)

addEventHandler("mzansi:housing:parkVehicle", root, function()
    local s = client or source
    Mzansi.Housing.parkVehicle(s)
end)

addEventHandler("mzansi:housing:retrieveVehicle", root, function()
    local s = client or source
    Mzansi.Housing.retrieveVehicle(s)
end)

function assignAdminHouse(player)
    return Mzansi.Housing.assignAdminHouse(player)
end

-- Resource lifecycle
addEventHandler("onResourceStart", resourceRoot, function()
    Mzansi.Housing.loadProperties()
    outputDebugString("[Mzansi-Housing] Housing & Garage system loaded successfully.")
end)
