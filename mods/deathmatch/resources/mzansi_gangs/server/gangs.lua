Mzansi = Mzansi or {}
Mzansi.Gangs = Mzansi.Gangs or {}
Mzansi.Gangs._gangs = {}
Mzansi.Gangs._territories = {}
Mzansi.Gangs._members = {}
Mzansi.Gangs._wars = {}

addEvent("mzansi:gangs:create", true)
addEvent("mzansi:gangs:join", true)
addEvent("mzansi:gangs:leave", true)
addEvent("mzansi:gangs:kick", true)
addEvent("mzansi:gangs:promote", true)
addEvent("mzansi:gangs:demote", true)
addEvent("mzansi:gangs:invite", true)
addEvent("mzansi:gangs:acceptInvite", true)
addEvent("mzansi:gangs:claimTerritory", true)
addEvent("mzansi:gangs:attackTerritory", true)
addEvent("mzansi:gangs:sprayTag", true)
addEvent("mzansi:gangs:getMembers", true)
addEvent("mzansi:gangs:getGangInfo", true)
addEvent("mzansi:gangs:depositMoney", true)
addEvent("mzansi:gangs:withdrawMoney", true)
addEvent("mzansi:gangs:callBackup", true)

function Mzansi.Gangs.init()
    for gangId, gangData in pairs(Mzansi.Gangs.Config.Gangs) do
        Mzansi.Gangs._gangs[gangId] = {
            id = gangId,
            name = gangData.name,
            tag = gangData.tag,
            color = gangData.color,
            leader = gangData.leader,
            description = gangData.description,
            spawn = gangData.spawn,
            ranks = gangData.ranks,
            balance = 0,
            territoryCount = 0,
            active = gangData.leader ~= nil,
        }
    end

    for _, territory in ipairs(Mzansi.Gangs.Config.Territories) do
        Mzansi.Gangs._territories[territory.id] = {
            id = territory.id,
            name = territory.name,
            x = territory.x,
            y = territory.y,
            z = territory.z,
            radius = territory.radius,
            gangId = territory.gangId,
            controlledBy = nil,
            lastAttacked = 0,
        }
    end

    outputDebugString("[Mzansi-Gangs] Gang system initialized.")
end

function Mzansi.Gangs.createGang(source, gangId, name, tag)
    local char = Mzansi.Characters.getCharacter(source)
    if not char then return false, "Not logged in." end

    local existingGang = Mzansi.Gangs.getPlayerGang(source)
    if existingGang then
        return false, "You are already in a gang."
    end

    if char.cash < Mzansi.Gangs.Config.GangCreationCost then
        return false, "You need " .. Mzansi.Util.formatMoney(Mzansi.Gangs.Config.GangCreationCost) .. " to create a gang."
    end

    local gang = Mzansi.Gangs._gangs[gangId]
    if not gang then
        return false, "Invalid gang slot."
    end

    if gang.active then
        return false, "This gang already exists."
    end

    name = Mzansi.Util.sanitizeInput(name or gang.name)
    tag = Mzansi.Util.sanitizeInput(tag or gang.tag)

    Mzansi.Characters.removeCash(source, Mzansi.Gangs.Config.GangCreationCost)
    gang.leader = char.id
    gang.active = true
    gang.name = name
    gang.tag = tag

    Mzansi.Database.addGangMember(gangId, char.id, 6)

    Mzansi.Gangs._members[source] = {
        gangId = gangId,
        rankLevel = 6,
        rankName = gang.ranks[7].name,
    }

    setElementData(source, "mzansi:gang", gangId)
    setElementData(source, "mzansi:gangRank", 6)

    Mzansi.Util.sendNotification(source, "Gang created: " .. name .. " [" .. tag .. "]", "success")
    Mzansi.Database.logAction("GANG", char.id, char.firstName .. " " .. char.lastName, "Created gang", name, "")
    return true
end

