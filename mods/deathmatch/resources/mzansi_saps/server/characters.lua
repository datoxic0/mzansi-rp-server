Mzansi = Mzansi or {}
Mzansi.Characters = Mzansi.Characters or {}

function Mzansi.Characters.getCharacter(player)
    if not isElement(player) then return nil end
    local core = getResourceFromName("mzansi_core")
    if core and getResourceState(core) == "running" then
        return exports.mzansi_core:getCharacter(player)
    end
    return nil
end

function Mzansi.Characters.addCash(player, amount)
    if not isElement(player) then return false end
    local core = getResourceFromName("mzansi_core")
    if core and getResourceState(core) == "running" then
        return exports.mzansi_core:addCash(player, amount)
    end
    return false
end

function Mzansi.Characters.removeCash(player, amount)
    if not isElement(player) then return false end
    local core = getResourceFromName("mzansi_core")
    if core and getResourceState(core) == "running" then
        return exports.mzansi_core:removeCash(player, amount)
    end
    return false
end

function Mzansi.Characters.addBank(player, amount)
    if not isElement(player) then return false end
    local core = getResourceFromName("mzansi_core")
    if core and getResourceState(core) == "running" then
        return exports.mzansi_core:addBank(player, amount)
    end
    return false
end

function Mzansi.Characters.removeBank(player, amount)
    if not isElement(player) then return false end
    local core = getResourceFromName("mzansi_core")
    if core and getResourceState(core) == "running" then
        return exports.mzansi_core:removeBank(player, amount)
    end
    return false
end

function Mzansi.Characters.addXP(player, amount)
    if not isElement(player) then return false end
    local core = getResourceFromName("mzansi_core")
    if core and getResourceState(core) == "running" then
        return exports.mzansi_core:addXP(player, amount)
    end
    return false
end

function Mzansi.Characters.setJob(player, jobId)
    if not isElement(player) then return false end
    local core = getResourceFromName("mzansi_core")
    if core and getResourceState(core) == "running" then
        return exports.mzansi_core:setJob(player, jobId)
    end
    return false
end

function Mzansi.Characters.setFaction(player, factionId, rank)
    if not isElement(player) then return false end
    local core = getResourceFromName("mzansi_core")
    if core and getResourceState(core) == "running" then
        return exports.mzansi_core:setFaction(player, factionId, rank)
    end
    return false
end

function Mzansi.Characters.getCharacterField(player, field)
    if not isElement(player) then return nil end
    local core = getResourceFromName("mzansi_core")
    if core and getResourceState(core) == "running" then
        return exports.mzansi_core:getCharacterField(player, field)
    end
    return nil
end

function Mzansi.Characters.setCharacterField(player, field, value)
    if not isElement(player) then return false end
    local core = getResourceFromName("mzansi_core")
    if core and getResourceState(core) == "running" then
        return exports.mzansi_core:setCharacterField(player, field, value)
    end
    return false
end
