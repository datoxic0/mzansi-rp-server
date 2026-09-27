Mzansi = Mzansi or {}
Mzansi.Crime = Mzansi.Crime or {}
Mzansi.Crime._robberyBlips = {}
Mzansi.Crime._blackMarketBlips = {}

addEvent("mzansi:crime:robberyStarted", true)
addEvent("mzansi:crime:robberyComplete", true)

function Mzansi.Crime.startRobbery(robberyId)
    triggerServerEvent("mzansi:crime:robbery", localPlayer, robberyId)
end

function Mzansi.Crime.startHeist(heistId)
    triggerServerEvent("mzansi:crime:heist", localPlayer, heistId)
end

function Mzansi.Crime.startIllegalJob(jobId)
    triggerServerEvent("mzansi:crime:illegalJob", localPlayer, jobId)
end

function Mzansi.Crime.sellToBlackMarket(itemId)
    triggerServerEvent("mzansi:crime:blackMarket", localPlayer, itemId)
end

function Mzansi.Crime.takeMask()
    triggerServerEvent("mzansi:crime:takeMask", localPlayer)
end

function Mzansi.Crime.renderRobberyLocations()
    for _, robbery in ipairs(Mzansi.Crime.Config.Robberies) do
        local dist = Mzansi.Util.distance(localPlayer,
            robbery.x, robbery.y, robbery.z
        )

        if dist < 100 then
            local pulse = math.sin(getTickCount() / 400) * 0.3 + 0.7
            dxDrawCircle3D(robbery.x, robbery.y, robbery.z - 1, 2, tocolor(255, 0, 0, pulse * 80))

            if dist < robbery.radius then
                dxDrawText("CRIME: " .. robbery.name, robbery.x - 100, robbery.y, robbery.x + 100, robbery.z + 2, tocolor(255, 50, 50, 255), 1.1, "default-bold", "center", "center")
                dxDrawText(robbery.description, robbery.x - 100, robbery.y, robbery.x + 100, robbery.z + 3, tocolor(200, 200, 200, 200), 0.8, "default", "center", "center")
                dxDrawText("Players needed: " .. robbery.minPlayers .. " | Reward: " .. Mzansi.Util.formatMoney(robbery.reward.min) .. "-" .. Mzansi.Util.formatMoney(robbery.reward.max), robbery.x - 120, robbery.y, robbery.x + 120, robbery.z + 4, tocolor(200, 170, 50, 180), 0.7, "default", "center", "center")
                dxDrawText("Press E to start robbery", robbery.x - 75, robbery.y, robbery.x + 75, robbery.z + 5, tocolor(255, 150, 0, 180), 0.8, "default", "center", "center")
            end
        end
    end
end

function Mzansi.Crime.renderBlackMarketLocations()
    for _, shop in ipairs(Mzansi.Crime.Config.BlackMarket) do
        local loc = shop.location
        local dist = Mzansi.Util.distance(localPlayer,
            loc.x, loc.y, loc.z
        )

        if dist < 50 then
            local pulse = math.sin(getTickCount() / 500) * 0.3 + 0.7
            dxDrawCircle3D(loc.x, loc.y, loc.z - 1, 1.5, tocolor(150, 0, 200, pulse * 80))

            if dist < 5 then
                dxDrawText(shop.name, loc.x - 75, loc.y, loc.x + 75, loc.z + 2, tocolor(150, 0, 200, 255), 1.1, "default-bold", "center", "center")
                dxDrawText("Press E to browse", loc.x - 75, loc.y, loc.x + 75, loc.z + 3, tocolor(200, 200, 200, 180), 0.8, "default", "center", "center")
            end
        end
    end
end

function Mzansi.Crime.renderIllegalJobLocations()
    for _, job in ipairs(Mzansi.Crime.Config.IllegalJobs) do
        local dist = Mzansi.Util.distance(localPlayer,
            job.x, job.y, job.z
        )

        if dist < 50 then
            local pulse = math.sin(getTickCount() / 600) * 0.3 + 0.7
            dxDrawCircle3D(job.x, job.y, job.z - 1, 1.5, tocolor(255, 100, 0, pulse * 80))

            if dist < 5 then
                dxDrawText("ILLEGAL: " .. job.name, job.x - 75, job.y, job.x + 75, job.z + 2, tocolor(255, 100, 0, 255), 1.1, "default-bold", "center", "center")
                dxDrawText(job.description, job.x - 75, job.y, job.x + 75, job.z + 3, tocolor(200, 200, 200, 200), 0.8, "default", "center", "center")
                dxDrawText("Reward: " .. Mzansi.Util.formatMoney(job.reward.min) .. "-" .. Mzansi.Util.formatMoney(job.reward.max), job.x - 75, job.y, job.x + 75, job.z + 4, tocolor(200, 170, 50, 180), 0.7, "default", "center", "center")
                dxDrawText("Press E to start", job.x - 50, job.y, job.x + 50, job.z + 5, tocolor(255, 150, 0, 180), 0.8, "default", "center", "center")
            end
        end
    end
