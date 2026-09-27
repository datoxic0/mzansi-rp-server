Mzansi = Mzansi or {}
Mzansi.MarketUI = Mzansi.MarketUI or {}
Mzansi.MarketUI._visible = false
Mzansi.MarketUI._quotes = {}
Mzansi.MarketUI._portfolio = {}
Mzansi.MarketUI._funds = {}
Mzansi.MarketUI._tab = 1
Mzansi.MarketUI._selected = 1
Mzansi.MarketUI._fundSel = 1
Mzansi.MarketUI._amount = ""

local FONT_TITLE = "default-bold"
local FONT_BODY = "default"
local FONT_SMALL = "default-small"

local TABS = { "Watchlist", "Portfolio", "Funds" }

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
    triggerEvent("mzansi:bank:close", localPlayer)
    triggerEvent("mzansi:shop:closeUI", localPlayer)
    triggerEvent("mzansi:vshop:closeUI", localPlayer)
    triggerEvent("mzansi:reserve:closeUI", localPlayer)
end

function Mzansi.MarketUI.open()
    if Mzansi.MarketUI._visible then return end
    closeOthers()
    Mzansi.MarketUI._visible = true
    Mzansi.MarketUI._tab = 1
    Mzansi.MarketUI._selected = 1
    Mzansi.MarketUI._amount = ""
    showCursor(true)
    playSoundFrontEnd(41)
    triggerServerEvent("mzansi:market:requestQuotes", localPlayer)
    triggerServerEvent("mzansi:market:requestPortfolio", localPlayer)
    triggerServerEvent("mzansi:market:requestFunds", localPlayer)
end

function Mzansi.MarketUI.close()
    if not Mzansi.MarketUI._visible then return end
    Mzansi.MarketUI._visible = false
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

addEvent("mzansi:market:setQuotes", true)
addEventHandler("mzansi:market:setQuotes", root, function(quotes)
    if type(quotes) == "table" then Mzansi.MarketUI._quotes = quotes end
end)

addEvent("mzansi:market:setPortfolio", true)
addEventHandler("mzansi:market:setPortfolio", root, function(portfolio)
    if type(portfolio) == "table" then Mzansi.MarketUI._portfolio = portfolio end
end)

addEvent("mzansi:market:setFunds", true)
addEventHandler("mzansi:market:setFunds", root, function(funds)
    if type(funds) == "table" then Mzansi.MarketUI._funds = funds end
end)

bindKey("x", "down", function()
    if Mzansi.MarketUI._visible then Mzansi.MarketUI.close() end
end)

bindKey("mouse_wheel_up", "down", function()
    if not Mzansi.MarketUI._visible then return end
    if Mzansi.MarketUI._tab == 1 then
        Mzansi.MarketUI._selected = math.max(1, Mzansi.MarketUI._selected - 1)
    elseif Mzansi.MarketUI._tab == 3 then
        Mzansi.MarketUI._fundSel = math.max(1, Mzansi.MarketUI._fundSel - 1)
    end
end)