function Mzansi.Gangs.joinGang(source, gangId)
    local char = Mzansi.Characters.getCharacter(source)
    if not char then return false end

    local existingGang = Mzansi.Gangs.getPlayerGang(source)
    if existingGang then
        return false, "You are already in a gang."
    end

    local gang = Mzansi.Gangs._gangs[gangId]
    if not gang or not gang.active then
        return false, "Gang not found."
    end

    local memberCount = Mzansi.Gangs.getGangMemberCount(gangId)
    if memberCount >= Mzansi.Gangs.Config.MaxGangMembers then
        return false, "Gang is full."
    end

    Mzansi.Database.addGangMember(gangId, char.id, 0)

    Mzansi.Gangs._members[source] = {
        gangId = gangId,
        rankLevel = 0,
        rankName = gang.ranks[1].name,
    }

    setElementData(source, "mzansi:gang", gangId)
    setElementData(source, "mzansi:gangRank", 0)

    Mzansi.Util.sendNotification(source, "You joined " .. gang.name, "success")

    for _, player in ipairs(getElementsByType("player")) do
        local memberGang = Mzansi.Gangs.getPlayerGang(player)
        if memberGang == gangId and player ~= source then
            Mzansi.Util.sendNotification(player, char.firstName .. " " .. char.lastName .. " joined the gang.", "info")
        end
    end

    return true
end

function Mzansi.Gangs.leaveGang(source)
    local char = Mzansi.Characters.getCharacter(source)
    if not char then return false end

    local memberData = Mzansi.Gangs._members[source]
    if not memberData then
        return false, "You are not in a gang."
    end

    local gang = Mzansi.Gangs._gangs[memberData.gangId]
    if gang and gang.leader == char.id then
        return false, "Leaders cannot leave. Transfer leadership or disband."
    end

    Mzansi.Database.delete(
        "DELETE FROM mzansi_gang_members WHERE character_id = ?",
        char.id
    )

    local gangName = gang and gang.name or "Unknown"
    Mzansi.Gangs._members[source] = nil
    removeElementData(source, "mzansi:gang")
    removeElementData(source, "mzansi:gangRank")

    Mzansi.Util.sendNotification(source, "You left " .. gangName, "info")
    return true
end

function Mzansi.Gangs.kickMember(source, target)
    local char = Mzansi.Characters.getCharacter(source)
    local targetChar = Mzansi.Characters.getCharacter(target)
    if not char or not targetChar then return false end

    local sourceGang = Mzansi.Gangs.getPlayerGang(source)
    local targetGang = Mzansi.Gangs.getPlayerGang(target)
    if not sourceGang or not targetGang or sourceGang ~= targetGang then
        return false, "Not in the same gang."
    end

    local sourceRank = Mzansi.Gangs._members[source] and Mzansi.Gangs._members[source].rankLevel or 0
    local targetRank = Mzansi.Gangs._members[target] and Mzansi.Gangs._members[target].rankLevel or 0

    if sourceRank <= targetRank then
        return false, "Cannot kick someone of equal or higher rank."
    end

    Mzansi.Database.delete(
        "DELETE FROM mzansi_gang_members WHERE character_id = ?",
        targetChar.id
    )

    Mzansi.Gangs._members[target] = nil
    removeElementData(target, "mzansi:gang")
    removeElementData(target, "mzansi:gangRank")

    local gang = Mzansi.Gangs._gangs[sourceGang]
    Mzansi.Util.sendNotification(source, targetChar.firstName .. " kicked from " .. (gang and gang.name or ""), "success")
    Mzansi.Util.sendNotification(target, "You were kicked from your gang.", "error")
    return true
end

function Mzansi.Gangs.promoteMember(source, target)
    local char = Mzansi.Characters.getCharacter(source)
    local targetChar = Mzansi.Characters.getCharacter(target)
    if not char or not targetChar then return false end

    local sourceGang = Mzansi.Gangs.getPlayerGang(source)
    local targetGang = Mzansi.Gangs.getPlayerGang(target)
    if not sourceGang or sourceGang ~= targetGang then return false end

    local sourceRank = Mzansi.Gangs._members[source] and Mzansi.Gangs._members[source].rankLevel or 0
    local memberData = Mzansi.Gangs._members[target]
    if not memberData then return false end

    if sourceRank <= memberData.rankLevel then return false end
    if memberData.rankLevel >= 6 then return false end

    local gang = Mzansi.Gangs._gangs[sourceGang]
    memberData.rankLevel = memberData.rankLevel + 1
    memberData.rankName = gang.ranks[memberData.rankLevel + 1].name

    setElementData(target, "mzansi:gangRank", memberData.rankLevel)

    Mzansi.Database.updateGangMemberRank(targetChar.id, memberData.rankLevel)

    Mzansi.Util.sendNotification(target, "Promoted to " .. memberData.rankName, "success")
    return true
