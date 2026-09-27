Mzansi = Mzansi or {}
Mzansi.Properties = Mzansi.Properties or {}

Mzansi.Properties.Registry = {
    {
        id = 1,
        name = "Johannesburg Executive Flat",
        type = "apartment",
        region = "Johannesburg",
        rent = 1200,
        owner = "Civilian",
    },
    {
        id = 2,
        name = "Cape Town Waterfront Office",
        type = "office",
        region = "Cape Town",
        rent = 2500,
        owner = "Business",
    },
    {
        id = 3,
        name = "Pretoria Medical House",
        type = "medical",
        region = "Pretoria",
        rent = 1900,
        owner = "EMS",
    },
}

local function getCharacterAccess(player)
    local character = Mzansi.Player.getCharacter(player)
    if not character then
        return nil
    end

    return {
        job = tonumber(character.job or Mzansi.Enums.Job.CIVILIAN),
        faction = tonumber(character.faction or Mzansi.Enums.Faction.CIVILIAN),
    }
end

function Mzansi.Properties.canAccess(player, property)
    local access = getCharacterAccess(player)
    if not access then
        return false
    end

    local owner = tostring(property.owner or "Civilian")
    if owner == "Civilian" then
        return true
    end

    if owner == "EMS" and (access.job == Mzansi.Enums.Job.EMS or access.faction == Mzansi.Enums.Faction.EMS) then
        return true
    end

    if owner == "Business" and (access.job == Mzansi.Enums.Job.BUSINESS or access.faction == Mzansi.Enums.Faction.CIVILIAN) then
        return true
    end

    return false
end

function Mzansi.Properties.getAll()
    return Mzansi.Properties.Registry
end

function Mzansi.Properties.getByRegion(region)
    local result = {}
    for _, property in ipairs(Mzansi.Properties.Registry) do
        if not region or property.region == region then
            table.insert(result, property)
        end
    end
    return result
end

function Mzansi.Properties.getAccessibleForPlayer(player, region)
    local result = {}
    for _, property in ipairs(Mzansi.Properties.getByRegion(region)) do
        if Mzansi.Properties.canAccess(player, property) then
            table.insert(result, property)
        end
    end
    return result
end

addEvent("mzansi:properties:list", true)
addEventHandler("mzansi:properties:list", root, function(region)
    triggerClientEvent(client, "mzansi:properties:response", client, Mzansi.Properties.getAccessibleForPlayer(client, region))
end)
