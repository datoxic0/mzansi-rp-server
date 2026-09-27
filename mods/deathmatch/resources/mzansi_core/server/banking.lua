Mzansi = Mzansi or {}
Mzansi.Banking = Mzansi.Banking or {}

addEvent("mzansi:bank:open", true)
addEvent("mzansi:bank:deposit", true)
addEvent("mzansi:bank:withdraw", true)
addEvent("mzansi:bank:transfer", true)
addEvent("mzansi:bank:requestHistory", true)
addEvent("mzansi:bank:requestLoan", true)
addEvent("mzansi:bank:repayLoan", true)
addEvent("mzansi:bank:requestStatus", true)

-- ==============================================================
-- CONFIG
-- ==============================================================
local LOAN_TIERS = {
    { name = "Starter Loan",    min = 1000,   max = 10000,   rate = 0.05, term = 15 },   -- 5% over 15 paydays
    { name = "Personal Loan",   min = 10000,  max = 50000,   rate = 0.08, term = 20 },
    { name = "Business Loan",   min = 50000,  max = 200000,  rate = 0.12, term = 30 },
    { name = "Mortgage",        min = 200000, max = 1000000, rate = 0.15, term = 40 },
}

local TRANSFER_FEE_RATE = 0.02  -- 2% fee on transfers
local TRANSFER_MIN = 100
local MAX_TRANSFER = 500000

local function money(amount)
    return Mzansi.Util.formatMoney(amount)
end

local function playerName(char)
    local n = (char.firstName or char.first_name or "Citizen") .. " " .. (char.lastName or char.last_name or "")
    return string.gsub(n, "%s+$", "")
end

local function safePlaySound(player, soundId)
    if isElement(player) and getElementType(player) == "player" then
        playSoundFrontEnd(player, soundId)
    end
end

-- ==============================================================
-- TRANSACTION LEDGER
-- ==============================================================
function Mzansi.Banking.logTransaction(charId, txType, amount, balanceAfter, detail, counterparty)
    Mzansi.Database.insert(
        "INSERT INTO mzansi_bank_transactions (character_id, tx_type, amount, balance_after, detail, counterparty) VALUES (?, ?, ?, ?, ?, ?)",
        charId, txType, amount, balanceAfter, detail or "", counterparty or ""
    )
end

function Mzansi.Banking.getTransactions(charId, limit)
    limit = tonumber(limit) or 50
    return Mzansi.Database.query(
        "SELECT * FROM mzansi_bank_transactions WHERE character_id = ? ORDER BY id DESC LIMIT " .. tostring(limit),
        charId
    ) or {}
end

-- ==============================================================
-- DEPOSIT (cash → bank)
-- ==============================================================
function Mzansi.Banking.deposit(player, amount)
    if not isElement(player) then return false end
    local char = Mzansi.Characters.getCharacter(player)
    if not char then return false end

    amount = math.floor(tonumber(amount) or 0)
    if amount <= 0 then
        Mzansi.Util.sendNotification(player, "Enter a valid amount.", "error")
        return false
    end
    if char.cash < amount then
        Mzansi.Util.sendNotification(player, "Not enough cash. You have " .. money(char.cash), "error")
        return false
    end

    Mzansi.Characters.removeCash(player, amount)
    Mzansi.Characters.addBank(player, amount)

    Mzansi.Banking.logTransaction(char.id, "DEPOSIT", amount, char.bank + amount, "Cash deposit", "")
    Mzansi.Database.logAction("BANK", char.id, playerName(char), "Deposit", money(amount), getPlayerIP(player))

    Mzansi.Util.sendNotification(player, "Deposited " .. money(amount) .. " into your bank account.", "success")
    safePlaySound(player, 41)
    return true
end

-- ==============================================================
-- WITHDRAW (bank → cash)
-- ==============================================================
function Mzansi.Banking.withdraw(player, amount)
    if not isElement(player) then return false end
    local char = Mzansi.Characters.getCharacter(player)
    if not char then return false end

    amount = math.floor(tonumber(amount) or 0)
    if amount <= 0 then
        Mzansi.Util.sendNotification(player, "Enter a valid amount.", "error")
        return false
    end
    if char.bank < amount then
        Mzansi.Util.sendNotification(player, "Insufficient bank balance. You have " .. money(char.bank), "error")
        return false
    end

    Mzansi.Characters.removeBank(player, amount)
    Mzansi.Characters.addCash(player, amount)

    Mzansi.Banking.logTransaction(char.id, "WITHDRAW", amount, char.bank - amount, "Cash withdrawal", "")
    Mzansi.Database.logAction("BANK", char.id, playerName(char), "Withdraw", money(amount), getPlayerIP(player))

    Mzansi.Util.sendNotification(player, "Withdrew " .. money(amount) .. " from your bank.", "success")
    safePlaySound(player, 41)
    return true
