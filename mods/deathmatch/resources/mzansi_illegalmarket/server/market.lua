Mzansi = Mzansi or {}
Mzansi.IllegalMarket = Mzansi.IllegalMarket or {}
Mzansi.IllegalMarket._cooldowns = {}

local function invHas(player, item, qty)
    local res = getResourceFromName("mzansi_inventory")
    if res and getResourceState(res) == "running" then
        local ok, result = pcall(function()
            return exports.mzansi_inventory:hasItem(player, item, qty or 1)
        end)
        if ok then return result end
    end
    return false
end

local function invAdd(player, item, qty, meta)
    local res = getResourceFromName("mzansi_inventory")
    if res and getResourceState(res) == "running" then
        local ok, result = pcall(function()
            return exports.mzansi_inventory:addItem(player, item, qty or 1, meta)
        end)
        if ok then return result end
    end
    return false
end

local function invRemove(player, item, qty)
    local res = getResourceFromName("mzansi_inventory")
    if res and getResourceState(res) == "running" then
        local ok, result = pcall(function()
            return exports.mzansi_inventory:removeItem(player, item, qty or 1)
        end)
        if ok then return result end
    end
    return false
end

addEvent("mzansi:illegalmarket:buy", true)
addEvent("mzansi:illegalmarket:sell", true)
addEvent("mzansi:illegalmarket:chop", true)
addEvent("mzansi:illegalmarket:fence", true)

function Mzansi.IllegalMarket.buyItem(source, locationId, itemId)
    local char = Mzansi.Characters.getCharacter(source)
    if not char then return false end

    local location = nil
    for _, loc in ipairs(Mzansi.IllegalMarket.Config.Locations) do
        if loc.id == locationId then
            location = loc
            break
        end
    end

    if not location then
        Mzansi.Util.sendNotification(source, "Invalid location.", "error")
        return false
    end

    local x, y, z = getElementPosition(source)
    if Mzansi.Util.distance(x, y, z, location.x, location.y, location.z) > location.radius then
        Mzansi.Util.sendNotification(source, "Not at dealer location.", "error")
        return false
    end

    local item = nil
    for _, i in ipairs(location.items) do
        if i.name == itemId or i.weaponId == tonumber(itemId) then
            item = i
            break
        end
    end

    if not item then
        Mzansi.Util.sendNotification(source, "Item not found.", "error")
        return false
    end

    if char.cash < item.price then
        Mzansi.Util.sendNotification(source, "Need " .. Mzansi.Util.formatMoney(item.price), "error")
        return false
    end

    Mzansi.Characters.removeCash(source, item.price)

    if item.weaponId then
        giveWeapon(source, item.weaponId, item.ammo or 50)
        Mzansi.Util.sendNotification(source, "Bought " .. item.name .. " with ammo.", "success")
    else
        invAdd(source, item.name:gsub(" ", "_"):lower(), 1)
        Mzansi.Util.sendNotification(source, "Bought " .. item.name, "success")
    end

    setElementData(source, "mzansi:wantedLevel", (getElementData(source, "mzansi:wantedLevel") or 0) + 1)

    Mzansi.Database.logAction("ILLEGAL", char.id, char.firstName .. " " .. char.lastName, "Bought illegal item", item.name .. " for " .. Mzansi.Util.formatMoney(item.price), "")
    return true
end

function Mzansi.IllegalMarket.sellFenceItem(source, itemName)
    local char = Mzansi.Characters.getCharacter(source)
    if not char then return false end

    local fenceItem = nil
    for _, item in ipairs(Mzansi.IllegalMarket.Config.FenceItems) do
        if item.name == itemName then
            fenceItem = item
            break
        end
    end

    if not fenceItem then
        Mzansi.Util.sendNotification(source, "Cannot fence this item.", "error")
        return false
    end

    local itemNameSafe = itemName:gsub(" ", "_"):lower()
    if not invHas(source, itemNameSafe) then
        Mzansi.Util.sendNotification(source, "You don't have " .. itemName, "error")
        return false
    end

    local sellPrice = math.floor(fenceItem.basePrice * (0.7 + math.random() * 0.3))
    invRemove(source, itemNameSafe, 1)
    Mzansi.Characters.addCash(source, sellPrice)

    Mzansi.Util.sendNotification(source, "Fenced " .. itemName .. " for " .. Mzansi.Util.formatMoney(sellPrice), "success")
    Mzansi.Characters.addXP(source, 100)

    Mzansi.Database.logAction("FENCE", char.id, char.firstName .. " " .. char.lastName, "Fenced item", itemName .. " for " .. Mzansi.Util.formatMoney(sellPrice), "")
    return true
