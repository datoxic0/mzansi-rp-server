Mzansi = Mzansi or {}
Mzansi.ReserveUI = Mzansi.ReserveUI or {}
Mzansi.ReserveUI._visible = false
Mzansi.ReserveUI._policy = nil
Mzansi.ReserveUI._supply = nil

local FONT_TITLE = "default-bold"
local FONT_BODY = "default"

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
    triggerEvent("mzansi:shop:closeUI", localPlayer)
    triggerEvent("mzansi:vshop:closeUI", localPlayer)
end

function Mzansi.ReserveUI.open()
    if Mzansi.ReserveUI._visible then return end
    closeOthers()
    Mzansi.ReserveUI._visible = true
    showCursor(true)
    playSoundFrontEnd(41)
    triggerServerEvent("mzansi:reserve:requestPolicy", localPlayer)
    triggerServerEvent("mzansi:reserve:requestSupply", localPlayer)
end

function Mzansi.ReserveUI.close()
    if not Mzansi.ReserveUI._visible then return end
    Mzansi.ReserveUI._visible = false
    showCursor(false)
    playSoundFrontEnd(42)
end

function Mzansi.ReserveUI.toggle()
    if Mzansi.ReserveUI._visible then
        Mzansi.ReserveUI.close()
    else
        Mzansi.ReserveUI.open()
    end
end

addEvent("mzansi:reserve:openUI", true)
addEventHandler("mzansi:reserve:openUI", root, function()
    Mzansi.ReserveUI.open()
end)

addEvent("mzansi:reserve:closeUI", true)
addEventHandler("mzansi:reserve:closeUI", root, function()
    Mzansi.ReserveUI.close()
end)

addEvent("mzansi:reserve:setPolicy", true)
addEventHandler("mzansi:reserve:setPolicy", root, function(policy)
    if type(policy) == "table" then
        Mzansi.ReserveUI._policy = policy
    end
end)

addEvent("mzansi:reserve:setSupply", true)
addEventHandler("mzansi:reserve:setSupply", root, function(supply)
    if type(supply) == "table" then
        Mzansi.ReserveUI._supply = supply
    end
end)

bindKey("x", "down", function()
    if Mzansi.ReserveUI._visible then Mzansi.ReserveUI.close() end
end)

addCommandHandler("reserveui", function()
    Mzansi.ReserveUI.toggle()
end)