end

-- ==============================================================
-- TRANSFER (bank → bank, with fee)
-- ==============================================================
function Mzansi.Banking.transfer(player, targetName, amount)
    if not isElement(player) then return false end
    local char = Mzansi.Characters.getCharacter(player)
    if not char then return false end

    amount = math.floor(tonumber(amount) or 0)
    if amount < TRANSFER_MIN then
        Mzansi.Util.sendNotification(player, "Minimum transfer is " .. money(TRANSFER_MIN), "error")
        return false
    end
    if amount > MAX_TRANSFER then
        Mzansi.Util.sendNotification(player, "Maximum transfer is " .. money(MAX_TRANSFER), "error")
        return false
    end

    local fee = math.floor(amount * TRANSFER_FEE_RATE)

    -- P3: optional reserve tax sink on transfers (policy.tax_rate)
    local tax = 0
    if Mzansi.Reserve and Mzansi.Reserve.applyTransferTax then
        local policyRate = 0
        if Mzansi.Reserve.getPolicy then
            local ok, policy = pcall(Mzansi.Reserve.getPolicy)
            if ok and type(policy) == "table" then
                policyRate = tonumber(policy.tax_rate) or 0
            end
        end
        local okTax, applied = pcall(Mzansi.Reserve.applyTransferTax, player, amount, policyRate)
        if okTax then tax = tonumber(applied) or 0 end
    end

    local totalCost = amount + fee + tax

    if char.bank < totalCost then
        Mzansi.Util.sendNotification(player, "Insufficient funds (including " .. money(fee) .. " fee" ..
            (tax > 0 and (", " .. money(tax) .. " reserve tax") or "") .. ").", "error")
        return false
    end

    -- Find target (online first, then offline via DB)
    local targetPlayer = nil
    local targetChar = nil

    -- Try online players
    for _, p in ipairs(getElementsByType("player")) do
        if p ~= player then
            local tChar = Mzansi.Characters.getCharacter(p)
            if tChar then
                local tName = (tChar.firstName or tChar.first_name or "") .. " " .. (tChar.lastName or tChar.last_name or "")
                tName = string.gsub(tName, "%s+$", "")
                local tFirst = tChar.firstName or tChar.first_name or ""
                if string.lower(tName) == string.lower(targetName) or string.lower(tFirst) == string.lower(targetName) or tostring(tChar.id) == tostring(targetName) then
                    targetPlayer = p
                    targetChar = tChar
                    break
                end
            end
        end
    end

    -- If not found online, try DB lookup by name (portable: no CONCAT — works on MySQL + SQLite)
    if not targetChar then
        local trimmed = tostring(targetName or ""):gsub("^%s+", ""):gsub("%s+$", "")
        local first, last = trimmed:match("^(%S+)%s+(%S+)$")
        local rows
        if first and last then
            rows = Mzansi.Database.query(
                "SELECT * FROM mzansi_characters WHERE LOWER(first_name) = LOWER(?) AND LOWER(last_name) = LOWER(?) LIMIT 1",
                first, last
            )
        end
        if (not rows or #rows == 0) and #trimmed > 0 then
            rows = Mzansi.Database.query(
                "SELECT * FROM mzansi_characters WHERE LOWER(first_name) = LOWER(?) LIMIT 1",
                trimmed
            )
        end
        if rows and rows[1] then
            targetChar = rows[1]
        end
    end

    if not targetChar then
        Mzansi.Util.sendNotification(player, "Recipient not found.", "error")
        return false
    end

    if targetChar.id == char.id then
        Mzansi.Util.sendNotification(player, "You cannot transfer to yourself.", "error")
        return false
    end

    -- Deduct from sender
    Mzansi.Characters.removeBank(player, totalCost)

    -- Credit recipient
    if targetPlayer then
        Mzansi.Characters.addBank(targetPlayer, amount)
        Mzansi.Util.sendNotification(targetPlayer, "You received " .. money(amount) .. " from " .. playerName(char), "success")
    else
        -- Offline: direct DB update
        Mzansi.Database.update("UPDATE mzansi_characters SET bank = bank + ? WHERE id = ?", amount, targetChar.id)
    end

    -- Log both sides
    local tName = (targetChar.first_name or targetChar.firstName or "?") .. " " .. (targetChar.last_name or targetChar.lastName or "")
    Mzansi.Banking.logTransaction(char.id, "TRANSFER_OUT", amount, char.bank - totalCost, "Transfer to " .. tName .. " (fee " .. money(fee) .. ")", tName)
    if targetPlayer then
        local tChar2 = Mzansi.Characters.getCharacter(targetPlayer)
        if tChar2 then
            Mzansi.Banking.logTransaction(tChar2.id, "TRANSFER_IN", amount, tChar2.bank + amount, "Transfer from " .. playerName(char), playerName(char))
        end
    else
        Mzansi.Banking.logTransaction(targetChar.id, "TRANSFER_IN", amount, (targetChar.bank or 0) + amount, "Transfer from " .. playerName(char), playerName(char))
    end

    Mzansi.Database.logAction("BANK", char.id, playerName(char), "Transfer",
        money(amount) .. " to " .. tName .. " (fee " .. money(fee) .. ")", getPlayerIP(player))

    Mzansi.Util.sendNotification(player, "Sent " .. money(amount) .. " to " .. tName .. " (fee: " .. money(fee) .. ")", "success")
    safePlaySound(player, 41)
    return true
end

-- ==============================================================
-- LOANS
-- ==============================================================
function Mzansi.Banking.requestLoan(player, tierIndex, amount)
    if not isElement(player) then return false end
    local char = Mzansi.Characters.getCharacter(player)
    if not char then return false end

    tierIndex = tonumber(tierIndex)
    local tier = LOAN_TIERS[tierIndex or 0]
    if not tier then
        Mzansi.Util.sendNotification(player, "Invalid loan tier.", "error")
        return false
    end

    amount = math.floor(tonumber(amount) or 0)
    if amount < tier.min or amount > tier.max then
        Mzansi.Util.sendNotification(player, "Amount must be between " .. money(tier.min) .. " and " .. money(tier.max), "error")
        return false
    end

    -- Check existing loan
    local existing = Mzansi.Database.query(
        "SELECT * FROM mzansi_bank_transactions WHERE character_id = ? AND tx_type = 'LOAN' AND balance_after > 0 ORDER BY id DESC LIMIT 1",
        char.id
    )
    if existing and existing[1] and (tonumber(existing[1].balance_after) or 0) > 0 then
        Mzansi.Util.sendNotification(player, "You already have an outstanding loan. Repay it first.", "error")
        return false
    end

    -- Credit bank
    Mzansi.Characters.addBank(player, amount)

    -- Record loan (balance_after = remaining principal)
    local totalOwed = math.floor(amount * (1 + tier.rate))
    Mzansi.Banking.logTransaction(char.id, "LOAN", amount, totalOwed, tier.name .. " (rate " .. math.floor(tier.rate * 100) .. "%, term " .. tier.term .. " paydays)", "")

    Mzansi.Database.logAction("BANK", char.id, playerName(char), "Loan taken",
        tier.name .. " " .. money(amount) .. " (owed " .. money(totalOwed) .. ")", getPlayerIP(player))

    Mzansi.Util.sendNotification(player, tier.name .. " approved! Received " .. money(amount) .. ". Total to repay: " .. money(totalOwed), "success")
    safePlaySound(player, 41)
    return true
end

function Mzansi.Banking.repayLoan(player, amount)
    if not isElement(player) then return false end
    local char = Mzansi.Characters.getCharacter(player)
    if not char then return false end

    amount = math.floor(tonumber(amount) or 0)
    if amount <= 0 then
        Mzansi.Util.sendNotification(player, "Enter a valid repayment amount.", "error")
        return false
    end

    -- Find outstanding loan
    local loans = Mzansi.Database.query(
        "SELECT * FROM mzansi_bank_transactions WHERE character_id = ? AND tx_type = 'LOAN' AND balance_after > 0 ORDER BY id ASC",
        char.id
    )
    if not loans or #loans == 0 then
        Mzansi.Util.sendNotification(player, "You have no outstanding loans.", "error")
        return false
    end

    local loan = loans[1]
    local owed = tonumber(loan.balance_after) or 0
    if amount > owed then amount = owed end

    if char.bank < amount then
        Mzansi.Util.sendNotification(player, "Insufficient bank balance. You have " .. money(char.bank), "error")
        return false
    end

    Mzansi.Characters.removeBank(player, amount)
    local remaining = owed - amount

    -- Update loan record
    Mzansi.Database.update("UPDATE mzansi_bank_transactions SET balance_after = ? WHERE id = ?", remaining, loan.id)
    Mzansi.Banking.logTransaction(char.id, "LOAN_REPAY", amount, remaining, "Loan repayment", "")

    Mzansi.Database.logAction("BANK", char.id, playerName(char), "Loan repayment", money(amount) .. " (remaining " .. money(remaining) .. ")", getPlayerIP(player))

    if remaining <= 0 then
        Mzansi.Util.sendNotification(player, "Loan fully repaid! " .. money(amount) .. " paid. You are debt-free.", "success")
    else
        Mzansi.Util.sendNotification(player, "Repaid " .. money(amount) .. ". Remaining debt: " .. money(remaining), "success")
    end
    safePlaySound(player, 41)
    return true
end

-- ==============================================================
-- STATUS (for UI)
-- ==============================================================
local function sendStatus(player)
    local char = Mzansi.Characters.getCharacter(player)
    if not char then return end

    -- Find outstanding loan
    local loanOwed = 0
    local loanName = ""
    local loans = Mzansi.Database.query(
        "SELECT * FROM mzansi_bank_transactions WHERE character_id = ? AND tx_type = 'LOAN' AND balance_after > 0 ORDER BY id DESC LIMIT 1",
        char.id
    )
    if loans and loans[1] then
        loanOwed = tonumber(loans[1].balance_after) or 0
        loanName = loans[1].detail or "Loan"
    end

    -- Investment total
    local invTotal = 0
    local invs = Mzansi.Database.getPlayerInvestments(char.id)
    for _, inv in ipairs(invs) do
        invTotal = invTotal + (tonumber(inv.principal) or 0) + (tonumber(inv.accrued_interest) or 0)
    end

    -- Reserve policy (P3) overrides static config when available
    local interestRate = Mzansi.Config.Server.interestRate or 0.02
    local taxRate = Mzansi.Config.Server.taxRate or 0.05
    if Mzansi.Reserve and Mzansi.Reserve.getPolicy then
        local ok, policy = pcall(Mzansi.Reserve.getPolicy)
        if ok and type(policy) == "table" then
            interestRate = tonumber(policy.policy_rate) or interestRate
            taxRate = tonumber(policy.tax_rate) or taxRate
        end
    end

    triggerClientEvent(player, "mzansi:bank:setStatus", player, {
        cash = char.cash or 0,
        bank = char.bank or 0,
        loanOwed = loanOwed,
        loanName = loanName,
        investmentTotal = invTotal,
        loanTiers = LOAN_TIERS,
        transferFeeRate = TRANSFER_FEE_RATE,
        transferMin = TRANSFER_MIN,
        maxTransfer = MAX_TRANSFER,
        interestRate = interestRate,
        taxRate = taxRate,
    })
end

-- ==============================================================
-- EVENT HANDLERS
-- ==============================================================
function Mzansi.Banking._openUI(player)
    sendStatus(player)
    triggerClientEvent(player, "mzansi:bank:openUI", player)
end

addEventHandler("mzansi:bank:open", root, function()
    local player = client or source
    Mzansi.Banking._openUI(player)
end)

addEventHandler("mzansi:bank:deposit", root, function(amount)
    local player = client or source
    Mzansi.Banking.deposit(player, amount)
    sendStatus(player)
end)

addEventHandler("mzansi:bank:withdraw", root, function(amount)
    local player = client or source
    Mzansi.Banking.withdraw(player, amount)
    sendStatus(player)
end)

addEventHandler("mzansi:bank:transfer", root, function(targetName, amount)
    local player = client or source
    Mzansi.Banking.transfer(player, targetName, amount)
    sendStatus(player)
end)

addEventHandler("mzansi:bank:requestLoan", root, function(tierIndex, amount)
    local player = client or source
    Mzansi.Banking.requestLoan(player, tierIndex, amount)
    sendStatus(player)
end)

addEventHandler("mzansi:bank:repayLoan", root, function(amount)
    local player = client or source
    Mzansi.Banking.repayLoan(player, amount)
    sendStatus(player)
end)

addEventHandler("mzansi:bank:requestHistory", root, function()
    local player = client or source
    local char = Mzansi.Characters.getCharacter(player)
    if not char then return end
    local txs = Mzansi.Banking.getTransactions(char.id, 50)
    triggerClientEvent(player, "mzansi:bank:setHistory", player, txs)
end)

addEventHandler("mzansi:bank:requestStatus", root, function()
    local player = client or source
    sendStatus(player)
end)

-- ==============================================================
-- /bank COMMAND
-- ==============================================================
addCommandHandler("bank", function(player)
    Mzansi.Banking._openUI(player)
end)

addCommandHandler("balance", function(player)
    local char = Mzansi.Characters.getCharacter(player)
    if not char then return end
    outputChatBox("#FFC850[BANK] #FFFFFFCash: #00CC66" .. money(char.cash) .. "  |  Bank: #00AAFF" .. money(char.bank), player, 255, 255, 255, true)
end)

addEventHandler("onResourceStart", resourceRoot, function()
    outputDebugString("[Mzansi-Banking] Advanced banking system loaded. /bank, /balance")
end)
