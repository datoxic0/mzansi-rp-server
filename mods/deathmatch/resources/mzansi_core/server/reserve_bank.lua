Mzansi = Mzansi or {}
Mzansi.Reserve = Mzansi.Reserve or {}

addEvent("mzansi:reserve:requestPolicy", true)
addEvent("mzansi:reserve:setPolicy", true)
addEvent("mzansi:reserve:requestSupply", true)

local DEFAULT_POLICY = {
    policy_rate = 0.02,
    reserve_ratio = 0.10,
    tax_rate = 0.05,
    discount_rate = 0.03,
    updated_by = 0,
}

local function isAdmin(player)
    local acc = getPlayerAccount and getPlayerAccount(player)
    if not acc then return false end
    if isGuestAccount(acc) then return false end
    local name = getAccountName(acc)
    return name == "console"
        or hasObjectPermissionTo(player, "function.banPlayer", false)
        or hasObjectPermissionTo(player, "command.kick", false)
        or (ACLGet and ACLGet("Admin") and isObjectInACLGroup("user." .. name, ACLGet("Admin")))
        or (ACLGet and ACLGet("Console") and isObjectInACLGroup("user." .. name, ACLGet("Console")))
end

function Mzansi.Reserve.getPolicy()
    local rows = Mzansi.Database.query("SELECT * FROM mzansi_reserve_policy WHERE id = 1 LIMIT 1")
    if rows and rows[1] then
        return {
            policy_rate = tonumber(rows[1].policy_rate) or DEFAULT_POLICY.policy_rate,
            reserve_ratio = tonumber(rows[1].reserve_ratio) or DEFAULT_POLICY.reserve_ratio,
            tax_rate = tonumber(rows[1].tax_rate) or DEFAULT_POLICY.tax_rate,
            discount_rate = tonumber(rows[1].discount_rate) or DEFAULT_POLICY.discount_rate,
            updated_by = tonumber(rows[1].updated_by) or 0,
            updated_at = rows[1].updated_at,
        }
    end
    -- seed default
    pcall(function()
        Mzansi.Database.insert(
            "INSERT INTO mzansi_reserve_policy (id, policy_rate, reserve_ratio, tax_rate, discount_rate, updated_by) VALUES (1, ?, ?, ?, ?, 0)",
            DEFAULT_POLICY.policy_rate, DEFAULT_POLICY.reserve_ratio, DEFAULT_POLICY.tax_rate, DEFAULT_POLICY.discount_rate
        )
    end)
    return DEFAULT_POLICY
end

function Mzansi.Reserve.setPolicy(player, patch)
    if not isAdmin(player) then
        Mzansi.Util.sendNotification(player, "Reserve policy requires admin.", "error")
        return false
    end
    local cur = Mzansi.Reserve.getPolicy()
    local function clamp(v, lo, hi)
        v = tonumber(v)
        if not v then return nil end
        if v < lo then return lo end
        if v > hi then return hi end
        return v
    end

    local pr = clamp(patch and patch.policy_rate, 0, 0.15) or cur.policy_rate
    local rr = clamp(patch and patch.reserve_ratio, 0, 0.5) or cur.reserve_ratio
    local tx = clamp(patch and patch.tax_rate, 0, 0.3) or cur.tax_rate
    local dr = clamp(patch and patch.discount_rate, 0, 0.15) or cur.discount_rate

    local char = Mzansi.Characters.getCharacter(player)
    local uid = char and char.id or 0

    local ok = Mzansi.Database.update(
        "UPDATE mzansi_reserve_policy SET policy_rate = ?, reserve_ratio = ?, tax_rate = ?, discount_rate = ?, updated_by = ?, updated_at = CURRENT_TIMESTAMP WHERE id = 1",
        pr, rr, tx, dr, uid
    )
    if not ok then
        pcall(function()
            Mzansi.Database.insert(
                "INSERT INTO mzansi_reserve_policy (id, policy_rate, reserve_ratio, tax_rate, discount_rate, updated_by) VALUES (1, ?, ?, ?, ?, ?)",
                pr, rr, tx, dr, uid
            )
        end)
    end

    -- Reflect into shared config for payday interest (jobs resource reads Mzansi.Config.Server)
    if Mzansi.Config and Mzansi.Config.Server then
        Mzansi.Config.Server.interestRate = pr
        Mzansi.Config.Server.taxRate = tx
    end

    Mzansi.Util.sendNotification(player, "Reserve policy updated.", "success")
    if Mzansi.Database.logAction then
        Mzansi.Database.logAction("RESERVE", char and char.id or 0, "Admin", "Set policy",
            string.format("rate=%.4f ratio=%.4f tax=%.4f", pr, rr, tx), getPlayerIP(player))
    end
    return true, { policy_rate = pr, reserve_ratio = rr, tax_rate = tx, discount_rate = dr }
