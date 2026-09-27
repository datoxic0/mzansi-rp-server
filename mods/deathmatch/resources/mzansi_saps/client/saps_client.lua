Mzansi = Mzansi or {}
Mzansi.SAPS = Mzansi.SAPS or {}

Mzansi.SAPS._dispatchBlips = {}
Mzansi.SAPS._mdtBrowser = nil

addEvent("mzansi:saps:newDispatch", true)
addEvent("mzansi:saps:friskResult", true)
addEvent("mzansi:saps:mdtResult", true)

function Mzansi.SAPS.isOfficer()
    local char = getElementData(localPlayer, "mzansi:character")
    return char and char.faction == Mzansi.Enums.Faction.SAPS
end

function isOfficer()
    return Mzansi.SAPS.isOfficer() or false
end

function Mzansi.SAPS.openMDT()
    if not Mzansi.SAPS.isOfficer() then
        Mzansi.Util.notify("Access denied.", "error")
        return
    end

    if Mzansi.SAPS._mdtBrowser then
        destroyElement(Mzansi.SAPS._mdtBrowser)
    end

    Mzansi.SAPS._mdtBrowser = createBrowser(800, 600, true, true)
    addEventHandler("onClientBrowserCreated", Mzansi.SAPS._mdtBrowser, function()
        loadBrowserURL(Mzansi.SAPS._mdtBrowser, "http://mta/local/ui/mdt.html")
        showCursor(true)
    end)
end

function Mzansi.SAPS.closeMDT()
    if Mzansi.SAPS._mdtBrowser then
        destroyElement(Mzansi.SAPS._mdtBrowser)
        Mzansi.SAPS._mdtBrowser = nil
    end
    showCursor(false)
end

function Mzansi.SAPS.cuffPlayer(target)
    if not Mzansi.SAPS.isOfficer() then return end
    if not target then
        target = Mzansi.SAPS.getClosestPlayer(3)
    end
    if target then
        triggerServerEvent("mzansi:saps:cuff", localPlayer, target)
    else
        Mzansi.Util.notify("No player nearby.", "error")
    end
end

function Mzansi.SAPS.arrestPlayer(target, jailTime)
    if not Mzansi.SAPS.isOfficer() then return end
    if not target then
        target = Mzansi.SAPS.getClosestPlayer(5)
    end
    if target then
        local time = tonumber(jailTime) or 300
        triggerServerEvent("mzansi:saps:arrest", localPlayer, target, time)
    else
        Mzansi.Util.notify("No player nearby.", "error")
    end
end

function Mzansi.SAPS.issueTicket(target, amount, reason)
    if not Mzansi.SAPS.isOfficer() then return end
    if not target then
        target = Mzansi.SAPS.getClosestPlayer(5)
    end
    if target then
        triggerServerEvent("mzansi:saps:ticket", localPlayer, target, amount, reason)
    else
        Mzansi.Util.notify("No player nearby.", "error")
    end
end

function Mzansi.SAPS.friskPlayer(target)
    if not Mzansi.SAPS.isOfficer() then return end
    if not target then
        target = Mzansi.SAPS.getClosestPlayer(3)
    end
    if target then
        triggerServerEvent("mzansi:saps:frisk", localPlayer, target)
    else
        Mzansi.Util.notify("No player nearby.", "error")
    end
end

function Mzansi.SAPS.createDispatch(type, description)
    if not Mzansi.SAPS.isOfficer() then return end
    local x, y, z = getElementPosition(localPlayer)
    triggerServerEvent("mzansi:saps:dispatch", localPlayer, type, x, y, z, description)
end

function Mzansi.SAPS.searchMDT(query)
    if not Mzansi.SAPS.isOfficer() then return end
    triggerServerEvent("mzansi:saps:mdtSearch", localPlayer, query)
end

function Mzansi.SAPS.addRecord(charId, charge, description, fine, jailTime)
    if not Mzansi.SAPS.isOfficer() then return end
    triggerServerEvent("mzansi:saps:mdtAddRecord", localPlayer, charId, charge, description, fine, jailTime)
end

function Mzansi.SAPS.issueWarrant(charId, reason)
    if not Mzansi.SAPS.isOfficer() then return end
    triggerServerEvent("mzansi:saps:mdtWarrant", localPlayer, charId, reason)
end