end

function Mzansi.Gangs.demoteMember(source, target)
    local char = Mzansi.Characters.getCharacter(source)
    local targetChar = Mzansi.Characters.getCharacter(target)
    if not char or not targetChar then return false end

    local sourceGang = Mzansi.Gangs.getPlayerGang(source)
    local targetGang = Mzansi.Gangs.getPlayerGang(target)
    if not sourceGang or sourceGang ~= targetGang then return false end

    local sourceRank = Mzansi.Gangs._members[source] and Mzansi.Gangs._members[source].rankLevel or 0
    local memberData = Mzansi.Gangs._members[target]
    if not memberData then return false end

    if sourceRank <= memberData.rankLevel then return false end
    if memberData.rankLevel <= 0 then return false end

    local gang = Mzansi.Gangs._gangs[sourceGang]
    memberData.rankLevel = memberData.rankLevel - 1
    memberData.rankName = gang.ranks[memberData.rankLevel + 1].name

    setElementData(target, "mzansi:gangRank", memberData.rankLevel)

    Mzansi.Database.updateGangMemberRank(targetChar.id, memberData.rankLevel)

    Mzansi.Util.sendNotification(target, "Demoted to " .. memberData.rankName, "warning")
    return true
end

function Mzansi.Gangs.inviteMember(source, target)
    local char = Mzansi.Characters.getCharacter(source)
    local targetChar = Mzansi.Characters.getCharacter(target)
    if not char or not targetChar then return false end

    local sourceGang = Mzansi.Gangs.getPlayerGang(source)
    if not sourceGang then return false end

    local sourceRank = Mzansi.Gangs._members[source] and Mzansi.Gangs._members[source].rankLevel or 0
    if sourceRank < 3 then
        return false, "Only Lieutenants and above can invite."
    end

    local targetGang = Mzansi.Gangs.getPlayerGang(target)
    if targetGang then
        return false, "Target is already in a gang."
    end

    local gang = Mzansi.Gangs._gangs[sourceGang]
    setElementData(target, "mzansi:gangInvite", sourceGang)

    Mzansi.Util.sendNotification(source, "Invitation sent to " .. targetChar.firstName, "info")
    Mzansi.Util.sendNotification(target, "You were invited to " .. (gang and gang.name or "") .. ". Type /gang accept to join.", "info")
    return true
end

function Mzansi.Gangs.acceptInvite(source)
    local gangId = getElementData(source, "mzansi:gangInvite")
    if not gangId then
        Mzansi.Util.sendNotification(source, "No pending invitation.", "error")
        return false
    end

    removeElementData(source, "mzansi:gangInvite")
    return Mzansi.Gangs.joinGang(source, gangId)
end

function Mzansi.Gangs.claimTerritory(source, territoryId)
    local char = Mzansi.Characters.getCharacter(source)
    if not char then return false end

    local gangId = Mzansi.Gangs.getPlayerGang(source)
    if not gangId then
        return false, "You are not in a gang."
    end

    local memberData = Mzansi.Gangs._members[source]
    if not memberData or memberData.rankLevel < 3 then
        return false, "Only Lieutenants and above can claim territory."
    end

    local territory = Mzansi.Gangs._territories[territoryId]
    if not territory then return false end

    if territory.gangId then
        return false, "Territory is already controlled."
    end

    local x, y, z = getElementPosition(source)
    local dist = Mzansi.Util.distance(x, y, z, territory.x, territory.y, territory.z)
    if dist > territory.radius then
        return false, "You are not in this territory."
    end

    local gang = Mzansi.Gangs._gangs[gangId]
    if char.cash < Mzansi.Gangs.Config.TerritoryClaimCost then
        return false, "Need " .. Mzansi.Util.formatMoney(Mzansi.Gangs.Config.TerritoryClaimCost) .. " to claim."
    end

    Mzansi.Characters.removeCash(source, Mzansi.Gangs.Config.TerritoryClaimCost)
    territory.gangId = gangId
    territory.controlledBy = gangId

    Mzansi.Database.update(
        "UPDATE mzansi_territories SET gang_id = ? WHERE id = ?",
        gangId, territoryId
    )

    Mzansi.Util.sendNotification(source, "Territory claimed: " .. territory.name, "success")

    for _, player in ipairs(getElementsByType("player")) do
        if Mzansi.Gangs.getPlayerGang(player) == gangId then
            Mzansi.Util.sendNotification(player, gang.name .. " claimed " .. territory.name, "info")
        end
    end

    return true