end

function Mzansi.Reserve.getSupply()
    local cashRows = Mzansi.Database.query("SELECT COALESCE(SUM(cash),0) AS s FROM mzansi_characters")
    local bankRows = Mzansi.Database.query("SELECT COALESCE(SUM(bank),0) AS s FROM mzansi_characters")
    local gangRows = Mzansi.Database.query("SELECT COALESCE(SUM(treasury),0) AS s FROM mzansi_gangs")
    local grpRows = Mzansi.Database.query("SELECT COALESCE(SUM(balance),0) AS s FROM mzansi_group_accounts")
    local m0 = tonumber(cashRows and cashRows[1] and cashRows[1].s) or 0
    local bVal = tonumber(bankRows and bankRows[1] and bankRows[1].s) or 0
    local gVal = tonumber(gangRows and gangRows[1] and gangRows[1].s) or 0
    local grpVal = tonumber(grpRows and grpRows[1] and grpRows[1].s) or 0
    local deposits = bVal + gVal + grpVal
    return {
        m0_cash = m0,
        m1_deposits = deposits,
        m2_proxy = m0 + deposits,
        policy = Mzansi.Reserve.getPolicy(),
        snapshot_at = os.time and os.time() or getRealTime().timestamp,
    }
end

function Mzansi.Reserve.applyTransferTax(player, amount, taxRate)
    -- Optional sink: charge taxRate on transfers beyond fee. Called from banking if wired.
    taxRate = tonumber(taxRate) or 0
    if taxRate <= 0 or amount <= 0 then return 0 end
    local tax = math.floor(amount * taxRate)
    if tax <= 0 then return 0 end
    local char = Mzansi.Characters.getCharacter(player)
    if not char then return 0 end
    if char.cash < tax then return 0 end
    -- Burn via removeCash (sink)
    Mzansi.Characters.removeCash(player, tax)
    if Mzansi.Banking and Mzansi.Banking.logTransaction then
        Mzansi.Banking.logTransaction(char.id, "TAX", tax, char.bank, "Transfer tax", "")
    end
    return tax
end

function Mzansi.Reserve.sendPolicy(player)
    triggerClientEvent(player, "mzansi:reserve:setPolicy", player, Mzansi.Reserve.getPolicy())
end

function Mzansi.Reserve.sendSupply(player)
    triggerClientEvent(player, "mzansi:reserve:setSupply", player, Mzansi.Reserve.getSupply())
end

addEventHandler("mzansi:reserve:requestPolicy", root, function()
    local player = client or source
    Mzansi.Reserve.sendPolicy(player)
end)

addEventHandler("mzansi:reserve:requestSupply", root, function()
    local player = client or source
    Mzansi.Reserve.sendSupply(player)
end)

addEventHandler("mzansi:reserve:setPolicy", root, function(patch)
    local player = client or source
    local ok, result = Mzansi.Reserve.setPolicy(player, patch)
    if ok then
        Mzansi.Reserve.sendPolicy(player)
        Mzansi.Reserve.sendSupply(player)
    end
end)

addCommandHandler("reserve", function(player)
    if not isAdmin(player) then
        Mzansi.Util.sendNotification(player, "Access denied.", "error")
        return
    end
    Mzansi.Reserve.sendPolicy(player)
    Mzansi.Reserve.sendSupply(player)
    triggerClientEvent(player, "mzansi:reserve:openUI", player)
end)

addEventHandler("onResourceStart", resourceRoot, function()
    Mzansi.Reserve.getPolicy() -- seed
    outputDebugString("[Mzansi-Reserve] Central bank policy layer loaded.")
end)
