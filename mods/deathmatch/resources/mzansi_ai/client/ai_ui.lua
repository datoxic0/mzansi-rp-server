Mzansi = Mzansi or {}
Mzansi.AIUI = Mzansi.AIUI or {}
Mzansi.AIUI._visible = false
Mzansi.AIUI._lines = {}
Mzansi.AIUI._input = ""
Mzansi.AIUI._sessionId = nil

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
    triggerEvent("mzansi:ce:close", localPlayer)
    triggerEvent("mzansi:mech:close", localPlayer)
    triggerEvent("mzansi:lab:close", localPlayer)
end

function Mzansi.AIUI.open()
    if Mzansi.AIUI._visible then return end
    closeOthers()
    Mzansi.AIUI._visible = true
    Mzansi.AIUI._input = ""
    if not Mzansi.AIUI._sessionId then
        Mzansi.AIUI._sessionId = "u" .. tostring(getTickCount())
    end
    if #Mzansi.AIUI._lines == 0 then
        Mzansi.AIUI._lines = {
            { role = "assistant", text = "Mzansi copilot ready. Ask about jobs, banking, markets, CE, mechatronics, lab circuits." },
            { role = "assistant", text = "Agent tools: 'my stats', 'list open bugs' (or /aiagent <intent>)." },
        }
    end
    showCursor(true)
    playSoundFrontEnd(41)
    triggerServerEvent("mzansi:ai:history", localPlayer, Mzansi.AIUI._sessionId)
end

function Mzansi.AIUI.close()
    if not Mzansi.AIUI._visible then return end
    Mzansi.AIUI._visible = false
    showCursor(false)
    playSoundFrontEnd(42)
end

function Mzansi.AIUI.toggle()
    if Mzansi.AIUI._visible then Mzansi.AIUI.close() else Mzansi.AIUI.open() end
end

addEvent("mzansi:ai:reply", true)
addEventHandler("mzansi:ai:reply", root, function(reply)
    table.insert(Mzansi.AIUI._lines, { role = "user", text = Mzansi.AIUI._lastSent or "" })
    table.insert(Mzansi.AIUI._lines, { role = "assistant", text = tostring(reply) })
    if #Mzansi.AIUI._lines > 40 then
        table.remove(Mzansi.AIUI._lines, 1)
        table.remove(Mzansi.AIUI._lines, 1)
    end
end)