end

function Mzansi.Crime.renderWantedHUD()
    local wanted = getElementData(localPlayer, "mzansi:wantedLevel") or 0
    if wanted <= 0 then return end

    local screenW, screenH = guiGetScreenSize()
    local x, y = screenW / 2 - 100, 20

    dxDrawRectangle(x, y, 200, 35, tocolor(0, 0, 0, 180), true)
    dxDrawRectangle(x, y, 200, 2, tocolor(255, 0, 0, 255), true)

    local stars = string.rep("★", wanted) .. string.rep("☆", 4 - wanted)
    dxDrawText("WANTED", x + 10, y + 5, x + 190, y + 20, tocolor(255, 50, 50, 255), 0.9, "default-bold", "center", "top")
    dxDrawText(stars, x + 10, y + 18, x + 190, y + 33, tocolor(255, 200, 0, 255), 1.2, "default-bold", "center", "top")
end

function Mzansi.Crime.renderHeistLocations()
    for _, heist in ipairs(Mzansi.Crime.Config.Heists) do
        local dist = Mzansi.Util.distance(localPlayer,
            1470.5, -1010.5, 27.5
        )

        if dist < 50 then
            local pulse = math.sin(getTickCount() / 300) * 0.3 + 0.7
            dxDrawCircle3D(1470.5, -1010.5, 26.5, 3, tocolor(255, 0, 0, pulse * 100))

            if dist < 10 then
                dxDrawText("HEIST: " .. heist.name, 1470.5 - 100, -1010.5, 1470.5 + 100, 29.5, tocolor(255, 0, 0, 255), 1.3, "default-bold", "center", "center")
                dxDrawText(heist.description, 1470.5 - 100, -1010.5, 1470.5 + 100, 30.5, tocolor(200, 200, 200, 200), 0.8, "default", "center", "center")
                dxDrawText("Players: " .. heist.minPlayers .. " | Reward: " .. Mzansi.Util.formatMoney(heist.reward.min) .. "-" .. Mzansi.Util.formatMoney(heist.reward.max), 1470.5 - 120, -1010.5, 1470.5 + 120, 31.5, tocolor(200, 170, 50, 180), 0.7, "default", "center", "center")
            end
        end
    end
end

addEventHandler("mzansi:crime:robberyStarted", root, function(robberyName)
    outputChatBox("[CRIME] " .. robberyName .. " started!", 255, 50, 50)
end)

addEventHandler("mzansi:crime:robberyComplete", root, function(reward)
    outputChatBox("[CRIME] Robbery complete! Reward: " .. Mzansi.Util.formatMoney(reward), 50, 255, 50)
end)

addEventHandler("onClientRender", root, function()
    Mzansi.Crime.renderRobberyLocations()
    Mzansi.Crime.renderBlackMarketLocations()
    Mzansi.Crime.renderIllegalJobLocations()
    Mzansi.Crime.renderWantedHUD()
    Mzansi.Crime.renderHeistLocations()
end)

addCommandHandler("crime", function(cmd, action, ...)
    if action == "rob" then
        local id = tonumber(({...})[1]) or 1
        Mzansi.Crime.startRobbery(id)
    elseif action == "heist" then
        local id = tonumber(({...})[1]) or 1
        Mzansi.Crime.startHeist(id)
    elseif action == "job" then
        local id = tonumber(({...})[1]) or 1
        Mzansi.Crime.startIllegalJob(id)
    elseif action == "mask" then
        Mzansi.Crime.takeMask()
    elseif action == "wanted" then
        local level = tonumber(({...})[1]) or 0
        triggerServerEvent("mzansi:crime:setWanted", localPlayer, level)
    else
        outputChatBox("[CRIME] Commands:", 255, 100, 50)
        outputChatBox("  /crime rob [id] - Start robbery", 200, 200, 200)
        outputChatBox("  /crime heist [id] - Start heist", 200, 200, 200)
        outputChatBox("  /crime job [id] - Start illegal job", 200, 200, 200)
        outputChatBox("  /crime mask - Toggle mask", 200, 200, 200)
    end
end)

addCommandHandler("mask", function()
    Mzansi.Crime.takeMask()
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
    outputDebugString("[Mzansi-Crime] Crime client loaded.")
end)
