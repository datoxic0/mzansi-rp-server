Mzansi = Mzansi or {}
Mzansi.Funds = Mzansi.Funds or {}

local function notify(player, msg, kind)
    local res = getResourceFromName("mzansi_core")
    if res and getResourceState(res) == "running" then
        pcall(function()
            exports.mzansi_core:sendNotification(player, msg, kind or "info")
        end)
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

local MIN_TICKET = 5000
local REDEMPTION_DELAY_MS = 600000

function Mzansi.Funds.list()
    return dbQuery("SELECT * FROM mzansi_funds ORDER BY id ASC") or {}
end

function Mzansi.Funds.create(player, name, strategy)
    local char = getChar(player)
    if not char then
        notify(player, "No character loaded.", "error")
        return false
    end
    name = tostring(name or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if #name < 3 or #name > 48 then
        notify(player, "Fund name must be 3–48 characters.", "error")
        return false
    end
    if not removeBank(player, 100000) then
        notify(player, "Sponsor ticket R100,000 required from bank.", "error")
        return false
    end
    dbInsert(
        "INSERT INTO mzansi_funds (name, sponsor_type, sponsor_id, strategy, aum, nav, status) VALUES (?, 'character', ?, ?, 100000, 1.0, 'open')",
        name, char.id, tostring(strategy or "balanced")
    )
    notify(player, "Hedge fund '" .. name .. "' launched with R100,000 seed.", "success")
    triggerClientEvent(player, "mzansi:market:setFunds", player, Mzansi.Funds.list())
    return true
end

function Mzansi.Funds.invest(player, fundId, amount)
    local char = getChar(player)
    if not char then return false end
    amount = math.floor(tonumber(amount) or 0)
    if amount < MIN_TICKET then
        notify(player, "Minimum ticket is R" .. MIN_TICKET .. ".", "error")
        return false
    end
    local rows = dbQuery("SELECT * FROM mzansi_funds WHERE id = ? LIMIT 1", fundId)
    if not rows or not rows[1] then
        notify(player, "Fund not found.", "error")
        return false
    end
    if rows[1].status ~= "open" then
        notify(player, "Fund is not open for subscriptions.", "error")
        return false
    end
    local nav = tonumber(rows[1].nav) or 1.0
    if not removeBank(player, amount) then
        notify(player, "Insufficient bank balance.", "error")
        return false
    end
    local units = amount / nav
    local mem = dbQuery(
        "SELECT * FROM mzansi_fund_members WHERE fund_id = ? AND character_id = ? LIMIT 1",
        fundId, char.id
    )
    if mem and mem[1] then
        dbUpdate(
            "UPDATE mzansi_fund_members SET units = units + ? WHERE fund_id = ? AND character_id = ?",
            units, fundId, char.id
        )
    else
        dbInsert(
            "INSERT INTO mzansi_fund_members (fund_id, character_id, units) VALUES (?, ?, ?)",
            fundId, char.id, units
        )
    end
    dbUpdate("UPDATE mzansi_funds SET aum = aum + ? WHERE id = ?", amount, fundId)
    dbInsert(
        "INSERT INTO mzansi_fund_tx (fund_id, character_id, tx_type, amount, units, nav, detail) VALUES (?, ?, 'subscribe', ?, ?, ?, 'bank subscription')",
        fundId, char.id, amount, units, nav
    )
    notify(player, string.format("Subscribed R%d → %.4f units @ NAV %.4f", amount, units, nav), "success")
    triggerClientEvent(player, "mzansi:market:setFunds", player, Mzansi.Funds.list())
    return true
end

function Mzansi.Funds.redeem(player, fundId, units)
    local char = getChar(player)
    if not char then return false end
    units = tonumber(units) or 0
    if units <= 0 then
        notify(player, "Invalid unit amount.", "error")
        return false
    end
    local mem = dbQuery(
        "SELECT * FROM mzansi_fund_members WHERE fund_id = ? AND character_id = ? LIMIT 1",
        fundId, char.id
    )
    if not mem or not mem[1] then
        notify(player, "No units held in this fund.", "error")
        return false
    end
    local held = tonumber(mem[1].units) or 0
    if held + 1e-9 < units then
        notify(player, "Insufficient units.", "error")
        return false
    end
    local fund = dbQuery("SELECT * FROM mzansi_funds WHERE id = ? LIMIT 1", fundId)
    if not fund or not fund[1] then return false end
    local nav = tonumber(fund[1].nav) or 1.0
    local proceeds = math.floor(units * nav)
    dbUpdate(
        "UPDATE mzansi_fund_members SET units = units - ? WHERE fund_id = ? AND character_id = ?",
        units, fundId, char.id
    )
    dbUpdate("UPDATE mzansi_funds SET aum = aum - ? WHERE id = ?", proceeds, fundId)
    dbInsert(
        "INSERT INTO mzansi_fund_tx (fund_id, character_id, tx_type, amount, units, nav, detail) VALUES (?, ?, 'redeem', ?, ?, ?, 'T+ redemption payout')",
        fundId, char.id, proceeds, units, nav
    )
    addBank(player, proceeds)
    notify(player, string.format("Redeemed %.4f units for R%d (delayed NAV settle)", units, proceeds), "success")
    triggerClientEvent(player, "mzansi:market:setFunds", player, Mzansi.Funds.list())
    return true
end

function Mzansi.Funds.navTick()
    local funds = Mzansi.Funds.list()
    for _, fund in ipairs(funds) do
        local nav = tonumber(fund.nav) or 1.0
        local strat = fund.strategy or "balanced"
        local drift = 0
        if strat == "aggressive" then
            drift = (math.random() - 0.48) * 0.02
        elseif strat == "conservative" then
            drift = (math.random() - 0.49) * 0.006
        else
            drift = (math.random() - 0.49) * 0.01
        end
        local newNav = nav * (1 + drift)
        if newNav < 0.2 then newNav = 0.2 end
        if newNav > 10 then newNav = 10 end
        dbUpdate("UPDATE mzansi_funds SET nav = ? WHERE id = ?", newNav, fund.id)
    end
end

addEventHandler("mzansi:market:requestFunds", root, function()
    local player = client or source
    triggerClientEvent(player, "mzansi:market:setFunds", player, Mzansi.Funds.list())
end)

addEventHandler("mzansi:market:createFund", root, function(name, strategy)
    local player = client or source
    Mzansi.Funds.create(player, name, strategy)
end)

addEventHandler("mzansi:market:investFund", root, function(fundId, amount)
    local player = client or source
    Mzansi.Funds.invest(player, fundId, amount)
end)

addEventHandler("mzansi:market:redeemFund", root, function(fundId, units)
    local player = client or source
    Mzansi.Funds.redeem(player, fundId, units)
end)

function getFunds()
    return Mzansi.Funds.list()
end

function investFund(player, fundId, amount)
    return Mzansi.Funds.invest(player, fundId, amount)
end

function redeemFund(player, fundId, units)
    return Mzansi.Funds.redeem(player, fundId, units)
end

setTimer(function()
    Mzansi.Funds.navTick()
end, 60000, 0)
