Mzansi = Mzansi or {}
Mzansi.Gangs = Mzansi.Gangs or {}
Mzansi.Gangs._territoryBlips = {}
Mzansi.Gangs._gangBlips = {}
Mzansi.Gangs._tagObjects = {}

addEvent("mzansi:gangs:membersList", true)
addEvent("mzansi:gangs:info", true)

function Mzansi.Gangs.getPlayerGang()
    return getElementData(localPlayer, "mzansi:gang")
end

function Mzansi.Gangs.getPlayerRank()
    return getElementData(localPlayer, "mzansi:gangRank") or 0
end

function Mzansi.Gangs.createGang(gangId, name, tag)
    triggerServerEvent("mzansi:gangs:create", localPlayer, gangId, name, tag)
end

function Mzansi.Gangs.joinGang(gangId)
    triggerServerEvent("mzansi:gangs:join", localPlayer, gangId)
end

function Mzansi.Gangs.leaveGang()
    triggerServerEvent("mzansi:gangs:leave", localPlayer)
end

function Mzansi.Gangs.inviteMember(target)
    triggerServerEvent("mzansi:gangs:invite", localPlayer, target)
end

function Mzansi.Gangs.acceptInvite()
    triggerServerEvent("mzansi:gangs:acceptInvite", localPlayer)
end

function Mzansi.Gangs.claimTerritory(territoryId)
    triggerServerEvent("mzansi:gangs:claimTerritory", localPlayer, territoryId)
end

function Mzansi.Gangs.attackTerritory(territoryId)
    triggerServerEvent("mzansi:gangs:attackTerritory", localPlayer, territoryId)
end

function Mzansi.Gangs.sprayTag(gangId)
    triggerServerEvent("mzansi:gangs:sprayTag", localPlayer, gangId)
end

function Mzansi.Gangs.depositMoney(amount)
    triggerServerEvent("mzansi:gangs:depositMoney", localPlayer, amount)
end

function Mzansi.Gangs.withdrawMoney(amount)
    triggerServerEvent("mzansi:gangs:withdrawMoney", localPlayer, amount)
end

function Mzansi.Gangs.callBackup()
    triggerServerEvent("mzansi:gangs:callBackup", localPlayer)
end

function Mzansi.Gangs.getMembers()
    triggerServerEvent("mzansi:gangs:getMembers", localPlayer)
end

function Mzansi.Gangs.getGangInfo()
    triggerServerEvent("mzansi:gangs:getGangInfo", localPlayer)
end

function Mzansi.Gangs.renderTerritories()
    for _, territory in ipairs(Mzansi.Gangs.Config.Territories) do
        local dist = Mzansi.Util.distance(localPlayer,
            territory.x, territory.y, territory.z
        )

        if dist < territory.radius + 50 then
            local gangId = Mzansi.Gangs.getPlayerGang()
            local isOwned = territory.gangId == gangId
            local isEnemy = territory.gangId and territory.gangId ~= gangId

            local color = tocolor(100, 100, 100, 30)
            if isOwned then
                color = tocolor(0, 255, 0, 50)
            elseif isEnemy then
                color = tocolor(255, 0, 0, 50)
            end

            dxDrawCircle3D(territory.x, territory.y, territory.z - 2, territory.radius * 0.3, color)

            if dist < 10 then
                local status = "Unclaimed"
                if territory.gangId then
                    local controlling = Mzansi.Gangs.Config.Gangs[territory.gangId]
                    status = controlling and controlling.name or "Unknown"
                end

                dxDrawText(territory.name, territory.x - 75, territory.y, territory.x + 75, territory.z + 2, tocolor(255, 215, 0, 255), 1.2, "default-bold", "center", "center")
                dxDrawText(status, territory.x - 75, territory.y, territory.x + 75, territory.z + 3, tocolor(200, 200, 200, 200), 0.9, "default", "center", "center")

                if not territory.gangId and gangId then
                    dxDrawText("Press E to claim (" .. Mzansi.Util.formatMoney(Mzansi.Gangs.Config.TerritoryClaimCost) .. ")", territory.x - 100, territory.y, territory.x + 100, territory.z + 4, tocolor(0, 255, 100, 180), 0.8, "default", "center", "center")
                elseif isEnemy and Mzansi.Gangs.getPlayerRank() >= 3 then
                    dxDrawText("Press E to attack", territory.x - 75, territory.y, territory.x + 75, territory.z + 4, tocolor(255, 50, 50, 180), 0.8, "default", "center", "center")
                end
            end
        end
    end
end

function Mzansi.Gangs.renderGangHUD()
    local gangId = Mzansi.Gangs.getPlayerGang()
    if not gangId then return end

    local gang = Mzansi.Gangs.Config.Gangs[gangId]
    if not gang then return end

    local screenW, screenH = guiGetScreenSize()
    local x, y = 20, 180

    dxDrawRectangle(x - 5, y - 5, 220, 60, tocolor(0, 0, 0, 150), true)
    dxDrawRectangle(x - 5, y - 5, 220, 2, tocolor(gang.color.r, gang.color.g, gang.color.b, 255), true)

    dxDrawText(gang.name .. " [" .. gang.tag .. "]", x, y, x + 210, y + 20, tocolor(gang.color.r, gang.color.g, gang.color.b, 255), 1, "default-bold", "left", "top")

    local rankName = "Associate"
    local memberData = getElementData(localPlayer, "mzansi:gangRank") or 0
    if gang.ranks and gang.ranks[memberData + 1] then
        rankName = gang.ranks[memberData + 1].name
    end
    dxDrawText("Rank: " .. rankName, x, y + 22, x + 210, y + 40, tocolor(200, 200, 200, 255), 0.8, "default", "left", "top")
