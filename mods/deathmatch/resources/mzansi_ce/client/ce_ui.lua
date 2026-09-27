Mzansi = Mzansi or {}
Mzansi.CEUI = Mzansi.CEUI or {}
Mzansi.CEUI._visible = false
Mzansi.CEUI._tickets = {}
Mzansi.CEUI._selected = 1
Mzansi.CEUI._pick = nil
Mzansi.CEUI._snippet = ""
Mzansi.CEUI._result = nil

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
    triggerEvent("mzansi:vshop:closeUI", localPlayer)
    triggerEvent("mzansi:reserve:closeUI", localPlayer)
    triggerEvent("mzansi:mech:close", localPlayer)
    triggerEvent("mzansi:ai:close", localPlayer)
end

function Mzansi.CEUI.open()
    if Mzansi.CEUI._visible then return end
    closeOthers()
    Mzansi.CEUI._visible = true
    Mzansi.CEUI._selected = 1
    Mzansi.CEUI._pick = nil
    Mzansi.CEUI._result = nil
    showCursor(true)
    playSoundFrontEnd(41)
    triggerServerEvent("mzansi:ce:requestTickets", localPlayer)
end

function Mzansi.CEUI.close()
    if not Mzansi.CEUI._visible then return end
    Mzansi.CEUI._visible = false
    showCursor(false)
    playSoundFrontEnd(42)
end

function Mzansi.CEUI.toggle()
    if Mzansi.CEUI._visible then Mzansi.CEUI.close() else Mzansi.CEUI.open() end
end

addEvent("mzansi:ce:setTickets", true)
addEventHandler("mzansi:ce:setTickets", root, function(tickets)
    if type(tickets) == "table" then Mzansi.CEUI._tickets = tickets end
end)

addEvent("mzansi:ce:sandboxResult", true)
addEventHandler("mzansi:ce:sandboxResult", root, function(ok, msg)
    Mzansi.CEUI._result = { ok = ok, msg = msg }
end)

bindKey("x", "down", function()
    if Mzansi.CEUI._visible then Mzansi.CEUI.close() end
end)

bindKey("mouse_wheel_up", "down", function()
    if Mzansi.CEUI._visible then
        Mzansi.CEUI._selected = math.max(1, Mzansi.CEUI._selected - 1)
        Mzansi.CEUI._pick = nil
    end
end)

