Mzansi = Mzansi or {}
Mzansi.Paper = Mzansi.Paper or {}

addEvent("mzansi:market:requestQuotes", true)
addEvent("mzansi:market:buy", true)
addEvent("mzansi:market:sell", true)
addEvent("mzansi:market:requestPortfolio", true)
addEvent("mzansi:market:requestFunds", true)
addEvent("mzansi:market:investFund", true)
addEvent("mzansi:market:redeemFund", true)
addEvent("mzansi:market:createFund", true)
addEvent("mzansi:market:openUI", true)

local function notify(player, msg, kind)
    local res = getResourceFromName("mzansi_core")
    if res and getResourceState(res) == "running" then
        pcall(function()
            exports.mzansi_core:sendNotification(player, msg, kind or "info")
        end)
    else
        outputChatBox("[Market] " .. tostring(msg), player, 220, 180, 60, false)
    end
end

local function getChar(player)
    local res = getResourceFromName("mzansi_core")
    if res and getResourceState(res) == "running" then
        local ok, char = pcall(function()
            return exports.mzansi_core:getCharacter(player)
        end)
        if ok then return char end
    end
    return nil
end

local function addBank(player, amount)
    local res = getResourceFromName("mzansi_core")
    if res and getResourceState(res) == "running" then
        local ok = pcall(function()
            return exports.mzansi_core:addBank(player, amount)
        end)
        return ok
    end
    return false
end

local function removeBank(player, amount)
    local res = getResourceFromName("mzansi_core")
    if res and getResourceState(res) == "running" then
        local ok, result = pcall(function()
            return exports.mzansi_core:removeBank(player, amount)
        end)
        return ok and result
    end
    return false
end

local function dbQuery(sql, ...)
    local args = { ... }
    local res = getResourceFromName("mzansi_core")
    if res and getResourceState(res) == "running" then
        local ok, rows = pcall(function()
            return exports.mzansi_core:database_query(sql, unpack(args))
        end)
        if ok then return rows end
    end
    return nil
end

local function dbInsert(sql, ...)
    local args = { ... }
    local res = getResourceFromName("mzansi_core")
    if res and getResourceState(res) == "running" then
        local ok, id = pcall(function()
            return exports.mzansi_core:database_insert(sql, unpack(args))
        end)
        if ok then return id end
    end
    return nil
end

local function dbUpdate(sql, ...)
    local args = { ... }
    local res = getResourceFromName("mzansi_core")
    if res and getResourceState(res) == "running" then
        local ok = pcall(function()
            return exports.mzansi_core:database_update(sql, unpack(args))
        end)
        return ok
    end
    return false
end

function Mzansi.Paper.getPosition(charId, symbol)
    local rows = dbQuery(
        "SELECT * FROM mzansi_market_positions WHERE character_id = ? AND symbol = ? LIMIT 1",
        charId, symbol
    )
    if rows and rows[1] then return rows[1] end
    return nil
end

function Mzansi.Paper.upsertPosition(charId, symbol, qtyDelta, avgPrice, realized)
    local pos = Mzansi.Paper.getPosition(charId, symbol)
    if not pos then
        dbInsert(
            "INSERT INTO mzansi_market_positions (character_id, symbol, qty, avg_price, realized_pnl) VALUES (?, ?, ?, ?, ?)",
            charId, symbol, math.max(qtyDelta, 0), avgPrice or 0, realized or 0
        )
        return
    end
    local qty = tonumber(pos.qty) or 0
    local avg = tonumber(pos.avg_price) or 0
    local realizedPnl = tonumber(pos.realized_pnl) or 0
    local newQty = qty + qtyDelta
    local newAvg = avg
    local newRealized = realizedPnl + (realized or 0)
    if qtyDelta > 0 then
        newAvg = ((avg * math.max(qty, 0)) + (avgPrice or 0) * qtyDelta) / math.max(qty + qtyDelta, 1)
    elseif newQty <= 0 then
        newQty = 0
        newAvg = 0
    end
    dbUpdate(
        "UPDATE mzansi_market_positions SET qty = ?, avg_price = ?, realized_pnl = ?, updated_at = CURRENT_TIMESTAMP WHERE character_id = ? AND symbol = ?",
        newQty, newAvg, newRealized, charId, symbol
    )
end

