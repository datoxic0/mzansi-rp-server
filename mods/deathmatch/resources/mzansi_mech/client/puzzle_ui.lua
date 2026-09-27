Mzansi = Mzansi or {}
Mzansi.MechUI = Mzansi.MechUI or {}
Mzansi.MechUI._visible = false
Mzansi.MechUI._progress = nil
Mzansi.MechUI._result = nil
Mzansi.MechUI._answers = {}

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
    triggerEvent("mzansi:ai:close", localPlayer)
end

function Mzansi.MechUI.open()
    if Mzansi.MechUI._visible then return end
    closeOthers()
    Mzansi.MechUI._visible = true
    Mzansi.MechUI._result = nil
    Mzansi.MechUI._answers = {}
    showCursor(true)
    playSoundFrontEnd(41)
    triggerServerEvent("mzansi:mech:requestProgress", localPlayer)
end

function Mzansi.MechUI.close()
    if not Mzansi.MechUI._visible then return end
    Mzansi.MechUI._visible = false
    showCursor(false)
    playSoundFrontEnd(42)
end

function Mzansi.MechUI.toggle()
    if Mzansi.MechUI._visible then Mzansi.MechUI.close() else Mzansi.MechUI.open() end
end

addEvent("mzansi:mech:setProgress", true)
addEventHandler("mzansi:mech:setProgress", root, function(progress)
    if type(progress) == "table" then
        Mzansi.MechUI._progress = progress
    end
end)

addEvent("mzansi:mech:result", true)
addEventHandler("mzansi:mech:result", root, function(ok, msg)
    Mzansi.MechUI._result = { ok = ok, msg = msg }
end)

addEvent("mzansi:mech:close", true)
addEventHandler("mzansi:mech:close", root, function()
    Mzansi.MechUI.close()
end)

bindKey("x", "down", function()
    if Mzansi.MechUI._visible then Mzansi.MechUI.close() end
end)

addCommandHandler("mech", function()
    Mzansi.MechUI.toggle()
end)

local function currentStage()
    local stage = tonumber(Mzansi.MechUI._progress and Mzansi.MechUI._progress.stage or 0) or 0
    local nextId = stage + 1
    if not Mzansi.Mech or not Mzansi.Mech.Stages then return nil end
    for _, s in ipairs(Mzansi.Mech.Stages) do
        if s.id == nextId then return s end
    end
    return nil
end

