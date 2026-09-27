Mzansi = Mzansi or {}
Mzansi.Jobs = Mzansi.Jobs or {}

function Mzansi.Jobs.applyJob(jobId)
    triggerServerEvent("mzansi:jobs:apply", localPlayer, jobId)
end

function Mzansi.Jobs.quitJob()
    triggerServerEvent("mzansi:jobs:quit", localPlayer)
end

function Mzansi.Jobs.startRoute()
    triggerServerEvent("mzansi:jobs:startRoute", localPlayer)
end

function Mzansi.Jobs.completeRoute()
    triggerServerEvent("mzansi:jobs:completeRoute", localPlayer)
end

function Mzansi.Jobs.fish()
    triggerServerEvent("mzansi:jobs:fish", localPlayer)
end

function Mzansi.Jobs.startActivity()
    triggerServerEvent("mzansi:jobs:startActivity", localPlayer)
end

function Mzansi.Jobs.completeStop()
    triggerServerEvent("mzansi:jobs:completeStop", localPlayer)
end

function Mzansi.Jobs.cancelActivity()
    triggerServerEvent("mzansi:jobs:cancelActivity", localPlayer)
end

local _lastAutoComplete = 0

function Mzansi.Jobs.renderJobStop()
    local stop = getElementData(localPlayer, "mzansi:jobStop")
    if type(stop) ~= "table" or not stop.x then return end

    local px, py, pz = getElementPosition(localPlayer)
    local dist = Mzansi.Util.distance(px, py, pz, stop.x, stop.y, stop.z)
    local reach = (Mzansi.Jobs.Config and Mzansi.Jobs.Config.ActivityReach) or 12.0

    if dist < 80 then
        local pulse = math.sin(getTickCount() / 400) * 0.3 + 0.7
        dxDrawCircle3D(stop.x, stop.y, stop.z - 1, 2.0, tocolor(255, 200, 0, pulse * 160))

        if dist < 25 then
            local sx, sy = getScreenFromWorldPosition(stop.x, stop.y, stop.z + 2.5, 0.5)
            if sx then
                dxDrawText("[JOB] " .. tostring(stop.name) .. "  (" .. tostring(stop.index) .. "/" .. tostring(stop.total) .. ")",
                    sx - 80, sy - 10, sx + 80, sy + 10,
                    tocolor(255, 215, 0, 255), 1.1, "default-bold", "center", "center")
            end
        end

        if dist <= reach then
            local sw, sh = guiGetScreenSize()
            dxDrawText("Press ENTER or type /job complete",
                0, 0.42 * sh, sw, 0.46 * sh,
                tocolor(0, 255, 120, 230), 1.15, "default-bold", "center", "center")

            local tick = getTickCount()
            if tick - _lastAutoComplete > 2500 then
                _lastAutoComplete = tick
                Mzansi.Jobs.completeStop()
            end
        end
    end
end

function Mzansi.Jobs.renderJobMarkers()
    local char = getElementData(localPlayer, "mzansi:character")
    if not char then return end

    for jobId, locations in pairs(Mzansi.Jobs.Config.Locations) do
        for _, loc in ipairs(locations) do
            local dist = Mzansi.Util.distance(localPlayer,
                loc.x, loc.y, loc.z
        )

            if dist < 50 then
                local pulse = math.sin(getTickCount() / 500) * 0.3 + 0.7
                dxDrawCircle3D(loc.x, loc.y, loc.z - 1, 1.5, tocolor(0, 200, 255, pulse * 100))

                if dist < 5 then
                    local jobName = Mzansi.Config.Jobs[jobId] and Mzansi.Config.Jobs[jobId].name or "Unknown"
                    dxDrawText("[" .. jobName .. "]", loc.x - 50, loc.y, loc.x + 50, loc.z + 2, tocolor(200, 170, 50, 255), 1.2, "default-bold", "center", "center")
                    dxDrawText("Press E to apply", loc.x - 50, loc.y, loc.x + 50, loc.z + 3, tocolor(200, 200, 200, 180), 0.9, "default", "center", "center")
                end
            end
        end
    end
end

addEventHandler("onClientRender", root, function()
    Mzansi.Jobs.renderJobMarkers()
    Mzansi.Jobs.renderJobStop()
end)

bindKey("enter", "down", function()
    if Mzansi.Util and Mzansi.Util.bindBlocked and Mzansi.Util.bindBlocked() then return end
    local stop = getElementData(localPlayer, "mzansi:jobStop")
    if type(stop) == "table" and stop.x then
        local px, py, pz = getElementPosition(localPlayer)
        local reach = (Mzansi.Jobs.Config and Mzansi.Jobs.Config.ActivityReach) or 12.0
        if Mzansi.Util.distance(px, py, pz, stop.x, stop.y, stop.z) <= reach then
            Mzansi.Jobs.completeStop()
        end
    end
end)

addCommandHandler("job", function(cmd, action, jobId)
    if action == "apply" then
        local id = tonumber(jobId)
        if id then
            Mzansi.Jobs.applyJob(id)
        else
            local char = getElementData(localPlayer, "mzansi:character")
            if char then
                outputChatBox("[Jobs] Available jobs:", 200, 170, 50)
                for jobId, jobConfig in pairs(Mzansi.Config.Jobs) do
                    if jobId ~= Mzansi.Enums.Job.UNEMPLOYED then
                        outputChatBox("  " .. jobId .. " - " .. jobConfig.name .. " (Pay: " .. Mzansi.Util.formatMoney(jobConfig.pay) .. ")", 200, 200, 200)
                    end
                end
                outputChatBox("Use /job apply <id> to apply.", 200, 200, 200)
            end
        end
    elseif action == "quit" then
        Mzansi.Jobs.quitJob()
    elseif action == "start" then
        Mzansi.Jobs.startRoute()
    elseif action == "work" then
        Mzansi.Jobs.startActivity()
    elseif action == "complete" then
        Mzansi.Jobs.completeStop()
    elseif action == "cancel" then
        Mzansi.Jobs.cancelActivity()
    elseif action == "fish" then
        Mzansi.Jobs.fish()
    else
        outputChatBox("[Jobs] Usage: /job [apply|quit|work|complete|cancel|start|fish]", 200, 170, 50)
    end
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
    outputDebugString("[Mzansi-Jobs] Job client loaded.")
end)