function Mzansi.Paper.buy(player, symbol, qty)
    local char = getChar(player)
    if not char then
        notify(player, "No character loaded.", "error")
        return false
    end
    qty = math.floor(tonumber(qty) or 0)
    if qty <= 0 or qty > 10000 then
        notify(player, "Invalid quantity.", "error")
        return false
    end
    local marketPrice = Mzansi.MarketSim.getPrice(symbol)
    if not marketPrice then
        notify(player, "Unknown symbol.", "error")
        return false
    end
    local fill = Mzansi.Strategy.fillPrice("buy", marketPrice, qty)
    local notional = fill * qty
    local fee = Mzansi.Strategy.commission(notional)
    local total = notional + fee
    if not removeBank(player, math.ceil(total)) then
        notify(player, "Insufficient bank balance.", "error")
        return false
    end
    Mzansi.Paper.upsertPosition(char.id, symbol, qty, fill, 0)
    notify(player, string.format("Bought %d %s @ R%.2f (fee R%d)", qty, symbol, fill, fee), "success")
    triggerClientEvent(player, "mzansi:market:setPortfolio", player, Mzansi.Paper.portfolio(char.id))
    triggerClientEvent(player, "mzansi:market:setQuotes", player, Mzansi.MarketSim.getQuotes())
    return true
end

function Mzansi.Paper.sell(player, symbol, qty)
    local char = getChar(player)
    if not char then
        notify(player, "No character loaded.", "error")
        return false
    end
    qty = math.floor(tonumber(qty) or 0)
    if qty <= 0 then
        notify(player, "Invalid quantity.", "error")
        return false
    end
    local pos = Mzansi.Paper.getPosition(char.id, symbol)
    local held = pos and (tonumber(pos.qty) or 0) or 0
    if held < qty then
        notify(player, "Not enough position to sell.", "error")
        return false
    end
    local marketPrice = Mzansi.MarketSim.getPrice(symbol)
    if not marketPrice then
        notify(player, "Unknown symbol.", "error")
        return false
    end
    local fill = Mzansi.Strategy.fillPrice("sell", marketPrice, qty)
    local notional = fill * qty
    local fee = Mzansi.Strategy.commission(notional)
    local avg = tonumber(pos.avg_price) or 0
    local realized = (fill - avg) * qty - fee
    Mzansi.Paper.upsertPosition(char.id, symbol, -qty, fill, realized)
    addBank(player, math.floor(notional - fee))
    notify(player, string.format("Sold %d %s @ R%.2f (PnL R%d)", qty, symbol, fill, math.floor(realized)), "success")
    triggerClientEvent(player, "mzansi:market:setPortfolio", player, Mzansi.Paper.portfolio(char.id))
    triggerClientEvent(player, "mzansi:market:setQuotes", player, Mzansi.MarketSim.getQuotes())
    return true
end

function Mzansi.Paper.portfolio(charId)
    local rows = dbQuery(
        "SELECT symbol, qty, avg_price, realized_pnl FROM mzansi_market_positions WHERE character_id = ?",
        charId
    ) or {}
    local out = {}
    for _, row in ipairs(rows) do
        local px = Mzansi.MarketSim.getPrice(row.symbol) or 0
        local qty = tonumber(row.qty) or 0
        local avg = tonumber(row.avg_price) or 0
        out[#out + 1] = {
            symbol = row.symbol,
            qty = qty,
            avg_price = avg,
            mark = px,
            market_value = px * qty,
            unrealized = (px - avg) * qty,
            realized_pnl = tonumber(row.realized_pnl) or 0,
        }
    end
    return out
end

addEventHandler("mzansi:market:requestQuotes", root, function()
    local player = client or source
    triggerClientEvent(player, "mzansi:market:setQuotes", player, Mzansi.MarketSim.getQuotes())
end)

addEventHandler("mzansi:market:requestPortfolio", root, function()
    local player = client or source
    local char = getChar(player)
    if not char then return end
    triggerClientEvent(player, "mzansi:market:setPortfolio", player, Mzansi.Paper.portfolio(char.id))
end)

addEventHandler("mzansi:market:buy", root, function(symbol, qty)
    local player = client or source
    Mzansi.Paper.buy(player, symbol, qty)
end)

addEventHandler("mzansi:market:sell", root, function(symbol, qty)
    local player = client or source
    Mzansi.Paper.sell(player, symbol, qty)
end)

addEventHandler("mzansi:market:openUI", root, function()
    local player = client or source
    triggerClientEvent(player, "mzansi:market:openUI", player)
end)

function getQuotes()
    return Mzansi.MarketSim.getQuotes()
end

function getPortfolio(player)
    local char = getChar(player)
    if not char then return {} end
    return Mzansi.Paper.portfolio(char.id)
end

function buyPaper(player, symbol, qty)
    return Mzansi.Paper.buy(player, symbol, qty)
end

function sellPaper(player, symbol, qty)
    return Mzansi.Paper.sell(player, symbol, qty)
end
