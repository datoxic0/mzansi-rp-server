Mzansi = Mzansi or {}
Mzansi.Businesses = Mzansi.Businesses or {}

Mzansi.Businesses.Registry = {
    {
        id = 1,
        name = "Mzanzi Fuel & Transport",
        type = "fuel",
        region = "Johannesburg",
        owner = "Civilian",
    },
    {
        id = 2,
        name = "Cape Town Logistics Hub",
        type = "logistics",
        region = "Cape Town",
        owner = "Business",
    },
    {
        id = 3,
        name = "Pretoria Medical Supply Co.",
        type = "medical",
        region = "Pretoria",
        owner = "EMS",
    },
    {
        id = 4,
        name = "Durban Auto Works",
        type = "mechanic",
        region = "Durban",
        owner = "Mechanic",
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

function Mzansi.Businesses.canAccess(player, business)
    local access = getCharacterAccess(player)
    if not access then
        return false
    end

    local owner = tostring(business.owner or "Civilian")
    if owner == "Civilian" then
        return true
    end

    if owner == "EMS" and (access.job == Mzansi.Enums.Job.EMS or access.faction == Mzansi.Enums.Faction.EMS) then
        return true
    end

    if owner == "Business" and (access.job == Mzansi.Enums.Job.BUSINESS or access.faction == Mzansi.Enums.Faction.CIVILIAN) then
        return true
    end

    if owner == "Mechanic" and access.job == Mzansi.Enums.Job.MECHANIC then
        return true
    end

    return false
end

function Mzansi.Businesses.getAll()
    return Mzansi.Businesses.Registry
end

function Mzansi.Businesses.getByRegion(region)
    local result = {}
    for _, business in ipairs(Mzansi.Businesses.Registry) do
        if not region or business.region == region then
            table.insert(result, business)
        end
    end
    return result
end

function Mzansi.Businesses.getAccessibleForPlayer(player, region)
    local result = {}
    for _, business in ipairs(Mzansi.Businesses.getByRegion(region)) do
        if Mzansi.Businesses.canAccess(player, business) then
            table.insert(result, business)
        end
    end
    return result
end

addEvent("mzansi:businesses:list", true)
addEventHandler("mzansi:businesses:list", root, function(region)
    triggerClientEvent(client, "mzansi:businesses:response", client, Mzansi.Businesses.getAccessibleForPlayer(client, region))
end)