end

function Mzansi.IllegalMarket.chopVehicle(source, vehicle)
    local char = Mzansi.Characters.getCharacter(source)
    if not char then return false end

    if not vehicle or not isElement(vehicle) then
        Mzansi.Util.sendNotification(source, "Invalid vehicle.", "error")
        return false
    end

    local x, y, z = getElementPosition(source)
    local chopLocation = nil
    for _, loc in ipairs(Mzansi.IllegalMarket.Config.Locations) do
        if loc.id == 6 then
            chopLocation = loc
            break
        end
    end

    if chopLocation then
        if Mzansi.Util.distance(x, y, z, chopLocation.x, chopLocation.y, chopLocation.z) > chopLocation.radius then
            Mzansi.Util.sendNotification(source, "Not at chop shop.", "error")
            return false
        end
    end

    local model = getElementModel(vehicle)
    local reward = 5000
    for _, v in ipairs(Mzansi.IllegalMarket.Config.ChopShop.vehicleRewards) do
        if v.model == model then
            reward = v.scrap
            break
        end
    end

    local plate = getElementData(vehicle, "mzansi:plate") or "Unknown"
    local ownerId = getElementData(vehicle, "mzansi:ownerId")

    if ownerId then
        local owner = Mzansi.Util.getPlayerFromIdentifier("account:" .. tostring(ownerId))
        if owner and isElement(owner) then
            Mzansi.Util.sendNotification(owner, "Your vehicle (" .. plate .. ") was stolen and chopped!", "error")
        end
    end

    Mzansi.Characters.addCash(source, reward)
    Mzansi.Characters.addXP(source, 500)

    Mzansi.Util.sendNotification(source, "Vehicle chopped! " .. Mzansi.Util.formatMoney(reward), "success")
    setElementData(source, "mzansi:wantedLevel", (getElementData(source, "mzansi:wantedLevel") or 0) + 3)

    Mzansi.Database.logAction("CHOPSHOP", char.id, char.firstName .. " " .. char.lastName, "Chopped vehicle", plate .. " for " .. Mzansi.Util.formatMoney(reward), "")

    destroyElement(vehicle)
    return true
end

function Mzansi.IllegalMarket.sellDrugsToDealer(source, drugId, amount)
    local char = Mzansi.Characters.getCharacter(source)
    if not char then return false end

    local x, y, z = getElementPosition(source)
    local dealerLocation = nil
    for _, loc in ipairs(Mzansi.IllegalMarket.Config.Locations) do
        if loc.id == 4 then
            dealerLocation = loc
            break
        end
    end

    if dealerLocation then
        if Mzansi.Util.distance(x, y, z, dealerLocation.x, dealerLocation.y, dealerLocation.z) > dealerLocation.radius then
            Mzansi.Util.sendNotification(source, "Not at drug dealer.", "error")
            return false
        end
    end

    amount = tonumber(amount) or 1
    if not invHas(source, drugId, amount) then
        Mzansi.Util.sendNotification(source, "Not enough drugs.", "error")
        return false
    end

    local drugPrices = {
        weed = 800,
        cocaine = 2500,
        heroin = 5000,
        ecstasy = 1200,
        meth = 3500,
    }

    local pricePerUnit = drugPrices[drugId] or 500
    local totalPrice = pricePerUnit * amount

    invRemove(source, drugId, amount)
    Mzansi.Characters.addCash(source, totalPrice)

    Mzansi.Util.sendNotification(source, "Sold " .. amount .. "x " .. drugId .. " for " .. Mzansi.Util.formatMoney(totalPrice), "success")
    setElementData(source, "mzansi:wantedLevel", (getElementData(source, "mzansi:wantedLevel") or 0) + 2)

    return true
end

addEventHandler("mzansi:illegalmarket:buy", root, function(locationId, itemId)
    local source = client or source
    Mzansi.IllegalMarket.buyItem(source, locationId, itemId)
end)

addEventHandler("mzansi:illegalmarket:sell", root, function(itemName)
    local source = client or source
    Mzansi.IllegalMarket.sellFenceItem(source, itemName)
end)

addEventHandler("mzansi:illegalmarket:chop", root, function(vehicle)
    local source = client or source
    Mzansi.IllegalMarket.chopVehicle(source, vehicle)
end)

addEventHandler("mzansi:illegalmarket:fence", root, function(drugId, amount)
    local source = client or source
    Mzansi.IllegalMarket.sellDrugsToDealer(source, drugId, amount)
end)

addEventHandler("onResourceStart", resourceRoot, function()
    outputDebugString("[Mzansi-IllegalMarket] Illegal market system loaded.")
end)
