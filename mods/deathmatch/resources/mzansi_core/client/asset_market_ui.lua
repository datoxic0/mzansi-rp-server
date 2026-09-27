Mzansi = Mzansi or {}
Mzansi.MarketUI = Mzansi.MarketUI or {}
Mzansi.MarketUI._visible = false
Mzansi.MarketUI._tab = "cars"
Mzansi.MarketUI._selected = 1
Mzansi.MarketUI._scroll = 0
Mzansi.MarketUI._anim = 0
Mzansi.MarketUI._catalog = nil
Mzansi.MarketUI._portfolio = nil

local FONT_TITLE = "default-bold"
local FONT_BODY = "default"
local FONT_SMALL = "default-small"

local TABS = {
    { id = "cars", name = "Cars" },
    { id = "boats", name = "Boats" },
    { id = "planes", name = "Aircraft" },
    { id = "invest", name = "Invest" },
    { id = "owned", name = "My Assets" },
}

local KIND_FOR_TAB = {
    cars = "car",
    boats = "boat",
    planes = "plane",
}

local function screen()
    return guiGetScreenSize()
end

local function mouseIn(x, y, w, h)
    local mx, my = getCursorPosition()
    if not mx or not my then return false end
    local sx, sy = screen()
    mx, my = mx * sx, my * sy
    return mx >= x and mx <= x + w and my >= y and my <= y + h
end

local function closeOthers()
    triggerEvent("mzansi:phone:close", localPlayer)
    triggerEvent("mzansi:radio:close", localPlayer)
    triggerEvent("mzansi:freeroam:close", localPlayer)
    triggerEvent("mzansi:admin:close", localPlayer)
    triggerEvent("mzansi:dashboard:close", localPlayer)
    triggerEvent("mzansi:flight:close", localPlayer)
    triggerEvent("mzansi:bank:close", localPlayer)
    triggerEvent("mzansi:shop:closeUI", localPlayer)
end

function Mzansi.MarketUI.open()
    if Mzansi.Cutscene and Mzansi.Cutscene.isPlaying() then return end
    if isChatBoxInputActive() or isConsoleActive() then return end
    if Mzansi.MarketUI._visible then return end
    closeOthers()
    Mzansi.MarketUI._visible = true
    Mzansi.MarketUI._anim = 0
    Mzansi.MarketUI._selected = 1
    Mzansi.MarketUI._scroll = 0
    showCursor(true)
    playSoundFrontEnd(41)
    triggerServerEvent("mzansi:market:requestCatalog", localPlayer)
    triggerServerEvent("mzansi:market:requestPortfolio", localPlayer)
end

function Mzansi.MarketUI.close()
    if not Mzansi.MarketUI._visible then return end
    Mzansi.MarketUI._visible = false
    Mzansi.MarketUI._anim = 0
    showCursor(false)
    playSoundFrontEnd(42)
end

function Mzansi.MarketUI.toggle()
    if Mzansi.MarketUI._visible then
        Mzansi.MarketUI.close()
    else
        Mzansi.MarketUI.open()
    end
end

addEvent("mzansi:market:openUI", true)
addEventHandler("mzansi:market:openUI", root, function()
    Mzansi.MarketUI.open()
end)

addEvent("mzansi:market:close", true)
addEventHandler("mzansi:market:close", root, function()
    Mzansi.MarketUI.close()
end)

addEvent("mzansi:market:setCatalog", true)
addEventHandler("mzansi:market:setCatalog", root, function(catalog)
    if type(catalog) == "table" then
        Mzansi.MarketUI._catalog = catalog
    end
end)

addEvent("mzansi:market:setPortfolio", true)
addEventHandler("mzansi:market:setPortfolio", root, function(portfolio)
    if type(portfolio) == "table" then
        Mzansi.MarketUI._portfolio = portfolio
    end
end)

bindKey("f5", "down", function()
    if Mzansi.Util and Mzansi.Util.bindBlocked and Mzansi.Util.bindBlocked() then return end
    if Mzansi.Cutscene and Mzansi.Cutscene.isPlaying() then return end
    Mzansi.MarketUI.toggle()
end)

bindKey("x", "down", function()
    if Mzansi.MarketUI._visible then
        Mzansi.MarketUI.close()
    end
end)

addCommandHandler("marketui", function()
    Mzansi.MarketUI.toggle()
end)

