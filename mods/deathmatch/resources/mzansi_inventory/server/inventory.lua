Mzansi = Mzansi or {}
Mzansi.Inventory = {}
Mzansi.Inventory._items = {}

addEvent("mzansi:inventory:use", true)
addEvent("mzansi:inventory:drop", true)
addEvent("mzansi:inventory:give", true)
addEvent("mzansi:inventory:getItems", true)

Mzansi.Inventory.Definitions = {
    ["bread"] = { name = "Bread", type = Mzansi.Enums.ItemType.FOOD, weight = 0.5, usable = true, healAmount = 10 },
    ["water"] = { name = "Water Bottle", type = Mzansi.Enums.ItemType.DRINK, weight = 0.5, usable = true, healAmount = 5 },
    ["cola"] = { name = "Cola", type = Mzansi.Enums.ItemType.DRINK, weight = 0.5, usable = true, healAmount = 8 },
    ["bandage"] = { name = "Bandage", type = Mzansi.Enums.ItemType.MEDICAL, weight = 0.2, usable = true, healAmount = 25 },
    ["medkit"] = { name = "Medical Kit", type = Mzansi.Enums.ItemType.MEDICAL, weight = 2.0, usable = true, healAmount = 75 },
    ["phone"] = { name = "Mobile Phone", type = Mzansi.Enums.ItemType.ELECTRONIC, weight = 0.3, usable = true },
    ["lockpick"] = { name = "Lockpick", type = Mzansi.Enums.ItemType.TOOL, weight = 0.5, usable = true },
    ["repair_kit"] = { name = "Repair Kit", type = Mzansi.Enums.ItemType.TOOL, weight = 3.0, usable = true },
    ["fishing_rod"] = { name = "Fishing Rod", type = Mzansi.Enums.ItemType.TOOL, weight = 2.0, usable = true },
    ["fish"] = { name = "Fish", type = Mzansi.Enums.ItemType.FOOD, weight = 1.0, usable = true, healAmount = 15 },
    ["gold_ore"] = { name = "Gold Ore", type = Mzansi.Enums.ItemType.MATERIAL, weight = 5.0, usable = false },
    ["iron_ore"] = { name = "Iron Ore", type = Mzansi.Enums.ItemType.MATERIAL, weight = 4.0, usable = false },
    ["diamond"] = { name = "Diamond", type = Mzansi.Enums.ItemType.MATERIAL, weight = 0.1, usable = false },
    ["weapon_license"] = { name = "Weapon License", type = Mzansi.Enums.ItemType.DOCUMENT, weight = 0.1, usable = false },
    ["driver_license"] = { name = "Driver License", type = Mzansi.Enums.ItemType.DOCUMENT, weight = 0.1, usable = false },
    ["id_card"] = { name = "ID Card", type = Mzansi.Enums.ItemType.DOCUMENT, weight = 0.1, usable = false },
    ["radio"] = { name = "Radio", type = Mzansi.Enums.ItemType.ELECTRONIC, weight = 0.5, usable = true },
    ["spray"] = { name = "Spray Can", type = Mzansi.Enums.ItemType.TOOL, weight = 0.5, usable = true },
    ["pc_toolkit"] = { name = "PC Toolkit", type = Mzansi.Enums.ItemType.TOOL, weight = 1.5, usable = true },
    ["mech_toolkit"] = { name = "Mechatronics Toolkit", type = Mzansi.Enums.ItemType.TOOL, weight = 2.5, usable = true },
    ["logic_module"] = { name = "Logic Module", type = Mzansi.Enums.ItemType.MATERIAL, weight = 0.4, usable = false },
    ["plc_basic"] = { name = "PLC Basic Unit", type = Mzansi.Enums.ItemType.MATERIAL, weight = 1.2, usable = false },
    ["servo_kit"] = { name = "Servo Kit", type = Mzansi.Enums.ItemType.MATERIAL, weight = 1.8, usable = false },
}

function Mzansi.Inventory.getItems(source)
    local char = Mzansi.Characters.getCharacter(source)
    if not char then return {} end

    return Mzansi.Database.query(
        "SELECT * FROM mzansi_inventory WHERE owner_id = ?",
        char.id
    ) or {}
end

function Mzansi.Inventory.addItem(source, itemName, quantity, metadata)
    local char = Mzansi.Characters.getCharacter(source)
    if not char then return false end

    local def = Mzansi.Inventory.Definitions[itemName]
    if not def then
        Mzansi.Util.sendNotification(source, "Invalid item: " .. itemName, "error")
        return false
    end

    quantity = quantity or 1

    local existing = Mzansi.Database.query(
        "SELECT * FROM mzansi_inventory WHERE owner_id = ? AND item_name = ? LIMIT 1",
        char.id, itemName
    )

    if existing and #existing > 0 then
        Mzansi.Database.update(
            "UPDATE mzansi_inventory SET quantity = quantity + ? WHERE id = ?",
            quantity, existing[1].id
        )
    else
        Mzansi.Database.insert(
            "INSERT INTO mzansi_inventory (owner_id, item_name, item_type, quantity, metadata) VALUES (?, ?, ?, ?, ?)",
            char.id, itemName, def.type, quantity, metadata or ""
        )
    end

    Mzansi.Util.sendNotification(source, "Received " .. quantity .. "x " .. def.name, "success")
    return true
end

