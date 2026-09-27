--[[
    Mzansi ACSA Flight UI (Client)
    F3 = open flight board. Airport markers open it via mzansi:flight:open.
    Bookings call mzansi:flight:book -> server reuses /fly logic.
]]

Mzansi = Mzansi or {}
Mzansi.Flight = Mzansi.Flight or {}
Mzansi.Flight._visible = false
Mzansi.Flight._dests = {}
Mzansi.Flight._selected = 1
Mzansi.Flight._scroll = 0
Mzansi.Flight._anim = 0

local FONT_TITLE = "default-bold"
local FONT_BODY = "default"
local FONT_SMALL = "default-small"

local function screen()
    local sx, sy = guiGetScreenSize()
    return sx, sy
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
    triggerEvent("mzansi:market:close", localPlayer)
    triggerEvent("mzansi:bank:close", localPlayer)
    triggerEvent("mzansi:shop:closeUI", localPlayer)
    triggerEvent("mzansi:intel:uiToggle", resourceRoot, false)
end

function Mzansi.Flight.open(dests)
    if Mzansi.Cutscene and Mzansi.Cutscene.isPlaying() then return end
    if isChatBoxInputActive() or isConsoleActive() then return end
    if type(dests) == "table" then
        Mzansi.Flight._dests = dests
    end
    if Mzansi.Flight._visible then return end
    closeOthers()
    Mzansi.Flight._visible = true
    Mzansi.Flight._anim = 0
    Mzansi.Flight._selected = 1
    Mzansi.Flight._scroll = 0
    showCursor(true)
    playSoundFrontEnd(41)
end

function Mzansi.Flight.close()
    if not Mzansi.Flight._visible then return end
    Mzansi.Flight._visible = false
    Mzansi.Flight._anim = 0
    showCursor(false)
    playSoundFrontEnd(42)
end

function Mzansi.Flight.toggle()
    if Mzansi.Flight._visible then
        Mzansi.Flight.close()
    else
        triggerServerEvent("mzansi:flight:requestList", localPlayer)
        Mzansi.Flight.open()
    end
end

addEvent("mzansi:flight:open", true)
addEventHandler("mzansi:flight:open", root, function(dests)
    Mzansi.Flight.open(dests)
end)

addEvent("mzansi:flight:close", true)
addEventHandler("mzansi:flight:close", root, function()
    Mzansi.Flight.close()
end)