function Mzansi.SAPS.getClosestPlayer(range)
    local closestPlayer = nil
    local closestDist = range or 3
    local px, py, pz = getElementPosition(localPlayer)
    for _, player in ipairs(getElementsByType("player")) do
        if player ~= localPlayer then
            local tx, ty, tz = getElementPosition(player)
            local dist = Mzansi.Util.distance(px, py, pz, tx, ty, tz)
            if dist < closestDist then
                closestPlayer = player
                closestDist = dist
            end
        end
    end
    return closestPlayer
end

function Mzansi.SAPS.renderDispatchBlips()
    local px, py = getElementPosition(localPlayer)
    for id, dispatch in pairs(Mzansi.SAPS._dispatchBlips) do
        if isElement(dispatch.blip) then
            local x, y, z = getElementPosition(dispatch.blip)
            local dist = Mzansi.Util.distance2D(px, py, x, y)
            if dist < 50 then
                local sx, sy = getScreenFromWorldPosition(x, y, z + 1)
                if sx and sy then
                    dxDrawText("DISPATCH #" .. id, sx - 50, sy - 10, sx + 50, sy + 10, tocolor(255, 50, 50, 200), 1, "default-bold", "center", "center")
                end
            end
        end
    end
end

addEventHandler("mzansi:saps:newDispatch", root, function(dispatch)
    local blip = createBlip(dispatch.x, dispatch.y, dispatch.z, 0, 2, 255, 0, 0)
    setBlipColor(blip, 255, 0, 0)
    setBlipDisplayMode(blip, 2)
    Mzansi.SAPS._dispatchBlips[dispatch.id] = { dispatch = dispatch, blip = blip }
    Mzansi.Util.notify("New dispatch: " .. dispatch.type .. " - " .. dispatch.description, "warning")
end)

addEventHandler("mzansi:saps:friskResult", root, function(target)
    local items = getElementsInsideSphere(getElementPosition(target), 1)
    Mzansi.Util.notify("Search complete. Check chat for results.", "info")
end)

addEvent("mzansi:saps:closeMDT", true)
addEventHandler("mzansi:saps:closeMDT", root, function()
    Mzansi.SAPS.closeMDT()
end)

addEventHandler("mzansi:saps:mdtResult", root, function(results)
    if #results == 0 then
        Mzansi.Util.notify("No results found.", "info")
        return
    end
    if Mzansi.SAPS._mdtBrowser and results[1] then
        local js = string.format("window.postMessage({type: 'profile', record: %s}, '*');", toJSON(results[1]))
        executeBrowserJavascript(Mzansi.SAPS._mdtBrowser, js)
    end
    for _, char in ipairs(results) do
        outputChatBox("[MDT] " .. char.first_name .. " " .. char.last_name .. " (ID: " .. char.id .. ") - Job: " .. (Mzansi.Config.Jobs[char.job] and Mzansi.Config.Jobs[char.job].name or "Unknown"), 0, 150, 255)
    end
end)

addEventHandler("onClientRender", root, function()
    if Mzansi.SAPS.isOfficer() then
        Mzansi.SAPS.renderDispatchBlips()
        if Mzansi.SAPS._mdtBrowser then
            local sw, sh = guiGetScreenSize()
            local bx, by = (sw - 800) / 2, (sh - 560) / 2
            dxDrawImage(bx, by, 800, 560, Mzansi.SAPS._mdtBrowser, 0, 0, 0, tocolor(255, 255, 255, 255), true)
        end
    end
end)

addCommandHandler("mdt", function(cmd, query)
    if not Mzansi.SAPS.isOfficer() then
        outputChatBox("[SAPS] Access denied. You are not on active police duty.", 255, 50, 50)
        return
    end
    if not query or string.len(query) == 0 then
        if Mzansi.SAPS._mdtBrowser then
            Mzansi.SAPS.closeMDT()
        else
            Mzansi.SAPS.openMDT()
        end
        return
    end
    triggerServerEvent("mzansi:saps:mdtSearch", localPlayer, query)
end)

addCommandHandler("cuff", function()
    Mzansi.SAPS.cuffPlayer()
end)

addCommandHandler("arrest", function(cmd, jailTime)
    Mzansi.SAPS.arrestPlayer(nil, jailTime)
end)

addCommandHandler("ticket", function(cmd, amount, ...)
    Mzansi.SAPS.issueTicket(nil, amount, table.concat({...}, " "))
end)

addCommandHandler("frisk", function()
    Mzansi.SAPS.friskPlayer()
end)

addCommandHandler("dispatch", function(cmd, ...)
    Mzansi.SAPS.createDispatch("Request Backup", table.concat({...}, " "))
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
    outputDebugString("[Mzansi-SAPS] SAPS client loaded.")
end)
