Mzansi = Mzansi or {}
Mzansi.HUD = Mzansi.HUD or {}

function Mzansi.HUD.notify(message, r, g, b)
    outputChatBox("[Mzansi-ZA] " .. tostring(message), r or 255, g or 204, b or 0)
end

addEventHandler("onClientRender", root, function()
    if not getElementData(localPlayer, "mzansi:character") then
        return
    end

    local character = getElementData(localPlayer, "mzansi:character")
    if not character then
        return
    end

    local x, y = 20, 20
    local nameText = character.first_name .. " " .. character.last_name
    dxDrawText(nameText, x, y, x + 400, y + 30, tocolor(255, 255, 255, 255), 1.1, "default-bold")
    dxDrawText("Cash: $" .. tostring(character.money or 0), x, y + 25, x + 400, y + 55, tocolor(0, 255, 140, 255), 1, "default")
    dxDrawText("Bank: $" .. tostring(character.bank or 0), x, y + 45, x + 400, y + 75, tocolor(255, 255, 255, 255), 1, "default")
end)
