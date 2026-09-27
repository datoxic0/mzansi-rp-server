Mzansi = Mzansi or {}
Mzansi.Crime = Mzansi.Crime or {}
Mzansi.Crime._activeRobberies = Mzansi.Crime._activeRobberies or {}
Mzansi.Crime._wantedLevels = Mzansi.Crime._wantedLevels or {}

local function invHas(player, item, qty)
    local res = getResourceFromName("mzansi_inventory")
    if res and getResourceState(res) == "running" then
        local ok, result = pcall(function()
            return exports.mzansi_inventory:hasItem(player, item, qty or 1)
        end)
        if ok then return result end
    end
    return false
end
Mzansi.Crime._activeRobberies = {}
Mzansi.Crime._activeHeists = {}
Mzansi.Crime._cooldowns = {}
Mzansi.Crime._wantedLevels = {}

addEvent("mzansi:crime:robbery", true)
addEvent("mzansi:crime:heist", true)
addEvent("mzansi:crime:illegalJob", true)
addEvent("mzansi:crime:blackMarket", true)
addEvent("mzansi:crime:processStolen", true)
addEvent("mzansi:crime:setWanted", true)
addEvent("mzansi:crime:payBounty", true)
addEvent("mzansi:crime:takeMask", true)

function Mzansi.Crime.startRobbery(source, robberyId)
    local char = Mzansi.Characters.getCharacter(source)
    if not char then return false end

    local now = getRealTime().timestamp
    local cooldownKey = char.id .. "_" .. robberyId
    if Mzansi.Crime._cooldowns[cooldownKey] and now - Mzansi.Crime._cooldowns[cooldownKey] < Mzansi.Crime.Config.RobberyCooldown / 1000 then
        Mzansi.Util.sendNotification(source, "You must wait before robbing again.", "error")
        return false
    end

    local robbery = nil
    for _, r in ipairs(Mzansi.Crime.Config.Robberies) do
        if r.id == robberyId then
            robbery = r
            break
        end
    end

    if not robbery then
        Mzansi.Util.sendNotification(source, "Invalid robbery.", "error")
        return false
    end

    local x, y, z = getElementPosition(source)
    if Mzansi.Util.distance(x, y, z, robbery.x, robbery.y, robbery.z) > robbery.radius then
        Mzansi.Util.sendNotification(source, "You are not at the robbery location.", "error")
        return false
    end

    for _, requiredItem in ipairs(robbery.requiredItems or {}) do
        if not invHas(source, requiredItem) then
            Mzansi.Util.sendNotification(source, "Missing required item: " .. requiredItem, "error")
            return false
        end
    end

    local nearbyPlayers = 0
    for _, player in ipairs(getElementsByType("player")) do
        local dist = Mzansi.Util.distance(player, robbery.x, robbery.y, robbery.z)
        if dist < robbery.radius then
            nearbyPlayers = nearbyPlayers + 1
        end
    end

    if nearbyPlayers < robbery.minPlayers then
        Mzansi.Util.sendNotification(source, "Need at least " .. robbery.minPlayers .. " players for this robbery.", "error")
        return false
    end

    Mzansi.Crime._activeRobberies[source] = {
        robberyId = robberyId,
        robbery = robbery,
        startTime = getTickCount(),
        participants = {},
    }

    for _, player in ipairs(getElementsByType("player")) do
        local dist = Mzansi.Util.distance(player, robbery.x, robbery.y, robbery.z)
        if dist < robbery.radius then
            Mzansi.Crime._activeRobberies[source].participants[#Mzansi.Crime._activeRobberies[source].participants + 1] = player
            setElementData(player, "mzansi:wantedLevel", robbery.wantedLevel)
            Mzansi.Crime._wantedLevels[player] = { level = robbery.wantedLevel, timestamp = getTickCount() }
        end
    end

    Mzansi.Util.sendNotification(source, robbery.name .. " started! " .. robbery.description, "warning")

    -- Dispatch to police via event
    for _, player in ipairs(getElementsByType("player")) do
        if getElementData(player, "mzansi:faction") == 1 then
            Mzansi.Util.sendNotification(player, "DISPATCH: " .. robbery.name .. " in progress!", "warning")
        end
    end

    setTimer(function()
        Mzansi.Crime.completeRobbery(source)
    end, robbery.duration, 1)

    return true
end

function Mzansi.Crime.completeRobbery(source)
    local active = Mzansi.Crime._activeRobberies[source]
    if not active then return end

    local robbery = active.robbery
    local reward = math.random(robbery.reward.min, robbery.reward.max)
    local participants = #active.participants
    local share = math.floor(reward / math.max(1, participants))

    for _, player in ipairs(active.participants) do
        if isElement(player) then
            Mzansi.Characters.addCash(player, share)
            Mzansi.Characters.addXP(player, 500)
            Mzansi.Util.sendNotification(player, "Robbery complete! You received " .. Mzansi.Util.formatMoney(share), "success")
        end
    end

    local cooldownKey = Mzansi.Characters.getCharacterField(source, "id") .. "_" .. active.robberyId
    Mzansi.Crime._cooldowns[cooldownKey] = getRealTime().timestamp

    Mzansi.Database.logAction("ROBBERY", 0, Mzansi.Util.getPlayerFullName(source), robbery.name, "Reward: " .. Mzansi.Util.formatMoney(reward) .. " (" .. participants .. " participants)", "")

    Mzansi.Crime._activeRobberies[source] = nil
end

function Mzansi.Crime.startHeist(source, heistId)
    local char = Mzansi.Characters.getCharacter(source)
    if not char then return false end

    local now = getRealTime().timestamp
    local cooldownKey = char.id .. "_heist_" .. heistId
    if Mzansi.Crime._cooldowns[cooldownKey] and now - Mzansi.Crime._cooldowns[cooldownKey] < Mzansi.Crime.Config.HeistCooldown / 1000 then
        Mzansi.Util.sendNotification(source, "You must wait before attempting another heist.", "error")
        return false
    end

    local heist = nil
    for _, h in ipairs(Mzansi.Crime.Config.Heists) do
        if h.id == heistId then
            heist = h
            break
        end
    end

    if not heist then return false end

    for _, requiredItem in ipairs(heist.requiredItems or {}) do
        if not invHas(source, requiredItem) then
            Mzansi.Util.sendNotification(source, "Missing: " .. requiredItem, "error")
            return false
        end
    end

    local nearbyPlayers = 0
    local x, y, z = getElementPosition(source)
    for _, player in ipairs(getElementsByType("player")) do
        if Mzansi.Util.distance(player, x, y, z) < 30 then
            nearbyPlayers = nearbyPlayers + 1
        end
    end

    if nearbyPlayers < heist.minPlayers then
        Mzansi.Util.sendNotification(source, "Need " .. heist.minPlayers .. " players for this heist.", "error")
        return false
    end

    Mzansi.Crime._activeHeists[source] = {
        heistId = heistId,
        heist = heist,
        currentPhase = 1,
        phaseStart = getTickCount(),
        participants = {},
    }

    for _, player in ipairs(getElementsByType("player")) do
        if Mzansi.Util.distance(player, x, y, z) < 30 then
            Mzansi.Crime._activeHeists[source].participants[#Mzansi.Crime._activeHeists[source].participants + 1] = player
            setElementData(player, "mzansi:wantedLevel", heist.wantedLevel)
        end
    end

    Mzansi.Util.sendNotification(source, "HEIST STARTED: " .. heist.name .. " - Phase: " .. heist.phases[1].name, "warning")

    Mzansi.Crime.advanceHeistPhase(source)
    return true
end

function Mzansi.Crime.advanceHeistPhase(source)
    local active = Mzansi.Crime._activeHeists[source]
    if not active then return end

    local heist = active.heist
    local phase = heist.phases[active.currentPhase]

    if not phase then
        Mzansi.Crime.completeHeist(source)
        return
    end

    for _, player in ipairs(active.participants) do
        if isElement(player) then
            Mzansi.Util.sendNotification(player, "HEIST PHASE: " .. phase.name .. " - " .. phase.objective, "info")
        end
    end

    setTimer(function()
        active.currentPhase = active.currentPhase + 1
        Mzansi.Crime.advanceHeistPhase(source)
    end, phase.duration, 1)
end

function Mzansi.Crime.completeHeist(source)
    local active = Mzansi.Crime._activeHeists[source]
    if not active then return end

    local heist = active.heist
    local reward = math.random(heist.reward.min, heist.reward.max)
    local participants = #active.participants
    local share = math.floor(reward / math.max(1, participants))

    for _, player in ipairs(active.participants) do
        if isElement(player) then
            Mzansi.Characters.addCash(player, share)
            Mzansi.Characters.addXP(player, 2000)
            Mzansi.Util.sendNotification(player, "HEIST COMPLETE! You received " .. Mzansi.Util.formatMoney(share), "success")
        end
    end

    local cooldownKey = Mzansi.Characters.getCharacterField(source, "id") .. "_heist_" .. active.heistId
    Mzansi.Crime._cooldowns[cooldownKey] = getRealTime().timestamp

    Mzansi.Database.logAction("HEIST", 0, Mzansi.Util.getPlayerFullName(source), heist.name, "Reward: " .. Mzansi.Util.formatMoney(reward), "")

    Mzansi.Crime._activeHeists[source] = nil
end

function Mzansi.Crime.startIllegalJob(source, jobId)
    local char = Mzansi.Characters.getCharacter(source)
    if not char then return false end

    local job = nil
    for _, j in ipairs(Mzansi.Crime.Config.IllegalJobs) do
        if j.id == jobId then
            job = j
            break
        end
    end

    if not job then return false end

    if job.requiredItems then
        for _, item in ipairs(job.requiredItems) do
            if not invHas(source, item) then
                Mzansi.Util.sendNotification(source, "Missing: " .. item, "error")
                return false
            end
        end
    end

    local x, y, z = getElementPosition(source)
    if Mzansi.Util.distance(x, y, z, job.x, job.y, job.z) > 20 then
        Mzansi.Util.sendNotification(source, "Not at job location.", "error")
        return false
    end

    setElementData(source, "mzansi:wantedLevel", job.wantedLevel)

    local reward = math.random(job.reward.min, job.reward.max)
    Mzansi.Characters.addCash(source, reward)
    Mzansi.Characters.addXP(source, 300)

    Mzansi.Util.sendNotification(source, "Job complete! " .. job.name .. " - " .. Mzansi.Util.formatMoney(reward), "success")
    Mzansi.Database.logAction("CRIME", char.id, char.firstName .. " " .. char.lastName, job.name, "Reward: " .. Mzansi.Util.formatMoney(reward), "")

    return true
end

function Mzansi.Crime.sellToBlackMarket(source, itemId)
    local char = Mzansi.Characters.getCharacter(source)
    if not char then return false end

    local item = nil
    for _, shop in ipairs(Mzansi.Crime.Config.BlackMarket) do
        for _, shopItem in ipairs(shop.items) do
            if shopItem.name == itemId or shopItem.weaponId == tonumber(itemId) then
                item = shopItem
                break
            end
        end
    end

    if not item then
        Mzansi.Util.sendNotification(source, "Invalid item.", "error")
        return false
    end

    local sellPrice = math.floor(item.price * 0.7)
    Mzansi.Characters.addCash(source, sellPrice)
    Mzansi.Util.sendNotification(source, "Sold for " .. Mzansi.Util.formatMoney(sellPrice), "success")

    return true
end

function Mzansi.Crime.setWantedLevel(source, level)
    level = Mzansi.Util.clamp(tonumber(level) or 0, 0, 4)
    setElementData(source, "mzansi:wantedLevel", level)
    Mzansi.Crime._wantedLevels[source] = { level = level, timestamp = getTickCount() }

    if level > 0 then
        for _, player in ipairs(getElementsByType("player")) do
            if getElementData(player, "mzansi:faction") == 1 then
                Mzansi.Util.sendNotification(player, "WANTED: " .. Mzansi.Util.getPlayerFullName(source) .. " (Level " .. level .. ")", "warning")
            end
        end
    end
end

function Mzansi.Crime.takeMask(source)
    local wearing = getElementData(source, "mzansi:wearingMask")
    setElementData(source, "mzansi:wearingMask", not wearing)
    if wearing then
        Mzansi.Util.sendNotification(source, "Mask removed.", "info")
    else
        Mzansi.Util.sendNotification(source, "Mask on.", "info")
    end
end

function Mzansi.Crime.decayWantedLevels()
    local now = getTickCount()
    for player, data in pairs(Mzansi.Crime._wantedLevels) do
        if isElement(player) and now - data.timestamp > Mzansi.Crime.Config.WantedDecayTime then
            if data.level > 0 then
                data.level = data.level - 1
                setElementData(player, "mzansi:wantedLevel", data.level)
                if data.level == 0 then
                    Mzansi.Crime._wantedLevels[player] = nil
                end
            end
        end
    end
end

addEventHandler("mzansi:crime:robbery", root, function(robberyId)
    local source = client or source
    Mzansi.Crime.startRobbery(source, robberyId)
end)

addEventHandler("mzansi:crime:heist", root, function(heistId)
    local source = client or source
    Mzansi.Crime.startHeist(source, heistId)
end)

addEventHandler("mzansi:crime:illegalJob", root, function(jobId)
    local source = client or source
    Mzansi.Crime.startIllegalJob(source, jobId)
end)

addEventHandler("mzansi:crime:blackMarket", root, function(itemId)
    local source = client or source
    Mzansi.Crime.sellToBlackMarket(source, itemId)
end)

addEventHandler("mzansi:crime:setWanted", root, function(level)
    local source = client or source
    Mzansi.Crime.setWantedLevel(source, level)
end)

addEventHandler("mzansi:crime:takeMask", root, function()
    local source = client or source
    Mzansi.Crime.takeMask(source)
end)

addEventHandler("onPlayerQuit", root, function()
    Mzansi.Crime._activeRobberies[source] = nil
    Mzansi.Crime._activeHeists[source] = nil
    Mzansi.Crime._wantedLevels[source] = nil
end)

addEventHandler("onResourceStart", resourceRoot, function()
    setTimer(Mzansi.Crime.decayWantedLevels, 60000, 0)
    outputDebugString("[Mzansi-Crime] Crime system loaded.")
end)