local function buildSubmitPayload(stage)
    if stage.kind == "truth" then
        local outputs = {}
        for i = 1, #(stage.inputs or {}) do
            outputs[i] = Mzansi.MechUI._answers["r" .. i] or 0
        end
        return { outputs = outputs }
    elseif stage.kind == "sequence" then
        local seq = {}
        for i = 1, #(stage.sequence or {}) do
            seq[i] = Mzansi.MechUI._answers["s" .. i] or 0
        end
        return { sequence = seq }
    elseif stage.kind == "value" then
        return { value = tonumber(Mzansi.MechUI._answers.value or "") }
    elseif stage.kind == "order" then
        local order = {}
        for i = 1, #(stage.order or {}) do
            local v = tonumber(Mzansi.MechUI._answers["o" .. i] or "")
            if v then order[#order + 1] = v end
        end
        return {
            order = order,
            safety = (Mzansi.MechUI._answers.safety == true or Mzansi.MechUI._answers.safety == 1),
        }
    end
    return {}
end

addEventHandler("onClientRender", root, function()
    if not Mzansi.MechUI._visible then return end
    local sx, sy = screen()
    local w, h = 720, 500
    local x = (sx - w) / 2
    local y = (sy - h) / 2
    local accent = tocolor(200, 140, 40, 255)

    dxDrawRectangle(0, 0, sx, sy, tocolor(5, 10, 18, 150), false)
    dxDrawRectangle(x, y, w, h, tocolor(10, 16, 24, 250), false)
    dxDrawRectangle(x, y, w, 44, tocolor(30, 24, 12, 255), false)
    dxDrawRectangle(x, y, w, 3, accent, false)
    dxDrawText("MZANSI AUTOMATION — MECHATRONICS LAB", x + 16, y, x + w - 16, y + 44, accent, 1.05, FONT_TITLE, "left", "center")

    local stage = currentStage()
    local bodyY = y + 58
    local prog = Mzansi.MechUI._progress
    if prog then
        dxDrawText("Progress: stage " .. tostring(prog.stage or 0) .. " / 10 · score " .. tostring(prog.score or 0),
            x + 16, bodyY, x + w - 16, bodyY + 20, tocolor(170, 190, 210), 0.9, FONT_BODY, "left", "top")
        bodyY = bodyY + 28
    end

    if not stage then
        dxDrawText("All stages complete. Maintenance cycle done.", x + 16, bodyY, x + w - 16, bodyY + 24, tocolor(80, 220, 120), 1.0, FONT_BODY, "left", "top")
        return
    end

    dxDrawText("Stage " .. stage.id .. " — " .. stage.name, x + 16, bodyY, x + w - 16, bodyY + 22, tocolor(235, 235, 235), 1.0, FONT_TITLE, "left", "top")
    bodyY = bodyY + 28
    dxDrawText(stage.concept, x + 16, bodyY, x + w - 16, bodyY + 20, tocolor(160, 180, 200), 0.9, FONT_BODY, "left", "top")
    bodyY = bodyY + 30

    local panelX = x + 16
    local panelW = w - 32
    local submitY = y + h - 90

    if stage.kind == "truth" then
        dxDrawText("Gate: " .. stage.gate .. "   (click cells to toggle 0/1)", panelX, bodyY, panelX + panelW, bodyY + 20, tocolor(200, 170, 80), 0.9, FONT_BODY, "left", "top")
        bodyY = bodyY + 26
        dxDrawText("A", panelX + 40, bodyY, panelX + 80, bodyY + 20, tocolor(150, 170, 190), 0.9, FONT_BODY, "center", "top")
        dxDrawText("B", panelX + 100, bodyY, panelX + 140, bodyY + 20, tocolor(150, 170, 190), 0.9, FONT_BODY, "center", "top")
        dxDrawText("OUT", panelX + 200, bodyY, panelX + 260, bodyY + 20, tocolor(150, 170, 190), 0.9, FONT_BODY, "center", "top")
        bodyY = bodyY + 24
        for i, pair in ipairs(stage.inputs) do
            local ry = bodyY + (i - 1) * 30
            dxDrawText(tostring(pair[1]), panelX + 40, ry, panelX + 80, ry + 24, tocolor(230, 230, 230), 0.95, FONT_BODY, "center", "center")
            dxDrawText(tostring(pair[2]), panelX + 100, ry, panelX + 140, ry + 24, tocolor(230, 230, 230), 0.95, FONT_BODY, "center", "center")
            local val = Mzansi.MechUI._answers["r" .. i] or 0
            dxDrawRectangle(panelX + 200, ry + 2, 50, 22, val == 1 and tocolor(40, 120, 60, 255) or tocolor(40, 40, 60, 255), false)
            dxDrawText(tostring(val), panelX + 200, ry + 2, panelX + 250, ry + 24, tocolor(255, 255, 255), 0.9, FONT_BODY, "center", "center")
            Mzansi.MechUI._cells = Mzansi.MechUI._cells or {}
            Mzansi.MechUI._cells[i] = { x = panelX + 200, y = ry + 2, w = 50, h = 22 }
        end
    elseif stage.kind == "value" then
        dxDrawText(string.format("Set reading to %.1f %s (±%.1f)", stage.target, stage.unit or "", stage.tolerance or 0.5),
            panelX, bodyY, panelX + panelW, bodyY + 22, tocolor(200, 170, 80), 0.95, FONT_BODY, "left", "top")
        bodyY = bodyY + 30
        local cur = Mzansi.MechUI._answers.value or ""
        dxDrawRectangle(panelX, bodyY, 220, 36, tocolor(8, 12, 20, 255), false)
        dxDrawText("VALUE: " .. (cur ~= "" and cur or "_"), panelX + 10, bodyY, panelX + 210, bodyY + 36, tocolor(120, 220, 160), 0.95, FONT_BODY, "left", "center")
        bodyY = bodyY + 50
        dxDrawText("Tip: +/- via +/- keys, digits via number keys", panelX, bodyY, panelX + panelW, bodyY + 20, tocolor(130, 150, 170), 0.8, FONT_SMALL, "left", "top")
        Mzansi.MechUI._valueBox = { x = panelX, y = bodyY - 50, w = 220, h = 36 }
    elseif stage.kind == "order" then
        if stage.safety then
            local on = Mzansi.MechUI._answers.safety == true or Mzansi.MechUI._answers.safety == 1
            dxDrawRectangle(panelX, bodyY, 260, 30, on and tocolor(40, 120, 60, 255) or tocolor(90, 50, 40, 255), false)
            dxDrawText(on and "SAFETY INTERLOCK: ENGAGED" or "SAFETY INTERLOCK: OFF (click)",
                panelX, bodyY, panelX + 260, bodyY + 30, tocolor(255, 255, 255), 0.9, FONT_BODY, "center", "center")
            Mzansi.MechUI._safetyBtn = { x = panelX, y = bodyY, w = 260, h = 30 }
            bodyY = bodyY + 40
        end
        dxDrawText("Enter waypoint order (comma-separated), e.g. 1,0,3,2,4", panelX, bodyY, panelX + panelW, bodyY + 20, tocolor(200, 170, 80), 0.9, FONT_BODY, "left", "top")
        bodyY = bodyY + 26
        local text = Mzansi.MechUI._answers.orderText or ""
        dxDrawRectangle(panelX, bodyY, panelW, 36, tocolor(8, 12, 20, 255), false)
        dxDrawText(text ~= "" and text or "type order...", panelX + 10, bodyY, panelX + panelW - 10, bodyY + 36, tocolor(120, 220, 160), 0.95, FONT_BODY, "left", "center")
        bodyY = bodyY + 50
        local order = {}
        for num in tostring(Mzansi.MechUI._answers.orderText or ""):gmatch("%-?%d+") do
            order[#order + 1] = tonumber(num)
        end
        Mzansi.MechUI._parsedOrder = order
        Mzansi.MechUI._orderBox = true
    elseif stage.kind == "sequence" then
        dxDrawText("Build the state sequence (toggle bits)", panelX, bodyY, panelX + panelW, bodyY + 20, tocolor(200, 170, 80), 0.9, FONT_BODY, "left", "top")
        bodyY = bodyY + 26
        Mzansi.MechUI._cells = {}
        for i = 1, #(stage.sequence or {}) do
            local bx = panelX + (i - 1) * 54
            local val = Mzansi.MechUI._answers["s" .. i] or 0
            dxDrawRectangle(bx, bodyY, 44, 32, val == 1 and tocolor(40, 120, 60, 255) or tocolor(40, 40, 60, 255), false)
            dxDrawText(tostring(val), bx, bodyY, bx + 44, bodyY + 32, tocolor(255, 255, 255), 0.95, FONT_BODY, "center", "center")
            Mzansi.MechUI._cells[i] = { x = bx, y = bodyY, w = 44, h = 32, key = "s" .. i }
        end
        bodyY = bodyY + 50
    end

    dxDrawRectangle(panelX, submitY, 160, 40, tocolor(40, 90, 50, 255), false)
    dxDrawText("RUN TEST", panelX, submitY, panelX + 160, submitY + 40, tocolor(255, 255, 255), 1.0, FONT_BODY, "center", "center")

    if Mzansi.MechUI._result then
        local col = Mzansi.MechUI._result.ok and tocolor(80, 220, 120) or tocolor(230, 90, 90)
        dxDrawText(tostring(Mzansi.MechUI._result.msg), panelX + 180, submitY, x + w - 16, submitY + 40, col, 0.9, FONT_BODY, "left", "center")
    end

    dxDrawText("server evaluates · X close · /mech", x + 16, y + h - 22, x + w - 16, y + h - 4, tocolor(120, 140, 160, 255), 0.75, FONT_SMALL, "left", "center")

    Mzansi.MechUI._hit = {
        submit = { x = panelX, y = submitY, w = 160, h = 40 },
        stage = stage,
    }
end)

addEventHandler("onClientClick", root, function(button, state, mx, my)
    if button ~= "left" or state ~= "down" then return end
    if not Mzansi.MechUI._visible then return end
    local hit = Mzansi.MechUI._hit
    if not hit then return end

    if isMouseIn(mx, my, hit.submit.x, hit.submit.y, hit.submit.w, hit.submit.h) then
        local payload = buildSubmitPayload(hit.stage)
        if hit.stage.kind == "order" then
            payload.order = Mzansi.MechUI._parsedOrder or {}
            payload.safety = (Mzansi.MechUI._answers.safety == true or Mzansi.MechUI._answers.safety == 1)
        end
        triggerServerEvent("mzansi:mech:submitStage", localPlayer, hit.stage.id, payload)
        playSoundFrontEnd(41)
        return
    end

    if hit.stage and hit.stage.safety and Mzansi.MechUI._safetyBtn then
        local b = Mzansi.MechUI._safetyBtn
        if isMouseIn(mx, my, b.x, b.y, b.w, b.h) then
            local on = Mzansi.MechUI._answers.safety == true or Mzansi.MechUI._answers.safety == 1
            Mzansi.MechUI._answers.safety = not on
            return
        end
    end

    local stage = hit.stage
    if not stage or not Mzansi.MechUI._cells then return end

    if stage.kind == "truth" and type(Mzansi.MechUI._cells) == "table" then
        for i, cell in pairs(Mzansi.MechUI._cells) do
            if type(i) == "number" and cell and cell.w and isMouseIn(mx, my, cell.x, cell.y, cell.w, cell.h) then
                local key = "r" .. i
                Mzansi.MechUI._answers[key] = (Mzansi.MechUI._answers[key] == 1) and 0 or 1
                return
            end
        end
    elseif stage.kind == "sequence" then
        for i, cell in pairs(Mzansi.MechUI._cells or {}) do
            if cell.key and isMouseIn(mx, my, cell.x, cell.y, cell.w, cell.h) then
                Mzansi.MechUI._answers[cell.key] = (Mzansi.MechUI._answers[cell.key] == 1) and 0 or 1
                return
            end
        end
    end
end)

addEventHandler("onClientKey", root, function(key, press)
    if not Mzansi.MechUI._visible or not press then return end
    if key == "escape" then
        cancelEvent()
        Mzansi.MechUI.close()
        return
    end
    local stage = currentStage()
    if not stage then return end

    if stage.kind == "value" then
        if key == "bs" and #(Mzansi.MechUI._answers.value or "") > 0 then
            Mzansi.MechUI._answers.value = (Mzansi.MechUI._answers.value or ""):sub(1, -2)
        elseif key == "minus" then
            local cur = tonumber(Mzansi.MechUI._answers.value or "0") or 0
            Mzansi.MechUI._answers.value = tostring(cur - 1)
        elseif key == "plus" or key == "equals" then
            local cur = tonumber(Mzansi.MechUI._answers.value or "0") or 0
            Mzansi.MechUI._answers.value = tostring(cur + 1)
        elseif key:match("^num_") then
            local n = key:gsub("num_", "")
            Mzansi.MechUI._answers.value = (Mzansi.MechUI._answers.value or "") .. n
        elseif key:match("^%d$") or key == "decimal" or key == "period" then
            local ch = (key == "decimal" or key == "period") and "." or key
            Mzansi.MechUI._answers.value = (Mzansi.MechUI._answers.value or "") .. ch
        end
    elseif stage.kind == "order" then
        if key == "bs" then
            Mzansi.MechUI._answers.orderText = (Mzansi.MechUI._answers.orderText or ""):sub(1, -2)
        elseif key == "space" then
            Mzansi.MechUI._answers.orderText = (Mzansi.MechUI._answers.orderText or "") .. " "
        elseif key:match("^%d$") or key:match("^num_") or key == "comma" then
            local ch = key:match("^num_(%d)$") or (key == "comma" and "," or key)
            Mzansi.MechUI._answers.orderText = (Mzansi.MechUI._answers.orderText or "") .. tostring(ch)
        end
    end
end)
