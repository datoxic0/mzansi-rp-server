Mzansi = Mzansi or {}
Mzansi.Drugs = Mzansi.Drugs or {}
Mzansi.Drugs._growBlips = {}
Mzansi.Drugs._plantObjects = {}

function Mzansi.Drugs.plantSeed(drugId, locationId)
    triggerServerEvent("mzansi:drugs:plant", localPlayer, drugId, locationId)
end

function Mzansi.Drugs.harvestPlant(locationId, plantId)
    triggerServerEvent("mzansi:drugs:harvest", localPlayer, locationId, plantId)
end

function Mzansi.Drugs.useDrug(drugId)
    triggerServerEvent("mzansi:drugs:use", localPlayer, drugId)
end

function Mzansi.Drugs.sellDrugs(drugId, amount)
    triggerServerEvent("mzansi:drugs:sell", localPlayer, drugId, amount)
end

function Mzansi.Drugs.startTraffic(routeId)
    triggerServerEvent("mzansi:drugs:traffic", localPlayer, routeId)
end

function Mzansi.Drugs.processDrugs(processId)
    triggerServerEvent("mzansi:drugs:process", localPlayer, processId)
end

function Mzansi.Drugs.renderGrowLocations()
    for _, loc in ipairs(Mzansi.Drugs.Config.GrowLocations) do
        local dist = Mzansi.Util.distance(localPlayer,
            loc.x, loc.y, loc.z
        )

        if dist < 100 then
            local pulse = math.sin(getTickCount() / 400) * 0.3 + 0.7
            dxDrawCircle3D(loc.x, loc.y, loc.z - 1, loc.radius * 0.3, tocolor(0, 200, 0, pulse * 30))

            if dist < 10 then
                dxDrawText("GROW OP: " .. loc.name, loc.x - 100, loc.y, loc.x + 100, loc.z + 2, tocolor(0, 200, 0, 255), 1.1, "default-bold", "center", "center")
                dxDrawText("Slots: " .. loc.slots, loc.x - 75, loc.y, loc.x + 75, loc.z + 3, tocolor(200, 200, 200, 200), 0.8, "default", "center", "center")
                dxDrawText("Press E to plant / H to harvest", loc.x - 100, loc.y, loc.x + 100, loc.z + 4, tocolor(200, 170, 50, 180), 0.7, "default", "center", "center")
            end
        end
    end
end

function Mzansi.Drugs.renderProcessingLocations()
    for _, process in ipairs(Mzansi.Drugs.Config.Processing) do
        local loc = process.location
        local dist = Mzansi.Util.distance(localPlayer,
            loc.x, loc.y, loc.z
        )

        if dist < 50 then
            local pulse = math.sin(getTickCount() / 500) * 0.3 + 0.7
            dxDrawCircle3D(loc.x, loc.y, loc.z - 1, 2, tocolor(200, 100, 0, pulse * 60))

            if dist < 5 then
                dxDrawText("PROCESS: " .. process.name, loc.x - 75, loc.y, loc.x + 75, loc.z + 2, tocolor(200, 100, 0, 255), 1.1, "default-bold", "center", "center")
                dxDrawText("Input: " .. process.input.amount .. "x " .. process.input.drug, loc.x - 75, loc.y, loc.x + 75, loc.z + 3, tocolor(200, 200, 200, 180), 0.7, "default", "center", "center")
                dxDrawText("Output: " .. process.output.amount .. "x " .. process.output.drug, loc.x - 75, loc.y, loc.x + 75, loc.z + 4, tocolor(0, 200, 0, 180), 0.7, "default", "center", "center")
                dxDrawText("Press E to process", loc.x - 50, loc.y, loc.x + 50, loc.z + 5, tocolor(255, 150, 0, 180), 0.8, "default", "center", "center")
            end
        end
    end
end

function Mzansi.Drugs.renderTrafficLocations()
    for _, route in ipairs(Mzansi.Drugs.Config.TrafficRoutes) do
        local loc = route.start
        local dist = Mzansi.Util.distance(localPlayer,
            loc.x, loc.y, loc.z
        )

        if dist < 50 then
            local pulse = math.sin(getTickCount() / 600) * 0.3 + 0.7
            dxDrawCircle3D(loc.x, loc.y, loc.z - 1, 2, tocolor(200, 0, 200, pulse * 60))

            if dist < 5 then
                dxDrawText("TRAFFIC: " .. route.name, loc.x - 75, loc.y, loc.x + 75, loc.z + 2, tocolor(200, 0, 200, 255), 1.1, "default-bold", "center", "center")
                dxDrawText("Dropoffs: " .. #route.dropoffs, loc.x - 75, loc.y, loc.x + 75, loc.z + 3, tocolor(200, 200, 200, 180), 0.7, "default", "center", "center")
                dxDrawText("Press E to start run", loc.x - 50, loc.y, loc.x + 50, loc.z + 4, tocolor(255, 150, 0, 180), 0.8, "default", "center", "center")
            end
        end
    end
end

function Mzansi.Drugs.renderDrugEffects()
    local screenW, screenH = guiGetScreenSize()

    dxDrawRectangle(0, 0, screenW, screenH, tocolor(0, 0, 0, 50), true)

    local vignette = math.sin(getTickCount() / 500) * 20 + 40
    dxDrawRectangle(0, 0, screenW, vignette, tocolor(0, 0, 0, vignette), true)
    dxDrawRectangle(0, screenH - vignette, screenW, vignette, tocolor(0, 0, 0, vignette), true)
end

addEventHandler("onClientRender", root, function()
    Mzansi.Drugs.renderGrowLocations()
    Mzansi.Drugs.renderProcessingLocations()
    Mzansi.Drugs.renderTrafficLocations()

    local activeEffect = getElementData(localPlayer, "mzansi:drugEffect")
    if activeEffect then
        Mzansi.Drugs.renderDrugEffects()
    end
end)

addCommandHandler("drugs", function(cmd, action, ...)
    local args = {...}
    if action == "plant" then
        local drugId = args[1] or "weed"
        local locationId = tonumber(args[2]) or 1
        Mzansi.Drugs.plantSeed(drugId, locationId)
    elseif action == "harvest" then
        local locationId = tonumber(args[1]) or 1
        local plantId = tonumber(args[2]) or 1
        Mzansi.Drugs.harvestPlant(locationId, plantId)
    elseif action == "use" then
        local drugId = args[1] or "weed"
        Mzansi.Drugs.useDrug(drugId)
    elseif action == "sell" then
        local drugId = args[1] or "weed"
        local amount = tonumber(args[2]) or 1
        Mzansi.Drugs.sellDrugs(drugId, amount)
    elseif action == "traffic" then
        local routeId = tonumber(args[1]) or 1
        Mzansi.Drugs.startTraffic(routeId)
    elseif action == "process" then
        local processId = tonumber(args[1]) or 1
        Mzansi.Drugs.processDrugs(processId)
    else
        outputChatBox("[DRUGS] Commands:", 0, 200, 0)
        outputChatBox("  /drugs plant [drug] [location] - Plant seeds", 200, 200, 200)
        outputChatBox("  /drugs harvest [location] [plant] - Harvest plants", 200, 200, 200)
        outputChatBox("  /drugs use [drug] - Use drugs", 200, 200, 200)
        outputChatBox("  /drugs sell [drug] [amount] - Sell drugs", 200, 200, 200)
        outputChatBox("  /drugs traffic [route] - Start traffic run", 200, 200, 200)
        outputChatBox("  /drugs process [id] - Process drugs", 200, 200, 200)
    end
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
    outputDebugString("[Mzansi-Drugs] Drug client loaded.")
end)
