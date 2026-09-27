Mzansi = Mzansi or {}
Mzansi.Housing = Mzansi.Housing or {}

function Mzansi.Housing.buyProperty(propertyId)
    triggerServerEvent("mzansi:housing:buy", localPlayer, propertyId)
end

function Mzansi.Housing.sellProperty(propertyId)
    triggerServerEvent("mzansi:housing:sell", localPlayer, propertyId)
end

function Mzansi.Housing.toggleLock()
    triggerServerEvent("mzansi:housing:lock", localPlayer)
end

function Mzansi.Housing.enterProperty()
    triggerServerEvent("mzansi:housing:enter", localPlayer)
end

function Mzansi.Housing.exitProperty()
    triggerServerEvent("mzansi:housing:exit", localPlayer)
end

function Mzansi.Housing.renderPropertyMarkers()
    local px, py, pz = getElementPosition(localPlayer)
    for _, prop in ipairs(Mzansi.Housing.Config.Properties) do
        local dist = Mzansi.Util.distance(px, py, pz, prop.x, prop.y, prop.z)

        if dist < 100 then
            local color = prop.type == Mzansi.Enums.PropertyType.HOUSE and tocolor(0, 200, 100, 100) or
                         prop.type == Mzansi.Enums.PropertyType.BUSINESS and tocolor(200, 200, 0, 100) or
                         tocolor(0, 150, 255, 100)

            dxDrawCircle3D(prop.x, prop.y, prop.z - 1, 1, color)

            if dist < 5 then
                local typeLabel = prop.type == Mzansi.Enums.PropertyType.HOUSE and "House" or
                                 prop.type == Mzansi.Enums.PropertyType.BUSINESS and "Business" or "Garage"

                dxDrawText(prop.name, prop.x - 75, prop.y, prop.x + 75, prop.z + 2, tocolor(255, 215, 0, 255), 1, "default-bold", "center", "center")
                dxDrawText(typeLabel .. " - " .. Mzansi.Util.formatMoney(prop.price), prop.x - 75, prop.y, prop.x + 75, prop.z + 3, tocolor(200, 200, 200, 200), 0.8, "default", "center", "center")
                dxDrawText("Press E to enter / B to buy", prop.x - 75, prop.y, prop.x + 75, prop.z + 4, tocolor(200, 200, 200, 150), 0.7, "default", "center", "center")
            end
        end
    end
end

addEventHandler("onClientRender", root, function()
    Mzansi.Housing.renderPropertyMarkers()
end)

addCommandHandler("house", function(cmd, action)
    local px, py, pz = getElementPosition(localPlayer)
    if action == "buy" then
        for _, prop in ipairs(Mzansi.Housing.Config.Properties) do
            local dist = Mzansi.Util.distance(px, py, pz, prop.x, prop.y, prop.z)
            if dist < 5 then
                Mzansi.Housing.buyProperty(prop.id)
                return
            end
        end
        Mzansi.Util.notify("No property nearby.", "error")
    elseif action == "sell" then
        for _, prop in ipairs(Mzansi.Housing.Config.Properties) do
            local dist = Mzansi.Util.distance(px, py, pz, prop.x, prop.y, prop.z)
            if dist < 5 then
                Mzansi.Housing.sellProperty(prop.id)
                return
            end
        end
        Mzansi.Util.notify("No property nearby.", "error")
    elseif action == "lock" then
        Mzansi.Housing.toggleLock()
    elseif action == "enter" then
        Mzansi.Housing.enterProperty()
    elseif action == "exit" then
        Mzansi.Housing.exitProperty()
    else
        outputChatBox("[Housing] Usage: /house [buy|sell|lock|enter|exit]", 200, 170, 50)
    end
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
    outputDebugString("[Mzansi-Housing] Housing client loaded.")
end)