end

function Mzansi.Gangs.renderTagBlips()
    local px, py, pz = getElementPosition(localPlayer)
    for _, tag in ipairs(Mzansi.Gangs._tagObjects) do
        if isElement(tag.object) then
            local tx, ty, tz = getElementPosition(tag.object)
            local dist = Mzansi.Util.distance(px, py, pz, tx, ty, tz)
            if dist < 20 then
                local sx, sy = getScreenFromWorldPosition(tx, ty, tz + 0.5)
                if sx and sy then
                    local gang = Mzansi.Gangs.Config.Gangs[tag.gangId]
                    if gang then
                        dxDrawText(gang.name .. " Tag", sx - 50, sy - 10, sx + 50, sy + 10, tocolor(255, 255, 255, 220), 1, "default-bold", "center", "center")
                    end
                end
            end
        end
    end
end

addEventHandler("mzansi:gangs:membersList", root, function(members)
    outputChatBox("[GANG] Members:", 200, 170, 50)
    for _, member in ipairs(members) do
        local status = member.online and "[ONLINE]" or "[OFFLINE]"
        outputChatBox("  " .. member.name .. " - " .. member.rank .. " " .. status, 200, 200, 200)
    end
end)

addEventHandler("mzansi:gangs:info", root, function(gang)
    if not gang then return end
    outputChatBox("[GANG] " .. gang.name .. " [" .. gang.tag .. "]", 200, 170, 50)
    outputChatBox("  Description: " .. (gang.description or "None"), 200, 200, 200)
    outputChatBox("  Balance: " .. Mzansi.Util.formatMoney(gang.balance or 0), 200, 200, 200)
    outputChatBox("  Territories: " .. (gang.territoryCount or 0), 200, 200, 200)
end)

addEventHandler("onClientRender", root, function()
    Mzansi.Gangs.renderTerritories()
    Mzansi.Gangs.renderGangHUD()
    Mzansi.Gangs.renderTagBlips()
end)

addCommandHandler("gang", function(cmd, action, ...)
    if action == "create" then
        local args = {...}
        local gangId = tonumber(args[1]) or 1
        local name = args[2] or "My Gang"
        local tag = args[3] or "MG"
        Mzansi.Gangs.createGang(gangId, name, tag)
    elseif action == "join" then
        local gangId = tonumber(({...})[1]) or 1
        Mzansi.Gangs.joinGang(gangId)
    elseif action == "leave" then
        Mzansi.Gangs.leaveGang()
    elseif action == "invite" then
        local target = getPedOccupiedVehicleSeat(localPlayer) == -1 and getClosestPlayer(5)
        if target then Mzansi.Gangs.inviteMember(target) end
    elseif action == "accept" then
        Mzansi.Gangs.acceptInvite()
    elseif action == "members" then
        Mzansi.Gangs.getMembers()
    elseif action == "info" then
        Mzansi.Gangs.getGangInfo()
    elseif action == "deposit" then
        local amount = tonumber(({...})[1]) or 0
        Mzansi.Gangs.depositMoney(amount)
    elseif action == "withdraw" then
        local amount = tonumber(({...})[1]) or 0
        Mzansi.Gangs.withdrawMoney(amount)
    elseif action == "backup" then
        Mzansi.Gangs.callBackup()
    elseif action == "tag" then
        local gangId = Mzansi.Gangs.getPlayerGang()
        if gangId then Mzansi.Gangs.sprayTag(gangId) end
    elseif action == "claim" then
        local px, py, pz = getElementPosition(localPlayer)
        for _, territory in ipairs(Mzansi.Gangs.Config.Territories) do
            local dist = Mzansi.Util.distance(px, py, pz, territory.x, territory.y, territory.z)
            if dist < territory.radius then
                Mzansi.Gangs.claimTerritory(territory.id)
                return
            end
        end
        Mzansi.Util.notify("No territory nearby.", "error")
    elseif action == "attack" then
        local px, py, pz = getElementPosition(localPlayer)
        for _, territory in ipairs(Mzansi.Gangs.Config.Territories) do
            local dist = Mzansi.Util.distance(px, py, pz, territory.x, territory.y, territory.z)
            if dist < territory.radius then
                Mzansi.Gangs.attackTerritory(territory.id)
                return
            end
        end
        Mzansi.Util.notify("No territory nearby.", "error")
    else
        outputChatBox("[GANG] Commands: /gang [create|join|leave|invite|accept|members|info|deposit|withdraw|backup|tag|claim|attack]", 200, 170, 50)
    end
end)

function getClosestPlayer(range)
    local closest = nil
    local closestDist = range or 5
    local px, py, pz = getElementPosition(localPlayer)
    for _, player in ipairs(getElementsByType("player")) do
        if player ~= localPlayer then
            local tx, ty, tz = getElementPosition(player)
            local dist = Mzansi.Util.distance(px, py, pz, tx, ty, tz)
            if dist < closestDist then
                closest = player
                closestDist = dist
            end
        end
    end
    return closest
end

addEventHandler("onClientResourceStart", resourceRoot, function()
    outputDebugString("[Mzansi-Gangs] Gang client loaded.")
end)
