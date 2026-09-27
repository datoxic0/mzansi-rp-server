Mzansi = Mzansi or {}
Mzansi.IllegalMarket = Mzansi.IllegalMarket or {}
Mzansi.IllegalMarket._dealerBlips = {}

function Mzansi.IllegalMarket.buyItem(locationId, itemId)
    triggerServerEvent("mzansi:illegalmarket:buy", localPlayer, locationId, itemId)
end

function Mzansi.IllegalMarket.sellFence(itemName)
    triggerServerEvent("mzansi:illegalmarket:sell", localPlayer, itemName)
end

function Mzansi.IllegalMarket.chopVehicle(vehicle)
    triggerServerEvent("mzansi:illegalmarket:chop", localPlayer, vehicle)
end

function Mzansi.IllegalMarket.sellDrugs(drugId, amount)
    triggerServerEvent("mzansi:illegalmarket:fence", localPlayer, drugId, amount)
end

function Mzansi.IllegalMarket.renderDealerLocations()
    for _, location in ipairs(Mzansi.IllegalMarket.Config.Locations) do
        local dist = Mzansi.Util.distance(localPlayer,
            location.x, location.y, location.z
        )

        if dist < 80 then
            local pulse = math.sin(getTickCount() / 400) * 0.3 + 0.7
            local color = tocolor(150, 0, 200, pulse * 60)

            if location.id == 1 then color = tocolor(255, 0, 0, pulse * 60)
            elseif location.id == 3 then color = tocolor(255, 150, 0, pulse * 60)
            elseif location.id == 4 then color = tocolor(0, 200, 0, pulse * 60)
            elseif location.id == 5 then color = tocolor(255, 0, 0, pulse * 80)
            elseif location.id == 6 then color = tocolor(200, 100, 0, pulse * 60)
            end

            dxDrawCircle3D(location.x, location.y, location.z - 1, 2, color)

            if dist < location.radius then
                dxDrawText(location.name, location.x - 100, location.y, location.x + 100, location.z + 2, tocolor(200, 0, 200, 255), 1.1, "default-bold", "center", "center")
                dxDrawText(location.description, location.x - 100, location.y, location.x + 100, location.z + 3, tocolor(200, 200, 200, 200), 0.8, "default", "center", "center")
                dxDrawText("Press E to browse", location.x - 75, location.y, location.x + 75, location.z + 4, tocolor(200, 170, 50, 180), 0.7, "default", "center", "center")
            end
        end
    end
end

function Mzansi.IllegalMarket.renderChopShop()
    local chopLocation = nil
    for _, loc in ipairs(Mzansi.IllegalMarket.Config.Locations) do
        if loc.id == 6 then
            chopLocation = loc
            break
        end
    end

    if not chopLocation then return end

    local dist = Mzansi.Util.distance(localPlayer,
        chopLocation.x, chopLocation.y, chopLocation.z
        )

    if dist < 50 then
        local pulse = math.sin(getTickCount() / 300) * 0.3 + 0.7
        dxDrawCircle3D(chopLocation.x, chopLocation.y, chopLocation.z - 1, chopLocation.radius * 0.5, tocolor(200, 100, 0, pulse * 40))

        if dist < chopLocation.radius then
            local vehicle = getPedOccupiedVehicle(localPlayer)
            if vehicle then
                dxDrawText("Press E to chop vehicle", chopLocation.x - 100, chopLocation.y, chopLocation.x + 100, chopLocation.z + 5, tocolor(255, 100, 0, 200), 1, "default-bold", "center", "center")
            end
        end
    end
end

function Mzansi.IllegalMarket.renderIllegalHUD()
    local screenW, screenH = guiGetScreenSize()
    local x, y = screenW - 250, 200

    local wanted = getElementData(localPlayer, "mzansi:wantedLevel") or 0
    if wanted > 0 then
        dxDrawRectangle(x - 5, y - 5, 245, 30, tocolor(0, 0, 0, 150), true)
        dxDrawRectangle(x - 5, y - 5, 245, 2, tocolor(255, 0, 0, 255), true)
        dxDrawText("CRIMINAL RECORD", x, y, x + 235, y + 20, tocolor(255, 50, 50, 255), 0.9, "default-bold", "center", "center")
    end
end

addEventHandler("onClientRender", root, function()
    Mzansi.IllegalMarket.renderDealerLocations()
    Mzansi.IllegalMarket.renderChopShop()
    Mzansi.IllegalMarket.renderIllegalHUD()
end)

addCommandHandler("market", function(cmd, action, ...)
    local args = {...}
    if action == "buy" then
        local locationId = tonumber(args[1]) or 1
        local itemId = args[2] or "weapon"
        Mzansi.IllegalMarket.buyItem(locationId, itemId)
    elseif action == "sell" then
        local itemName = args[1] or "Stolen Phone"
        Mzansi.IllegalMarket.sellFence(itemName)
    elseif action == "chop" then
        local vehicle = getPedOccupiedVehicle(localPlayer)
        if vehicle then
            Mzansi.IllegalMarket.chopVehicle(vehicle)
        else
            Mzansi.Util.notify("You must be in a vehicle.", "error")
        end
    elseif action == "drugs" then
        local drugId = args[1] or "weed"
        local amount = tonumber(args[2]) or 1
        Mzansi.IllegalMarket.sellDrugs(drugId, amount)
    else
        outputChatBox("[ILLEGAL MARKET] Commands:", 200, 0, 200)
        outputChatBox("  /market buy [location] [item] - Buy illegal items", 200, 200, 200)
        outputChatBox("  /market sell [item] - Sell stolen goods", 200, 200, 200)
        outputChatBox("  /market chop - Chop a vehicle", 200, 200, 200)
        outputChatBox("  /market drugs [drug] [amount] - Sell drugs", 200, 200, 200)
    end
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
    outputDebugString("[Mzansi-IllegalMarket] Illegal market client loaded.")
end)
