Mzansi = Mzansi or {}
Mzansi.GroupBank = Mzansi.GroupBank or {}

addEvent("mzansi:groupbank:requestAccounts", true)
addEvent("mzansi:groupbank:deposit", true)
addEvent("mzansi:groupbank:withdraw", true)
addEvent("mzansi:groupbank:requestHistory", true)

local function money(amount)
    return Mzansi.Util.formatMoney(amount)
end

local function playerName(char)
    local n = (char.firstName or char.first_name or "Citizen") .. " " .. (char.lastName or char.last_name or "")
    return string.gsub(n, "%s+$", "")
end

local function logGroupTx(accountId, charId, txType, amount, balanceAfter, detail)
    pcall(function()
        Mzansi.Database.insert(
            "INSERT INTO mzansi_group_transactions (account_id, character_id, tx_type, amount, balance_after, detail) VALUES (?, ?, ?, ?, ?, ?)",
            accountId, charId, txType, amount, balanceAfter, detail or ""
        )
    end)
end

-- ==============================================================
-- ACCOUNT LOOKUP
-- ==============================================================
function Mzansi.GroupBank.getAccount(ownerType, ownerId)
    local rows = Mzansi.Database.query(
        "SELECT * FROM mzansi_group_accounts WHERE owner_type = ? AND owner_id = ? LIMIT 1",
        tostring(ownerType), tonumber(ownerId)
    )
    if rows and rows[1] then
        return rows[1]
    end
    return nil
end

function Mzansi.GroupBank.ensureAccount(ownerType, ownerId, name, withdrawLevel)
    local acct = Mzansi.GroupBank.getAccount(ownerType, ownerId)
    if acct then return acct end

    Mzansi.Database.insert(
        "INSERT INTO mzansi_group_accounts (owner_type, owner_id, name, balance, withdraw_level) VALUES (?, ?, ?, 0, ?)",
        tostring(ownerType), tonumber(ownerId), tostring(name or (ownerType .. " " .. ownerId)), tonumber(withdrawLevel) or 5
    )
    return Mzansi.GroupBank.getAccount(ownerType, ownerId)
end

-- ==============================================================
-- RANK / AUTHORITY
-- ==============================================================
local function getGangRankLevel(player, gangId)
    -- Prefer in-memory gang member rank if gangs resource loaded
    if Mzansi.Gangs and Mzansi.Gangs._members then
        local m = Mzansi.Gangs._members[player]
        if m and m.gangId == gangId then
            return tonumber(m.rankLevel) or 0
        end
    end
    local char = Mzansi.Characters.getCharacter(player)
    if not char then return 0 end
    local rows = Mzansi.Database.query(
        "SELECT rank FROM mzansi_gang_members WHERE gang_id = ? AND character_id = ? LIMIT 1",
        tonumber(gangId), char.id
    )
    if rows and rows[1] then
        -- DB rank 0..N maps roughly to rankLevel; treat leader as 10
        local rank = tonumber(rows[1].rank) or 0
        return rank >= 1 and (rank + 4) or 1
    end
    return 0
end

local function canWithdraw(player, acct)
    local need = tonumber(acct.withdraw_level) or 5
    if acct.owner_type == "gang" then
        return getGangRankLevel(player, tonumber(acct.owner_id)) >= need
    end
    -- business / club: owner character only
    if acct.owner_type == "business" or acct.owner_type == "club" then
        local char = Mzansi.Characters.getCharacter(player)
        if not char then return false end
        -- load owner_id from business_ownership if present
        local rows = Mzansi.Database.query(
            "SELECT owner_id FROM mzansi_business_ownership WHERE id = ? LIMIT 1",
            tonumber(acct.owner_id)
        )
        if rows and rows[1] and tonumber(rows[1].owner_id) == tonumber(char.id) then
            return true
        end
        -- also allow if account was created with owner_id == char.id
        return tonumber(acct.owner_id) == tonumber(char.id)
    end
    -- faction: members of that faction
    if acct.owner_type == "faction" then
        local char = Mzansi.Characters.getCharacter(player)
        if not char then return false end
        return tonumber(char.faction) == tonumber(acct.owner_id)
    end
    return false
end

local function canDeposit(player, acct)
    -- any member of the group can deposit cash
    if acct.owner_type == "gang" then
        return getGangRankLevel(player, tonumber(acct.owner_id)) > 0
    end
    if acct.owner_type == "business" or acct.owner_type == "club" then
        local char = Mzansi.Characters.getCharacter(player)
        if not char then return false end
        local rows = Mzansi.Database.query(
            "SELECT owner_id FROM mzansi_business_ownership WHERE id = ? LIMIT 1",
            tonumber(acct.owner_id)
        )
        if rows and rows[1] and tonumber(rows[1].owner_id) == tonumber(char.id) then
            return true
        end
        return tonumber(acct.owner_id) == tonumber(char.id)
    end
    if acct.owner_type == "faction" then
        local char = Mzansi.Characters.getCharacter(player)
        if not char then return false end
        return tonumber(char.faction) == tonumber(acct.owner_id)
    end
    return false
