Mzansi = Mzansi or {}
Mzansi.Player = Mzansi.Player or {}

local characterCache = {}

local function getAccountKey(player)
    local account = getPlayerAccount(player)
    local accountName = getAccountName(account)
    if accountName and accountName ~= "" then
        return accountName
    end

    return getPlayerSerial(player)
end

function Mzansi.Player.getCharacter(player)
    local accountKey = getAccountKey(player)
    if not accountKey then
        return nil
    end

    if characterCache[accountKey] then
        return characterCache[accountKey]
    end

    local character = Mzansi.DB.getPlayerCharacter(accountKey)
    if not character then
        character = Mzansi.DB.getPlayerCharacterBySerial(getPlayerSerial(player))
    end

    characterCache[accountKey] = character
    return character
end

function Mzansi.Player.saveCharacter(player, data)
    local success = Mzansi.DB.savePlayerCharacter(player, data)
    if success then
        local accountKey = getAccountKey(player)
        if accountKey then
            characterCache[accountKey] = data
        end
    end
    return success
end

function Mzansi.Player.authenticate(player)
    local account = getPlayerAccount(player)
    if not account then
        outputChatBox("[Mzansi-ZA] Please log in first.", player, 255, 200, 0)
        return false
    end

    local character = Mzansi.Player.getCharacter(player)
    if not character then
        outputChatBox("[Mzansi-ZA] No character profile found. Create one with /register.", player, 255, 200, 0)
        return false
    end

    return true
end

function Mzansi.Player.refresh(player)
    local accountKey = getAccountKey(player)
    if accountKey then
        characterCache[accountKey] = nil
    end
    return Mzansi.Player.getCharacter(player)
end

addEvent("mzansi:requestCharacter", true)
addEventHandler("mzansi:requestCharacter", root, function()
    local character = Mzansi.Player.getCharacter(client)
    triggerClientEvent(client, "mzansi:characterReceived", client, character)
end)

addEvent("mzansi:saveCharacter", true)
addEventHandler("mzansi:saveCharacter", root, function(data)
    if Mzansi.Player.saveCharacter(client, data) then
        triggerClientEvent(client, "mzansi:characterSaved", client, true)
    else
        triggerClientEvent(client, "mzansi:characterSaved", client, false)
    end
end)