function Mzansi.Inventory.removeItem(source, itemName, quantity)
    local char = Mzansi.Characters.getCharacter(source)
    if not char then return false end

    quantity = quantity or 1

    local existing = Mzansi.Database.query(
        "SELECT * FROM mzansi_inventory WHERE owner_id = ? AND item_name = ? LIMIT 1",
        char.id, itemName
    )

    if not existing or #existing == 0 then
        return false
    end

    if existing[1].quantity < quantity then
        return false
    end

    if existing[1].quantity <= quantity then
        Mzansi.Database.delete(
            "DELETE FROM mzansi_inventory WHERE id = ?",
            existing[1].id
        )
    else
        Mzansi.Database.update(
            "UPDATE mzansi_inventory SET quantity = quantity - ? WHERE id = ?",
            quantity, existing[1].id
        )
    end

    return true
end

function Mzansi.Inventory.hasItem(source, itemName, quantity)
    local char = Mzansi.Characters.getCharacter(source)
    if not char then return false end

    quantity = quantity or 1

    local existing = Mzansi.Database.query(
        "SELECT * FROM mzansi_inventory WHERE owner_id = ? AND item_name = ? LIMIT 1",
        char.id, itemName
    )

    return existing and #existing > 0 and existing[1].quantity >= quantity
end

function Mzansi.Inventory.useItem(source, itemName)
    local def = Mzansi.Inventory.Definitions[itemName]
    if not def or not def.usable then
        Mzansi.Util.sendNotification(source, "Cannot use this item.", "error")
        return false
    end

    if not Mzansi.Inventory.hasItem(source, itemName) then
        Mzansi.Util.sendNotification(source, "You don't have this item.", "error")
        return false
    end

    if def.type == Mzansi.Enums.ItemType.FOOD or def.type == Mzansi.Enums.ItemType.DRINK then
        local health = getElementHealth(source)
        setElementHealth(source, math.min(100, health + (def.healAmount or 10)))
    end

    if def.type == Mzansi.Enums.ItemType.MEDICAL then
        local health = getElementHealth(source)
        setElementHealth(source, math.min(100, health + (def.healAmount or 25)))
    end

    if itemName == "repair_kit" then
        local vehicle = getPedOccupiedVehicle(source)
        if vehicle then
            fixVehicle(vehicle)
            setElementHealth(vehicle, 1000)
        else
            Mzansi.Util.sendNotification(source, "You must be in a vehicle.", "error")
            return false
        end
    end

    Mzansi.Inventory.removeItem(source, itemName, 1)
    Mzansi.Util.sendNotification(source, "Used " .. def.name, "success")
    return true
end

function Mzansi.Inventory.dropItem(source, itemName, quantity)
    if not Mzansi.Inventory.hasItem(source, itemName, quantity) then
        Mzansi.Util.sendNotification(source, "You don't have enough of this item.", "error")
        return false
    end

    Mzansi.Inventory.removeItem(source, itemName, quantity)
    Mzansi.Util.sendNotification(source, "Dropped " .. (quantity or 1) .. "x " .. itemName, "info")
    return true
end

function Mzansi.Inventory.giveItem(source, target, itemName, quantity)
    if not Mzansi.Inventory.hasItem(source, itemName, quantity) then
        Mzansi.Util.sendNotification(source, "You don't have enough of this item.", "error")
        return false
    end

    local x, y, z = getElementPosition(source)
    local tx, ty, tz = getElementPosition(target)
    if Mzansi.Util.distance(x, y, z, tx, ty, tz) > 5 then
        Mzansi.Util.sendNotification(source, "Target too far away.", "error")
        return false
    end

    Mzansi.Inventory.removeItem(source, itemName, quantity)
    Mzansi.Inventory.addItem(target, itemName, quantity)

    local giverName = Mzansi.Util.getPlayerFullName(source)
    local receiverName = Mzansi.Util.getPlayerFullName(target)
    local def = Mzansi.Inventory.Definitions[itemName]

    Mzansi.Util.sendNotification(source, "Gave " .. (quantity or 1) .. "x " .. def.name .. " to " .. receiverName, "success")
    Mzansi.Util.sendNotification(target, "Received " .. (quantity or 1) .. "x " .. def.name .. " from " .. giverName, "success")
    return true
end

addEventHandler("mzansi:inventory:use", root, function(itemName)
    local source = client or source
    Mzansi.Inventory.useItem(source, itemName)
end)

addEventHandler("mzansi:inventory:drop", root, function(itemName, quantity)
    local source = client or source
    Mzansi.Inventory.dropItem(source, itemName, quantity)
end)

addEventHandler("mzansi:inventory:give", root, function(target, itemName, quantity)
    local source = client or source
    Mzansi.Inventory.giveItem(source, target, itemName, quantity)
end)

addEventHandler("mzansi:inventory:getItems", root, function()
    local source = client or source
    local items = Mzansi.Inventory.getItems(source)
    triggerClientEvent(source, "mzansi:inventory:itemsList", source, items)
end)

addEventHandler("onResourceStart", resourceRoot, function()
    outputDebugString("[Mzansi-Inventory] Inventory system loaded.")
end)

-- Export wrapper functions for cross-resource access
function hasItem(source, itemName, quantity)
    return Mzansi.Inventory.hasItem(source, itemName, quantity)
end

function addItem(source, itemName, quantity, metadata)
    return Mzansi.Inventory.addItem(source, itemName, quantity, metadata)
end

function removeItem(source, itemName, quantity)
    return Mzansi.Inventory.removeItem(source, itemName, quantity)
end

function getItemCount(source, itemName)
    local char = Mzansi.Characters.getCharacter(source)
    if not char then return 0 end

    local existing = Mzansi.Database.query(
        "SELECT quantity FROM mzansi_inventory WHERE owner_id = ? AND item_name = ? LIMIT 1",
        char.id, itemName
    )

    return existing and #existing > 0 and existing[1].quantity or 0
end