end

function Mzansi.Gangs.attackTerritory(source, territoryId)
    local char = Mzansi.Characters.getCharacter(source)
    if not char then return false end

    local gangId = Mzansi.Gangs.getPlayerGang(source)
    if not gangId then return false end

    local territory = Mzansi.Gangs._territories[territoryId]
    if not territory then return false end

    if not territory.gangId or territory.gangId == gangId then
        return false, "Cannot attack your own territory."
    end

    local now = getRealTime().timestamp
    if now - territory.lastAttacked < Mzansi.Gangs.Config.WarCooldown / 1000 then
        return false, "Territory was recently attacked."
    end

    territory.lastAttacked = now

    local gang = Mzansi.Gangs._gangs[gangId]
    local defGang = Mzansi.Gangs._gangs[territory.gangId]

    Mzansi.Util.sendNotification(source, "Attack started on " .. territory.name .. "!", "warning")

    for _, player in ipairs(getElementsByType("player")) do
        local pGang = Mzansi.Gangs.getPlayerGang(player)
        if pGang == gangId or pGang == territory.gangId then
            Mzansi.Util.sendNotification(player, "TURF WAR: " .. (gang and gang.name or "") .. " attacking " .. territory.name .. "!", "warning")
            local blip = createBlip(territory.x, territory.y, territory.z, 0, 3, 255, 0, 0)
            setTimer(function()
                if isElement(blip) then destroyElement(blip) end
            end, 300000, 1)
        end
    end

    setTimer(function()
        Mzansi.Gangs.resolveWar(territoryId, gangId)
    end, 300000, 1)

    return true
end

function Mzansi.Gangs.resolveWar(territoryId, attackerGangId)
    local territory = Mzansi.Gangs._territories[territoryId]
    if not territory then return end

    local defenderGangId = territory.gangId
    local attackerOnline = 0
    local defenderOnline = 0

    for _, player in ipairs(getElementsByType("player")) do
        local pGang = Mzansi.Gangs.getPlayerGang(player)
        local px, py, pz = getElementPosition(player)
        if pGang == attackerGangId then
            local dist = Mzansi.Util.distance(px, py, pz, territory.x, territory.y, territory.z)
            if dist < territory.radius then
                attackerOnline = attackerOnline + 1
            end
        elseif pGang == defenderGangId then
            local dist = Mzansi.Util.distance(px, py, pz, territory.x, territory.y, territory.z)
            if dist < territory.radius then
                defenderOnline = defenderOnline + 1
            end
        end
    end

    if attackerOnline > defenderOnline then
        territory.gangId = attackerGangId
        territory.controlledBy = attackerGangId

        Mzansi.Database.update(
            "UPDATE mzansi_territories SET gang_id = ? WHERE id = ?",
            attackerGangId, territoryId
        )

        local gang = Mzansi.Gangs._gangs[attackerGangId]
        for _, player in ipairs(getElementsByType("player")) do
            if Mzansi.Gangs.getPlayerGang(player) == attackerGangId then
                Mzansi.Util.sendNotification(player, "VICTORY! " .. territory.name .. " is now ours!", "success")
            elseif Mzansi.Gangs.getPlayerGang(player) == defenderGangId then
                Mzansi.Util.sendNotification(player, "DEFEAT! Lost " .. territory.name, "error")
            end
        end
    else
        for _, player in ipairs(getElementsByType("player")) do
            if Mzansi.Gangs.getPlayerGang(player) == attackerGangId then
                Mzansi.Util.sendNotification(player, "Attack failed on " .. territory.name, "error")
            elseif Mzansi.Gangs.getPlayerGang(player) == defenderGangId then
                Mzansi.Util.sendNotification(player, "Successfully defended " .. territory.name, "success")
            end
        end
    end