local function currentList()
    local cat = Mzansi.MarketUI._catalog
    if not cat then return {} end
    if Mzansi.MarketUI._tab == "cars" then return cat.vehicles and cat.vehicles.car or {} end
    if Mzansi.MarketUI._tab == "boats" then return cat.vehicles and cat.vehicles.boat or {} end
    if Mzansi.MarketUI._tab == "planes" then return cat.vehicles and cat.vehicles.plane or {} end
    if Mzansi.MarketUI._tab == "invest" then return cat.investments or {} end
    if Mzansi.MarketUI._tab == "owned" then
        local p = Mzansi.MarketUI._portfolio
        return p and p.vehicles or {}
    end
    return {}
end

addEventHandler("onClientRender", root, function()
    if not Mzansi.MarketUI._visible then return end

    local sx, sy = screen()
    local w, h = 880, 560
    local x = (sx - w) / 2
    local y = (sy - h) / 2
    Mzansi.MarketUI._anim = math.min(1, Mzansi.MarketUI._anim + 0.08)

    dxDrawRectangle(0, 0, sx, sy, tocolor(5, 10, 18, 150), false)
    dxDrawRectangle(x, y, w, h, tocolor(10, 18, 30, 250), false)
    dxDrawRectangle(x, y, w, 3, tocolor(200, 170, 50, 255), false)
    dxDrawRectangle(x, y, w, 50, tocolor(15, 26, 44, 255), false)
    dxDrawText("MZANSI ASSET MARKET", x + 25, y, x + w - 160, y + 50, tocolor(200, 170, 50, 255), 1.1, FONT_TITLE, "left", "center")
    dxDrawText("[F5 or X to Close]", x + w - 150, y, x + w - 25, y + 50, tocolor(150, 170, 190, 200), 0.9, FONT_TITLE, "right", "center")

    local cat = Mzansi.MarketUI._catalog
    local port = Mzansi.MarketUI._portfolio
    if cat then
        dxDrawText("Cash: " .. Mzansi.Util.formatMoney(cat.cash or 0) .. "   |   Bank: " .. Mzansi.Util.formatMoney(cat.bank or 0) .. "   |   Vehicles: " .. tostring(cat.vehicleCount or 0) .. "/" .. tostring(cat.maxVehicles or 4), x + 25, y + 52, x + w - 25, y + 74, tocolor(170, 200, 230, 255), 0.9, FONT_BODY, "left", "center")
    end

    local tabX = x + 20
    local tabY = y + 80
    local tabW = (w - 40) / #TABS
    for _, tab in ipairs(TABS) do
        local active = Mzansi.MarketUI._tab == tab.id
        local hover = mouseIn(tabX, tabY, tabW - 4, 32)
        local bg = active and tocolor(200, 170, 50, 255) or (hover and tocolor(25, 45, 75, 255) or tocolor(18, 30, 50, 200))
        local fg = active and tocolor(10, 18, 30, 255) or tocolor(220, 230, 240, 255)
        dxDrawRectangle(tabX, tabY, tabW - 4, 32, bg, false)
        dxDrawText(tab.name, tabX, tabY, tabX + tabW - 4, tabY + 32, fg, 0.85, FONT_TITLE, "center", "center")
        tabX = tabX + tabW
    end

    local contX = x + 20
    local contY = y + 122
    local contW = w - 40
    local contH = h - 142
    dxDrawRectangle(contX, contY, contW, contH, tocolor(14, 22, 36, 230), false)

    local list = currentList()
    if Mzansi.MarketUI._selected > #list then
        Mzansi.MarketUI._selected = math.max(1, #list)
    end

    if Mzansi.MarketUI._tab == "invest" then
        dxDrawText("INVESTMENT PRODUCTS (interest accrues from bank)", contX + 15, contY + 8, contX + contW - 15, contY + 28, tocolor(200, 170, 50, 255), 0.9, FONT_TITLE, "left", "top")
        local iy = contY + 36
        for i, inv in ipairs(list) do
            local selected = Mzansi.MarketUI._selected == i
            local bg = selected and tocolor(30, 55, 90, 240) or tocolor(18, 28, 44, 220)
            dxDrawRectangle(contX + 15, iy, contW - 30, 64, bg, false)
            dxDrawText(inv.name, contX + 28, iy + 8, contX + contW - 200, iy + 28, tocolor(255, 255, 255, 255), 0.95, FONT_TITLE, "left", "top")
            dxDrawText(inv.desc, contX + 28, iy + 30, contX + contW - 200, iy + 55, tocolor(170, 185, 200, 255), 0.8, FONT_BODY, "left", "top")
            dxDrawText("Risk: " .. tostring(inv.risk) .. "   |   Yield/cycle: " .. string.format("%.2f%%", (inv.rate or 0) * 100) .. "   |   Min: " .. Mzansi.Util.formatMoney(inv.min or 0), contX + 28, iy + 48, contX + contW - 130, iy + 62, tocolor(120, 220, 160, 230), 0.75, FONT_SMALL, "left", "top")
            local bx = contX + contW - 175
            dxDrawRectangle(bx, iy + 16, 75, 32, tocolor(40, 140, 80, 255), false)
            dxDrawText("INVEST", bx, iy + 16, bx + 75, iy + 48, tocolor(255, 255, 255, 255), 0.85, FONT_TITLE, "center", "center")
            dxDrawRectangle(bx + 82, iy + 16, 60, 32, tocolor(40, 100, 180, 255), false)
            dxDrawText("AMT", bx + 82, iy + 16, bx + 142, iy + 48, tocolor(255, 255, 255, 255), 0.85, FONT_TITLE, "center", "center")
            iy = iy + 70
        end
        if #list == 0 then
            dxDrawText("No investment products available.", contX, contY + 40, contX + contW, contY + 80, tocolor(150, 170, 190, 255), 0.9, FONT_BODY, "center", "top")
        end
        return
    end

    if Mzansi.MarketUI._tab == "owned" then
        dxDrawText("OWNED ASSETS", contX + 15, contY + 8, contX + contW - 15, contY + 28, tocolor(200, 170, 50, 255), 0.9, FONT_TITLE, "left", "top")
        local oy = contY + 36
        local vehicles = (port and port.vehicles) or {}
        for i, v in ipairs(vehicles) do
            local selected = Mzansi.MarketUI._selected == i
            local bg = selected and tocolor(30, 55, 90, 240) or tocolor(18, 28, 44, 220)
            dxDrawRectangle(contX + 15, oy, contW - 30, 52, bg, false)
            local kindName = (v.kind == "boat" and "Boat") or (v.kind == "plane" and "Aircraft") or "Car"
            dxDrawText(kindName .. "  Model " .. tostring(v.model) .. "  [" .. tostring(v.plate) .. "]", contX + 28, oy + 8, contX + contW - 200, oy + 28, tocolor(255, 255, 255, 255), 0.9, FONT_TITLE, "left", "top")
            dxDrawText("Fuel " .. math.floor(v.fuel or 0) .. "%   Health " .. math.floor(v.health or 0) .. "   Odo " .. math.floor(v.mileage or 0) .. " km", contX + 28, oy + 28, contX + contW - 200, oy + 48, tocolor(170, 185, 200, 255), 0.8, FONT_BODY, "left", "top")
            local sxBtn = contX + contW - 110
            dxDrawRectangle(sxBtn, oy + 10, 85, 32, tocolor(180, 50, 50, 255), false)
            dxDrawText("SELL", sxBtn, oy + 10, sxBtn + 85, oy + 42, tocolor(255, 255, 255, 255), 0.85, FONT_TITLE, "center", "center")
            oy = oy + 58
        end

        local props = (port and port.properties) or {}
        dxDrawText("PROPERTIES (" .. #props .. "/" .. tostring(port and port.maxHouses or 2) .. ")", contX + 15, oy + 8, contX + contW - 15, oy + 28, tocolor(200, 170, 50, 255), 0.9, FONT_TITLE, "left", "top")
        oy = oy + 34
        for _, p in ipairs(props) do
            dxDrawText("- " .. tostring(p.name) .. "  (" .. Mzansi.Util.formatMoney(p.price or 0) .. ")", contX + 28, oy, contX + contW - 20, oy + 20, tocolor(180, 220, 180, 255), 0.85, FONT_BODY, "left", "top")
            oy = oy + 22
        end

        local invs = (port and port.investments) or {}
        dxDrawText("INVESTMENTS", contX + 15, oy + 8, contX + contW - 15, oy + 28, tocolor(200, 170, 50, 255), 0.9, FONT_TITLE, "left", "top")
        oy = oy + 34
        for _, inv in ipairs(invs) do
            dxDrawText("- " .. tostring(inv.key) .. "  principal " .. Mzansi.Util.formatMoney(inv.principal or 0) .. "  + interest " .. Mzansi.Util.formatMoney(inv.accrued or 0), contX + 28, oy, contX + contW - 200, oy + 20, tocolor(180, 210, 255, 255), 0.85, FONT_BODY, "left", "top")
            local cbx = contX + contW - 170
            dxDrawRectangle(cbx, oy - 2, 70, 24, tocolor(40, 140, 80, 255), false)
            dxDrawText("CLAIM", cbx, oy - 2, cbx + 70, oy + 22, tocolor(255, 255, 255, 255), 0.75, FONT_TITLE, "center", "center")
            dxDrawRectangle(cbx + 75, oy - 2, 70, 24, tocolor(180, 80, 40, 255), false)
            dxDrawText("EXIT", cbx + 75, oy - 2, cbx + 145, oy + 22, tocolor(255, 255, 255, 255), 0.75, FONT_TITLE, "center", "center")
            oy = oy + 28
        end

        if #vehicles == 0 and #props == 0 and #invs == 0 then
            dxDrawText("No assets yet. Buy from Cars / Boats / Aircraft / Invest tabs.", contX, contY + 50, contX + contW, contY + 90, tocolor(150, 170, 190, 255), 0.9, FONT_BODY, "center", "top")
        end
        return
    end

    -- Catalog tabs (cars/boats/planes)
    dxDrawText(string.upper(Mzansi.MarketUI._tab) .. " FOR SALE", contX + 15, contY + 8, contX + contW - 15, contY + 28, tocolor(200, 170, 50, 255), 0.9, FONT_TITLE, "left", "top")

    local rowH = 46
    local visible = math.floor((contH - 80) / rowH)
    if Mzansi.MarketUI._scroll > math.max(0, #list - visible) then
        Mzansi.MarketUI._scroll = math.max(0, #list - visible)
    end

    local iy = contY + 36
    for i = 1, visible do
        local idx = Mzansi.MarketUI._scroll + i
        local entry = list[idx]
        if not entry then break end
        local selected = Mzansi.MarketUI._selected == idx
        local afford = (cat and (cat.cash or 0) >= (entry.price or 0))
        local bg = selected and tocolor(30, 55, 90, 240) or tocolor(18, 28, 44, 220)
        dxDrawRectangle(contX + 15, iy, contW - 30, rowH - 4, bg, false)
        dxDrawText(entry.name, contX + 28, iy + 6, contX + contW - 220, iy + 26, tocolor(255, 255, 255, 255), 0.95, FONT_TITLE, "left", "top")
        dxDrawText((entry.class or "") .. "  |  Model " .. tostring(entry.model), contX + 28, iy + 24, contX + contW - 220, iy + 42, tocolor(160, 180, 200, 255), 0.78, FONT_BODY, "left", "top")
        local priceCol = afford and tocolor(120, 230, 150, 255) or tocolor(255, 120, 120, 255)
        dxDrawText(Mzansi.Util.formatMoney(entry.price or 0), contX + contW - 330, iy + 8, contX + contW - 120, iy + 36, priceCol, 1.0, FONT_TITLE, "right", "center")
        dxDrawRectangle(contX + contW - 110, iy + 8, 85, 30, afford and tocolor(40, 150, 90, 255) or tocolor(70, 70, 70, 255), false)
        dxDrawText("BUY", contX + contW - 110, iy + 8, contX + contW - 25, iy + 38, tocolor(255, 255, 255, 255), 0.85, FONT_TITLE, "center", "center")
        iy = iy + rowH
    end

    if #list == 0 then
        dxDrawText("Catalog empty.", contX, contY + 50, contX + contW, contY + 90, tocolor(150, 170, 190, 255), 0.9, FONT_BODY, "center", "top")
    elseif #list > visible then
        dxDrawText("Scroll with mouse wheel  (" .. math.min(Mzansi.MarketUI._scroll + 1, #list) .. "-" .. math.min(Mzansi.MarketUI._scroll + visible, #list) .. " of " .. #list .. ")", contX + 15, contY + contH - 28, contX + contW - 15, contY + contH - 8, tocolor(140, 160, 180, 220), 0.8, FONT_SMALL, "left", "center")
    end
end)

addEventHandler("onClientKey", root, function(button, pressed)
    if not Mzansi.MarketUI._visible then return end
    if button == "mouse_wheel_up" and pressed then
        Mzansi.MarketUI._scroll = math.max(0, Mzansi.MarketUI._scroll - 1)
        cancelEvent()
    elseif button == "mouse_wheel_down" and pressed then
        Mzansi.MarketUI._scroll = Mzansi.MarketUI._scroll + 1
        cancelEvent()
    elseif button == "escape" and pressed then
        Mzansi.MarketUI.close()
        cancelEvent()
    end
end)

addEventHandler("onClientClick", root, function(button, state)
    if not Mzansi.MarketUI._visible then return end
    if button ~= "left" or state ~= "down" then return end

    local sx, sy = screen()
    local w, h = 880, 560
    local x = (sx - w) / 2
    local y = (sy - h) / 2
    local contX = x + 20
    local contY = y + 122
    local contW = w - 40
    local contH = h - 142

    local tabX = x + 20
    local tabY = y + 80
    local tabW = (w - 40) / #TABS
    for _, tab in ipairs(TABS) do
        if mouseIn(tabX, tabY, tabW - 4, 32) then
            Mzansi.MarketUI._tab = tab.id
            Mzansi.MarketUI._selected = 1
            Mzansi.MarketUI._scroll = 0
            playSoundFrontEnd(40)
            return
        end
        tabX = tabX + tabW
    end

    if Mzansi.MarketUI._tab == "invest" then
        local list = currentList()
        local iy = contY + 36
        for i, inv in ipairs(list) do
            local bx = contX + contW - 175
            if mouseIn(bx, iy + 16, 75, 32) then
                Mzansi.MarketUI._selected = i
                Mzansi.Modal.prompt(
                    "Invest in " .. inv.name,
                    "Minimum " .. Mzansi.Util.formatMoney(inv.min) .. ". Enter amount from bank:",
                    tostring(inv.min),
                    function(amount)
                        local n = tonumber(amount)
                        if n then
                            triggerServerEvent("mzansi:market:invest", localPlayer, inv.key, n)
                        end
                    end
                )
                return
            end
            if mouseIn(bx + 82, iy + 16, 60, 32) then
                Mzansi.MarketUI._selected = i
                Mzansi.Modal.prompt(
                    "Quick Invest " .. inv.name,
                    "Enter amount:",
                    tostring(inv.min),
                    function(amount)
                        local n = tonumber(amount)
                        if n then
                            triggerServerEvent("mzansi:market:invest", localPlayer, inv.key, n)
                        end
                    end
                )
                return
            end
            if mouseIn(contX + 15, iy, contW - 30, 64) then
                Mzansi.MarketUI._selected = i
            end
            iy = iy + 70
        end
        return
    end

    if Mzansi.MarketUI._tab == "owned" then
        local port = Mzansi.MarketUI._portfolio
        local vehicles = (port and port.vehicles) or {}
        local oy = contY + 36
        for i, v in ipairs(vehicles) do
            local sxBtn = contX + contW - 110
            if mouseIn(sxBtn, oy + 10, 85, 32) then
                triggerServerEvent("mzansi:market:sellVehicle", localPlayer, v.id)
                return
            end
            if mouseIn(contX + 15, oy, contW - 30, 52) then
                Mzansi.MarketUI._selected = i
            end
            oy = oy + 58
        end

        local props = (port and port.properties) or {}
        oy = oy + 42 + #props * 22
        local invs = (port and port.investments) or {}
        oy = oy + 34
        for _, inv in ipairs(invs) do
            local cbx = contX + contW - 170
            if mouseIn(cbx, oy - 2, 70, 24) then
                triggerServerEvent("mzansi:market:claimInterest", localPlayer, inv.id)
                return
            end
            if mouseIn(cbx + 75, oy - 2, 70, 24) then
                triggerServerEvent("mzansi:market:withdraw", localPlayer, inv.id)
                return
            end
            oy = oy + 28
        end
        return
    end

    local list = currentList()
    local rowH = 46
    local visible = math.floor((contH - 80) / rowH)
    local iy = contY + 36
    for i = 1, visible do
        local idx = Mzansi.MarketUI._scroll + i
        local entry = list[idx]
        if not entry then break end
        if mouseIn(contX + contW - 110, iy + 8, 85, 30) then
            local kind = KIND_FOR_TAB[Mzansi.MarketUI._tab]
            if kind then
                triggerServerEvent("mzansi:market:buyVehicle", localPlayer, kind, entry.model)
            end
            return
        end
        if mouseIn(contX + 15, iy, contW - 30, rowH - 4) then
            Mzansi.MarketUI._selected = idx
        end
        iy = iy + rowH
    end
end)