bindKey("mouse_wheel_down", "down", function()
    if not Mzansi.MarketUI._visible then return end
    if Mzansi.MarketUI._tab == 1 then
        Mzansi.MarketUI._selected = math.min(#Mzansi.MarketUI._quotes, Mzansi.MarketUI._selected + 1)
    elseif Mzansi.MarketUI._tab == 3 then
        Mzansi.MarketUI._fundSel = math.min(#Mzansi.MarketUI._funds, Mzansi.MarketUI._fundSel + 1)
    end
end)

addEventHandler("onClientKey", root, function(key, press)
    if not Mzansi.MarketUI._visible or not press then return end
    if key == "escape" then
        cancelEvent()
        Mzansi.MarketUI.close()
        return
    end
    if key == "1" then Mzansi.MarketUI._tab = 1
    elseif key == "2" then Mzansi.MarketUI._tab = 2
    elseif key == "3" then Mzansi.MarketUI._tab = 3
    elseif key == "bs" and #Mzansi.MarketUI._amount > 0 then
        Mzansi.MarketUI._amount = Mzansi.MarketUI._amount:sub(1, -2)
    elseif key:match("^num_") then
        local n = key:gsub("num_", "")
        if #Mzansi.MarketUI._amount < 8 then
            Mzansi.MarketUI._amount = Mzansi.MarketUI._amount .. n
        end
    elseif key:match("^%d$") and #Mzansi.MarketUI._amount < 8 then
        Mzansi.MarketUI._amount = Mzansi.MarketUI._amount .. key
    end
end)

addCommandHandler("markets", function()
    Mzansi.MarketUI.toggle()
end)

addEventHandler("onClientRender", root, function()
    if not Mzansi.MarketUI._visible then return end
    local sx, sy = screen()
    local w, h = 820, 520
    local x = (sx - w) / 2
    local y = (sy - h) / 2
    local accent = tocolor(40, 160, 90, 255)

    dxDrawRectangle(0, 0, sx, sy, tocolor(5, 10, 18, 150), false)
    dxDrawRectangle(x, y, w, h, tocolor(10, 16, 24, 250), false)
    dxDrawRectangle(x, y, w, 44, tocolor(14, 24, 34, 255), false)
    dxDrawRectangle(x, y, w, 3, accent, false)
    dxDrawText("MZANSI EXCHANGE — PAPER MARKETS (closed loop)", x + 16, y, x + w - 16, y + 44, accent, 1.05, FONT_TITLE, "left", "center")

    for i, tab in ipairs(TABS) do
        local tx = x + 16 + (i - 1) * 130
        local ty = y + 52
        local active = Mzansi.MarketUI._tab == i
        dxDrawRectangle(tx, ty, 120, 30, active and tocolor(30, 70, 50, 255) or tocolor(24, 34, 48, 255), false)
        dxDrawText(tab, tx, ty, tx + 120, ty + 30, tocolor(230, 230, 230, 255), 0.9, FONT_BODY, "center", "center")
    end

    local bodyY = y + 92
    local bodyX = x + 16
    local bodyW = w - 32

    if Mzansi.MarketUI._tab == 1 then
        dxDrawText("SYMBOL", bodyX, bodyY, bodyX + 120, bodyY + 20, tocolor(150, 170, 190), 0.9, FONT_BODY, "left", "top")
        dxDrawText("PRICE", bodyX + 140, bodyY, bodyX + 260, bodyY + 20, tocolor(150, 170, 190), 0.9, FONT_BODY, "left", "top")
        dxDrawText("CHANGE%", bodyX + 280, bodyY, bodyX + 400, bodyY + 20, tocolor(150, 170, 190), 0.9, FONT_BODY, "left", "top")
        dxDrawText("REGIME", bodyX + 420, bodyY, bodyX + 560, bodyY + 20, tocolor(150, 170, 190), 0.9, FONT_BODY, "left", "top")
        bodyY = bodyY + 24
        for i, q in ipairs(Mzansi.MarketUI._quotes) do
            local ry = bodyY + (i - 1) * 22
            if ry > y + h - 120 then break end
            local sel = i == Mzansi.MarketUI._selected
            if sel then
                dxDrawRectangle(bodyX - 4, ry - 2, bodyW, 22, tocolor(30, 60, 45, 200), false)
            end
            local col = (q.change_pct or 0) >= 0 and tocolor(80, 220, 120, 255) or tocolor(230, 90, 90, 255)
            dxDrawText(q.symbol, bodyX, ry, bodyX + 120, ry + 20, tocolor(230, 230, 230), 0.85, FONT_BODY, "left", "top")
            dxDrawText(string.format("R%.2f", q.price or 0), bodyX + 140, ry, bodyX + 260, ry + 20, tocolor(230, 230, 230), 0.85, FONT_BODY, "left", "top")
            dxDrawText(string.format("%+.2f%%", q.change_pct or 0), bodyX + 280, ry, bodyX + 400, ry + 20, col, 0.85, FONT_BODY, "left", "top")
            dxDrawText(q.regime or "normal", bodyX + 420, ry, bodyX + 560, ry + 20, tocolor(180, 200, 220), 0.85, FONT_BODY, "left", "top")
        end

        local btnY = y + h - 58
        local buyX = bodyX
        local sellX = bodyX + 130
        local amtX = bodyX + 260
        local hover = getCursorPosition()
        local mx, my = hover and hover * sx or 0, hover and ({ getCursorPosition() })[2] * sy or 0
        dxDrawRectangle(buyX, btnY, 120, 34, tocolor(30, 90, 50, 255), false)
        dxDrawText("BUY QTY", buyX, btnY, buyX + 120, btnY + 34, tocolor(255, 255, 255), 0.9, FONT_BODY, "center", "center")
        dxDrawRectangle(sellX, btnY, 120, 34, tocolor(90, 40, 40, 255), false)
        dxDrawText("SELL QTY", sellX, btnY, sellX + 120, btnY + 34, tocolor(255, 255, 255), 0.9, FONT_BODY, "center", "center")
        dxDrawRectangle(amtX, btnY, 160, 34, tocolor(20, 30, 44, 255), false)
        dxDrawText("QTY: " .. (Mzansi.MarketUI._amount ~= "" and Mzansi.MarketUI._amount or "_"), amtX + 8, btnY, amtX + 152, btnY + 34, tocolor(220, 220, 220), 0.9, FONT_BODY, "left", "center")
        Mzansi.MarketUI._btn = { buyX = buyX, sellX = sellX, btnY = btnY }

    elseif Mzansi.MarketUI._tab == 2 then
        dxDrawText("SYMBOL", bodyX, bodyY, bodyX + 120, bodyY + 20, tocolor(150, 170, 190), 0.9, FONT_BODY, "left", "top")
        dxDrawText("QTY", bodyX + 140, bodyY, bodyX + 220, bodyY + 20, tocolor(150, 170, 190), 0.9, FONT_BODY, "left", "top")
        dxDrawText("AVG", bodyX + 240, bodyY, bodyX + 340, bodyY + 20, tocolor(150, 170, 190), 0.9, FONT_BODY, "left", "top")
        dxDrawText("MARK", bodyX + 360, bodyY, bodyX + 460, bodyY + 20, tocolor(150, 170, 190), 0.9, FONT_BODY, "left", "top")
        dxDrawText("UNREAL", bodyX + 480, bodyY, bodyX + 600, bodyY + 20, tocolor(150, 170, 190), 0.9, FONT_BODY, "left", "top")
        bodyY = bodyY + 24
        if #Mzansi.MarketUI._portfolio == 0 then
            dxDrawText("No open positions. Buy on Watchlist.", bodyX, bodyY, bodyX + bodyW, bodyY + 24, tocolor(160, 170, 180), 0.9, FONT_BODY, "left", "top")
        else
            for i, p in ipairs(Mzansi.MarketUI._portfolio) do
                local ry = bodyY + (i - 1) * 22
                local col = (p.unrealized or 0) >= 0 and tocolor(80, 220, 120, 255) or tocolor(230, 90, 90, 255)
                dxDrawText(p.symbol, bodyX, ry, bodyX + 120, ry + 20, tocolor(230, 230, 230), 0.85, FONT_BODY, "left", "top")
                dxDrawText(tostring(p.qty or 0), bodyX + 140, ry, bodyX + 220, ry + 20, tocolor(230, 230, 230), 0.85, FONT_BODY, "left", "top")
                dxDrawText(string.format("R%.2f", p.avg_price or 0), bodyX + 240, ry, bodyX + 340, ry + 20, tocolor(230, 230, 230), 0.85, FONT_BODY, "left", "top")
                dxDrawText(string.format("R%.2f", p.mark or 0), bodyX + 360, ry, bodyX + 460, ry + 20, tocolor(230, 230, 230), 0.85, FONT_BODY, "left", "top")
                dxDrawText(string.format("R%.0f", p.unrealized or 0), bodyX + 480, ry, bodyX + 600, ry + 20, col, 0.85, FONT_BODY, "left", "top")
            end
        end

    else
        dxDrawText("FUND", bodyX, bodyY, bodyX + 220, bodyY + 20, tocolor(150, 170, 190), 0.9, FONT_BODY, "left", "top")
        dxDrawText("NAV", bodyX + 240, bodyY, bodyX + 340, bodyY + 20, tocolor(150, 170, 190), 0.9, FONT_BODY, "left", "top")
        dxDrawText("AUM", bodyX + 360, bodyY, bodyX + 500, bodyY + 20, tocolor(150, 170, 190), 0.9, FONT_BODY, "left", "top")
        dxDrawText("STRATEGY", bodyX + 520, bodyY, bodyX + 640, bodyY + 20, tocolor(150, 170, 190), 0.9, FONT_BODY, "left", "top")
        bodyY = bodyY + 24
        if #Mzansi.MarketUI._funds == 0 then
            dxDrawText("No funds yet. Create with /mktfund name.", bodyX, bodyY, bodyX + bodyW, bodyY + 24, tocolor(160, 170, 180), 0.9, FONT_BODY, "left", "top")
        else
            for i, f in ipairs(Mzansi.MarketUI._funds) do
                local ry = bodyY + (i - 1) * 22
                if i == Mzansi.MarketUI._fundSel then
                    dxDrawRectangle(bodyX - 4, ry - 2, bodyW, 22, tocolor(30, 50, 70, 200), false)
                end
                dxDrawText(tostring(f.name or "?"), bodyX, ry, bodyX + 220, ry + 20, tocolor(230, 230, 230), 0.85, FONT_BODY, "left", "top")
                dxDrawText(string.format("%.4f", tonumber(f.nav) or 1), bodyX + 240, ry, bodyX + 340, ry + 20, tocolor(80, 200, 255), 0.85, FONT_BODY, "left", "top")
                dxDrawText(Mzansi.Util and Mzansi.Util.formatMoney and Mzansi.Util.formatMoney(f.aum or 0) or tostring(f.aum or 0), bodyX + 360, ry, bodyX + 500, ry + 20, tocolor(218, 165, 32), 0.85, FONT_BODY, "left", "top")
                dxDrawText(tostring(f.strategy or "balanced"), bodyX + 520, ry, bodyX + 640, ry + 20, tocolor(180, 200, 220), 0.85, FONT_BODY, "left", "top")
            end
        end

        local btnY = y + h - 58
        local invX = bodyX
        local redX = bodyX + 140
        dxDrawRectangle(invX, btnY, 130, 34, tocolor(30, 90, 50, 255), false)
        dxDrawText("INVEST", invX, btnY, invX + 130, btnY + 34, tocolor(255, 255, 255), 0.9, FONT_BODY, "center", "center")
        dxDrawRectangle(redX, btnY, 130, 34, tocolor(90, 50, 30, 255), false)
        dxDrawText("REDEEM", redX, btnY, redX + 130, btnY + 34, tocolor(255, 255, 255), 0.9, FONT_BODY, "center", "center")
        dxDrawText("Amount (R): " .. (Mzansi.MarketUI._amount ~= "" and Mzansi.MarketUI._amount or "_"),
            redX + 150, btnY, bodyX + bodyW, btnY + 34, tocolor(200, 200, 200), 0.9, FONT_BODY, "left", "center")
        Mzansi.MarketUI._fundBtn = { invX = invX, redX = redX, btnY = btnY }
    end

    dxDrawText("1/2/3 tabs · wheel select · X close · type digits for qty", x + 16, y + h - 22, x + w - 16, y + h - 4, tocolor(120, 140, 160, 255), 0.75, FONT_SMALL, "left", "center")
end)

addEventHandler("onClientClick", root, function(button, state, mx, my)
    if button ~= "left" or state ~= "down" then return end
    if not Mzansi.MarketUI._visible then return end

    local x, y = (select(1, screen()) - 820) / 2, (select(2, screen()) - 520) / 2
    for i = 1, 3 do
        local tx = x + 16 + (i - 1) * 130
        local ty = y + 52
        if isMouseIn(mx, my, tx, ty, 120, 30) then
            Mzansi.MarketUI._tab = i
            playSoundFrontEnd(41)
            return
        end
    end

    if Mzansi.MarketUI._tab == 1 then
        local bodyY = y + 92 + 24
        for i, q in ipairs(Mzansi.MarketUI._quotes) do
            local ry = bodyY + (i - 1) * 22
            if isMouseIn(mx, my, x + 16, ry - 2, 788, 22) then
                Mzansi.MarketUI._selected = i
                return
            end
        end
        local b = Mzansi.MarketUI._btn
        if b then
            local qty = tonumber(Mzansi.MarketUI._amount) or 0
            local q = Mzansi.MarketUI._quotes[Mzansi.MarketUI._selected]
            if isMouseIn(mx, my, b.buyX, b.btnY, 120, 34) and q and qty > 0 then
                triggerServerEvent("mzansi:market:buy", localPlayer, q.symbol, qty)
                playSoundFrontEnd(41)
            elseif isMouseIn(mx, my, b.sellX, b.btnY, 120, 34) and q and qty > 0 then
                triggerServerEvent("mzansi:market:sell", localPlayer, q.symbol, qty)
                playSoundFrontEnd(42)
            end
        end
    elseif Mzansi.MarketUI._tab == 3 then
        local b = Mzansi.MarketUI._fundBtn
        local fund = Mzansi.MarketUI._funds[Mzansi.MarketUI._fundSel]
        if b and fund then
            local amount = tonumber(Mzansi.MarketUI._amount) or 0
            if isMouseIn(mx, my, b.invX, b.btnY, 130, 34) and amount > 0 then
                triggerServerEvent("mzansi:market:investFund", localPlayer, fund.id, amount)
                playSoundFrontEnd(41)
            elseif isMouseIn(mx, my, b.redX, b.btnY, 130, 34) and amount > 0 then
                local units = amount
                triggerServerEvent("mzansi:market:redeemFund", localPlayer, fund.id, units)
                playSoundFrontEnd(42)
            end
        end
    end
end)

addCommandHandler("mktfund", function(_, name, strategy)
    if not name or name == "" then
        outputChatBox("Usage: /mktfund <name> [balanced|aggressive|conservative]", 255, 200, 80, false)
        return
    end
    triggerServerEvent("mzansi:market:createFund", localPlayer, name, strategy or "balanced")
end)
