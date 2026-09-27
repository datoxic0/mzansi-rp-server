Mzansi = Mzansi or {}
Mzansi.Housing = Mzansi.Housing or {}
Mzansi.Housing._properties = {}

addEvent("mzansi:housing:buy", true)
addEvent("mzansi:housing:sell", true)
addEvent("mzansi:housing:rent", true)
addEvent("mzansi:housing:unrent", true)
addEvent("mzansi:housing:lock", true)
addEvent("mzansi:housing:enter", true)
addEvent("mzansi:housing:exit", true)
addEvent("mzansi:housing:getProperties", true)

function Mzansi.Housing.loadProperties()
    for _, prop in ipairs(Mzansi.Housing.Config.Properties) do
        local dbProp = Mzansi.Database.getProperty(prop.id)
        if not dbProp then
            Mzansi.Database.insert(
                "INSERT INTO mzansi_properties (id, owner_id, name, type, x, y, z, interior, dimension, price, rent_price, locked) VALUES (?, NULL, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1)",
                prop.id, prop.name, prop.type or 0, prop.x, prop.y, prop.z,
                prop.interior or 0, prop.dimension or 0, prop.price or 0, prop.rentPrice or 0
            )
            dbProp = Mzansi.Database.getProperty(prop.id)
        end
        if dbProp then
            Mzansi.Housing._properties[prop.id] = {
                id = prop.id,
                name = prop.name,
                type = prop.type,
                x = prop.x,
                y = prop.y,
                z = prop.z,
                price = prop.price,
                rentPrice = prop.rentPrice,
                interior = prop.interior,
                dimension = prop.dimension,
                ownerId = dbProp.owner_id,
                locked = dbProp.locked == 1,
            }
        else
            Mzansi.Housing._properties[prop.id] = {
                id = prop.id,
                name = prop.name,
                type = prop.type,
                x = prop.x,
                y = prop.y,
                z = prop.z,
                price = prop.price,
                rentPrice = prop.rentPrice,
                interior = prop.interior,
                dimension = prop.dimension,
                ownerId = nil,
                locked = true,
            }
        end
    end
end

function Mzansi.Housing.buyProperty(source, propertyId)
    local char = Mzansi.Characters.getCharacter(source)
    if not char then return false end

    local prop = Mzansi.Housing._properties[propertyId]
    if not prop then
        Mzansi.Util.sendNotification(source, "Invalid property.", "error")
        return false
    end

    if prop.ownerId then
        Mzansi.Util.sendNotification(source, "Property already owned.", "error")
        return false
    end

    if char.cash < prop.price then
        Mzansi.Util.sendNotification(source, "Insufficient funds. Need " .. Mzansi.Util.formatMoney(prop.price), "error")
        return false
    end

    local playerProps = Mzansi.Database.getPlayerProperties(char.id)
    if #playerProps >= Mzansi.Config.Server.maxHousesPerPlayer then
        Mzansi.Util.sendNotification(source, "Maximum properties reached.", "error")
        return false
    end

    Mzansi.Characters.removeCash(source, prop.price)

    local existing = Mzansi.Database.getProperty(prop.id)
    if existing then
        Mzansi.Database.update(
            "UPDATE mzansi_properties SET owner_id = ? WHERE id = ?",
            char.id, prop.id
        )
    else
        Mzansi.Database.insert(
            "INSERT INTO mzansi_properties (id, owner_id, name, type, x, y, z, interior, dimension, price, rent_price, locked) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1)",
            prop.id, char.id, prop.name, prop.type or 0, prop.x, prop.y, prop.z,
            prop.interior or 0, prop.dimension or 0, prop.price or 0, prop.rentPrice or 0
        )
    end

    prop.ownerId = char.id
    prop.locked = true

    Mzansi.Util.sendNotification(source, "Property purchased: " .. prop.name, "success")
    local playerName = (char.firstName or "") .. " " .. (char.lastName or "")
    Mzansi.Database.logAction("PROPERTY", char.id, playerName, "Bought property", prop.name .. " for " .. Mzansi.Util.formatMoney(prop.price), "")
    return true
end

function Mzansi.Housing.sellProperty(source, propertyId)
    local char = Mzansi.Characters.getCharacter(source)
    if not char then return false end

    local prop = Mzansi.Housing._properties[propertyId]
    if not prop then return false end

    if prop.ownerId ~= char.id then
        Mzansi.Util.sendNotification(source, "You don't own this property.", "error")
        return false
    end

    local sellPrice = math.floor(prop.price * 0.7)
    Mzansi.Characters.addCash(source, sellPrice)
    Mzansi.Database.update(
        "UPDATE mzansi_properties SET owner_id = NULL WHERE id = ?",
        prop.id
    )

    prop.ownerId = nil
    prop.locked = true

    Mzansi.Util.sendNotification(source, "Property sold for " .. Mzansi.Util.formatMoney(sellPrice), "success")
    return true
