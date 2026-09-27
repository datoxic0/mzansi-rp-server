Mzansi = Mzansi or {}
Mzansi.FactionSystem = Mzansi.FactionSystem or {}

function Mzansi.FactionSystem.getLabel(factionId)
    return Mzansi.Config.Factions[factionId] or "Civilian"
end

function Mzansi.FactionSystem.setPlayerFaction(player, factionId)
    local character = Mzansi.Player.getCharacter(player)
    if not character then
        return false, "No character profile found"
    end

    character.faction = tonumber(factionId) or Mzansi.Enums.Faction.CIVILIAN
    local success, message = Mzansi.PoliceEMS.enforceFactionRules(player, character.faction)
    if success then
        setElementData(player, "mzansi:character", character)
        return true, Mzansi.FactionSystem.getLabel(character.faction)
    end

    return false, message or "Faction update failed"
end

addEvent("mzansi:faction:set", true)
addEventHandler("mzansi:faction:set", root, function(factionId)
    local success, message = Mzansi.FactionSystem.setPlayerFaction(client, factionId)
    triggerClientEvent(client, "mzansi:faction:result", client, { success = success, message = message })
end)
