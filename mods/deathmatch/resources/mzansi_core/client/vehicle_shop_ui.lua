Mzansi = Mzansi or {}
Mzansi.VehicleShopUI = Mzansi.VehicleShopUI or {}
Mzansi.VehicleShopUI._visible = false
Mzansi.VehicleShopUI._catalog = nil
Mzansi.VehicleShopUI._shopId = nil
Mzansi.VehicleShopUI._anim = 0
Mzansi.VehicleShopUI._scroll = 0
Mzansi.VehicleShopUI._selected = 1

local FONT_TITLE = "default-bold"
local FONT_BODY = "default"
local FONT_SMALL = "default-small"

local function screen()
    return guiGetScreenSize()
end

local function isMouseIn(mx, my, x, y, w, h)
    return mx >= x and mx <= x + w and my >= y and my <= y + h
end

local function closeOthers()
    triggerEvent("mzansi:phone:close", localPlayer)
    triggerEvent("mzansi:radio:close", localPlayer)
    triggerEvent("mzansi:freeroam:close", localPlayer)
    triggerEvent("mzansi:admin:close", localPlayer)
    triggerEvent("mzansi:dashboard:close", localPlayer)
    triggerEvent("mzansi:flight:close", localPlayer)
    triggerEvent("mzansi:market:close", localPlayer)
    triggerEvent("mzansi:bank:close", localPlayer)
    triggerEvent("mzansi:shop:closeUI", localPlayer)
end

function Mzansi.VehicleShopUI.open(shopId)
    if Mzansi.Cutscene and Mzansi.Cutscene.isPlaying() then return end
    if isChatBoxInputActive() or isConsoleActive() then return end
    if Mzansi.VehicleShopUI._visible then return end
    closeOthers()
    Mzansi.VehicleShopUI._visible = true
    Mzansi.VehicleShopUI._anim = 0
    Mzansi.VehicleShopUI._scroll = 0
    Mzansi.VehicleShopUI._selected = 1
    Mzansi.VehicleShopUI._shopId = shopId or "vshop_ls_1"
    showCursor(true)
    playSoundFrontEnd(41)
    triggerServerEvent("mzansi:vshop:open", localPlayer, Mzansi.VehicleShopUI._shopId)
end

function Mzansi.VehicleShopUI.close()
    if not Mzansi.VehicleShopUI._visible then return end
    Mzansi.VehicleShopUI._visible = false
    Mzansi.VehicleShopUI._anim = 0
    Mzansi.VehicleShopUI._shopId = nil
    showCursor(false)
    playSoundFrontEnd(42)
end

function Mzansi.VehicleShopUI.toggle(shopId)
    if Mzansi.VehicleShopUI._visible then
        Mzansi.VehicleShopUI.close()
    else
        Mzansi.VehicleShopUI.open(shopId)
    end
end

addEvent("mzansi:vshop:openUI", true)
addEventHandler("mzansi:vshop:openUI", root, function(shopId)
    Mzansi.VehicleShopUI.open(shopId)
end)

addEvent("mzansi:vshop:closeUI", true)
addEventHandler("mzansi:vshop:closeUI", root, function()
    Mzansi.VehicleShopUI.close()
end)

addEvent("mzansi:vshop:setCatalog", true)
addEventHandler("mzansi:vshop:setCatalog", root, function(cat)
    if type(cat) == "table" then
        Mzansi.VehicleShopUI._catalog = cat
    end
end)

bindKey("x", "down", function()
    if Mzansi.VehicleShopUI._visible then
        Mzansi.VehicleShopUI.close()
    end
end)

bindKey("mouse_wheel_up", "down", function()
    if not Mzansi.VehicleShopUI._visible then return end
    Mzansi.VehicleShopUI._scroll = math.max(0, Mzansi.VehicleShopUI._scroll - 1)
    Mzansi.VehicleShopUI._selected = math.max(1, Mzansi.VehicleShopUI._selected - 1)
end)

