Mzansi = Mzansi or {}
Mzansi.VehicleShop = Mzansi.VehicleShop or {}
Mzansi.VehicleShop._slotCursor = {}

addEvent("mzansi:vshop:open", true)
addEvent("mzansi:vshop:buy", true)

local function money(amount)
    return Mzansi.Util.formatMoney(amount)
end

local function findShop(shopId)
    if not Mzansi.VehicleShops or not Mzansi.VehicleShops.Locations then return nil end
    for _, loc in ipairs(Mzansi.VehicleShops.Locations) do
        if loc.id == shopId then return loc end
    end
    return Mzansi.VehicleShops.Locations[1]
end

local function nextSpawn(shop)
    local offsets = Mzansi.VehicleShops.SpawnOffsets or { { dx = 8, dy = 0, rot = 0 } }
    Mzansi.VehicleShop._slotCursor[shop.id] = ((Mzansi.VehicleShop._slotCursor[shop.id] or 0) + 1)
    local idx = ((Mzansi.VehicleShop._slotCursor[shop.id] - 1) % #offsets) + 1
    local o = offsets[idx]
    return shop.x + o.dx, shop.y + o.dy, shop.z, o.rot or 0
end

local function sendCatalog(player, shopId)
    local char = Mzansi.Characters.getCharacter(player)
    local cat = {
        cash = char and char.cash or 0,
        bank = char and char.bank or 0,
        maxVehicles = Mzansi.Config.Server.maxVehiclesPerPlayer,
        vehicleCount = char and #Mzansi.Database.getPlayerVehicles(char.id) or 0,
        shopId = shopId,
        vehicles = Mzansi.Market.Vehicles,
        kinds = Mzansi.Market.VehicleKinds,
    }
    triggerClientEvent(player, "mzansi:vshop:setCatalog", player, cat)
end

function Mzansi.VehicleShop.open(player, shopId)
    local shop = findShop(shopId)
    if not shop then
        Mzansi.Util.sendNotification(player, "Vehicle shop not found.", "error")
        return
    end
    local x, y, z = getElementPosition(player)
    if Mzansi.Util.distance(x, y, z, shop.x, shop.y, shop.z) > 25 then
        Mzansi.Util.sendNotification(player, "You are not at a dealership.", "error")
        return
    end
    sendCatalog(player, shop.id)
    triggerClientEvent(player, "mzansi:vshop:openUI", player, shop.id)
end

function Mzansi.VehicleShop.buy(player, shopId, model, kindHint)
    local char = Mzansi.Characters.getCharacter(player)
    if not char then return false end

    local shop = findShop(shopId)
    if not shop then
        Mzansi.Util.sendNotification(player, "Vehicle shop not found.", "error")
        return false
    end

    local x, y, z = getElementPosition(player)
    if Mzansi.Util.distance(x, y, z, shop.x, shop.y, shop.z) > 30 then
        Mzansi.Util.sendNotification(player, "Too far from dealership counter.", "error")
        return false
    end

    model = tonumber(model)
    if not model then
        Mzansi.Util.sendNotification(player, "Invalid model.", "error")
        return false
    end

    local kind = tostring(kindHint or "car")
    -- Resolve entry from market config
    local entry = nil
    local foundKind = kind
    for k, list in pairs(Mzansi.Market.Vehicles) do
        for _, e in ipairs(list) do
            if e.model == model then
                entry = e
                foundKind = k
                break
            end
        end
        if entry then break end
    end
    if not entry then
        Mzansi.Util.sendNotification(player, "That vehicle is not for sale.", "error")
        return false
    end

    local owned = #Mzansi.Database.getPlayerVehicles(char.id)
    if owned >= (Mzansi.Config.Server.maxVehiclesPerPlayer or 4) then
        Mzansi.Util.sendNotification(player, "Vehicle limit reached (" .. owned .. ").", "error")
        return false
    end

    if char.cash < entry.price then
        Mzansi.Util.sendNotification(player, "Need " .. money(entry.price) .. " cash.", "error")
        return false
    end

    local sx, sy, sz, srot = nextSpawn(shop)

    -- createPlayerVehicle takes the player element (not char id) and does its own limit check
    local vehicle, err = Mzansi.Vehicles.createPlayerVehicle(player, model, sx, sy, sz)
    if not vehicle then
        Mzansi.Util.sendNotification(player, err or "Spawn failed.", "error")
        return false
    end
    if srot then
        setElementRotation(vehicle, 0, 0, srot)
    end

    Mzansi.Characters.removeCash(player, entry.price)
    if Mzansi.Database.logAction then
        Mzansi.Database.logAction("MARKET", char.id, "Player", "Bought vehicle",
            entry.name .. " (" .. model .. ") from " .. shop.name, getPlayerIP(player))
    end
    if Mzansi.Banking and Mzansi.Banking.logTransaction then
        Mzansi.Banking.logTransaction(char.id, "VEHICLE_BUY", entry.price, char.bank, entry.name, shop.name)
    end

    Mzansi.Util.sendNotification(player, "Purchased " .. entry.name .. " for " .. money(entry.price) .. ".", "success")
    sendCatalog(player, shop.id)
    return true
end

addEventHandler("mzansi:vshop:open", root, function(shopId)
    local player = client or source
    Mzansi.VehicleShop.open(player, shopId)
end)

addEventHandler("mzansi:vshop:buy", root, function(shopId, model, kind)
    local player = client or source
    Mzansi.VehicleShop.buy(player, shopId, model, kind)
end)