end

-- ==============================================================
-- OPERATIONS
-- ==============================================================
function Mzansi.GroupBank.deposit(player, ownerType, ownerId, amount)
    local char = Mzansi.Characters.getCharacter(player)
    if not char then return false end

    amount = math.floor(tonumber(amount) or 0)
    if amount < (Mzansi.GroupBank.Config.MinDeposit or 1) then
        Mzansi.Util.sendNotification(player, "Invalid deposit amount.", "error")
        return false
    end
    if amount > (Mzansi.GroupBank.Config.MaxDeposit or 1000000) then
        Mzansi.Util.sendNotification(player, "Deposit exceeds limit.", "error")
        return false
    end
    if char.cash < amount then
        Mzansi.Util.sendNotification(player, "Not enough cash.", "error")
        return false
    end

    local acct = Mzansi.GroupBank.getAccount(ownerType, ownerId)
    if not acct then
        acct = Mzansi.GroupBank.ensureAccount(ownerType, ownerId)
    end
    if not acct then
        Mzansi.Util.sendNotification(player, "No group account found.", "error")
        return false
    end
    if not canDeposit(player, acct) then
        Mzansi.Util.sendNotification(player, "You are not a member of this group.", "error")
        return false
    end

    Mzansi.Characters.removeCash(player, amount)
    local newBal = (tonumber(acct.balance) or 0) + amount

    local ok = Mzansi.Database.update(
        "UPDATE mzansi_group_accounts SET balance = balance + ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?",
        amount, acct.id
    )
    if not ok then
        -- rollback cash
        Mzansi.Characters.addCash(player, amount)
        Mzansi.Util.sendNotification(player, "Deposit failed (DB).", "error")
        return false
    end

    logGroupTx(acct.id, char.id, "DEPOSIT", amount, newBal, "Cash deposit")
    if Mzansi.Banking and Mzansi.Banking.logTransaction then
        Mzansi.Banking.logTransaction(char.id, "GROUP_DEPOSIT", amount, char.bank, "To " .. (acct.name or "group"), "")
    end
    if Mzansi.Database.logAction then
        Mzansi.Database.logAction("BANK", char.id, playerName(char), "Group deposit", money(amount) .. " -> " .. (acct.name or ""), getPlayerIP(player))
    end

    Mzansi.Util.sendNotification(player, "Deposited " .. money(amount) .. " to " .. (acct.name or "group") .. ".", "success")
    return true, newBal
end

function Mzansi.GroupBank.withdraw(player, ownerType, ownerId, amount)
    local char = Mzansi.Characters.getCharacter(player)
    if not char then return false end

    amount = math.floor(tonumber(amount) or 0)
    if amount < (Mzansi.GroupBank.Config.MinWithdraw or 1) then
        Mzansi.Util.sendNotification(player, "Invalid withdraw amount.", "error")
        return false
    end
    if amount > (Mzansi.GroupBank.Config.MaxWithdraw or 500000) then
        Mzansi.Util.sendNotification(player, "Withdraw exceeds limit.", "error")
        return false
    end

    local acct = Mzansi.GroupBank.getAccount(ownerType, ownerId)
    if not acct then
        Mzansi.Util.sendNotification(player, "No group account found.", "error")
        return false
    end
    if not canWithdraw(player, acct) then
        Mzansi.Util.sendNotification(player, "You lack withdraw rights for this account.", "error")
        return false
    end

    local cur = tonumber(acct.balance) or 0
    if cur < amount then
        Mzansi.Util.sendNotification(player, "Insufficient group funds. Balance: " .. money(cur), "error")
        return false
    end

    -- atomic decrement: only succeed if balance still covers
    local ok = Mzansi.Database.update(
        "UPDATE mzansi_group_accounts SET balance = balance - ?, updated_at = CURRENT_TIMESTAMP WHERE id = ? AND balance >= ?",
        amount, acct.id, amount
    )
    if not ok then
        Mzansi.Util.sendNotification(player, "Withdraw failed (insufficient or DB error).", "error")
        return false
    end

    local newBal = cur - amount
    Mzansi.Characters.addCash(player, amount)

    logGroupTx(acct.id, char.id, "WITHDRAW", amount, newBal, "Cash withdrawal")
    if Mzansi.Banking and Mzansi.Banking.logTransaction then
        Mzansi.Banking.logTransaction(char.id, "GROUP_WITHDRAW", amount, char.bank, "From " .. (acct.name or "group"), "")
    end
    if Mzansi.Database.logAction then
        Mzansi.Database.logAction("BANK", char.id, playerName(char), "Group withdraw", money(amount) .. " <- " .. (acct.name or ""), getPlayerIP(player))
    end

    Mzansi.Util.sendNotification(player, "Withdrew " .. money(amount) .. " from " .. (acct.name or "group") .. ".", "success")
    return true, newBal