bindKey("mouse_wheel_down", "down", function()
    if Mzansi.CEUI._visible then
        Mzansi.CEUI._selected = math.min(#Mzansi.CEUI._tickets, Mzansi.CEUI._selected + 1)
        Mzansi.CEUI._pick = nil
    end
end)

addEventHandler("onClientKey", root, function(key, press)
    if not Mzansi.CEUI._visible or not press then return end
    if key == "escape" then
        cancelEvent()
        Mzansi.CEUI.close()
    elseif key == "bs" and #Mzansi.CEUI._snippet > 0 then
        Mzansi.CEUI._snippet = Mzansi.CEUI._snippet:sub(1, -2)
    elseif key == "space" then
        Mzansi.CEUI._snippet = Mzansi.CEUI._snippet .. " "
    elseif key == "enter" then
        if #Mzansi.CEUI._snippet > 0 then
            triggerServerEvent("mzansi:ce:submitSnippet", localPlayer, Mzansi.CEUI._snippet)
        end
    elseif #key == 1 and key:match("[%w%p%s]") and #Mzansi.CEUI._snippet < 400 then
        Mzansi.CEUI._snippet = Mzansi.CEUI._snippet .. key
    end
end)

addCommandHandler("cetickets", function()
    Mzansi.CEUI.toggle()
end)

addEventHandler("onClientRender", root, function()
    if not Mzansi.CEUI._visible then return end
    local sx, sy = screen()
    local w, h = 860, 540
    local x = (sx - w) / 2
    local y = (sy - h) / 2
    local accent = tocolor(60, 140, 220, 255)

    dxDrawRectangle(0, 0, sx, sy, tocolor(5, 10, 18, 150), false)
    dxDrawRectangle(x, y, w, h, tocolor(10, 16, 24, 250), false)
    dxDrawRectangle(x, y, w, 44, tocolor(14, 24, 40, 255), false)
    dxDrawRectangle(x, y, w, 3, accent, false)
    dxDrawText("MZANSI DIGITAL — CE TICKET BOARD", x + 16, y, x + w - 16, y + 44, accent, 1.05, FONT_TITLE, "left", "center")

    local leftW = 340
    local bodyY = y + 56
    for i, t in ipairs(Mzansi.CEUI._tickets) do
        local ry = bodyY + (i - 1) * 36
        if i == Mzansi.CEUI._selected then
            dxDrawRectangle(x + 12, ry - 2, leftW, 34, tocolor(30, 55, 85, 230), false)
        end
        dxDrawText(t.title, x + 20, ry, x + 12 + leftW - 8, ry + 16, tocolor(230, 230, 230), 0.85, FONT_BODY, "left", "top")
        dxDrawText(string.upper(tostring(t.severity)) .. " · R" .. tostring(t.reward or 0), x + 20, ry + 16, x + 12 + leftW - 8, ry + 32, tocolor(160, 180, 200), 0.75, FONT_SMALL, "left", "top")
    end

    local t = Mzansi.CEUI._tickets[Mzansi.CEUI._selected]
    if t then
        local rx = x + leftW + 28
        local rw = w - leftW - 48
        dxDrawRectangle(rx, bodyY - 4, rw, 250, tocolor(16, 24, 36, 255), false)
        dxDrawText(t.prompt or "", rx + 14, bodyY + 8, rx + rw - 14, bodyY + 70, tocolor(220, 230, 240), 0.95, FONT_BODY, "left", "top")

        for j, opt in ipairs(t.options or {}) do
            local oy = bodyY + 80 + (j - 1) * 34
            local sel = Mzansi.CEUI._pick == j
            dxDrawRectangle(rx + 14, oy, rw - 28, 30, sel and tocolor(40, 90, 60, 255) or tocolor(24, 34, 50, 255), false)
            dxDrawText(j .. ") " .. opt, rx + 22, oy, rx + rw - 22, oy + 30, tocolor(230, 230, 230), 0.85, FONT_BODY, "left", "center")
        end

        local submitY = bodyY + 254
        dxDrawRectangle(rx + 14, submitY, 140, 34, tocolor(40, 90, 50, 255), false)
        dxDrawText("SUBMIT FIX", rx + 14, submitY, rx + 154, submitY + 34, tocolor(255, 255, 255), 0.9, FONT_BODY, "center", "center")

        local snipY = submitY + 48
        dxDrawText("SANDBOX (no io/os/require/debug) — Enter to run", rx, snipY, rx + rw, snipY + 18, tocolor(150, 170, 190), 0.85, FONT_BODY, "left", "top")
        dxDrawRectangle(rx, snipY + 22, rw, 40, tocolor(8, 12, 20, 255), false)
        dxDrawText(Mzansi.CEUI._snippet ~= "" and Mzansi.CEUI._snippet or "return 1+1", rx + 10, snipY + 22, rx + rw - 10, snipY + 62, tocolor(120, 220, 160), 0.9, FONT_BODY, "left", "center")

        if Mzansi.CEUI._result then
            local col = Mzansi.CEUI._result.ok and tocolor(80, 220, 120) or tocolor(230, 90, 90)
            dxDrawText(tostring(Mzansi.CEUI._result.msg), rx, snipY + 70, rx + rw, snipY + 90, col, 0.85, FONT_BODY, "left", "top")
        end

        Mzansi.CEUI._hit = { rx = rx, submitY = submitY, leftX = x + 12, leftW = leftW, bodyY = bodyY, ticket = t }
    end

    dxDrawText("wheel select · type snippet · X close", x + 16, y + h - 22, x + w - 16, y + h - 4, tocolor(120, 140, 160, 255), 0.75, FONT_SMALL, "left", "center")
end)

addEventHandler("onClientClick", root, function(button, state, mx, my)
    if button ~= "left" or state ~= "down" then return end
    if not Mzansi.CEUI._visible then return end
    local hit = Mzansi.CEUI._hit
    if not hit then return end

    for j = 1, #(hit.ticket.options or {}) do
        local oy = hit.bodyY + 80 + (j - 1) * 34
        if isMouseIn(mx, my, hit.rx + 14, oy, 400, 30) then
            Mzansi.CEUI._pick = j
            playSoundFrontEnd(41)
            return
        end
    end

    if isMouseIn(mx, my, hit.rx + 14, hit.submitY, 140, 34) then
        if Mzansi.CEUI._pick and hit.ticket then
            triggerServerEvent("mzansi:ce:submitAnswer", localPlayer, hit.ticket.id, Mzansi.CEUI._pick)
        else
            outputChatBox("[CE] Select an option first.", 230, 120, 80, false)
        end
        return
    end

    for i, _ in ipairs(Mzansi.CEUI._tickets) do
        local ry = hit.bodyY + (i - 1) * 36
        if isMouseIn(mx, my, hit.leftX, ry - 2, hit.leftW, 34) then
            Mzansi.CEUI._selected = i
            Mzansi.CEUI._pick = nil
            return
        end
    end
end)