bindKey("mouse_wheel_down", "down", function()
    if not Mzansi.VehicleShopUI._visible then return end
    Mzansi.VehicleShopUI._scroll = Mzansi.VehicleShopUI._scroll + 1
    local list = Mzansi.VehicleShopUI._catalog and Mzansi.VehicleShopUI._catalog.vehicles or {}
    if Mzansi.VehicleShopUI._selected < #list then
        Mzansi.VehicleShopUI._selected = Mzansi.VehicleShopUI._selected + 1
    end
end)

addCommandHandler("vehicleshop", function()
    Mzansi.VehicleShopUI.toggle("vshop_ls_1")
end)

-- RENDER
addEventHandler("onClientRender", root, function()
    if not Mzansi.VehicleShopUI._visible then return end

    local sx, sy = screen()
    local w, h = 760, 500
    local x = (sx - w) / 2
    local y = (sy - h) / 2
    Mzansi.VehicleShopUI._anim = math.min(1, Mzansi.VehicleShopUI._anim + 0.08)

    local mx, my = getCursorPosition()
    mx, my = (mx or 0) * sx, (my or 0) * sy

    local accent = tocolor(0, 180, 200, 255)
    local gold = tocolor(218, 165, 32, 255)

    dxDrawRectangle(0, 0, sx, sy, tocolor(5, 10, 18, 150), false)
    dxDrawRectangle(x, y, w, h, tocolor(8, 16, 28, 250), false)
    dxDrawRectangle(x, y, w, 3, accent, false)
    dxDrawRectangle(x, y, w, 46, tocolor(12, 24, 40, 255), false)

    local shopName = Mzansi.VehicleShopUI._shopId or "Vehicle Shop"
    dxDrawText("MZANSI AUTO — VEHICLE MARKET", x + 20, y, x + w - 160, y + 46, accent, 1.1, FONT_TITLE, "left", "center")
    dxDrawText("[X to Close]", x + w - 150, y, x + w - 20, y + 46, tocolor(150, 170, 190, 200), 0.85, FONT_TITLE, "right", "center")

    local contentX = x + 20
    local contentY = y + 58
    local contentW = w - 40
    local contentH = h - 70

    local cat = Mzansi.VehicleShopUI._catalog
    if not cat then
        dxDrawText("Loading catalog...", contentX, contentY + contentH / 2, contentX + contentW, contentY + contentH / 2 + 20,
            tocolor(150, 170, 190), 1, FONT_BODY, "center", "center")
        return
    end

    dxDrawText("Cash: " .. Mzansi.Util.formatMoney(cat.cash or 0) ..
        "   |   Bank: " .. Mzansi.Util.formatMoney(cat.bank or 0) ..
        "   |   Owned: " .. tostring(cat.vehicleCount or 0) .. "/" .. tostring(cat.maxVehicles or 4),
        contentX, contentY, contentX + contentW, contentY + 22, tocolor(180, 200, 220, 255), 0.9, FONT_BODY, "left", "top")
    contentY = contentY + 28

    local vehicles = cat.vehicles or {}
    local list = vehicles.car or vehicles
    if type(list) ~= "table" then list = {} end

    local rowH = 34
    local maxRows = math.floor((contentH - 40) / rowH)
    local scroll = Mzansi.VehicleShopUI._scroll
    if scroll > math.max(0, #list - maxRows) then
        scroll = math.max(0, #list - maxRows)
        Mzansi.VehicleShopUI._scroll = scroll
    end

    dxDrawRectangle(contentX, contentY, contentW, 26, tocolor(20, 40, 65, 255), false)
    dxDrawText("MODEL", contentX + 10, contentY, contentX + 200, contentY + 26, tocolor(150, 170, 190, 255), 0.85, FONT_BODY, "left", "center")
    dxDrawText("CLASS", contentX + 220, contentY, contentX + 400, contentY + 26, tocolor(150, 170, 190, 255), 0.85, FONT_BODY, "left", "center")
    dxDrawText("PRICE", contentX + 420, contentY, contentX + contentW - 10, contentY + 26, tocolor(150, 170, 190, 255), 0.85, FONT_BODY, "right", "center")
    contentY = contentY + 28

    if #list == 0 then
        dxDrawText("No vehicles at this dealership.", contentX, contentY, contentX + contentW, contentY + 24,
            tocolor(130, 150, 170), 0.95, FONT_BODY, "left", "top")
    else
        for i = 1, maxRows do
            local idx = scroll + i
            if idx > #list then break end
            local v = list[idx]
            local ry = contentY + (i - 1) * rowH
            local selected = (idx == Mzansi.VehicleShopUI._selected)
            local bg = selected and tocolor(20, 50, 90, 255) or ((i % 2 == 0) and tocolor(15, 28, 45, 255) or tocolor(18, 32, 52, 255))
            dxDrawRectangle(contentX, ry, contentW, rowH - 2, bg, false)
            if selected then
                dxDrawRectangle(contentX, ry, 3, rowH - 2, accent, false)
            end
            dxDrawText(tostring(v.name or ("ID " .. tostring(v.model))), contentX + 10, ry, contentX + 200, ry + rowH - 2,
                tocolor(220, 230, 240, 255), 0.85, FONT_BODY, "left", "center")
            dxDrawText(tostring(v.class or "-"), contentX + 220, ry, contentX + 400, ry + rowH - 2,
                tocolor(150, 170, 190, 255), 0.85, FONT_SMALL, "left", "center")
            dxDrawText(Mzansi.Util.formatMoney(v.price or 0), contentX + 420, ry, contentX + contentW - 10, ry + rowH - 2,
                tocolor(80, 220, 100, 255), 0.9, FONT_BODY, "right", "center")
        end
    end

    -- Buy button
    local btnY = y + h - 50
    local btnX = contentX + contentW - 160
    local hover = isMouseIn(mx, my, btnX, btnY, 150, 36)
    dxDrawRectangle(btnX, btnY, 150, 36, hover and tocolor(50, 160, 70, 255) or tocolor(40, 130, 55, 255), false)
    dxDrawText("BUY SELECTED", btnX, btnY, btnX + 150, btnY + 36, tocolor(255, 255, 255, 255), 0.85, FONT_BODY, "center", "center")

    local goldY = y + h - 50
    dxDrawText("Gold key = selected vehicle • Scroll wheel to browse", contentX, goldY, contentX + 400, goldY + 36,
        tocolor(130, 150, 170, 255), 0.8, FONT_SMALL, "left", "center")
end)

addEventHandler("onClientClick", root, function(button, state, mx, my)
    if button ~= "left" or state ~= "down" then return end
    if not Mzansi.VehicleShopUI._visible then return end

    local sx, sy = screen()
    local w, h = 760, 500
    local x = (sx - w) / 2
    local y = (sy - h) / 2
    local contentX = x + 20
    local contentY = y + 58 + 28 + 28
    local contentW = w - 40

    local cat = Mzansi.VehicleShopUI._catalog
    if not cat then return end
    local vehicles = cat.vehicles or {}
    local list = vehicles.car or vehicles
    if type(list) ~= "table" then list = {} end

    local rowH = 34
    local contentH = h - 70
    local maxRows = math.floor((contentH - 40) / rowH)
    local scroll = Mzansi.VehicleShopUI._scroll

    for i = 1, maxRows do
        local idx = scroll + i
        if idx > #list then break end
        local ry = contentY + (i - 1) * rowH
        if isMouseIn(mx, my, contentX, ry, contentW, rowH - 2) then
            Mzansi.VehicleShopUI._selected = idx
            playSoundFrontEnd(41)
            return
        end
    end

    local btnY = y + h - 50
    local btnX = contentX + contentW - 160
    if isMouseIn(mx, my, btnX, btnY, 150, 36) then
        local v = list[Mzansi.VehicleShopUI._selected]
        if v and v.model then
            triggerServerEvent("mzansi:vshop:buy", localPlayer, Mzansi.VehicleShopUI._shopId, v.model, v.class or "car")
            playSoundFrontEnd(41)
        end
    end
end)