end

function Mzansi.GroupBank.getAccountsForPlayer(player)
    local char = Mzansi.Characters.getCharacter(player)
    if not char then return {} end

    local list = {}

    -- Gang account (if in gang)
    local gangId = nil
    if Mzansi.Gangs and Mzansi.Gangs.getPlayerGang then
        gangId = Mzansi.Gangs.getPlayerGang(player)
    end
    if not gangId then
        local rows = Mzansi.Database.query(
            "SELECT gang_id FROM mzansi_gang_members WHERE character_id = ? LIMIT 1",
            char.id
        )
        if rows and rows[1] then gangId = tonumber(rows[1].gang_id) end
    end
    if gangId then
        local acct = Mzansi.GroupBank.ensureAccount("gang", gangId, "Gang Treasury", 5)
        if acct then
            list[#list + 1] = {
                id = acct.id,
                owner_type = "gang",
                owner_id = tonumber(acct.owner_id),
                name = acct.name or "Gang Treasury",
                balance = tonumber(acct.balance) or 0,
                canWithdraw = canWithdraw(player, acct),
                canDeposit = canDeposit(player, acct),
            }
        end
    end

    -- Business ownership
    local bizRows = Mzansi.Database.query(
        "SELECT id, business_id FROM mzansi_business_ownership WHERE owner_id = ?",
        char.id
    )
    if bizRows then
        for _, b in ipairs(bizRows) do
            local acct = Mzansi.GroupBank.ensureAccount("business", tonumber(b.id), "Business #" .. tostring(b.business_id), 5)
            if acct then
                list[#list + 1] = {
                    id = acct.id,
                    owner_type = "business",
                    owner_id = tonumber(acct.owner_id),
                    name = acct.name or "Business",
                    balance = tonumber(acct.balance) or 0,
                    canWithdraw = true,
                    canDeposit = true,
                }
            end
        end
    end

    return list
end

function Mzansi.GroupBank.getHistory(accountId, limit)
    limit = tonumber(limit) or 50
    return Mzansi.Database.query(
        "SELECT * FROM mzansi_group_transactions WHERE account_id = ? ORDER BY id DESC LIMIT " .. tostring(limit),
        tonumber(accountId)
    ) or {}
end

function Mzansi.GroupBank.sendAccounts(player)
    local accounts = Mzansi.GroupBank.getAccountsForPlayer(player)
    triggerClientEvent(player, "mzansi:groupbank:setAccounts", player, accounts)
end

-- ==============================================================
-- EVENTS
-- ==============================================================
addEventHandler("mzansi:groupbank:requestAccounts", root, function()
    local player = client or source
    Mzansi.GroupBank.sendAccounts(player)
end)

addEventHandler("mzansi:groupbank:deposit", root, function(ownerType, ownerId, amount)
    local player = client or source
    Mzansi.GroupBank.deposit(player, ownerType, ownerId, amount)
    Mzansi.GroupBank.sendAccounts(player)
end)

addEventHandler("mzansi:groupbank:withdraw", root, function(ownerType, ownerId, amount)
    local player = client or source
    Mzansi.GroupBank.withdraw(player, ownerType, ownerId, amount)
    Mzansi.GroupBank.sendAccounts(player)
end)

addEventHandler("mzansi:groupbank:requestHistory", root, function(accountId)
    local player = client or source
    local hist = Mzansi.GroupBank.getHistory(accountId, 50)
    triggerClientEvent(player, "mzansi:groupbank:setHistory", player, hist)
end)

-- ==============================================================
-- AUTO-WIRE: create gang treasury account when gang deposit/withdraw runs
-- (gangs.lua already writes treasury column; we mirror into group account)
-- ==============================================================
function Mzansi.GroupBank.syncGangTreasury(gangId, balance)
    if not gangId then return end
    local acct = Mzansi.GroupBank.ensureAccount("gang", gangId, "Gang Treasury", 5)
    if not acct then return end
    -- Prefer authoritative DB balance from mzansi_gangs.treasury if present
    local rows = Mzansi.Database.query("SELECT treasury FROM mzansi_gangs WHERE id = ? LIMIT 1", tonumber(gangId))
    local bal = tonumber(acct.balance) or 0
    if rows and rows[1] and rows[1].treasury ~= nil then
        bal = tonumber(rows[1].treasury) or bal
    elseif balance ~= nil then
        bal = tonumber(balance) or bal
    end
    Mzansi.Database.update(
        "UPDATE mzansi_group_accounts SET balance = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?",
        bal, acct.id
    )
end

addEventHandler("onResourceStart", resourceRoot, function()
    outputDebugString("[Mzansi-GroupBank] Group banking loaded.")
end)