addEventHandler("onClientRender", root, function()
    if not Mzansi.ReserveUI._visible then return end
    local sx, sy = screen()
    local w, h = 640, 420
    local x = (sx - w) / 2
    local y = (sy - h) / 2

    local accent = tocolor(180, 140, 40, 255)
    dxDrawRectangle(0, 0, sx, sy, tocolor(5, 10, 18, 150), false)
    dxDrawRectangle(x, y, w, h, tocolor(10, 16, 24, 250), false)
    dxDrawRectangle(x, y, w, 46, tocolor(18, 28, 40, 255), false)
    dxDrawRectangle(x, y, w, 3, accent, false)
    dxDrawText("SARB — CENTRAL RESERVE BANK", x + 20, y, x + w - 20, y + 46, accent, 1.1, FONT_TITLE, "left", "center")

    local p = Mzansi.ReserveUI._policy
    local s = Mzansi.ReserveUI._supply
    local cy = y + 60
    local cx = x + 25
    local cw = w - 50

    if p then
        dxDrawText("POLICY RATES", cx, cy, cx + cw, cy + 24, tocolor(218, 165, 32, 255), 1.0, FONT_TITLE, "left", "top")
        cy = cy + 30
        local lines = {
            "Policy / Interest Rate: " .. string.format("%.2f%%", (tonumber(p.policy_rate) or 0) * 100),
            "Reserve Ratio: " .. string.format("%.1f%%", (tonumber(p.reserve_ratio) or 0) * 100),
            "Tax Rate: " .. string.format("%.2f%%", (tonumber(p.tax_rate) or 0) * 100),
            "Discount Rate: " .. string.format("%.2f%%", (tonumber(p.discount_rate) or 0) * 100),
        }
        for _, line in ipairs(lines) do
            dxDrawText("• " .. line, cx + 8, cy, cx + cw, cy + 22, tocolor(180, 200, 220, 255), 0.9, FONT_BODY, "left", "top")
            cy = cy + 24
        end

        -- Admin buttons (harmless if not admin — server rejects)
        cy = cy + 10
        dxDrawText("ADMIN ACTIONS (server-enforced)", cx, cy, cx + cw, cy + 20, tocolor(150, 170, 190, 255), 0.85, FONT_BODY, "left", "top")
        cy = cy + 26

        local mx, my = getCursorPosition()
        mx, my = (mx or 0) * sx, (my or 0) * sy
        local btns = {
            { label = "RATE 2.5%", pr = 0.025 },
            { label = "RATE 3.5%", pr = 0.035 },
            { label = "RATE 5%",   pr = 0.05 },
            { label = "TAX 7%",    tx = 0.07 },
        }
        for i, b in ipairs(btns) do
            local bx = cx + (i - 1) * 140
            local hover = isMouseIn(mx, my, bx, cy, 130, 32)
            dxDrawRectangle(bx, cy, 130, 32, hover and tocolor(60, 90, 40, 255) or tocolor(40, 70, 30, 255), false)
            dxDrawText(b.label, bx, cy, bx + 130, cy + 32, tocolor(255, 255, 255, 255), 0.8, FONT_BODY, "center", "center")
            if hover and isMouseIn(mx, my, bx, cy, 130, 32) and not lastClick then
                -- handled in click
            end
        end
        Mzansi.ReserveUI._btnY = cy
        Mzansi.ReserveUI._btnX = cx
    else
        dxDrawText("Loading policy...", cx, cy, cx + cw, cy + 24, tocolor(150, 170, 190), 1, FONT_BODY, "left", "top")
    end

    if s then
        local sy0 = y + h - 130
        dxDrawText("MONEY SUPPLY", cx, sy0, cx + cw, sy0 + 24, tocolor(218, 165, 32, 255), 1.0, FONT_TITLE, "left", "top")
        sy0 = sy0 + 30
        dxDrawText("M0 (cash in wallets): " .. Mzansi.Util.formatMoney(s.m0_cash or 0),
            cx + 8, sy0, cx + cw, sy0 + 22, tocolor(80, 220, 100, 255), 0.9, FONT_BODY, "left", "top")
        sy0 = sy0 + 24
        dxDrawText("M1 (bank + group deposits): " .. Mzansi.Util.formatMoney(s.m1_deposits or 0),
            cx + 8, sy0, cx + cw, sy0 + 22, tocolor(0, 180, 255, 255), 0.9, FONT_BODY, "left", "top")
        sy0 = sy0 + 24
        dxDrawText("M2 proxy: " .. Mzansi.Util.formatMoney(s.m2_proxy or 0),
            cx + 8, sy0, cx + cw, sy0 + 22, tocolor(218, 165, 32, 255), 0.9, FONT_BODY, "left", "top")
    end
end)

addEventHandler("onClientClick", root, function(button, state, mx, my)
    if button ~= "left" or state ~= "down" then return end
    if not Mzansi.ReserveUI._visible then return end
    local p = Mzansi.ReserveUI._policy
    if not p then return end
    local cy = Mzansi.ReserveUI._btnY
    local cx = Mzansi.ReserveUI._btnX
    if not cy then return end

    local actions = {
        { pr = 0.025 },
        { pr = 0.035 },
        { pr = 0.05 },
        { tx = 0.07 },
    }
    for i, a in ipairs(actions) do
        local bx = cx + (i - 1) * 140
        if isMouseIn(mx, my, bx, cy, 130, 32) then
            local patch = { policy_rate = p.policy_rate, tax_rate = p.tax_rate, reserve_ratio = p.reserve_ratio, discount_rate = p.discount_rate }
            if a.pr then patch.policy_rate = a.pr end
            if a.tx then patch.tax_rate = a.tx end
            triggerServerEvent("mzansi:reserve:setPolicy", localPlayer, patch)
            playSoundFrontEnd(41)
            return
        end
    end
end)