end

function Mzansi.Housing.toggleLock(source)
    local char = Mzansi.Characters.getCharacter(source)
    if not char then return false end

    local px, py, pz = getElementPosition(source)
    for _, prop in pairs(Mzansi.Housing._properties) do
        local dist = Mzansi.Util.distance(px, py, pz, prop.x, prop.y, prop.z)

        if dist < 5 then
            if prop.ownerId ~= char.id then
                Mzansi.Util.sendNotification(source, "You don't own this property.", "error")
                return false
            end

            prop.locked = not prop.locked
            Mzansi.Database.update(
                "UPDATE mzansi_properties SET locked = ? WHERE id = ?",
                prop.locked and 1 or 0, prop.id
            )

            Mzansi.Util.sendNotification(source, prop.locked and "Property locked." or "Property unlocked.", "info")
            return true
        end
    end

    Mzansi.Util.sendNotification(source, "No property nearby.", "error")
    return false
end

function Mzansi.Housing.enterProperty(source)
    local char = Mzansi.Characters.getCharacter(source)
    if not char then return false end

    local px, py, pz = getElementPosition(source)
    for _, prop in pairs(Mzansi.Housing._properties) do
        local dist = Mzansi.Util.distance(px, py, pz, prop.x, prop.y, prop.z)

        if dist < 5 then
            if prop.locked and prop.ownerId ~= char.id then
                Mzansi.Util.sendNotification(source, "Property is locked.", "error")
                return false
            end

            local intId = (prop.interior and prop.interior > 0) and prop.interior or 1
            local dimId = prop.id or 100
            local ix = (prop.interiorX and prop.interiorX ~= 0) and prop.interiorX or 223.715
            local iy = (prop.interiorY and prop.interiorY ~= 0) and prop.interiorY or 1287.078
            local iz = (prop.interiorZ and prop.interiorZ ~= 0) and prop.interiorZ or 1082.140

            setElementInterior(source, intId)
            setElementDimension(source, dimId)
            setElementPosition(source, ix, iy, iz)
            setElementData(source, "mzansi:insideProperty", prop.id)

            Mzansi.Util.sendNotification(source, "Entered " .. prop.name, "info")
            return true
        end
    end

    return false
end

function Mzansi.Housing.exitProperty(source)
    local char = Mzansi.Characters.getCharacter(source)
    if not char then return false end

    local insidePropId = getElementData(source, "mzansi:insideProperty")
    local prop = insidePropId and Mzansi.Housing._properties[insidePropId] or Mzansi.Housing._properties[1]
    if prop then
        setElementInterior(source, 0)
        setElementDimension(source, 0)
        setElementPosition(source, prop.x, prop.y, prop.z + 1)
        setElementData(source, "mzansi:insideProperty", nil)
        Mzansi.Util.sendNotification(source, "Left " .. prop.name .. ".", "info")
        return true
    else
        setElementInterior(source, 0)
        setElementDimension(source, 0)
        setElementPosition(source, 1682.5, -2267.0, 13.5)
        setElementData(source, "mzansi:insideProperty", nil)
        Mzansi.Util.sendNotification(source, "Left property.", "info")
        return true
    end
end

function Mzansi.Housing.getProperties(source)
    local char = Mzansi.Characters.getCharacter(source)
    if not char then return {} end

    local owned = {}
    for _, prop in pairs(Mzansi.Housing._properties) do
        if prop.ownerId == char.id then
            owned[#owned + 1] = prop
        end
    end
    return owned
end

addEventHandler("mzansi:housing:buy", root, function(propertyId)
    local source = client or source
    Mzansi.Housing.buyProperty(source, propertyId)
end)

addEventHandler("mzansi:housing:sell", root, function(propertyId)
    local source = client or source
    Mzansi.Housing.sellProperty(source, propertyId)
end)

addEventHandler("mzansi:housing:lock", root, function()
    local source = client or source
    Mzansi.Housing.toggleLock(source)
end)

addEventHandler("mzansi:housing:enter", root, function()
    local source = client or source
    Mzansi.Housing.enterProperty(source)
end)

addEventHandler("mzansi:housing:exit", root, function()
    local source = client or source
    Mzansi.Housing.exitProperty(source)
end)

addEventHandler("onResourceStart", resourceRoot, function()
    Mzansi.Housing.loadProperties()
    outputDebugString("[Mzansi-Housing] Housing system loaded.")
end)
