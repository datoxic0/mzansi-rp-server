Mzansi = Mzansi or {}
Mzansi.PoliceEMS = Mzansi.PoliceEMS or {}

function Mzansi.PoliceEMS.enforceFactionRules(player, faction)
    local character = Mzansi.Player.getCharacter(player)
    if not character then
        return false, "No character profile"
    end

    local factionValue = tonumber(faction or character.faction or Mzansi.Enums.Faction.CIVILIAN)
    if factionValue == Mzansi.Enums.Faction.SAPS then
        character.job = Mzansi.Enums.Job.POLICE
        character.faction = Mzansi.Enums.Faction.SAPS
    elseif factionValue == Mzansi.Enums.Faction.EMS then
        character.job = Mzansi.Enums.Job.EMS
        character.faction = Mzansi.Enums.Faction.EMS
    else
        character.job = Mzansi.Enums.Job.CIVILIAN
        character.faction = Mzansi.Enums.Faction.CIVILIAN
    end

    Mzansi.Player.saveCharacter(player, character)
    setElementData(player, "mzansi:character", character)
    return true, "Faction enforcement applied"
end

function Mzansi.PoliceEMS.canAccess(player, requiredFaction)
    local character = Mzansi.Player.getCharacter(player)
    if not character then
        return false
    end

    local factionValue = tonumber(character.faction or Mzansi.Enums.Faction.CIVILIAN)
    if requiredFaction == nil then
        return true
    end

    if tonumber(requiredFaction) == factionValue then
        return true
    end

    return false
end

addEvent("mzansi:faction:enforce", true)
addEventHandler("mzansi:faction:enforce", root, function(faction)
    local success, message = Mzansi.PoliceEMS.enforceFactionRules(client, faction)
    triggerClientEvent(client, "mzansi:faction:result", client, { success = success, message = message })
end)
