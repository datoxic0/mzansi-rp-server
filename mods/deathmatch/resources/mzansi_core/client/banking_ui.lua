Mzansi = Mzansi or {}
Mzansi.BankUI = Mzansi.BankUI or {}
Mzansi.BankUI._visible = false
Mzansi.BankUI._status = nil
Mzansi.BankUI._history = nil
Mzansi.BankUI._anim = 0
Mzansi.BankUI._tab = 1  -- 1=Overview, 2=Transfer, 3=Loans, 4=History
Mzansi.BankUI._scroll = 0
Mzansi.BankUI._amount = ""
Mzansi.BankUI._target = ""
Mzansi.BankUI._inputMode = nil  -- "amount" | "target"
Mzansi.BankUI._loanTier = 1

local FONT_TITLE = "default-bold"
local FONT_BODY = "default"
local FONT_SMALL = "default-small"

local TABS = { "Overview", "Transfer", "Loans", "History", "Groups" }

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
end

function Mzansi.BankUI.open()
    if Mzansi.Cutscene and Mzansi.Cutscene.isPlaying() then return end
    if isChatBoxInputActive() or isConsoleActive() then return end
    if Mzansi.BankUI._visible then return end
    closeOthers()
    Mzansi.BankUI._visible = true
    Mzansi.BankUI._anim = 0
    Mzansi.BankUI._tab = 1
    Mzansi.BankUI._scroll = 0
    Mzansi.BankUI._amount = ""
    Mzansi.BankUI._target = ""
    Mzansi.BankUI._inputMode = nil
    Mzansi.BankUI._history = nil
    showCursor(true)
    playSoundFrontEnd(41)
    triggerServerEvent("mzansi:bank:requestStatus", localPlayer)
    triggerServerEvent("mzansi:bank:requestHistory", localPlayer)
end

function Mzansi.BankUI.close()
    if not Mzansi.BankUI._visible then return end
    Mzansi.BankUI._visible = false
    Mzansi.BankUI._anim = 0
    Mzansi.BankUI._inputMode = nil
    showCursor(false)
    playSoundFrontEnd(42)
end

function Mzansi.BankUI.toggle()
    if Mzansi.BankUI._visible then
        Mzansi.BankUI.close()
    else
        Mzansi.BankUI.open()
    end
end

-- ==============================================================
-- EVENTS
-- ==============================================================
addEvent("mzansi:bank:openUI", true)
addEventHandler("mzansi:bank:openUI", root, function()
    Mzansi.BankUI.open()
end)

addEvent("mzansi:bank:close", true)
addEventHandler("mzansi:bank:close", root, function()
    Mzansi.BankUI.close()
end)

addEvent("mzansi:bank:setStatus", true)
addEventHandler("mzansi:bank:setStatus", root, function(status)
    if type(status) == "table" then
        Mzansi.BankUI._status = status
    end
end)

addEvent("mzansi:bank:setHistory", true)
addEventHandler("mzansi:bank:setHistory", root, function(history)
    if type(history) == "table" then
        Mzansi.BankUI._history = history
    end
end)

-- ==============================================================
-- KEYBINDS — ScrollLock + F10 (no letter keys; numbers stay on weapons)
-- ==============================================================
local function bankToggleBlocked()
    if Mzansi.Util and Mzansi.Util.bindBlocked and Mzansi.Util.bindBlocked() then return true end
    if Mzansi.Cutscene and Mzansi.Cutscene.isPlaying() then return true end
    return false
end

bindKey("scrolllock", "down", function()
    if bankToggleBlocked() then return end
    Mzansi.BankUI.toggle()
end)

bindKey("f10", "down", function()
    if bankToggleBlocked() then return end
    Mzansi.BankUI.toggle()
end)

addCommandHandler("bankui", function()
    if bankToggleBlocked() then return end
    Mzansi.BankUI.toggle()
end)

