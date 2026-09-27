Mzansi = Mzansi or {}
Mzansi.JobSystem = Mzansi.JobSystem or {}

function Mzansi.JobSystem.getLabel(jobId)
    return Mzansi.Config.Jobs[jobId] or "Civilian"
end

function Mzansi.JobSystem.setPlayerJob(player, jobId)
    local character = Mzansi.Player.getCharacter(player)
    if not character then
        return false, "No character profile found"
    end

    character.job = tonumber(jobId) or Mzansi.Enums.Job.CIVILIAN
    Mzansi.Player.saveCharacter(player, character)
    setElementData(player, "mzansi:character", character)
    return true, Mzansi.JobSystem.getLabel(character.job)
end

addEvent("mzansi:job:set", true)
addEventHandler("mzansi:job:set", root, function(jobId)
    local success, message = Mzansi.JobSystem.setPlayerJob(client, jobId)
    triggerClientEvent(client, "mzansi:job:result", client, { success = success, message = message })
end)
