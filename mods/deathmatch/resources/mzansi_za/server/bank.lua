Mzansi = Mzansi or {}
Mzansi.Bank = Mzansi.Bank or {}

local function getCharacterData(player)
    local accountName = getAccountName(getPlayerAccount(player))
    local char = Mzansi.Player.getCharacter(player)
    if not char then
        return nil
    end
    return char, accountName
end

function Mzansi.Bank.getBalance(player)
    local character = getCharacterData(player)
    if not character then
        return 0
    end
    return tonumber(character.bank or 0)
end

function Mzansi.Bank.deposit(player, amount)
    local character = getCharacterData(player)
    if not character then
        return false, "Character not found"
    end

    amount = math.max(0, tonumber(amount) or 0)
    if amount <= 0 then
        return false, "Invalid amount"
    end

    local cash = tonumber(getPlayerMoney(player) or 0)
    if cash < amount then
        return false, "Not enough cash"
    end

    takePlayerMoney(player, amount)
    character.bank = tonumber(character.bank or 0) + amount
    Mzansi.Player.saveCharacter(player, character)
    return true, amount
end

function Mzansi.Bank.withdraw(player, amount)
    local character = getCharacterData(player)
    if not character then
        return false, "Character not found"
    end

    amount = math.max(0, tonumber(amount) or 0)
    if amount <= 0 then
        return false, "Invalid amount"
    end

    local bank = tonumber(character.bank or 0)
    if bank < amount then
        return false, "Insufficient bank balance"
    end

    character.bank = bank - amount
    Mzansi.Player.saveCharacter(player, character)
    givePlayerMoney(player, amount)
    return true, amount
end

addEvent("mzansi:bank:request", true)
addEventHandler("mzansi:bank:request", root, function()
    local balance = Mzansi.Bank.getBalance(client)
    triggerClientEvent(client, "mzansi:bank:response", client, { balance = balance })
end)

addEvent("mzansi:bank:deposit", true)
addEventHandler("mzansi:bank:deposit", root, function(amount)
    local success, msg = Mzansi.Bank.deposit(client, amount)
    triggerClientEvent(client, "mzansi:bank:result", client, { success = success, message = msg })
end)

addEvent("mzansi:bank:withdraw", true)
addEventHandler("mzansi:bank:withdraw", root, function(amount)
    local success, msg = Mzansi.Bank.withdraw(client, amount)
    triggerClientEvent(client, "mzansi:bank:result", client, { success = success, message = msg })
end)