-- ==============================================================
-- RENDER
-- ==============================================================
addEventHandler("onClientRender", root, function()
    if not Mzansi.BankUI._visible then return end

    local sx, sy = screen()
    local w, h = 820, 540
    local x = (sx - w) / 2
    local y = (sy - h) / 2
    Mzansi.BankUI._anim = math.min(1, Mzansi.BankUI._anim + 0.08)

    local mx, my = getCursorPosition()
    mx, my = (mx or 0) * sx, (my or 0) * sy

    local accent = tocolor(0, 140, 220, 255)  -- bank blue
    local gold = tocolor(218, 165, 32, 255)

    -- Backdrop
    dxDrawRectangle(0, 0, sx, sy, tocolor(5, 10, 18, 150), false)
    dxDrawRectangle(x, y, w, h, tocolor(8, 16, 28, 250), false)
    dxDrawRectangle(x, y, w, 3, accent, false)
    dxDrawRectangle(x, y, w, 50, tocolor(12, 24, 40, 255), false)

    dxDrawText("STANDARD BANK — MZANSI", x + 25, y, x + w - 160, y + 50, accent, 1.1, FONT_TITLE, "left", "center")
    dxDrawText("[N or X to Close]", x + w - 170, y, x + w - 25, y + 50, tocolor(150, 170, 190, 200), 0.85, FONT_TITLE, "right", "center")

    local status = Mzansi.BankUI._status

    -- Tabs
    local tabX = x + 20
    local tabY = y + 60
    local tabW = (w - 40) / #TABS

    for i, tabName in ipairs(TABS) do
        local tx = tabX + (i - 1) * tabW
        local isActive = (i == Mzansi.BankUI._tab)
        local hover = isMouseIn(mx, my, tx, tabY, tabW - 4, 32)
        local bg = isActive and accent or (hover and tocolor(25, 45, 75, 255) or tocolor(18, 32, 52, 255))
        dxDrawRectangle(tx, tabY, tabW - 4, 32, bg, false)
        dxDrawText(tabName, tx, tabY, tx + tabW - 4, tabY + 32,
            isActive and tocolor(255, 255, 255, 255) or tocolor(150, 170, 190, 255),
            0.9, FONT_BODY, "center", "center")
    end

    if not status then
        dxDrawText("Loading account...", x, y + h / 2, x + w, y + h / 2 + 20, tocolor(150, 170, 190), 1, FONT_BODY, "center", "center")
        return
    end

    local contentX = x + 20
    local contentY = tabY + 42
    local contentW = w - 40

    -- ============================================================
    -- TAB 1: OVERVIEW
    -- ============================================================
    if Mzansi.BankUI._tab == 1 then
        -- Balance cards
        local cardW = (contentW - 30) / 3
        local cards = {
            { title = "WALLET (CASH)", val = Mzansi.Util.formatMoney(status.cash or 0), col = tocolor(50, 220, 100, 255) },
            { title = "BANK ACCOUNT", val = Mzansi.Util.formatMoney(status.bank or 0), col = tocolor(0, 180, 255, 255) },
            { title = "INVESTMENTS", val = Mzansi.Util.formatMoney(status.investmentTotal or 0), col = tocolor(218, 165, 32, 255) },
        }
        for i, card in ipairs(cards) do
            local cx = contentX + (i - 1) * (cardW + 15)
            dxDrawRectangle(cx, contentY, cardW, 75, tocolor(15, 28, 45, 255), false)
            dxDrawRectangle(cx, contentY, cardW, 2, card.col, false)
            dxDrawText(card.title, cx + 15, contentY + 10, cx + cardW - 10, contentY + 30, tocolor(130, 150, 170, 255), 0.8, FONT_BODY, "left", "top")
            dxDrawText(card.val, cx + 15, contentY + 35, cx + cardW - 10, contentY + 70, card.col, 1.3, FONT_TITLE, "left", "top")
        end

        -- Stats
        local statY = contentY + 90
        dxDrawText("ACCOUNT STATISTICS", contentX, statY, contentX + contentW, statY + 25, gold, 1.0, FONT_TITLE, "left", "top")
        statY = statY + 30

        local stats = {
            "Interest Rate: " .. math.floor((status.interestRate or 0) * 100) .. "% per payday",
            "Tax Rate: " .. math.floor((status.taxRate or 0) * 100) .. "%",
            "Transfer Fee: " .. math.floor((status.transferFeeRate or 0) * 100) .. "% (min " .. Mzansi.Util.formatMoney(status.transferMin or 100) .. ")",
            "Outstanding Loan: " .. (status.loanOwed > 0 and (Mzansi.Util.formatMoney(status.loanOwed) .. " — " .. (status.loanName or "Loan")) or "None"),
            "Max Single Transfer: " .. Mzansi.Util.formatMoney(status.maxTransfer or 500000),
        }
        for _, line in ipairs(stats) do
            dxDrawText("• " .. line, contentX + 10, statY, contentX + contentW, statY + 22, tocolor(180, 200, 220, 255), 0.9, FONT_BODY, "left", "top")
            statY = statY + 24
        end

        -- Quick actions
        local actionY = statY + 15
        dxDrawText("QUICK ACTIONS", contentX, actionY, contentX + contentW, actionY + 25, gold, 1.0, FONT_TITLE, "left", "top")
        actionY = actionY + 30

        local bw, bh = 140, 38
        local buttons = {
            { label = "DEPOSIT R1000", action = "dep1000" },
            { label = "DEPOSIT R5000", action = "dep5000" },
            { label = "WITHDRAW R1000", action = "wd1000" },
            { label = "WITHDRAW R5000", action = "wd5000" },
        }
        for i, btn in ipairs(buttons) do
            local bx = contentX + (i - 1) * (bw + 12)
            local hover = isMouseIn(mx, my, bx, actionY, bw, bh)
            local isDeposit = string.find(btn.action, "dep")
            local baseCol = isDeposit and {40, 130, 55} or {40, 80, 130}
            local bg = hover
                and tocolor(baseCol[1] + 25, baseCol[2] + 25, baseCol[3] + 25, 255)
                or tocolor(baseCol[1], baseCol[2], baseCol[3], 255)
            dxDrawRectangle(bx, actionY, bw, bh, bg, false)
            dxDrawText(btn.label, bx, actionY, bx + bw, actionY + bh, tocolor(255, 255, 255, 255), 0.75, FONT_BODY, "center", "center")
        end

        -- Custom amount input
        local inputY = actionY + bh + 15
        dxDrawText("Custom Amount:", contentX, inputY, contentX + 150, inputY + 30, tocolor(180, 200, 220), 0.9, FONT_BODY, "left", "center")
        local inputHover = isMouseIn(mx, my, contentX + 150, inputY, 200, 30)
        dxDrawRectangle(contentX + 150, inputY, 200, 30, Mzansi.BankUI._inputMode == "amount" and tocolor(20, 45, 75, 255) or tocolor(15, 28, 45, 255), false)
        dxDrawText(Mzansi.BankUI._amount .. (Mzansi.BankUI._inputMode == "amount" and "_" or ""),
            contentX + 160, inputY, contentX + 340, inputY + 30, tocolor(255, 255, 255), 0.9, FONT_BODY, "left", "center")

        local depBtnX = contentX + 370
        local depHover = isMouseIn(mx, my, depBtnX, inputY, 100, 30)
        dxDrawRectangle(depBtnX, inputY, 100, 30, depHover and tocolor(50, 160, 70, 255) or tocolor(40, 130, 55, 255), false)
        dxDrawText("DEPOSIT", depBtnX, inputY, depBtnX + 100, inputY + 30, tocolor(255, 255, 255), 0.8, FONT_BODY, "center", "center")

        local wdBtnX = contentX + 485
        local wdHover = isMouseIn(mx, my, wdBtnX, inputY, 100, 30)
        dxDrawRectangle(wdBtnX, inputY, 100, 30, wdHover and tocolor(50, 100, 160, 255) or tocolor(40, 80, 130, 255), false)
        dxDrawText("WITHDRAW", wdBtnX, inputY, wdBtnX + 100, inputY + 30, tocolor(255, 255, 255), 0.8, FONT_BODY, "center", "center")

    -- ============================================================
    -- TAB 2: TRANSFER
    -- ============================================================
    elseif Mzansi.BankUI._tab == 2 then
        dxDrawText("SEND MONEY TO ANOTHER PLAYER", contentX, contentY, contentX + contentW, contentY + 25, gold, 1.0, FONT_TITLE, "left", "top")
        contentY = contentY + 35

        -- Target input
        dxDrawText("Recipient (name or ID):", contentX, contentY, contentX + 180, contentY + 30, tocolor(180, 200, 220), 0.9, FONT_BODY, "left", "center")
        dxDrawRectangle(contentX + 185, contentY, 300, 32, Mzansi.BankUI._inputMode == "target" and tocolor(20, 45, 75, 255) or tocolor(15, 28, 45, 255), false)
        dxDrawText(Mzansi.BankUI._target .. (Mzansi.BankUI._inputMode == "target" and "_" or ""),
            contentX + 195, contentY, contentX + 470, contentY + 32, tocolor(255, 255, 255), 0.9, FONT_BODY, "left", "center")
        contentY = contentY + 45

        -- Amount input
        dxDrawText("Amount (R):", contentX, contentY, contentX + 180, contentY + 30, tocolor(180, 200, 220), 0.9, FONT_BODY, "left", "center")
        dxDrawRectangle(contentX + 185, contentY, 300, 32, Mzansi.BankUI._inputMode == "amount" and tocolor(20, 45, 75, 255) or tocolor(15, 28, 45, 255), false)
        dxDrawText(Mzansi.BankUI._amount .. (Mzansi.BankUI._inputMode == "amount" and "_" or ""),
            contentX + 195, contentY, contentX + 470, contentY + 32, tocolor(255, 255, 255), 0.9, FONT_BODY, "left", "center")
        contentY = contentY + 45

        -- Fee info
        local amt = tonumber(Mzansi.BankUI._amount) or 0
        local fee = math.floor(amt * (status.transferFeeRate or 0.02))
        dxDrawText("Transfer fee (" .. math.floor((status.transferFeeRate or 0.02) * 100) .. "%): " .. Mzansi.Util.formatMoney(fee) ..
            "   |   Total cost: " .. Mzansi.Util.formatMoney(amt + fee),
            contentX, contentY, contentX + contentW, contentY + 22, tocolor(200, 180, 100, 255), 0.85, FONT_BODY, "left", "top")
        contentY = contentY + 30

        dxDrawText("Min: " .. Mzansi.Util.formatMoney(status.transferMin or 100) .. "   |   Max: " .. Mzansi.Util.formatMoney(status.maxTransfer or 500000),
            contentX, contentY, contentX + contentW, contentY + 22, tocolor(130, 150, 170, 255), 0.8, FONT_SMALL, "left", "top")
        contentY = contentY + 35

        -- Send button
        local sendHover = isMouseIn(mx, my, contentX, contentY, 160, 40)
        dxDrawRectangle(contentX, contentY, 160, 40, sendHover and tocolor(50, 160, 70, 255) or tocolor(40, 130, 55, 255), false)
        dxDrawText("SEND TRANSFER", contentX, contentY, contentX + 160, contentY + 40, tocolor(255, 255, 255), 0.9, FONT_BODY, "center", "center")

        -- Info
        contentY = contentY + 60
        dxDrawText("Transfers settle instantly for online players. Offline recipients receive funds on next login.",
            contentX, contentY, contentX + contentW, contentY + 40, tocolor(130, 150, 170, 255), 0.85, FONT_BODY, "left", "top")

    -- ============================================================
    -- TAB 3: LOANS
    -- ============================================================
    elseif Mzansi.BankUI._tab == 3 then
        dxDrawText("LOAN SERVICES", contentX, contentY, contentX + contentW, contentY + 25, gold, 1.0, FONT_TITLE, "left", "top")
        contentY = contentY + 35

        -- Outstanding loan
        if (status.loanOwed or 0) > 0 then
            dxDrawRectangle(contentX, contentY, contentW, 50, tocolor(80, 40, 30, 255), false)
            dxDrawText("OUTSTANDING: " .. Mzansi.Util.formatMoney(status.loanOwed) .. " — " .. (status.loanName or "Loan"),
                contentX + 15, contentY + 5, contentX + contentW - 15, contentY + 25, tocolor(255, 180, 80, 255), 1.0, FONT_TITLE, "left", "top")
            dxDrawText("Repay from bank balance below.", contentX + 15, contentY + 28, contentX + contentW - 15, contentY + 48,
                tocolor(200, 180, 160, 255), 0.85, FONT_BODY, "left", "top")
            contentY = contentY + 60

            -- Repay buttons
            local repayAmt = math.min(tonumber(Mzansi.BankUI._amount) or 0, status.loanOwed)
            dxDrawText("Repayment amount:", contentX, contentY, contentX + 160, contentY + 30, tocolor(180, 200, 220), 0.9, FONT_BODY, "left", "center")
            dxDrawRectangle(contentX + 165, contentY, 200, 30, Mzansi.BankUI._inputMode == "amount" and tocolor(20, 45, 75, 255) or tocolor(15, 28, 45, 255), false)
            dxDrawText(Mzansi.BankUI._amount .. (Mzansi.BankUI._inputMode == "amount" and "_" or ""),
                contentX + 175, contentY, contentX + 350, contentY + 30, tocolor(255, 255, 255), 0.9, FONT_BODY, "left", "center")

            local repayHover = isMouseIn(mx, my, contentX + 380, contentY, 130, 30)
            dxDrawRectangle(contentX + 380, contentY, 130, 30, repayHover and tocolor(180, 120, 30, 255) or tocolor(150, 100, 25, 255), false)
            dxDrawText("REPAY", contentX + 380, contentY, contentX + 510, contentY + 30, tocolor(255, 255, 255), 0.85, FONT_BODY, "center", "center")

            local fullHover = isMouseIn(mx, my, contentX + 525, contentY, 130, 30)
            dxDrawRectangle(contentX + 525, contentY, 130, 30, fullHover and tocolor(50, 160, 70, 255) or tocolor(40, 130, 55, 255), false)
            dxDrawText("REPAY ALL", contentX + 525, contentY, contentX + 655, contentY + 30, tocolor(255, 255, 255), 0.8, FONT_BODY, "center", "center")

            contentY = contentY + 50
        else
            dxDrawText("No outstanding loans.", contentX, contentY, contentX + contentW, contentY + 25, tocolor(80, 220, 100, 255), 0.95, FONT_BODY, "left", "top")
            contentY = contentY + 35
        end

        -- Loan tiers
        dxDrawText("AVAILABLE LOAN PRODUCTS", contentX, contentY, contentX + contentW, contentY + 25, gold, 1.0, FONT_TITLE, "left", "top")
        contentY = contentY + 30

        local tiers = status.loanTiers or {}
        for i, tier in ipairs(tiers) do
            local isSelected = (i == Mzansi.BankUI._loanTier)
            local ty = contentY + (i - 1) * 55
            local hover = isMouseIn(mx, my, contentX, ty, contentW, 50)
            local bg = isSelected and tocolor(20, 50, 90, 255) or (hover and tocolor(18, 40, 70, 255) or tocolor(15, 28, 45, 255))
            dxDrawRectangle(contentX, ty, contentW, 50, bg, false)
            if isSelected then
                dxDrawRectangle(contentX, ty, 3, 50, accent, false)
            end

            dxDrawText(tier.name, contentX + 15, ty + 5, contentX + 300, ty + 25, tocolor(220, 230, 240, 255), 0.95, FONT_TITLE, "left", "top")
            dxDrawText(Mzansi.Util.formatMoney(tier.min) .. " – " .. Mzansi.Util.formatMoney(tier.max) ..
                "  |  " .. math.floor(tier.rate * 100) .. "% interest  |  " .. tier.term .. " paydays",
                contentX + 15, ty + 27, contentX + 500, ty + 47, tocolor(150, 170, 190, 255), 0.8, FONT_SMALL, "left", "top")

            -- SELECT button
            local selHover = isMouseIn(mx, my, contentX + contentW - 100, ty + 10, 85, 30)
            local selBg = isSelected and tocolor(40, 120, 200, 255) or (selHover and tocolor(50, 100, 160, 255) or tocolor(40, 80, 130, 255))
            dxDrawRectangle(contentX + contentW - 100, ty + 10, 85, 30, selBg, false)
            dxDrawText(isSelected and "SELECTED" or "SELECT", contentX + contentW - 100, ty + 10, contentX + contentW - 15, ty + 40,
                tocolor(255, 255, 255, 255), 0.7, FONT_SMALL, "center", "center")
        end

        contentY = contentY + #tiers * 55 + 15

        -- Request loan
        local tier = tiers[Mzansi.BankUI._loanTier]
        if tier then
            dxDrawText("Loan amount:", contentX, contentY, contentX + 140, contentY + 30, tocolor(180, 200, 220), 0.9, FONT_BODY, "left", "center")
            dxDrawRectangle(contentX + 145, contentY, 200, 30, Mzansi.BankUI._inputMode == "amount" and tocolor(20, 45, 75, 255) or tocolor(15, 28, 45, 255), false)
            dxDrawText(Mzansi.BankUI._amount .. (Mzansi.BankUI._inputMode == "amount" and "_" or ""),
                contentX + 155, contentY, contentX + 330, contentY + 30, tocolor(255, 255, 255), 0.9, FONT_BODY, "left", "center")

            local takeHover = isMouseIn(mx, my, contentX + 360, contentY, 150, 30)
            dxDrawRectangle(contentX + 360, contentY, 150, 30, takeHover and tocolor(50, 160, 70, 255) or tocolor(40, 130, 55, 255), false)
            dxDrawText("TAKE LOAN", contentX + 360, contentY, contentX + 510, contentY + 30, tocolor(255, 255, 255), 0.85, FONT_BODY, "center", "center")

            dxDrawText("Selected: " .. tier.name .. " — you will owe " ..
                Mzansi.Util.formatMoney(math.floor((tonumber(Mzansi.BankUI._amount) or 0) * (1 + tier.rate))),
                contentX + 530, contentY, contentX + contentW, contentY + 30, tocolor(200, 180, 100, 255), 0.75, FONT_SMALL, "left", "center")
        end

    -- ============================================================
    -- TAB 4: HISTORY
    -- ============================================================
    elseif Mzansi.BankUI._tab == 4 then
        dxDrawText("TRANSACTION HISTORY (Last 50)", contentX, contentY, contentX + contentW, contentY + 25, gold, 1.0, FONT_TITLE, "left", "top")
        contentY = contentY + 30

        local history = Mzansi.BankUI._history or {}
        if #history == 0 then
            dxDrawText("No transactions yet.", contentX, contentY, contentX + contentW, contentY + 25, tocolor(130, 150, 170), 0.95, FONT_BODY, "left", "top")
        else
            -- Header
            dxDrawRectangle(contentX, contentY, contentW, 28, tocolor(20, 40, 65, 255), false)
            dxDrawText("TYPE", contentX + 10, contentY, contentX + 140, contentY + 28, tocolor(150, 170, 190, 255), 0.8, FONT_BODY, "left", "center")
            dxDrawText("AMOUNT", contentX + 150, contentY, contentX + 300, contentY + 28, tocolor(150, 170, 190, 255), 0.8, FONT_BODY, "left", "center")
            dxDrawText("BALANCE", contentX + 310, contentY, contentX + 460, contentY + 28, tocolor(150, 170, 190, 255), 0.8, FONT_BODY, "left", "center")
            dxDrawText("DETAILS", contentX + 470, contentY, contentX + contentW - 10, contentY + 28, tocolor(150, 170, 190, 255), 0.8, FONT_BODY, "left", "center")
            contentY = contentY + 30

            local rowH = 28
            local maxRows = math.floor((h - (contentY - y) - 50) / rowH)
            local scroll = Mzansi.BankUI._scroll
            if scroll > #history - maxRows then
                Mzansi.BankUI._scroll = math.max(0, #history - maxRows)
                scroll = Mzansi.BankUI._scroll
            end

            for i = 1, maxRows do
                local idx = scroll + i
                if idx > #history then break end
                local tx = history[idx]
                local ry = contentY + (i - 1) * rowH
                local bg = (i % 2 == 0) and tocolor(15, 28, 45, 255) or tocolor(18, 32, 52, 255)
                dxDrawRectangle(contentX, ry, contentW, rowH - 2, bg, false)

                local txType = tx.tx_type or "?"
                local typeColor = tocolor(150, 170, 190, 255)
                if txType == "DEPOSIT" or txType == "TRANSFER_IN" then typeColor = tocolor(80, 220, 100, 255)
                elseif txType == "WITHDRAW" or txType == "TRANSFER_OUT" then typeColor = tocolor(255, 120, 80, 255)
                elseif txType == "LOAN" then typeColor = tocolor(218, 165, 32, 255)
                elseif txType == "LOAN_REPAY" then typeColor = tocolor(180, 140, 80, 255)
                end

                dxDrawText(txType, contentX + 10, ry, contentX + 140, ry + rowH - 2, typeColor, 0.8, FONT_SMALL, "left", "center")
                dxDrawText(Mzansi.Util.formatMoney(tonumber(tx.amount) or 0), contentX + 150, ry, contentX + 300, ry + rowH - 2, tocolor(220, 230, 240, 255), 0.8, FONT_SMALL, "left", "center")
                dxDrawText(Mzansi.Util.formatMoney(tonumber(tx.balance_after) or 0), contentX + 310, ry, contentX + 460, ry + rowH - 2, tocolor(170, 190, 210, 255), 0.8, FONT_SMALL, "left", "center")
                dxDrawText(tostring(tx.detail or ""), contentX + 470, ry, contentX + contentW - 10, ry + rowH - 2, tocolor(130, 150, 170, 255), 0.75, FONT_SMALL, "left", "center")
            end
        end

    -- ============================================================
    -- TAB 5: GROUPS (gang / business / club shared accounts)
    -- ============================================================
    elseif Mzansi.BankUI._tab == 5 then
        dxDrawText("GROUP & BUSINESS ACCOUNTS", contentX, contentY, contentX + contentW, contentY + 25, gold, 1.0, FONT_TITLE, "left", "top")
        contentY = contentY + 32

        if Mzansi.GroupBankUI and Mzansi.GroupBankUI.request and (not Mzansi.GroupBankUI._accounts) then
            Mzansi.GroupBankUI.request()
        end

        local accounts = (Mzansi.GroupBankUI and Mzansi.GroupBankUI._accounts) or {}
        if #accounts == 0 then
            dxDrawText("No group accounts. Join a gang, own a business, or form a club to unlock shared banking.",
                contentX, contentY, contentX + contentW, contentY + 40, tocolor(130, 150, 170), 0.95, FONT_BODY, "left", "top")
            contentY = contentY + 50
        else
            dxDrawRectangle(contentX, contentY, contentW, 28, tocolor(20, 40, 65, 255), false)
            dxDrawText("ACCOUNT", contentX + 10, contentY, contentX + 260, contentY + 28, tocolor(150, 170, 190, 255), 0.8, FONT_BODY, "left", "center")
            dxDrawText("TYPE", contentX + 270, contentY, contentX + 400, contentY + 28, tocolor(150, 170, 190, 255), 0.8, FONT_BODY, "left", "center")
            dxDrawText("BALANCE", contentX + 410, contentY, contentX + contentW - 10, contentY + 28, tocolor(150, 170, 190, 255), 0.8, FONT_BODY, "right", "center")
            contentY = contentY + 30

            local sel = (Mzansi.GroupBankUI and Mzansi.GroupBankUI._selected) or 1
            for i, acct in ipairs(accounts) do
                local ty = contentY + (i - 1) * 42
                if ty + 40 > y + h - 70 then break end
                local isSelected = (i == sel)
                local hover = isMouseIn(mx, my, contentX, ty, contentW, 40)
                local bg = isSelected and tocolor(20, 50, 90, 255)
                    or (hover and tocolor(18, 40, 70, 255) or tocolor(15, 28, 45, 255))
                dxDrawRectangle(contentX, ty, contentW, 40, bg, false)
                if isSelected then
                    dxDrawRectangle(contentX, ty, 3, 40, accent, false)
                end
                dxDrawText(tostring(acct.name or "Group"), contentX + 15, ty, contentX + 260, ty + 40,
                    tocolor(220, 230, 240, 255), 0.9, FONT_BODY, "left", "center")
                dxDrawText(tostring(acct.owner_type or "?"), contentX + 270, ty, contentX + 400, ty + 40,
                    tocolor(150, 170, 190, 255), 0.8, FONT_SMALL, "left", "center")
                dxDrawText(Mzansi.Util.formatMoney(acct.balance or 0), contentX + 410, ty, contentX + contentW - 15, ty + 40,
                    tocolor(80, 220, 100, 255), 0.9, FONT_BODY, "right", "center")
            end
            contentY = contentY + #accounts * 42 + 12

            local acct = accounts[sel]
            if acct then
                dxDrawText("Amount:", contentX, contentY, contentX + 90, contentY + 30, tocolor(180, 200, 220), 0.9, FONT_BODY, "left", "center")
                local inputHover = isMouseIn(mx, my, contentX + 95, contentY, 180, 30)
                dxDrawRectangle(contentX + 95, contentY, 180, 30,
                    Mzansi.BankUI._inputMode == "amount" and tocolor(20, 45, 75, 255) or tocolor(15, 28, 45, 255), false)
                dxDrawText(Mzansi.BankUI._amount .. (Mzansi.BankUI._inputMode == "amount" and "_" or ""),
                    contentX + 105, contentY, contentX + 265, contentY + 30, tocolor(255, 255, 255), 0.9, FONT_BODY, "left", "center")

                local depHover = isMouseIn(mx, my, contentX + 290, contentY, 120, 30)
                dxDrawRectangle(contentX + 290, contentY, 120, 30, depHover and tocolor(50, 160, 70, 255) or tocolor(40, 130, 55, 255), false)
                dxDrawText("DEPOSIT", contentX + 290, contentY, contentX + 410, contentY + 30, tocolor(255, 255, 255), 0.8, FONT_BODY, "center", "center")

                local wdHover = isMouseIn(mx, my, contentX + 425, contentY, 120, 30)
                local canWd = acct.canWithdraw
                dxDrawRectangle(contentX + 425, contentY, 120, 30,
                    wdHover and tocolor(50, 100, 160, 255) or tocolor(40, 80, 130, 255), false)
                dxDrawText("WITHDRAW", contentX + 425, contentY, contentX + 545, contentY + 30,
                    canWd and tocolor(255, 255, 255, 255) or tocolor(120, 130, 140, 255), 0.8, FONT_BODY, "center", "center")

                local histHover = isMouseIn(mx, my, contentX + 560, contentY, 120, 30)
                dxDrawRectangle(contentX + 560, contentY, 120, 30, histHover and tocolor(180, 140, 40, 255) or tocolor(150, 110, 30, 255), false)
                dxDrawText("HISTORY", contentX + 560, contentY, contentX + 680, contentY + 30, tocolor(255, 255, 255), 0.8, FONT_BODY, "center", "center")

                contentY = contentY + 42
                if not canWd then
                    dxDrawText("Withdraw requires sufficient rank / ownership for this account.",
                        contentX, contentY, contentX + contentW, contentY + 22, tocolor(200, 140, 80, 255), 0.8, FONT_SMALL, "left", "top")
                end

                local hist = (Mzansi.GroupBankUI and Mzansi.GroupBankUI._history) or {}
                if #hist > 0 then
                    contentY = contentY + 26
                    dxDrawText("RECENT ACTIVITY", contentX, contentY, contentX + contentW, contentY + 22, gold, 0.9, FONT_TITLE, "left", "top")
                    contentY = contentY + 26
                    for hi = 1, math.min(5, #hist) do
                        local hrow = hist[hi]
                        dxDrawText(tostring(hrow.tx_type or "?") .. "  " ..
                            Mzansi.Util.formatMoney(tonumber(hrow.amount) or 0) .. "  —  " .. tostring(hrow.detail or ""),
                            contentX + 10, contentY, contentX + contentW, contentY + 20,
                            tocolor(150, 170, 190, 255), 0.75, FONT_SMALL, "left", "top")
                        contentY = contentY + 20
                    end
                end
            end
        end
    end
end)

-- ==============================================================
-- CLICK HANDLER
-- ==============================================================
addEventHandler("onClientClick", root, function(button, state, mx, my)
    if button ~= "left" or state ~= "down" then return end
    if not Mzansi.BankUI._visible then return end

    local sx, sy = screen()
    local w, h = 820, 540
    local x = (sx - w) / 2
    local y = (sy - h) / 2
    local status = Mzansi.BankUI._status
    if not status then return end

    local contentX = x + 20
    local tabY = y + 60

    -- Tab clicks
    local tabW = (w - 40) / #TABS
    for i, _ in ipairs(TABS) do
        local tx = contentX + (i - 1) * tabW
        if isMouseIn(mx, my, tx, tabY, tabW - 4, 32) then
            Mzansi.BankUI._tab = i
            Mzansi.BankUI._scroll = 0
            Mzansi.BankUI._inputMode = nil
            if i == 4 then
                triggerServerEvent("mzansi:bank:requestHistory", localPlayer)
            end
            if i == 5 and Mzansi.GroupBankUI and Mzansi.GroupBankUI.request then
                Mzansi.GroupBankUI.request()
            end
            playSoundFrontEnd(41)
            return
        end
    end

    local contentY = tabY + 42
    local contentW = w - 40

    -- TAB 1: Overview
    if Mzansi.BankUI._tab == 1 then
        local actionY = contentY + 90 + 30 + (#{"a","b","c","d"} * 0)  -- stats section is dynamic
        -- Recalculate: cards(75) + gap(15) + stats title(30) + 5 stats(120) + gap(15) + actions title(30)
        actionY = contentY + 75 + 15 + 30 + (5 * 24) + 15 + 30

        local bw, bh = 140, 38
        local buttons = { "dep1000", "dep5000", "wd1000", "wd5000" }
        for i, action in ipairs(buttons) do
            local bx = contentX + (i - 1) * (bw + 12)
            if isMouseIn(mx, my, bx, actionY, bw, bh) then
                local amt = (action == "dep1000" or action == "wd1000") and 1000 or 5000
                if string.find(action, "dep") then
                    triggerServerEvent("mzansi:bank:deposit", localPlayer, amt)
                else
                    triggerServerEvent("mzansi:bank:withdraw", localPlayer, amt)
                end
                playSoundFrontEnd(41)
                return
            end
        end

        -- Custom amount input field
        local inputY = actionY + bh + 15
        if isMouseIn(mx, my, contentX + 150, inputY, 200, 30) then
            Mzansi.BankUI._inputMode = "amount"
            return
        end

        -- Custom deposit button
        if isMouseIn(mx, my, contentX + 370, inputY, 100, 30) then
            local amt = tonumber(Mzansi.BankUI._amount)
            if amt and amt > 0 then
                triggerServerEvent("mzansi:bank:deposit", localPlayer, amt)
                playSoundFrontEnd(41)
            end
            return
        end

        -- Custom withdraw button
        if isMouseIn(mx, my, contentX + 485, inputY, 100, 30) then
            local amt = tonumber(Mzansi.BankUI._amount)
            if amt and amt > 0 then
                triggerServerEvent("mzansi:bank:withdraw", localPlayer, amt)
                playSoundFrontEnd(41)
            end
            return
        end

        Mzansi.BankUI._inputMode = nil

    -- TAB 2: Transfer
    elseif Mzansi.BankUI._tab == 2 then
        local ty = contentY + 35
        -- Target input
        if isMouseIn(mx, my, contentX + 185, ty, 300, 32) then
            Mzansi.BankUI._inputMode = "target"
            return
        end
        ty = ty + 45
        -- Amount input
        if isMouseIn(mx, my, contentX + 185, ty, 300, 32) then
            Mzansi.BankUI._inputMode = "amount"
            return
        end
        ty = ty + 45 + 30 + 30 + 35
        -- Send button
        if isMouseIn(mx, my, contentX, ty, 160, 40) then
            local target = Mzansi.BankUI._target
            local amt = tonumber(Mzansi.BankUI._amount)
            if not target or #target < 1 then
                Mzansi.Util.sendNotification(localPlayer, "Enter a recipient.", "error")
                return
            end
            if not amt or amt <= 0 then
                Mzansi.Util.sendNotification(localPlayer, "Enter a valid amount.", "error")
                return
            end
            triggerServerEvent("mzansi:bank:transfer", localPlayer, target, amt)
            playSoundFrontEnd(41)
            return
        end
        Mzansi.BankUI._inputMode = nil

    -- TAB 3: Loans
    elseif Mzansi.BankUI._tab == 3 then
        local ly = contentY + 35
        if (status.loanOwed or 0) > 0 then
            ly = ly + 60
            -- Repay amount input
            if isMouseIn(mx, my, contentX + 165, ly, 200, 30) then
                Mzansi.BankUI._inputMode = "amount"
                return
            end
            -- Repay button
            if isMouseIn(mx, my, contentX + 380, ly, 130, 30) then
                local amt = tonumber(Mzansi.BankUI._amount)
                if amt and amt > 0 then
                    triggerServerEvent("mzansi:bank:repayLoan", localPlayer, amt)
                    playSoundFrontEnd(41)
                end
                return
            end
            -- Repay all
            if isMouseIn(mx, my, contentX + 525, ly, 130, 30) then
                triggerServerEvent("mzansi:bank:repayLoan", localPlayer, status.loanOwed)
                playSoundFrontEnd(41)
                return
            end
            ly = ly + 50
        else
            ly = ly + 35
        end

        ly = ly + 30  -- title
        local tiers = status.loanTiers or {}
        -- Tier select
        for i, tier in ipairs(tiers) do
            local ty = ly + (i - 1) * 55
            if isMouseIn(mx, my, contentX + contentW - 100, ty + 10, 85, 30) then
                Mzansi.BankUI._loanTier = i
                playSoundFrontEnd(41)
                return
            end
        end

        ly = ly + #tiers * 55 + 15
        -- Loan amount input
        if isMouseIn(mx, my, contentX + 145, ly, 200, 30) then
            Mzansi.BankUI._inputMode = "amount"
            return
        end
        -- Take loan
        if isMouseIn(mx, my, contentX + 360, ly, 150, 30) then
            local amt = tonumber(Mzansi.BankUI._amount)
            if amt and amt > 0 then
                triggerServerEvent("mzansi:bank:requestLoan", localPlayer, Mzansi.BankUI._loanTier, amt)
                playSoundFrontEnd(41)
            end
            return
        end
        Mzansi.BankUI._inputMode = nil

    -- TAB 5: Groups
    elseif Mzansi.BankUI._tab == 5 then
        local accounts = (Mzansi.GroupBankUI and Mzansi.GroupBankUI._accounts) or {}
        local listY = contentY + 32 + 30
        local sel = (Mzansi.GroupBankUI and Mzansi.GroupBankUI._selected) or 1
        for i = 1, #accounts do
            local ty = listY + (i - 1) * 42
            if ty + 40 > y + h - 70 then break end
            if isMouseIn(mx, my, contentX, ty, contentW, 40) then
                if Mzansi.GroupBankUI and Mzansi.GroupBankUI.select then
                    Mzansi.GroupBankUI.select(i)
                end
                playSoundFrontEnd(41)
                return
            end
        end
        local acct = accounts[sel]
        if acct then
            local actionY = listY + #accounts * 42 + 12
            if isMouseIn(mx, my, contentX + 95, actionY, 180, 30) then
                Mzansi.BankUI._inputMode = "amount"
                return
            end
            if isMouseIn(mx, my, contentX + 290, actionY, 120, 30) then
                local amt = tonumber(Mzansi.BankUI._amount)
                if amt and amt > 0 and Mzansi.GroupBankUI and Mzansi.GroupBankUI.deposit then
                    Mzansi.GroupBankUI.deposit(acct.owner_type, acct.owner_id, amt)
                    playSoundFrontEnd(41)
                end
                return
            end
            if isMouseIn(mx, my, contentX + 425, actionY, 120, 30) then
                if not acct.canWithdraw then
                    Mzansi.Util.sendNotification(localPlayer, "You lack withdraw rights.", "error")
                    return
                end
                local amt = tonumber(Mzansi.BankUI._amount)
                if amt and amt > 0 and Mzansi.GroupBankUI and Mzansi.GroupBankUI.withdraw then
                    Mzansi.GroupBankUI.withdraw(acct.owner_type, acct.owner_id, amt)
                    playSoundFrontEnd(41)
                end
                return
            end
            if isMouseIn(mx, my, contentX + 560, actionY, 120, 30) then
                if Mzansi.GroupBankUI then
                    triggerServerEvent("mzansi:groupbank:requestHistory", localPlayer, acct.id)
                end
                playSoundFrontEnd(41)
                return
            end
        end
        Mzansi.BankUI._inputMode = nil
    end
end)

-- ==============================================================
-- KEYBOARD INPUT
-- ==============================================================
addEventHandler("onClientKey", root, function(button, pressed)
    if not Mzansi.BankUI._visible then return end
    if not pressed then return end

    -- Close on N/X
    if button == "n" or button == "x" then
        Mzansi.BankUI.close()
        cancelEvent()
        return
    end

    if not Mzansi.BankUI._inputMode then return end

    if button == "backspace" then
        if Mzansi.BankUI._inputMode == "amount" then
            Mzansi.BankUI._amount = string.sub(Mzansi.BankUI._amount, 1, -2)
        elseif Mzansi.BankUI._inputMode == "target" then
            Mzansi.BankUI._target = string.sub(Mzansi.BankUI._target, 1, -2)
        end
        cancelEvent()
    elseif button == "enter" then
        Mzansi.BankUI._inputMode = nil
        cancelEvent()
    elseif button == "escape" then
        Mzansi.BankUI._inputMode = nil
        cancelEvent()
    elseif Mzansi.BankUI._inputMode == "amount" then
        if #button == 1 and button:match("%d") then
            if #Mzansi.BankUI._amount < 9 then
                Mzansi.BankUI._amount = Mzansi.BankUI._amount .. button
            end
            cancelEvent()
        end
    elseif Mzansi.BankUI._inputMode == "target" then
        if #button == 1 then
            if #Mzansi.BankUI._target < 32 then
                Mzansi.BankUI._target = Mzansi.BankUI._target .. button
            end
            cancelEvent()
        end
    end
end)

-- Mouse wheel for history scroll (MTA has no onClientMouseWheel — use onClientKey)
addEventHandler("onClientKey", root, function(button, pressed)
    if not Mzansi.BankUI._visible or Mzansi.BankUI._tab ~= 4 then return end
    if not pressed then return end
    if button == "mouse_wheel_up" then
        Mzansi.BankUI._scroll = math.max(0, Mzansi.BankUI._scroll - 1)
        cancelEvent()
    elseif button == "mouse_wheel_down" then
        Mzansi.BankUI._scroll = Mzansi.BankUI._scroll + 1
        cancelEvent()
    end
end)