addEvent("mzansi:flight:setList", true)
addEventHandler("mzansi:flight:setList", root, function(dests)
    if type(dests) == "table" then
        Mzansi.Flight._dests = dests
        if Mzansi.Flight._selected > #dests then
            Mzansi.Flight._selected = math.max(1, #dests)
        end
    end
end)

local function bookSelected()
    local d = Mzansi.Flight._dests[Mzansi.Flight._selected]
    if not d then return end
    triggerServerEvent("mzansi:flight:book", localPlayer, d.id)
end

bindKey("f3", "down", function()
    if Mzansi.Util and Mzansi.Util.bindBlocked and Mzansi.Util.bindBlocked() then return end
    if Mzansi.Cutscene and Mzansi.Cutscene.isPlaying() then return end
    Mzansi.Flight.toggle()
end)

bindKey("x", "down", function()
    if Mzansi.Flight._visible then
        Mzansi.Flight.close()
    end
end)

addCommandHandler("flight", function()
    Mzansi.Flight.toggle()
end)

addCommandHandler("flights", function()
    Mzansi.Flight.toggle()
end)

addCommandHandler("airports", function()
    Mzansi.Flight.toggle()
end)

addEventHandler("onClientRender", root, function()
    if not Mzansi.Flight._visible then return end

    Mzansi.Flight._anim = math.min(1, Mzansi.Flight._anim + 0.12)
    local a = Mzansi.Flight._anim
    local sx, sy = screen()
    local mx, my = getCursorPosition()
    if mx and my then mx, my = mx * sx, my * sy end

    local w, h = 720, 440
    local x = math.floor((sx - w) / 2)
    local y = math.floor((sy - h) / 2)

    -- backdrop
    dxDrawRectangle(0, 0, sx, sy, tocolor(0, 0, 0, math.floor(140 * a)))
    -- panel
    dxDrawRectangle(x, y, w, h, tocolor(8, 16, 32, math.floor(245 * a)))
    dxDrawRectangle(x, y, w, 48, tocolor(12, 28, 56, math.floor(255 * a)))
    dxDrawRectangle(x, y + 48, w, 1, tocolor(200, 170, 50, math.floor(180 * a)))

    dxDrawText("ACSA INTERNATIONAL FLIGHT BOARD", x + 18, y + 8, x + w - 18, y + 40,
        tocolor(220, 190, 70, math.floor(255 * a)), 1.15, FONT_TITLE, "left", "center")
    dxDrawText("F3 /flight  |  X close", x + w - 220, y + 8, x + w - 18, y + 40,
        tocolor(130, 150, 170, math.floor(255 * a)), 1.0, FONT_SMALL, "right", "center")

    local listX = x + 14
    local listY = y + 62
    local listW = 430
    local listH = h - 76
    local detailX = x + 458
    local detailW = w - 458 - 14

    -- list background
    dxDrawRectangle(listX, listY, listW, listH, tocolor(4, 10, 20, math.floor(200 * a)))
    dxDrawRectangle(listX, listY, listW, 26, tocolor(20, 40, 70, math.floor(255 * a)))
    dxDrawText("DESTINATION", listX + 10, listY, listX + 260, listY + 26,
        tocolor(160, 190, 220, a * 255), 1.0, FONT_SMALL, "left", "center")
    dxDrawText("TICKET", listX + listW - 90, listY, listX + listW - 10, listY + 26,
        tocolor(160, 190, 220, a * 255), 1.0, FONT_SMALL, "right", "center")

    local rowH = 44
    local maxVisible = math.floor((listH - 30) / rowH)
    local total = #Mzansi.Flight._dests
    if Mzansi.Flight._selected < 1 then Mzansi.Flight._selected = 1 end
    if total > 0 and Mzansi.Flight._selected > total then Mzansi.Flight._selected = total end

    if Mzansi.Flight._selected < Mzansi.Flight._scroll + 1 then
        Mzansi.Flight._scroll = Mzansi.Flight._selected - 1
    end
    if Mzansi.Flight._selected > Mzansi.Flight._scroll + maxVisible then
        Mzansi.Flight._scroll = Mzansi.Flight._selected - maxVisible
    end
    if Mzansi.Flight._scroll > math.max(0, total - maxVisible) then
        Mzansi.Flight._scroll = math.max(0, total - maxVisible)
    end
    if Mzansi.Flight._scroll < 0 then Mzansi.Flight._scroll = 0 end

    for i = 1, math.min(maxVisible, total) do
        local idx = Mzansi.Flight._scroll + i
        local d = Mzansi.Flight._dests[idx]
        if not d then break end
        local ry = listY + 26 + (i - 1) * rowH
        local selected = (idx == Mzansi.Flight._selected)
        local hovered = mx and mouseIn(listX + 4, ry, listW - 8, rowH - 4)

        if selected then
            dxDrawRectangle(listX + 4, ry, listW - 8, rowH - 4, tocolor(40, 70, 120, math.floor(230 * a)))
            dxDrawRectangle(listX + 4, ry, 3, rowH - 4, tocolor(200, 170, 50, math.floor(255 * a)))
        elseif hovered then
            dxDrawRectangle(listX + 4, ry, listW - 8, rowH - 4, tocolor(25, 45, 75, math.floor(200 * a)))
        end

        local icon = d.icon or "✈"
        local tag = d.tag or "Flight"
        dxDrawText(icon .. "  " .. (d.name or d.id), listX + 14, ry + 2, listX + 300, ry + rowH / 2,
            tocolor(235, 240, 245, math.floor(255 * a)), 1.0, FONT_BODY, "left", "center")
        dxDrawText((d.city or "") .. "  ·  " .. tag, listX + 14, ry + rowH / 2, listX + 300, ry + rowH - 2,
            tocolor(140, 160, 180, math.floor(255 * a)), 0.95, FONT_SMALL, "left", "center")
        local costLabel = (d.free and "FREE") or ("R" .. tostring(d.cost or 0))
        dxDrawText(costLabel, listX + listW - 100, ry, listX + listW - 14, ry + rowH - 4,
            tocolor(200, 170, 50, math.floor(255 * a)), 1.05, FONT_BODY, "right", "center")

        if hovered and mx and isCursorShowing() then
            if getKeyState("mouse1") and not Mzansi.Flight._clickLock then
                Mzansi.Flight._selected = idx
                Mzansi.Flight._clickLock = true
                setTimer(function() Mzansi.Flight._clickLock = false end, 180, 1)
            end
        end
    end

    -- detail panel
    local sel = Mzansi.Flight._dests[Mzansi.Flight._selected]
    dxDrawRectangle(detailX, listY, detailW, listH, tocolor(4, 10, 20, math.floor(200 * a)))
    dxDrawRectangle(detailX, listY, detailW, 26, tocolor(20, 40, 70, math.floor(255 * a)))
    dxDrawText("FLIGHT DETAILS", detailX + 10, listY, detailX + detailW - 10, listY + 26,
        tocolor(160, 190, 220, a * 255), 1.0, FONT_SMALL, "left", "center")

    if sel then
        local lines = {
            { "Destination", sel.name or sel.id },
            { "City / Region", sel.city or "—" },
            { "Country", sel.country or "South Africa / Regional" },
            { "Class", sel.tag or "Flight" },
            { "Ticket", (sel.free and "Complimentary") or ("R" .. tostring(sel.cost or 0)) },
            { "Gate", sel.gate or "ACSA Departures" },
        }
        local ly = listY + 40
        for _, row in ipairs(lines) do
            dxDrawText(row[1], detailX + 14, ly, detailX + detailW - 14, ly + 22,
                tocolor(130, 150, 170, math.floor(255 * a)), 1.0, FONT_SMALL, "left", "top")
            dxDrawText(tostring(row[2]), detailX + 14, ly + 16, detailX + detailW - 14, ly + 40,
                tocolor(235, 240, 245, math.floor(255 * a)), 1.0, FONT_BODY, "left", "top")
            ly = ly + 46
        end

        local btnW = detailW - 28
        local btnH = 42
        local btnX = detailX + 14
        local btnY = listY + listH - btnH - 14
        local btnHover = mx and mouseIn(btnX, btnY, btnW, btnH)
        local br, bg, bb = 40, 140, 80
        if btnHover then br, bg, bb = 55, 170, 100 end
        dxDrawRectangle(btnX, btnY, btnW, btnH, tocolor(br, bg, bb, math.floor(255 * a)))
        dxDrawRectangle(btnX, btnY, btnW, 1, tocolor(255, 255, 255, math.floor(60 * a)))
        dxDrawText("BOARD FLIGHT  →", btnX, btnY, btnX + btnW, btnY + btnH,
            tocolor(255, 255, 255, math.floor(255 * a)), 1.1, FONT_TITLE, "center", "center")

        if btnHover and mx and getKeyState("mouse1") and not Mzansi.Flight._clickLock then
            Mzansi.Flight._clickLock = true
            setTimer(function() Mzansi.Flight._clickLock = false end, 250, 1)
            bookSelected()
        end
    else
        dxDrawText("No destinations loaded.\nOpen at an ACSA airport or reconnect.", detailX + 14, listY + 50,
            detailX + detailW - 14, listY + 120, tocolor(160, 170, 180, math.floor(255 * a)), 1.0, FONT_BODY, "left", "top")
    end

    -- hint
    dxDrawText("Scroll list with mouse wheel · Enter/Board to purchase ticket · Must be at an ACSA terminal",
        x + 18, y + h - 22, x + w - 18, y + h - 4,
        tocolor(120, 140, 160, math.floor(255 * a)), 0.95, FONT_SMALL, "left", "center")
end)

addEventHandler("onClientKey", root, function(button, press)
    if not Mzansi.Flight._visible or not press then return end
    local total = #Mzansi.Flight._dests
    if button == "mouse_wheel_up" then
        Mzansi.Flight._selected = math.max(1, Mzansi.Flight._selected - 1)
        cancelEvent()
    elseif button == "mouse_wheel_down" then
        Mzansi.Flight._selected = math.min(math.max(1, total), Mzansi.Flight._selected + 1)
        cancelEvent()
    elseif button == "enter" or button == "kp_enter" then
        bookSelected()
        cancelEvent()
    elseif button == "escape" then
        Mzansi.Flight.close()
        cancelEvent()
    end
end)