addEvent("mzansi:ai:setHistory", true)
addEventHandler("mzansi:ai:setHistory", root, function(history)
    if type(history) ~= "table" then return end
    local rebuilt = {}
    for _, h in ipairs(history) do
        rebuilt[#rebuilt + 1] = { role = h.role or "user", text = tostring(h.content or "") }
    end
    if #rebuilt > 0 then
        Mzansi.AIUI._lines = rebuilt
    end
end)

addEvent("mzansi:ai:close", true)
addEventHandler("mzansi:ai:close", root, function()
    Mzansi.AIUI.close()
end)

bindKey("x", "down", function()
    if Mzansi.AIUI._visible then Mzansi.AIUI.close() end
end)

addCommandHandler("ai", function()
    Mzansi.AIUI.toggle()
end)

addCommandHandler("aiagent", function(_, ...)
    local intent = table.concat({ ... }, " ")
    if intent == "" then intent = "help" end
    Mzansi.AIUI.open()
    Mzansi.AIUI._lastSent = intent
    triggerServerEvent("mzansi:ai:agentRun", localPlayer, Mzansi.AIUI._sessionId, intent)
end)

local function send()
    local text = Mzansi.AIUI._input:gsub("^%s+", ""):gsub("%s+$", "")
    if text == "" then return end
    Mzansi.AIUI._lastSent = text
    Mzansi.AIUI._input = ""
    triggerServerEvent("mzansi:ai:chat", localPlayer, Mzansi.AIUI._sessionId, "chat", text)
end

addEventHandler("onClientRender", root, function()
    if not Mzansi.AIUI._visible then return end
    local sx, sy = screen()
    local w, h = 640, 520
    local x = (sx - w) / 2
    local y = (sy - h) / 2
    local accent = tocolor(60, 140, 220, 255)

    dxDrawRectangle(0, 0, sx, sy, tocolor(5, 10, 18, 150), false)
    dxDrawRectangle(x, y, w, h, tocolor(10, 16, 24, 250), false)
    dxDrawRectangle(x, y, w, 44, tocolor(14, 28, 48, 255), false)
    dxDrawRectangle(x, y, w, 3, accent, false)
    dxDrawText("MZANSI COPILOT", x + 16, y, x + w - 16, y + 44, accent, 1.05, FONT_TITLE, "left", "center")
    dxDrawText("/ai · X close", x + w - 160, y, x + w - 16, y + 44, tocolor(140, 160, 180), 0.8, FONT_SMALL, "right", "center")

    local listX = x + 14
    local listY = y + 56
    local listW = w - 28
    local listH = h - 130
    dxDrawRectangle(listX, listY, listW, listH, tocolor(6, 10, 16, 255), false)

    local lineH = 32
    local maxLines = math.floor(listH / lineH)
    local startIdx = math.max(1, #Mzansi.AIUI._lines - maxLines + 1)
    local ly = listY + 6
    for i = startIdx, #Mzansi.AIUI._lines do
        local entry = Mzansi.AIUI._lines[i]
        local prefix = entry.role == "assistant" and "AI: " or "You: "
        local col = entry.role == "assistant" and tocolor(120, 200, 255) or tocolor(230, 230, 230)
        local text = prefix .. tostring(entry.text)
        if #text > 95 then text = text:sub(1, 92) .. "..." end
        dxDrawText(text, listX + 8, ly, listX + listW - 8, ly + lineH - 4, col, 0.9, FONT_BODY, "left", "top")
        ly = ly + lineH
        if ly > listY + listH - lineH then break end
    end

    local inputY = y + h - 66
    dxDrawRectangle(listX, inputY, listW, 40, tocolor(8, 12, 20, 255), false)
    dxDrawText(Mzansi.AIUI._input ~= "" and Mzansi.AIUI._input or "type message...",
        listX + 10, inputY, listX + listW - 90, inputY + 40,
        Mzansi.AIUI._input ~= "" and tocolor(160, 220, 255) or tocolor(100, 120, 140),
        0.95, FONT_BODY, "left", "center")

    local btnX = listX + listW - 80
    dxDrawRectangle(btnX, inputY + 5, 70, 30, tocolor(30, 80, 140, 255), false)
    dxDrawText("SEND", btnX, inputY + 5, btnX + 70, inputY + 35, tocolor(255, 255, 255), 0.9, FONT_BODY, "center", "center")

    Mzansi.AIUI._hit = {
        send = { x = btnX, y = inputY + 5, w = 70, h = 30 },
    }
end)

addEventHandler("onClientClick", root, function(button, state, mx, my)
    if button ~= "left" or state ~= "down" then return end
    if not Mzansi.AIUI._visible then return end
    local hit = Mzansi.AIUI._hit
    if hit and hit.send and isMouseIn(mx, my, hit.send.x, hit.send.y, hit.send.w, hit.send.h) then
        send()
        playSoundFrontEnd(41)
    end
end)

addEventHandler("onClientKey", root, function(key, press)
    if not Mzansi.AIUI._visible or not press then return end
    if key == "escape" then
        cancelEvent()
        Mzansi.AIUI.close()
        return
    end
    if key == "enter" then
        send()
        cancelEvent()
        return
    end
    if key == "backspace" then
        Mzansi.AIUI._input = Mzansi.AIUI._input:sub(1, -2)
        return
    end
    if key == "space" then
        if #Mzansi.AIUI._input < 780 then
            Mzansi.AIUI._input = Mzansi.AIUI._input .. " "
        end
        return
    end
    if #Mzansi.AIUI._input >= 780 then return end

    local ch = nil
    if key:match("^num_(%d)$") then
        ch = key:match("^num_(%d)$")
    elseif key:match("^%d$") then
        ch = key
    elseif key:match("^%a$") then
        ch = key
        if isKeyActive("lshift") or isKeyActive("rshift") then
            ch = string.upper(key)
        end
    elseif key == "comma" then ch = ","
    elseif key == "period" then ch = "."
    elseif key == "question" then ch = "?"
    elseif key == "slash" then ch = "/"
    elseif key == "minus" then ch = "-"
    elseif key == "equals" then ch = "="
    elseif key == "colon" then ch = ":"
    elseif key == "semicolon" then ch = ";"
    elseif key == "apostrophe" then ch = "'"
    end

    if ch then
        Mzansi.AIUI._input = Mzansi.AIUI._input .. ch
    end
end)
