Mzansi = Mzansi or {}
Mzansi.AssetMarket = Mzansi.AssetMarket or {}
Mzansi.AssetMarket._lotCursor = { car = 0, boat = 0, plane = 0 }
Mzansi.AssetMarket._interestTimers = {}

addEvent("mzansi:market:requestCatalog", true)
addEvent("mzansi:market:buyVehicle", true)
addEvent("mzansi:market:sellVehicle", true)
addEvent("mzansi:market:requestPortfolio", true)
addEvent("mzansi:market:invest", true)
addEvent("mzansi:market:withdraw", true)
addEvent("mzansi:market:claimInterest", true)
addEvent("mzansi:market:open", true)
addEvent("mzansi:characters:spawned", true)

local function money(amount)
    return Mzansi.Util.formatMoney(amount)
end

local function vehicleKindOf(model)
    for kind, list in pairs(Mzansi.Market.Vehicles) do
        for _, entry in ipairs(list) do
            if entry.model == model then
                return kind
            end
        end
    end
    return "car"
end

local function nextSpawnPoint(kind)
    local lot = Mzansi.Market.Lots[kind]
    if not lot then return nil end
    Mzansi.AssetMarket._lotCursor[kind] = (Mzansi.AssetMarket._lotCursor[kind] or 0) + 1
    local idx = ((Mzansi.AssetMarket._lotCursor[kind] - 1) % #lot.spawn) + 1
    return lot.spawn[idx]
end

local function sendCatalog(player)
    local char = Mzansi.Characters.getCharacter(player)
    local catalog = {
        cash = char and char.cash or 0,
        bank = char and char.bank or 0,
        maxVehicles = Mzansi.Config.Server.maxVehiclesPerPlayer,
        vehicleCount = char and #Mzansi.Database.getPlayerVehicles(char.id) or 0,
        vehicles = Mzansi.Market.Vehicles,
        investments = Mzansi.Market.Investments,
        lots = Mzansi.Market.Lots,
        kinds = Mzansi.Market.VehicleKinds,
    }
    triggerClientEvent(player, "mzansi:market:setCatalog", player, catalog)
end

local function sendPortfolio(player)
    local char = Mzansi.Characters.getCharacter(player)
    if not char then return end

    local vehicles = {}
    for _, v in ipairs(Mzansi.Database.getPlayerVehicles(char.id)) do
        local kind = vehicleKindOf(v.model_id)
        vehicles[#vehicles + 1] = {
            id = v.id,
            model = v.model_id,
            plate = v.plate,
            kind = kind,
            fuel = v.fuel or 100,
            health = v.health or 1000,
            mileage = v.mileage or 0,
        }
    end

    local investments = {}
    for _, inv in ipairs(Mzansi.Database.getPlayerInvestments(char.id)) do
        investments[#investments + 1] = {
            id = inv.id,
            key = inv.investment_key,
            principal = inv.principal,
            accrued = inv.accrued_interest or 0,
            rate = inv.rate_per_cycle or 0,
        }
    end

    local ownedProps = Mzansi.Database.getPlayerProperties(char.id)
    local props = {}
    for _, p in ipairs(ownedProps) do
        props[#props + 1] = {
            id = p.id,
            name = p.name,
            price = p.price or 0,
            type = p.type or 0,
        }
    end

    triggerClientEvent(player, "mzansi:market:setPortfolio", player, {
        cash = char.cash,
        bank = char.bank,
        vehicles = vehicles,
        investments = investments,
        properties = props,
        maxVehicles = Mzansi.Config.Server.maxVehiclesPerPlayer,
        maxHouses = Mzansi.Config.Server.maxHousesPerPlayer,
    })
end

function Mzansi.AssetMarket.buyVehicle(player, kind, model)
    local char = Mzansi.Characters.getCharacter(player)
    if not char then return false end

    kind = tostring(kind or "car")
    model = tonumber(model)
    if not model then
        Mzansi.Util.sendNotification(player, "Invalid vehicle model.", "error")
        return false
    end

    local entry = Mzansi.Market.findVehicle(kind, model)
    if not entry then
        Mzansi.Util.sendNotification(player, "That vehicle is not for sale.", "error")
        return false
    end

    local owned = Mzansi.Database.getPlayerVehicles(char.id)
    if #owned >= Mzansi.Config.Server.maxVehiclesPerPlayer then
        Mzansi.Util.sendNotification(player, "Vehicle limit reached (" .. Mzansi.Config.Server.maxVehiclesPerPlayer .. "). Sell one first.", "error")
        return false
    end

    if char.cash < entry.price then
        Mzansi.Util.sendNotification(player, "Insufficient cash. Need " .. money(entry.price), "error")
        return false
    end

    local spawn = nextSpawnPoint(kind) or { x = char.spawnX or 1682.5, y = char.spawnY or -2267.0, z = char.spawnZ or 13.5, rot = 0 }
    if not Mzansi.Characters.removeCash(player, entry.price) then
        Mzansi.Util.sendNotification(player, "Payment failed.", "error")
        return false
    end

    local vehicle, err = Mzansi.Vehicles.createPlayerVehicle(player, model, spawn.x, spawn.y, spawn.z)
    if not vehicle then
        Mzansi.Characters.addCash(player, entry.price)
        Mzansi.Util.sendNotification(player, err or "Vehicle creation failed. Refunded.", "error")
        return false
    end

    setElementRotation(vehicle, 0, 0, spawn.rot or 0)
    local dbData = Mzansi.Vehicles._byElement[vehicle]
    if dbData then
        dbData.type = (kind == "boat") and 1 or ((kind == "plane") and 2 or 0)
        Mzansi.Database.saveVehicle(dbData.id, { type = dbData.type, x = spawn.x, y = spawn.y, z = spawn.z, rotation = spawn.rot or 0 })
    end

    Mzansi.Util.sendNotification(player, "Purchased " .. entry.name .. " for " .. money(entry.price) .. ".", "success")
    Mzansi.Database.logAction("ASSET", char.id, char.firstName .. " " .. char.lastName, "Bought vehicle", entry.name .. " (" .. kind .. ") for " .. money(entry.price), getPlayerIP(player))
    sendCatalog(player)
    sendPortfolio(player)
    return true
end

function Mzansi.AssetMarket.sellVehicle(player, vehicleId)
    local char = Mzansi.Characters.getCharacter(player)
    if not char then return false end
    vehicleId = tonumber(vehicleId)
    if not vehicleId then return false end

    local rows = Mzansi.Database.query("SELECT * FROM mzansi_vehicles WHERE id = ? AND owner_id = ? LIMIT 1", vehicleId, char.id)
    if not rows or #rows == 0 then
        Mzansi.Util.sendNotification(player, "You do not own that vehicle.", "error")
        return false
    end

    local row = rows[1]
    local entry = Mzansi.Market.findVehicle(vehicleKindOf(row.model_id), row.model_id)
    local base = entry and entry.price or 10000
    local healthFactor = math.min(1, (row.health or 1000) / 1000)
    local payout = math.floor(base * 0.55 * healthFactor)

    local veh = Mzansi.Vehicles._spawned[vehicleId]
    if veh and isElement(veh) then
        Mzansi.Vehicles._spawned[vehicleId] = nil
        Mzansi.Vehicles._byPlate[row.plate] = nil
        Mzansi.Vehicles._byElement[veh] = nil
        destroyElement(veh)
    end

    Mzansi.Database.deleteVehicle(vehicleId)
    Mzansi.Characters.addCash(player, payout)
    Mzansi.Util.sendNotification(player, "Sold vehicle for " .. money(payout) .. ".", "success")
    Mzansi.Database.logAction("ASSET", char.id, char.firstName .. " " .. char.lastName, "Sold vehicle", (entry and entry.name or row.model_id) .. " for " .. money(payout), getPlayerIP(player))
    sendPortfolio(player)
    sendCatalog(player)
    return true
end

function Mzansi.AssetMarket.invest(player, key, amount)
    local char = Mzansi.Characters.getCharacter(player)
    if not char then return false end

    local cfg = Mzansi.Market.findInvestment(tostring(key or ""))
    if not cfg then
        Mzansi.Util.sendNotification(player, "Unknown investment product.", "error")
        return false
    end

    amount = math.floor(tonumber(amount) or 0)
    if amount < cfg.min then
        Mzansi.Util.sendNotification(player, "Minimum investment is " .. money(cfg.min) .. ".", "error")
        return false
    end
    if amount > cfg.max then
        Mzansi.Util.sendNotification(player, "Maximum investment is " .. money(cfg.max) .. ".", "error")
        return false
    end

    local existing = Mzansi.Database.getPlayerInvestments(char.id)
    local already = 0
    for _, inv in ipairs(existing) do
        if inv.investment_key == cfg.key then
            already = already + (inv.principal or 0) + (inv.accrued_interest or 0)
        end
    end
    if already + amount > cfg.max then
        Mzansi.Util.sendNotification(player, "Cap for this product is " .. money(cfg.max) .. ".", "error")
        return false
    end

    if not Mzansi.Characters.removeBank(player, amount) then
        Mzansi.Util.sendNotification(player, "Insufficient bank balance.", "error")
        return false
    end

    local invId = Mzansi.Database.createInvestment(char.id, cfg.key, amount, cfg.rate)
    if not invId then
        Mzansi.Characters.addBank(player, amount)
        Mzansi.Util.sendNotification(player, "Investment failed. Funds returned.", "error")
        return false
    end

    Mzansi.Util.sendNotification(player, "Invested " .. money(amount) .. " in " .. cfg.name .. ".", "success")
    Mzansi.Database.logAction("INVEST", char.id, char.firstName .. " " .. char.lastName, "Opened investment", cfg.name .. " " .. money(amount), getPlayerIP(player))
    Mzansi.AssetMarket.armInterest(char.id, invId, cfg)
    sendPortfolio(player)
    return true
end

function Mzansi.AssetMarket.withdraw(player, investmentId)
    local char = Mzansi.Characters.getCharacter(player)
    if not char then return false end
    investmentId = tonumber(investmentId)
    if not investmentId then return false end

    local rows = Mzansi.Database.query("SELECT * FROM mzansi_investments WHERE id = ? AND owner_id = ? LIMIT 1", investmentId, char.id)
    if not rows or #rows == 0 then
        Mzansi.Util.sendNotification(player, "Investment not found.", "error")
        return false
    end

    local inv = rows[1]
    local total = (inv.principal or 0) + (inv.accrued_interest or 0)
    Mzansi.Database.deleteInvestment(investmentId)
    Mzansi.Characters.addBank(player, total)

    if Mzansi.AssetMarket._interestTimers[investmentId] then
        killTimer(Mzansi.AssetMarket._interestTimers[investmentId])
        Mzansi.AssetMarket._interestTimers[investmentId] = nil
    end

    Mzansi.Util.sendNotification(player, "Withdrew " .. money(total) .. " from investment.", "success")
    Mzansi.Database.logAction("INVEST", char.id, char.firstName .. " " .. char.lastName, "Withdrew investment", money(total), getPlayerIP(player))
    sendPortfolio(player)
    return true
end

function Mzansi.AssetMarket.claimInterest(player, investmentId)
    local char = Mzansi.Characters.getCharacter(player)
    if not char then return false end
    investmentId = tonumber(investmentId)
    if not investmentId then return false end

    local rows = Mzansi.Database.query("SELECT * FROM mzansi_investments WHERE id = ? AND owner_id = ? LIMIT 1", investmentId, char.id)
    if not rows or #rows == 0 then return false end

    local inv = rows[1]
    local accrued = inv.accrued_interest or 0
    if accrued <= 0 then
        Mzansi.Util.sendNotification(player, "No interest accrued yet.", "info")
        return false
    end

    Mzansi.Database.updateInvestment(investmentId, { accrued_interest = 0 })
    Mzansi.Characters.addBank(player, accrued)
    Mzansi.Util.sendNotification(player, "Claimed " .. money(accrued) .. " interest.", "success")
    sendPortfolio(player)
    return true
end

function Mzansi.AssetMarket.armInterest(charId, investmentId, cfg)
    if Mzansi.AssetMarket._interestTimers[investmentId] then
        killTimer(Mzansi.AssetMarket._interestTimers[investmentId])
    end
    local cycle = (cfg and cfg.cycleMs) or 300000
    local rate = (cfg and cfg.rate) or 0.004

    Mzansi.AssetMarket._interestTimers[investmentId] = setTimer(function()
        if not Mzansi.Database._pool then return end
        local rows = Mzansi.Database.query("SELECT * FROM mzansi_investments WHERE id = ? LIMIT 1", investmentId)
        if not rows or #rows == 0 then
            if Mzansi.AssetMarket._interestTimers[investmentId] then
                killTimer(Mzansi.AssetMarket._interestTimers[investmentId])
                Mzansi.AssetMarket._interestTimers[investmentId] = nil
            end
            return
        end
        local inv = rows[1]
        local gain = math.floor((inv.principal or 0) * (inv.rate_per_cycle or rate))
        if gain < 1 then return end
        Mzansi.Database.updateInvestment(investmentId, {
            accrued_interest = (inv.accrued_interest or 0) + gain,
        })
        Mzansi.Database.update("UPDATE mzansi_investments SET last_payout = CURRENT_TIMESTAMP WHERE id = ?", investmentId)
    end, cycle, 0)
end

function Mzansi.AssetMarket.armAllForCharacter(charId)
    local investments = Mzansi.Database.getPlayerInvestments(charId)
    for _, inv in ipairs(investments) do
        local cfg = Mzansi.Market.findInvestment(inv.investment_key)
        Mzansi.AssetMarket.armInterest(charId, inv.id, cfg)
    end
end

addEventHandler("mzansi:market:requestCatalog", root, function()
    local player = client or source
    sendCatalog(player)
end)

addEventHandler("mzansi:market:open", root, function()
    local player = client or source
    sendCatalog(player)
    sendPortfolio(player)
    triggerClientEvent(player, "mzansi:market:openUI", player)
end)

addEventHandler("mzansi:market:buyVehicle", root, function(kind, model)
    local player = client or source
    Mzansi.AssetMarket.buyVehicle(player, kind, model)
end)

addEventHandler("mzansi:market:sellVehicle", root, function(vehicleId)
    local player = client or source
    Mzansi.AssetMarket.sellVehicle(player, vehicleId)
end)

addEventHandler("mzansi:market:requestPortfolio", root, function()
    local player = client or source
    sendPortfolio(player)
end)

addEventHandler("mzansi:market:invest", root, function(key, amount)
    local player = client or source
    Mzansi.AssetMarket.invest(player, key, amount)
end)

addEventHandler("mzansi:market:withdraw", root, function(investmentId)
    local player = client or source
    Mzansi.AssetMarket.withdraw(player, investmentId)
end)

addEventHandler("mzansi:market:claimInterest", root, function(investmentId)
    local player = client or source
    Mzansi.AssetMarket.claimInterest(player, investmentId)
end)

addCommandHandler("buyvehicle", function(player, cmd, a1, a2)
    local kind = string.lower(tostring(a1 or ""))
    local model = tonumber(a2)
    if not Mzansi.Market.Vehicles[kind] then
        local asCar = tonumber(a1)
        if asCar then
            kind = "car"
            model = asCar
        else
            kind = "car"
            model = nil
        end
    end
    if not model then
        outputChatBox("#FFC850[MARKET] Usage: /buyvehicle <car|boat|plane> <model_id>", player, 255, 255, 255, true)
        outputChatBox("#9EC9FF[MARKET] Example: /buyvehicle car 411  |  /buyvehicle boat 493  |  /buyvehicle plane 593", player, 255, 255, 255, true)
        return
    end
    Mzansi.AssetMarket.buyVehicle(player, kind, model)
end)

addCommandHandler("market", function(player)
    triggerEvent("mzansi:market:open", player, player)
end)

addCommandHandler("investments", function(player)
    triggerEvent("mzansi:market:open", player, player)
end)

addEventHandler("onPlayerJoin", root, function()
    setTimer(function()
        local player = source
        if isElement(player) then
            local char = Mzansi.Characters.getCharacter(player)
            if char then
                Mzansi.AssetMarket.armAllForCharacter(char.id)
            end
        end
    end, 5000, 1)
end)

addEventHandler("mzansi:characters:spawned", root, function()
    local player = client or source
    local char = Mzansi.Characters.getCharacter(player)
    if char then
        Mzansi.AssetMarket.armAllForCharacter(char.id)
    end
end)

addEventHandler("onResourceStart", resourceRoot, function()
    setTimer(function()
        if not Mzansi.Database._pool then return end
        local all = Mzansi.Database.getAllInvestments()
        for _, inv in ipairs(all) do
            local cfg = Mzansi.Market.findInvestment(inv.investment_key)
            Mzansi.AssetMarket.armInterest(inv.owner_id, inv.id, cfg)
        end
        outputDebugString("[Mzansi-AssetMarket] Market loaded. Investments armed: " .. #all)
    end, 8000, 1)
end)