end

function Mzansi.Gangs.sprayTag(source, gangId)
    local char = Mzansi.Characters.getCharacter(source)
    if not char then return false end

    local playerGang = Mzansi.Gangs.getPlayerGang(source)
    if not playerGang then return false end

    local now = getRealTime().timestamp
    local lastSpray = getElementData(source, "mzansi:lastSpray") or 0
    if now - lastSpray < Mzansi.Gangs.Config.SprayCooldown / 1000 then
        Mzansi.Util.sendNotification(source, "Wait before spraying again.", "error")
        return false
    end

    setElementData(source, "mzansi:lastSpray", now)

    local gang = Mzansi.Gangs._gangs[playerGang]
    Mzansi.Util.sendNotification(source, "Sprayed " .. (gang and gang.name or "") .. " tag", "success")

    for _, player in ipairs(getElementsByType("player")) do
        if Mzansi.Gangs.getPlayerGang(player) == playerGang and player ~= source then
            Mzansi.Util.sendNotification(player, char.firstName .. " sprayed a tag nearby.", "info")
        end
    end

    return true
end

function Mzansi.Gangs.depositMoney(source, amount)
    local char = Mzansi.Characters.getCharacter(source)
    if not char then return false end

    local gangId = Mzansi.Gangs.getPlayerGang(source)
    if not gangId then return false end

    amount = tonumber(amount) or 0
    if amount <= 0 then return false end

    if char.cash < amount then
        return false, "Insufficient funds."
    end

    Mzansi.Characters.removeCash(source, amount)
    Mzansi.Gangs._gangs[gangId].balance = Mzansi.Gangs._gangs[gangId].balance + amount

    Mzansi.Database.update(
        "UPDATE mzansi_gangs SET treasury = treasury + ? WHERE id = ?",
        amount, gangId
    )

    Mzansi.Util.sendNotification(source, "Deposited " .. Mzansi.Util.formatMoney(amount) .. " to gang.", "success")
    return true
end

function Mzansi.Gangs.withdrawMoney(source, amount)
    local char = Mzansi.Characters.getCharacter(source)
    if not char then return false end

    local gangId = Mzansi.Gangs.getPlayerGang(source)
    if not gangId then return false end

    local memberData = Mzansi.Gangs._members[source]
    if not memberData or memberData.rankLevel < 5 then
        return false, "Only Underboss and above can withdraw."
    end

    amount = tonumber(amount) or 0
    if amount <= 0 then return false end

    local gang = Mzansi.Gangs._gangs[gangId]
    if gang.balance < amount then
        return false, "Insufficient gang funds."
    end

    gang.balance = gang.balance - amount
    Mzansi.Characters.addCash(source, amount)

    Mzansi.Database.update(
        "UPDATE mzansi_gangs SET treasury = treasury - ? WHERE id = ?",
        amount, gangId
    )

    Mzansi.Util.sendNotification(source, "Withdrew " .. Mzansi.Util.formatMoney(amount) .. " from gang.", "success")
    return true
end

function Mzansi.Gangs.callBackup(source)
    local char = Mzansi.Characters.getCharacter(source)
    if not char then return false end

    local gangId = Mzansi.Gangs.getPlayerGang(source)
    if not gangId then return false end

    local x, y, z = getElementPosition(source)
    local gang = Mzansi.Gangs._gangs[gangId]

    for _, player in ipairs(getElementsByType("player")) do
        if Mzansi.Gangs.getPlayerGang(player) == gangId and player ~= source then
            Mzansi.Util.sendNotification(player, "BACKUP CALL from " .. char.firstName .. "!", "warning")
            local blip = createBlip(x, y, z, 0, 2, 255, 0, 0)
            setTimer(function()
                if isElement(blip) then destroyElement(blip) end
            -- PLACEHOLDER_CONTINUE
            end, 120000, 1)
        end
    end

    Mzansi.Util.sendNotification(source, "Backup called. Your crew has been notified.", "info")
    return true
