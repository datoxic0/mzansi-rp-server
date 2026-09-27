Mzansi = Mzansi or {}
Mzansi.Registration = Mzansi.Registration or {}

local function normalizeName(name)
    name = tostring(name or "")
    name = name:gsub("^%s+", "")
    name = name:gsub("%s+$", "")
    return name
end

function Mzansi.Registration.createCharacter(player, data)
    if not data then
        return false, "No registration data supplied"
    end

    local accountName = getAccountName(getPlayerAccount(player))
    if not accountName then
        return false, "Player is not authenticated"
    end

    local firstName = normalizeName(data.firstName or data.first_name or "")
    local lastName = normalizeName(data.lastName or data.last_name or "")
    local job = tonumber(data.job or Mzansi.Enums.Job.CIVILIAN)
    local faction = tonumber(data.faction or Mzansi.Enums.Faction.CIVILIAN)

    if firstName == "" or lastName == "" then
        return false, "First and last name are required"
    end

    if job < Mzansi.Enums.Job.CIVILIAN or job > Mzansi.Enums.Job.BUSINESS then
        job = Mzansi.Enums.Job.CIVILIAN
    end

    if faction < Mzansi.Enums.Faction.NONE or faction > Mzansi.Enums.Faction.CIVILIAN then
        faction = Mzansi.Enums.Faction.CIVILIAN
    end

    local playerCharacter = Mzansi.Player.getCharacter(player)
    if playerCharacter and playerCharacter.first_name then
        return false, "Character already exists for this account"
    end

    local payload = {
        firstName = firstName,
        lastName = lastName,
        money = Mzansi.Config.Server.defaultCash,
        bank = Mzansi.Config.Server.defaultBank,
        job = job,
        faction = faction,
        x = Mzansi.Enums.Spawn.CITY.x,
        y = Mzansi.Enums.Spawn.CITY.y,
        z = Mzansi.Enums.Spawn.CITY.z,
        rotation = Mzansi.Enums.Spawn.CITY.rotation,
    }

    local success = Mzansi.Player.saveCharacter(player, payload)
    if success then
        local profile = Mzansi.Player.refresh(player)
        outputChatBox("[Mzansi-ZA] Character created for " .. firstName .. " " .. lastName .. ".", player, 0, 255, 120)
        return true, profile
    end

    return false, "Failed to save character"
end

addEvent("mzansi:createCharacter", true)
addEventHandler("mzansi:createCharacter", root, function(data)
    local success, result = Mzansi.Registration.createCharacter(client, data)
    triggerClientEvent(client, "mzansi:registrationResult", client, { success = success, result = result })
end)