end

function Mzansi.Gangs.getPlayerGang(source)
    local memberData = Mzansi.Gangs._members[source]
    if memberData then
        return memberData.gangId
    end
    return nil
end

function Mzansi.Gangs.getGangMemberCount(gangId)
    local count = 0
    for _, memberData in pairs(Mzansi.Gangs._members) do
        if memberData.gangId == gangId then
            count = count + 1
        end
    end
    return count
end

function Mzansi.Gangs.getGangMembers(gangId)
    local members = {}
    for player, memberData in pairs(Mzansi.Gangs._members) do
        if memberData.gangId == gangId and isElement(player) then
            local char = Mzansi.Characters.getCharacter(player)
            if char then
                members[#members + 1] = {
                    name = char.firstName .. " " .. char.lastName,
                    rank = memberData.rankName,
                    rankLevel = memberData.rankLevel,
                    online = true,
                }
            end
        end
    end
    return members
end

addEventHandler("mzansi:gangs:create", root, function(gangId, name, tag)
    local source = client or source
    Mzansi.Gangs.createGang(source, gangId, name, tag)
end)

addEventHandler("mzansi:gangs:join", root, function(gangId)
    local source = client or source
    Mzansi.Gangs.joinGang(source, gangId)
end)

addEventHandler("mzansi:gangs:leave", root, function()
    local source = client or source
    Mzansi.Gangs.leaveGang(source)
end)

addEventHandler("mzansi:gangs:kick", root, function(target)
    local source = client or source
    Mzansi.Gangs.kickMember(source, target)
end)

addEventHandler("mzansi:gangs:promote", root, function(target)
    local source = client or source
    Mzansi.Gangs.promoteMember(source, target)
end)

addEventHandler("mzansi:gangs:demote", root, function(target)
    local source = client or source
    Mzansi.Gangs.demoteMember(source, target)
end)

addEventHandler("mzansi:gangs:invite", root, function(target)
    local source = client or source
    Mzansi.Gangs.inviteMember(source, target)
end)

addEventHandler("mzansi:gangs:acceptInvite", root, function()
    local source = client or source
    Mzansi.Gangs.acceptInvite(source)
end)

addEventHandler("mzansi:gangs:claimTerritory", root, function(territoryId)
    local source = client or source
    Mzansi.Gangs.claimTerritory(source, territoryId)
end)

addEventHandler("mzansi:gangs:attackTerritory", root, function(territoryId)
    local source = client or source
    Mzansi.Gangs.attackTerritory(source, territoryId)
end)

addEventHandler("mzansi:gangs:sprayTag", root, function(gangId)
    local source = client or source
    Mzansi.Gangs.sprayTag(source, gangId)
end)

addEventHandler("mzansi:gangs:depositMoney", root, function(amount)
    local source = client or source
    Mzansi.Gangs.depositMoney(source, amount)
end)

addEventHandler("mzansi:gangs:withdrawMoney", root, function(amount)
    local source = client or source
    Mzansi.Gangs.withdrawMoney(source, amount)
end)

addEventHandler("mzansi:gangs:callBackup", root, function()
    local source = client or source
    Mzansi.Gangs.callBackup(source)
end)

addEventHandler("mzansi:gangs:getMembers", root, function()
    local source = client or source
    local gangId = Mzansi.Gangs.getPlayerGang(source)
    if not gangId then return end
    local members = Mzansi.Gangs.getGangMembers(gangId)
    triggerClientEvent(source, "mzansi:gangs:membersList", source, members)
end)

addEventHandler("mzansi:gangs:getGangInfo", root, function()
    local source = client or source
    local gangId = Mzansi.Gangs.getPlayerGang(source)
    if not gangId then return end
    local gang = Mzansi.Gangs._gangs[gangId]
    triggerClientEvent(source, "mzansi:gangs:info", source, gang)
end)

addEventHandler("onPlayerQuit", root, function()
    Mzansi.Gangs._members[source] = nil
end)

addEventHandler("onResourceStart", resourceRoot, function()
    Mzansi.Gangs.init()
end)
