Mzansi = Mzansi or {}
Mzansi.Phone = {}
Mzansi.Phone._visible = false
Mzansi.Phone._animY = 1.0 -- 0.0 = fully open, 1.0 = hidden below screen
Mzansi.Phone._currentScreen = "home" -- home, dialer, call, messages, bank, emergency, contacts
Mzansi.Phone._myNumber = "082 --- ----"
Mzansi.Phone._cash = 0
Mzansi.Phone._bank = 0
Mzansi.Phone._contacts = {}
Mzansi.Phone._messages = {}

-- Active Call State
Mzansi.Phone._activeCall = nil -- { number = "...", name = "...", duration = 0, state = "calling" | "ringing" | "connected", isConference = false, memberCount = 1 }
Mzansi.Phone._showConferenceAdd = false
Mzansi.Phone._isSpeaking = false

-- GUI Inputs for typing
local editDialNumber = nil
local editSMSNumber = nil
local editSMSMessage = nil
local editContactName = nil
local editContactNumber = nil
local editBankTarget = nil
local editBankAmount = nil
local editConferenceNumber = nil

local function isMouseIn(x, y, w, h)
    local mx, my = getCursorPosition()
    if not mx or not my then return false end
    local sx, sy = guiGetScreenSize()
    mx, my = mx * sx, my * sy
    return mx >= x and mx <= x + w and my >= y and my <= y + h
end

function Mzansi.Phone.hideAllInputs()
    if editDialNumber then guiSetVisible(editDialNumber, false) end
    if editSMSNumber then guiSetVisible(editSMSNumber, false) end
    if editSMSMessage then guiSetVisible(editSMSMessage, false) end
    if editContactName then guiSetVisible(editContactName, false) end
    if editContactNumber then guiSetVisible(editContactNumber, false) end
    if editBankTarget then guiSetVisible(editBankTarget, false) end
    if editBankAmount then guiSetVisible(editBankAmount, false) end
    if editConferenceNumber then guiSetVisible(editConferenceNumber, false) end
end

-- Update input visibility only when screen changes or phone toggles (preserves keyboard focus)
function Mzansi.Phone.updateInputVisibility()
    Mzansi.Phone.hideAllInputs()
    if not Mzansi.Phone._visible then return end

    local s = Mzansi.Phone._currentScreen
    if s == "dialer" and editDialNumber then
        guiSetVisible(editDialNumber, true)
        guiBringToFront(editDialNumber)
    elseif s == "call" and editConferenceNumber and Mzansi.Phone._showConferenceAdd then
        guiSetVisible(editConferenceNumber, true)
        guiBringToFront(editConferenceNumber)
    elseif s == "messages" and editSMSNumber and editSMSMessage then
        guiSetVisible(editSMSNumber, true)
        guiSetVisible(editSMSMessage, true)
        guiBringToFront(editSMSNumber)
    elseif s == "contacts" and editContactName and editContactNumber then
        guiSetVisible(editContactName, true)
        guiSetVisible(editContactNumber, true)
        guiBringToFront(editContactName)
    elseif s == "bank" and editBankTarget and editBankAmount then
        guiSetVisible(editBankTarget, true)
        guiSetVisible(editBankAmount, true)
        guiBringToFront(editBankTarget)
    end
end

-- Update input positions smoothly during sliding without resetting focus
function Mzansi.Phone.updateInputPositions(px, py)
    if not Mzansi.Phone._visible then return end

    local s = Mzansi.Phone._currentScreen
    if s == "dialer" and editDialNumber then
        guiSetPosition(editDialNumber, px + 25, py + 120, false)
    elseif s == "call" and editConferenceNumber then
        guiSetPosition(editConferenceNumber, px + 25, py + 395, false)
    elseif s == "messages" and editSMSNumber and editSMSMessage then
        guiSetPosition(editSMSNumber, px + 25, py + 120, false)
        guiSetPosition(editSMSMessage, px + 25, py + 160, false)
    elseif s == "contacts" and editContactName and editContactNumber then
        guiSetPosition(editContactName, px + 25, py + 120, false)
        guiSetPosition(editContactNumber, px + 25, py + 160, false)
    elseif s == "bank" and editBankTarget and editBankAmount then
        guiSetPosition(editBankTarget, px + 25, py + 230, false)
        guiSetPosition(editBankAmount, px + 25, py + 270, false)
    end
end

function Mzansi.Phone.toggle()
    if isChatBoxInputActive() or isConsoleActive() then return end

    Mzansi.Phone._visible = not Mzansi.Phone._visible
    showCursor(Mzansi.Phone._visible)

    if Mzansi.Phone._visible then
        -- Close others FIRST (they may call showCursor(false)), then claim cursor
        triggerEvent("mzansi:dashboard:close", localPlayer)
        triggerEvent("mzansi:radio:close", localPlayer)
        triggerEvent("mzansi:freeroam:close", localPlayer)
        triggerEvent("mzansi:admin:close", localPlayer)
        triggerEvent("mzansi:flight:close", localPlayer)
        triggerEvent("mzansi:market:close", localPlayer)
        triggerEvent("mzansi:bank:close", localPlayer)
        triggerEvent("mzansi:shop:closeUI", localPlayer)
        showCursor(true)
        triggerServerEvent("mzansi:phone:requestData", localPlayer)
        triggerServerEvent("mzansi:phone:getContacts", localPlayer)
        triggerServerEvent("mzansi:phone:getMessages", localPlayer)
        triggerServerEvent("mzansi:phone:getAppStore", localPlayer)
        Mzansi.Phone._appPage = 1
        Mzansi.Phone.updateInputVisibility()
        playSoundFrontEnd(41)
    else
        Mzansi.Phone.hideAllInputs()
        showCursor(false)
        playSoundFrontEnd(42)
    end
end

function Mzansi.Phone.openScreen(screenName)
    Mzansi.Phone._currentScreen = screenName
    Mzansi.Phone.updateInputVisibility()
    playSoundFrontEnd(40)
end

-- Create GUI Elements on Start
addEventHandler("onClientResourceStart", resourceRoot, function()
    editDialNumber = guiCreateEdit(0, 0, 250, 32, "", false)
    editSMSNumber = guiCreateEdit(0, 0, 250, 32, "", false)
    editSMSMessage = guiCreateEdit(0, 0, 250, 32, "", false)
    editContactName = guiCreateEdit(0, 0, 250, 32, "", false)
    editContactNumber = guiCreateEdit(0, 0, 250, 32, "", false)
    editBankTarget = guiCreateEdit(0, 0, 250, 32, "", false)
    editBankAmount = guiCreateEdit(0, 0, 250, 32, "", false)
    editConferenceNumber = guiCreateEdit(0, 0, 160, 30, "", false)

    -- Style edits with validation
    guiSetProperty(editDialNumber, "ValidationString", "[0-9*# ]*")
    guiSetProperty(editBankAmount, "ValidationString", "[0-9]*")
    guiSetProperty(editConferenceNumber, "ValidationString", "[0-9*# ]*")

    Mzansi.Phone.hideAllInputs()
    -- Phone: NumLock (primary) + F9 (F-key UI). No letter keys (avoids login/password conflicts).
    local function phoneToggleBlocked()
        if Mzansi.Util and Mzansi.Util.bindBlocked and Mzansi.Util.bindBlocked() then return true end
        if Mzansi.Cutscene and Mzansi.Cutscene.isPlaying and Mzansi.Cutscene.isPlaying() then return true end
        return false
    end
    bindKey("numlock", "down", function()
        if phoneToggleBlocked() then return end
        Mzansi.Phone.toggle()
    end)
    bindKey("f9", "down", function()
        if phoneToggleBlocked() then return end
        Mzansi.Phone.toggle()
    end)
    addCommandHandler("phone", function()
        if phoneToggleBlocked() then return end
        Mzansi.Phone.toggle()
    end)
end)

-- Mutual exclusion event
addEvent("mzansi:phone:close", true)
addEventHandler("mzansi:phone:close", root, function()
    if Mzansi.Phone._visible then
        Mzansi.Phone.toggle()
    end
end)

-- App Store / registry receive (populates home screen grid)
addEvent("mzansi:phone:appStore", true)
addEventHandler("mzansi:phone:appStore", root, function(apps)
    if type(apps) == "table" and #apps > 0 then
        Mzansi.Phone._apps = apps
    end
end)

-- Main Render Loop
addEventHandler("onClientRender", root, function()
    -- Smooth Slide Animation
    local targetY = Mzansi.Phone._visible and 0.0 or 1.0
    Mzansi.Phone._animY = Mzansi.Phone._animY + (targetY - Mzansi.Phone._animY) * 0.25

    if Mzansi.Phone._animY >= 0.99 and not Mzansi.Phone._visible then
        return
    end

    local sx, sy = guiGetScreenSize()
    local pw, ph = 300, 540
    local px = sx - pw - 30
    local py = sy - ph - 30 + (Mzansi.Phone._animY * (ph + 50))

    -- Update input positions smoothly during sliding
    Mzansi.Phone.updateInputPositions(px, py)

    -- 1. Outer Chassis & Shadow (postGUI = false so CEGUI editboxes draw ON TOP)
    dxDrawRectangle(px - 5, py - 5, pw + 10, ph + 10, tocolor(5, 5, 10, 180), false)
    dxDrawRectangle(px, py, pw, ph, tocolor(15, 20, 30, 255), false)
    dxDrawRectangle(px, py, pw, 3, tocolor(200, 170, 50, 255), false) -- South African Gold Top Accent

    -- 2. Speaker Grill & Camera Notch
    dxDrawRectangle(px + (pw / 2) - 25, py + 8, 50, 4, tocolor(40, 45, 55, 255), false)
    dxDrawRectangle(px + (pw / 2) + 35, py + 8, 6, 6, tocolor(20, 25, 35, 255), false)

    -- 3. Top Status Bar (Carrier, Time, 5G, Battery)
    local time = getRealTime()
    local timeStr = string.format("%02d:%02d", time.hour, time.minute)
    dxDrawText("Mzansi Mobile", px + 15, py + 18, px + 120, py + 32, tocolor(160, 175, 190, 220), 0.75, "default-bold", "left", "center", false, false, false)
    dxDrawText(timeStr, px + (pw / 2) - 30, py + 18, px + (pw / 2) + 30, py + 32, tocolor(255, 255, 255, 255), 0.8, "default-bold", "center", "center", false, false, false)
    dxDrawText("5G ▮▮▮ 98%", px + pw - 90, py + 18, px + pw - 15, py + 32, tocolor(160, 220, 255, 220), 0.75, "default-bold", "right", "center", false, false, false)

    -- 4. Bottom Navigation / Home Bar
    local navY = py + ph - 42
    dxDrawRectangle(px, navY, pw, 42, tocolor(10, 15, 24, 255), false)
    local homeHover = isMouseIn(px + (pw / 2) - 35, navY + 6, 70, 30)
    dxDrawRectangle(px + (pw / 2) - 30, navY + 16, 60, 5, homeHover and tocolor(200, 170, 50, 255) or tocolor(120, 130, 145, 200), false)

    if Mzansi.Phone._currentScreen ~= "home" then
        local backHover = isMouseIn(px + 20, navY + 6, 40, 30)
        dxDrawText("◀", px + 20, navY + 6, px + 60, navY + 36, backHover and tocolor(200, 170, 50, 255) or tocolor(160, 175, 190, 220), 1.0, "default-bold", "center", "center", false, false, false)
    end

    -- 5. Render Active Screen
    local screen = Mzansi.Phone._currentScreen
    if Mzansi.Phone._activeCall then
        Mzansi.Phone.renderCallScreen(px, py, pw, ph)
    elseif screen == "home" then
        Mzansi.Phone.renderHomeScreen(px, py, pw, ph)
    elseif screen == "dialer" then
        Mzansi.Phone.renderDialerScreen(px, py, pw, ph)
    elseif screen == "messages" then
        Mzansi.Phone.renderMessagesScreen(px, py, pw, ph)
    elseif screen == "bank" then
        Mzansi.Phone.renderBankScreen(px, py, pw, ph)
    elseif screen == "emergency" then
        Mzansi.Phone.renderEmergencyScreen(px, py, pw, ph)
    elseif screen == "contacts" then
        Mzansi.Phone.renderContactsScreen(px, py, pw, ph)
    end
end)

-- SCREEN: Home Screen
function Mzansi.Phone.renderHomeScreen(px, py, pw, ph)
    -- Wallpaper Card
    dxDrawRectangle(px + 15, py + 40, pw - 30, 85, tocolor(20, 35, 60, 240), false)
    dxDrawRectangle(px + 15, py + 40, 3, 85, tocolor(200, 170, 50, 255), false)
    dxDrawText("MZANSI SMARTPHONE", px + 30, py + 50, px + pw - 25, py + 70, tocolor(200, 170, 50, 255), 0.95, "default-bold", "left", "top", false, false, false)
    dxDrawText("My Number: " .. Mzansi.Phone._myNumber, px + 30, py + 72, px + pw - 25, py + 90, tocolor(180, 210, 240, 255), 0.8, "default", "left", "top", false, false, false)
    dxDrawText("Bank: " .. Mzansi.Util.formatMoney(Mzansi.Phone._bank), px + 30, py + 92, px + pw - 25, py + 110, tocolor(100, 230, 140, 255), 0.85, "default-bold", "left", "top", false, false, false)

    -- Fallback 6 core apps if server registry not loaded yet
    local apps = Mzansi.Phone._apps
    if not apps or #apps == 0 then
        apps = {
            { id = "dialer",    name = "Phone",    icon = "📞", color = { 40, 180, 100 } },
            { id = "messages",  name = "SMS",      icon = "💬", color = { 60, 140, 240 } },
            { id = "banking",   name = "Banking",  icon = "🏦", color = { 220, 160, 40 } },
            { id = "emergency", name = "911 SOS",  icon = "🚨", color = { 240, 60, 60 } },
            { id = "contacts",  name = "Contacts", icon = "👥", color = { 140, 90, 220 } },
            { id = "uber",      name = "Hail Taxi",icon = "🚕", color = { 240, 200, 50 } },
        }
    end

    -- Pagination: 6 apps per page (2 rows x 3 cols fits phone height)
    local pageSize = 6
    local totalPages = math.max(1, math.ceil(#apps / pageSize))
    local page = math.min(math.max(Mzansi.Phone._appPage or 1, 1), totalPages)
    Mzansi.Phone._appPage = page
    local startIndex = (page - 1) * pageSize + 1
    local endIndex = math.min(startIndex + pageSize - 1, #apps)

    local startY = py + 145
    local colW = (pw - 60) / 3
    for i = startIndex, endIndex do
        local app = apps[i]
        local slot = i - startIndex
        local row = math.floor(slot / 3)
        local col = slot % 3
        local ax = px + 20 + col * (colW + 10)
        local ay = startY + row * 95

        local isHover = isMouseIn(ax, ay, colW, 75)
        dxDrawRectangle(ax, ay, colW, 75, isHover and tocolor(35, 50, 75, 255) or tocolor(22, 30, 45, 230), false)
        local colr = app.color and tocolor(app.color[1], app.color[2], app.color[3], 255) or tocolor(80, 100, 140, 255)
        dxDrawRectangle(ax, ay + 72, colW, 3, colr, false)
        dxDrawText(app.icon or "📱", ax, ay + 10, ax + colW, ay + 45, tocolor(255, 255, 255, 255), 1.5, "default-bold", "center", "center", false, false, false)
        dxDrawText(app.name or app.id, ax, ay + 50, ax + colW, ay + 70, tocolor(220, 230, 240, 255), 0.7, "default-bold", "center", "center", true, false, false)
    end

    -- Pagination bar
    if totalPages > 1 then
        local barY = py + 340
        local prevHover = isMouseIn(px + 20, barY, 60, 28)
        dxDrawRectangle(px + 20, barY, 60, 28, prevHover and tocolor(45, 65, 95, 255) or tocolor(24, 34, 50, 240), false)
        dxDrawText("◀", px + 20, barY, px + 80, barY + 28, tocolor(255, 255, 255, 255), 1.0, "default-bold", "center", "center")

        dxDrawText("Page " .. page .. "/" .. totalPages .. "  (" .. #apps .. " apps)", px + 90, barY, px + pw - 90, barY + 28, tocolor(180, 200, 220, 230), 0.8, "default", "center", "center")

        local nextHover = isMouseIn(px + pw - 80, barY, 60, 28)
        dxDrawRectangle(px + pw - 80, barY, 60, 28, nextHover and tocolor(45, 65, 95, 255) or tocolor(24, 34, 50, 240), false)
        dxDrawText("▶", px + pw - 80, barY, px + pw - 20, barY + 28, tocolor(255, 255, 255, 255), 1.0, "default-bold", "center", "center")
    end
end

-- SCREEN: Dialer Screen
function Mzansi.Phone.renderDialerScreen(px, py, pw, ph)
    dxDrawText("PHONE DIALPAD", px + 25, py + 42, px + pw - 25, py + 62, tocolor(200, 170, 50, 255), 1.0, "default-bold", "center", "top", false, false, false)
    dxDrawText("Enter number or fast-dial (911 / 411)", px + 25, py + 64, px + pw - 25, py + 84, tocolor(150, 170, 190, 200), 0.75, "default", "center", "top", false, false, false)

    -- Dialpad Buttons (1-9, *, 0, #)
    local buttons = {
        "1", "2", "3",
        "4", "5", "6",
        "7", "8", "9",
        "*", "0", "#"
    }

    local btnY = py + 165
    local bw = 65
    local bh = 42
    local gap = 15
    for i, b in ipairs(buttons) do
        local row = math.floor((i - 1) / 3)
        local col = (i - 1) % 3
        local bx = px + 35 + col * (bw + gap)
        local by = btnY + row * (bh + 8)

        local isHover = isMouseIn(bx, by, bw, bh)
        dxDrawRectangle(bx, by, bw, bh, isHover and tocolor(45, 65, 95, 255) or tocolor(24, 34, 50, 240), false)
        dxDrawText(b, bx, by, bx + bw, by + bh, tocolor(255, 255, 255, 255), 1.1, "default-bold", "center", "center", false, false, false)
    end

    -- Large Green Call Button & Backspace
    local callHover = isMouseIn(px + 45, py + 380, 140, 42)
    dxDrawRectangle(px + 45, py + 380, 140, 42, callHover and tocolor(50, 210, 110, 255) or tocolor(35, 170, 85, 255), false)
    dxDrawText("📞 DIAL", px + 45, py + 380, px + 185, py + 422, tocolor(255, 255, 255, 255), 0.95, "default-bold", "center", "center", false, false, false)

    local delHover = isMouseIn(px + 195, py + 380, 60, 42)
    dxDrawRectangle(px + 195, py + 380, 60, 42, delHover and tocolor(220, 60, 60, 255) or tocolor(160, 40, 40, 255), false)
    dxDrawText("⌫", px + 195, py + 380, px + 255, py + 422, tocolor(255, 255, 255, 255), 1.1, "default-bold", "center", "center", false, false, false)
end

-- SCREEN: Active Call
function Mzansi.Phone.renderCallScreen(px, py, pw, ph)
    local call = Mzansi.Phone._activeCall
    if not call then return end

    dxDrawRectangle(px + 15, py + 45, pw - 30, ph - 95, tocolor(12, 18, 28, 250), false)
    dxDrawText(call.isConference and "MZANSI CONFERENCE CALL" or "MZANSI VOICE CALL", px + 25, py + 58, px + pw - 25, py + 78, tocolor(200, 170, 50, 255), 0.95, "default-bold", "center", "top", false, false, false)

    -- Avatar Circle representation
    dxDrawRectangle(px + (pw / 2) - 35, py + 85, 70, 70, tocolor(30, 45, 70, 255), false)
    dxDrawText(call.isConference and "👥" or "👤", px + (pw / 2) - 35, py + 85, px + (pw / 2) + 35, py + 155, tocolor(200, 170, 50, 255), 2.0, "default-bold", "center", "center", false, false, false)

    dxDrawText(call.name or "Citizen", px + 25, py + 160, px + pw - 25, py + 180, tocolor(255, 255, 255, 255), 1.05, "default-bold", "center", "top", false, false, false)
    dxDrawText(call.number or "", px + 25, py + 180, px + pw - 25, py + 198, tocolor(150, 180, 210, 220), 0.8, "default", "center", "top", false, false, false)

    if call.state == "ringing" then
        dxDrawText("Incoming Call...", px + 25, py + 220, px + pw - 25, py + 245, tocolor(240, 200, 50, 255), 1.0, "default-bold", "center", "top", false, false, false)

        -- Answer & Decline Buttons
        local ansHover = isMouseIn(px + 35, py + 300, 105, 45)
        dxDrawRectangle(px + 35, py + 300, 105, 45, ansHover and tocolor(50, 220, 110, 255) or tocolor(35, 180, 85, 255), false)
        dxDrawText("ANSWER", px + 35, py + 300, px + 140, py + 345, tocolor(255, 255, 255, 255), 0.9, "default-bold", "center", "center", false, false, false)

        local decHover = isMouseIn(px + 160, py + 300, 105, 45)
        dxDrawRectangle(px + 160, py + 300, 105, 45, decHover and tocolor(240, 60, 60, 255) or tocolor(180, 40, 40, 255), false)
        dxDrawText("DECLINE", px + 160, py + 300, px + 265, py + 345, tocolor(255, 255, 255, 255), 0.9, "default-bold", "center", "center", false, false, false)
    else
        local statusText = call.isConference and ("Conference Room (" .. tostring(call.memberCount or 2) .. " Members) • Live") or "1-on-1 Call Connected • Live"
        dxDrawText(statusText, px + 25, py + 205, px + pw - 25, py + 225, tocolor(50, 220, 110, 255), 0.8, "default-bold", "center", "top", false, false, false)

        -- Voice Indicator & Dynamic Waveform
        local now = getTickCount()
        local isTransmitting = Mzansi.Phone._isSpeaking
        if isTransmitting then
            dxDrawText("🎙️ LIVE TRANSMITTING (Voice Routed)", px + 25, py + 230, px + pw - 25, py + 248, tocolor(70, 240, 120, 255), 0.8, "default-bold", "center", "top", false, false, false)
            -- Animated audio wave bars
            for b = 1, 7 do
                local barH = 6 + math.abs(math.sin((now / 110) + b * 0.85)) * 18
                local barX = px + (pw / 2) - 38 + (b * 10)
                dxDrawRectangle(barX, py + 265 - (barH / 2), 6, barH, tocolor(70, 240, 120, 230), false)
            end
        else
            dxDrawText("🎙️ Voice Active (Hold 'Z' to Speak)", px + 25, py + 230, px + pw - 25, py + 248, tocolor(160, 200, 230, 220), 0.78, "default", "center", "top", false, false, false)
            -- Idle wave bars
            for b = 1, 7 do
                local barX = px + (pw / 2) - 38 + (b * 10)
                dxDrawRectangle(barX, py + 263, 6, 4, tocolor(100, 140, 180, 160), false)
            end
        end

        -- Action Buttons: [👥 + MEMBER] and [🔴 HANG UP]
        local btnW = 110
        local addHover = isMouseIn(px + 28, py + 285, btnW, 40)
        dxDrawRectangle(px + 28, py + 285, btnW, 40, addHover and tocolor(45, 110, 200, 255) or tocolor(30, 80, 160, 255), false)
        dxDrawText(Mzansi.Phone._showConferenceAdd and "▲ CLOSE" or "👥 + MEMBER", px + 28, py + 285, px + 28 + btnW, py + 325, tocolor(255, 255, 255, 255), 0.8, "default-bold", "center", "center", false, false, false)

        local endHover = isMouseIn(px + 162, py + 285, btnW, 40)
        dxDrawRectangle(px + 162, py + 285, btnW, 40, endHover and tocolor(240, 60, 60, 255) or tocolor(180, 40, 40, 255), false)
        dxDrawText("🔴 HANG UP", px + 162, py + 285, px + 162 + btnW, py + 325, tocolor(255, 255, 255, 255), 0.8, "default-bold", "center", "center", false, false, false)

        -- If Conference Add section is toggled open
        if Mzansi.Phone._showConferenceAdd then
            dxDrawRectangle(px + 20, py + 345, pw - 40, 85, tocolor(18, 25, 40, 245), false)
            dxDrawText("Add Citizen / Phone to Conference:", px + 25, py + 352, px + pw - 25, py + 370, tocolor(200, 170, 50, 255), 0.75, "default-bold", "left", "top", false, false, false)
            dxDrawText("Type Phone Number or Citizen ID:", px + 25, py + 372, px + pw - 25, py + 390, tocolor(160, 175, 190, 200), 0.7, "default", "left", "top", false, false, false)

            -- [MERGE] Button next to editConferenceNumber
            local mergeHover = isMouseIn(px + 195, py + 395, 75, 30)
            dxDrawRectangle(px + 195, py + 395, 75, 30, mergeHover and tocolor(50, 200, 100, 255) or tocolor(35, 150, 75, 255), false)
            dxDrawText("MERGE", px + 195, py + 395, px + 270, py + 425, tocolor(255, 255, 255, 255), 0.8, "default-bold", "center", "center", false, false, false)
        end
    end
end

-- SCREEN: SMS Messages Screen
function Mzansi.Phone.renderMessagesScreen(px, py, pw, ph)
    dxDrawText("MESSAGES (SMS)", px + 25, py + 42, px + pw - 25, py + 62, tocolor(200, 170, 50, 255), 1.0, "default-bold", "center", "top", false, false, false)

    dxDrawText("Recipient Phone Number:", px + 25, py + 102, px + pw - 25, py + 118, tocolor(160, 175, 190, 200), 0.75, "default", "left", "top", false, false, false)
    dxDrawText("Message Text:", px + 25, py + 142, px + pw - 25, py + 158, tocolor(160, 175, 190, 200), 0.75, "default", "left", "top", false, false, false)

    -- Send Button
    local sendHover = isMouseIn(px + 25, py + 200, pw - 50, 32)
    dxDrawRectangle(px + 25, py + 200, pw - 50, 32, sendHover and tocolor(60, 140, 240, 255) or tocolor(40, 100, 200, 255), false)
    dxDrawText("SEND MESSAGE", px + 25, py + 200, px + pw - 25, py + 232, tocolor(255, 255, 255, 255), 0.85, "default-bold", "center", "center", false, false, false)

    -- Recent Messages Log
    dxDrawText("RECENT CHATS (Tap to reply):", px + 25, py + 242, px + pw - 25, py + 260, tocolor(160, 175, 190, 220), 0.8, "default-bold", "left", "top", false, false, false)
    local myY = py + 265
    for i = 1, math.min(#Mzansi.Phone._messages, 3) do
        local m = Mzansi.Phone._messages[i]
        local isHover = isMouseIn(px + 25, myY, pw - 50, 48)
        dxDrawRectangle(px + 25, myY, pw - 50, 48, isHover and tocolor(30, 42, 65, 240) or tocolor(20, 28, 42, 230), false)
        dxDrawText((m.sender_number or "Unknown") .. ":", px + 35, myY + 5, px + pw - 35, myY + 22, tocolor(200, 170, 50, 255), 0.8, "default-bold", "left", "top", false, false, false)
        dxDrawText(m.message or "", px + 35, myY + 22, px + pw - 35, myY + 44, tocolor(220, 230, 240, 255), 0.75, "default", "left", "top", false, false, false)
        myY = myY + 54
    end
end

-- SCREEN: Banking Screen
function Mzansi.Phone.renderBankScreen(px, py, pw, ph)
    dxDrawText("MZANSI MOBILE BANKING", px + 25, py + 42, px + pw - 25, py + 62, tocolor(200, 170, 50, 255), 1.0, "default-bold", "center", "top", false, false, false)

    -- Card UI
    dxDrawRectangle(px + 25, py + 75, pw - 50, 100, tocolor(18, 32, 55, 250), false)
    dxDrawRectangle(px + 25, py + 75, 3, 100, tocolor(200, 170, 50, 255), false)
    dxDrawText("Standard Account", px + 38, py + 85, px + pw - 35, py + 102, tocolor(160, 180, 210, 220), 0.8, "default-bold", "left", "top", false, false, false)
    dxDrawText("AVAILABLE BALANCE", px + 38, py + 108, px + pw - 35, py + 125, tocolor(140, 160, 180, 200), 0.75, "default", "left", "top", false, false, false)
    dxDrawText(Mzansi.Util.formatMoney(Mzansi.Phone._bank), px + 38, py + 126, px + pw - 35, py + 155, tocolor(100, 235, 140, 255), 1.2, "default-bold", "left", "top", false, false, false)

    -- Transfer Section
    dxDrawText("EFT INSTANT TRANSFER", px + 25, py + 190, px + pw - 25, py + 210, tocolor(200, 170, 50, 255), 0.85, "default-bold", "left", "top", false, false, false)
    dxDrawText("Recipient (Name, Player ID, or Mobile):", px + 25, py + 212, px + pw - 25, py + 226, tocolor(160, 175, 190, 200), 0.75, "default", "left", "top", false, false, false)
    dxDrawText("Amount to Transfer (ZAR):", px + 25, py + 252, px + pw - 25, py + 266, tocolor(160, 175, 190, 200), 0.75, "default", "left", "top", false, false, false)

    -- Transfer Button
    local transferHover = isMouseIn(px + 25, py + 315, pw - 50, 38)
    dxDrawRectangle(px + 25, py + 315, pw - 50, 38, transferHover and tocolor(220, 170, 40, 255) or tocolor(180, 135, 30, 255), false)
    dxDrawText("TRANSFER FUNDS", px + 25, py + 315, px + pw - 25, py + 353, tocolor(10, 20, 35, 255), 0.95, "default-bold", "center", "center", false, false, false)
end

-- SCREEN: Emergency 911 Screen
function Mzansi.Phone.renderEmergencyScreen(px, py, pw, ph)
    dxDrawText("EMERGENCY DISPATCH", px + 25, py + 42, px + pw - 25, py + 62, tocolor(240, 60, 60, 255), 1.0, "default-bold", "center", "top", false, false, false)
    dxDrawText("1-Tap live emergency GPS beacon", px + 25, py + 64, px + pw - 25, py + 84, tocolor(160, 175, 190, 200), 0.75, "default", "center", "top", false, false, false)

    -- SAPS Button
    local sapsHover = isMouseIn(px + 25, py + 110, pw - 50, 90)
    dxDrawRectangle(px + 25, py + 110, pw - 50, 90, sapsHover and tocolor(35, 60, 110, 255) or tocolor(20, 40, 80, 240), false)
    dxDrawRectangle(px + 25, py + 110, 4, 90, tocolor(60, 140, 255, 255), false)
    dxDrawText("👮 CALL SAPS POLICE (10111)", px + 40, py + 125, px + pw - 35, py + 148, tocolor(100, 180, 255, 255), 0.9, "default-bold", "left", "top", false, false, false)
    dxDrawText("Report armed violence, robberies, or active shootouts.", px + 40, py + 150, px + pw - 35, py + 190, tocolor(180, 200, 220, 220), 0.75, "default", "left", "top", false, false, false)

    -- EMS Button
    local emsHover = isMouseIn(px + 25, py + 225, pw - 50, 90)
    dxDrawRectangle(px + 25, py + 225, pw - 50, 90, emsHover and tocolor(90, 30, 30, 255) or tocolor(65, 20, 20, 240), false)
    dxDrawRectangle(px + 25, py + 225, 4, 90, tocolor(255, 60, 60, 255), false)
    dxDrawText("🚑 CALL AMBULANCE (10177)", px + 40, py + 240, px + pw - 35, py + 263, tocolor(255, 100, 100, 255), 0.9, "default-bold", "left", "top", false, false, false)
    dxDrawText("Request paramedic trauma response and urgent medical care.", px + 40, py + 265, px + pw - 35, py + 305, tocolor(220, 180, 180, 220), 0.75, "default", "left", "top", false, false, false)
end

-- SCREEN: Contacts Screen
function Mzansi.Phone.renderContactsScreen(px, py, pw, ph)
    dxDrawText("CONTACT DIRECTORY", px + 25, py + 42, px + pw - 25, py + 62, tocolor(200, 170, 50, 255), 1.0, "default-bold", "center", "top", false, false, false)

    dxDrawText("Contact Name:", px + 25, py + 102, px + pw - 25, py + 118, tocolor(160, 175, 190, 200), 0.75, "default", "left", "top", false, false, false)
    dxDrawText("Phone Number:", px + 25, py + 142, px + pw - 25, py + 158, tocolor(160, 175, 190, 200), 0.75, "default", "left", "top", false, false, false)

    -- Save Button
    local addHover = isMouseIn(px + 25, py + 200, pw - 50, 32)
    dxDrawRectangle(px + 25, py + 200, pw - 50, 32, addHover and tocolor(160, 100, 240, 255) or tocolor(120, 70, 200, 255), false)
    dxDrawText("➕ SAVE CONTACT", px + 25, py + 200, px + pw - 25, py + 232, tocolor(255, 255, 255, 255), 0.85, "default-bold", "center", "center", false, false, false)

    -- Contacts List
    dxDrawText("SAVED CONTACTS (" .. #Mzansi.Phone._contacts .. "):", px + 25, py + 242, px + pw - 25, py + 260, tocolor(160, 175, 190, 220), 0.8, "default-bold", "left", "top", false, false, false)
    local cy = py + 265
    for i = 1, math.min(#Mzansi.Phone._contacts, 3) do
        local c = Mzansi.Phone._contacts[i]
        dxDrawRectangle(px + 25, cy, pw - 50, 48, tocolor(20, 28, 42, 230), false)
        dxDrawText(c.name or "Contact", px + 35, cy + 6, px + 170, cy + 24, tocolor(255, 255, 255, 255), 0.85, "default-bold", "left", "top", false, false, false)
        dxDrawText(c.number or "", px + 35, cy + 24, px + 170, cy + 42, tocolor(160, 175, 190, 200), 0.75, "default", "left", "top", false, false, false)

        -- Call button for contact
        local cCallHover = isMouseIn(px + pw - 105, cy + 10, 45, 28)
        dxDrawRectangle(px + pw - 105, cy + 10, 45, 28, cCallHover and tocolor(40, 180, 90, 255) or tocolor(30, 140, 70, 255), false)
        dxDrawText("CALL", px + pw - 105, cy + 10, px + pw - 60, cy + 38, tocolor(255, 255, 255, 255), 0.75, "default-bold", "center", "center", false, false, false)

        -- Delete button for contact
        local cDelHover = isMouseIn(px + pw - 55, cy + 10, 25, 28)
        dxDrawRectangle(px + pw - 55, cy + 10, 25, 28, cDelHover and tocolor(220, 50, 50, 255) or tocolor(160, 30, 30, 255), false)
        dxDrawText("✕", px + pw - 55, cy + 10, px + pw - 30, cy + 38, tocolor(255, 255, 255, 255), 0.8, "default-bold", "center", "center", false, false, false)

        cy = cy + 54
    end
end

-- Mouse Click Handler
addEventHandler("onClientClick", root, function(button, state)
    if not Mzansi.Phone._visible or button ~= "left" or state ~= "down" then return end

    local sx, sy = guiGetScreenSize()
    local pw, ph = 300, 540
    local px = sx - pw - 30
    local py = sy - ph - 30 + (Mzansi.Phone._animY * (ph + 50))

    -- Home Bar click
    local navY = py + ph - 42
    if isMouseIn(px + (pw / 2) - 35, navY + 6, 70, 30) then
        Mzansi.Phone.openScreen("home")
        return
    end

    if Mzansi.Phone._currentScreen ~= "home" and isMouseIn(px + 20, navY + 6, 40, 30) then
        Mzansi.Phone.openScreen("home")
        return
    end

    -- Active Call Clicks
    if Mzansi.Phone._activeCall then
        if Mzansi.Phone._activeCall.state == "ringing" then
            if isMouseIn(px + 35, py + 300, 105, 45) then
                triggerServerEvent("mzansi:phone:answer", localPlayer)
                return
            elseif isMouseIn(px + 160, py + 300, 105, 45) then
                triggerServerEvent("mzansi:phone:hangup", localPlayer)
                return
            end
        else
            local btnW = 110
            -- + MEMBER / CLOSE toggle button
            if isMouseIn(px + 28, py + 285, btnW, 40) then
                Mzansi.Phone._showConferenceAdd = not Mzansi.Phone._showConferenceAdd
                Mzansi.Phone.updateInputVisibility()
                playSoundFrontEnd(41)
                return
            -- HANG UP button
            elseif isMouseIn(px + 162, py + 285, btnW, 40) then
                triggerServerEvent("mzansi:phone:hangup", localPlayer)
                return
            end

            -- MERGE button if conference add section is active
            if Mzansi.Phone._showConferenceAdd and isMouseIn(px + 195, py + 395, 75, 30) then
                local num = guiGetText(editConferenceNumber)
                if num and string.len(num) > 0 then
                    triggerServerEvent("mzansi:phone:conference", localPlayer, num)
                    guiSetText(editConferenceNumber, "")
                    Mzansi.Phone._showConferenceAdd = false
                    Mzansi.Phone.updateInputVisibility()
                    playSoundFrontEnd(41)
                end
                return
            end
        end
        return
    end

    -- Home Screen Clicks
    if Mzansi.Phone._currentScreen == "home" then
        -- Pagination controls
        local apps = Mzansi.Phone._apps
        if not apps or #apps == 0 then
            apps = {
                { id = "dialer" }, { id = "messages" }, { id = "banking" },
                { id = "emergency" }, { id = "contacts" }, { id = "uber" },
            }
        end
        local pageSize = 6
        local totalPages = math.max(1, math.ceil(#apps / pageSize))
        local page = Mzansi.Phone._appPage or 1
        local barY = py + 340
        if totalPages > 1 then
            if isMouseIn(px + 20, barY, 60, 28) then
                Mzansi.Phone._appPage = math.max(1, page - 1)
                playSoundFrontEnd(40)
                return
            elseif isMouseIn(px + pw - 80, barY, 60, 28) then
                Mzansi.Phone._appPage = math.min(totalPages, page + 1)
                playSoundFrontEnd(40)
                return
            end
        end

        local startIndex = (page - 1) * pageSize + 1
        local endIndex = math.min(startIndex + pageSize - 1, #apps)
        local startY = py + 145
        local colW = (pw - 60) / 3
        for i = startIndex, endIndex do
            local app = apps[i]
            local slot = i - startIndex
            local row = math.floor(slot / 3)
            local col = slot % 3
            local ax = px + 20 + col * (colW + 10)
            local ay = startY + row * 95
            if isMouseIn(ax, ay, colW, 75) then
                local appId = app.id
                -- Map registry ids to functional screens
                if appId == "phone" or appId == "dialer" then
                    Mzansi.Phone.openScreen("dialer")
                elseif appId == "messages" or appId == "sms" then
                    Mzansi.Phone.openScreen("messages")
                elseif appId == "banking" or appId == "bank" or appId == "wallet" then
                    Mzansi.Phone.openScreen("bank")
                elseif appId == "emergency" or appId == "ems" then
                    Mzansi.Phone.openScreen("emergency")
                elseif appId == "contacts" then
                    Mzansi.Phone.openScreen("contacts")
                elseif appId == "uber" or appId == "taxi" or appId == "uber_eats" then
                    triggerServerEvent("mzansi:phone:call", localPlayer, "taxi")
                elseif appId == "radio" or appId == "music" then
                    triggerEvent("mzansi:phone:close", localPlayer)
                    triggerServerEvent("mzansi:radio:requestStations", resourceRoot, "all", "")
                    -- Open radio via its own F6 path: simulate by requesting UI open through event
                    -- (radio client listens on its own bind; use openRadioUI if available)
                    if openRadioUI then openRadioUI() end
                else
                    Mzansi.Util.notify((app.name or appId) .. " — coming soon.", "info")
                end
                return
            end
        end

    -- Dialer Clicks
    elseif Mzansi.Phone._currentScreen == "dialer" then
        local buttons = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "*", "0", "#" }
        local btnY = py + 165
        local bw, bh = 65, 42
        local gap = 15
        for i, b in ipairs(buttons) do
            local row = math.floor((i - 1) / 3)
            local col = (i - 1) % 3
            local bx = px + 35 + col * (bw + gap)
            local by = btnY + row * (bh + 8)
            if isMouseIn(bx, by, bw, bh) then
                local cur = guiGetText(editDialNumber)
                guiSetText(editDialNumber, cur .. b)
                playSoundFrontEnd(41)
                return
            end
        end

        -- Call button
        if isMouseIn(px + 45, py + 380, 140, 42) then
            local num = guiGetText(editDialNumber)
            if string.len(num) > 0 then
                triggerServerEvent("mzansi:phone:call", localPlayer, num)
            end
            return
        -- Backspace
        elseif isMouseIn(px + 195, py + 380, 60, 42) then
            local cur = guiGetText(editDialNumber)
            if string.len(cur) > 0 then
                guiSetText(editDialNumber, string.sub(cur, 1, -2))
            end
            return
        end

    -- Messages Clicks
    elseif Mzansi.Phone._currentScreen == "messages" then
        if isMouseIn(px + 25, py + 200, pw - 50, 32) then
            local num = guiGetText(editSMSNumber)
            local msg = guiGetText(editSMSMessage)
            if string.len(num) > 0 and string.len(msg) > 0 then
                triggerServerEvent("mzansi:phone:sms", localPlayer, num, msg)
                guiSetText(editSMSMessage, "")
            end
            return
        end

        -- Clicking on recent chat autofills recipient
        local myY = py + 265
        for i = 1, math.min(#Mzansi.Phone._messages, 3) do
            local m = Mzansi.Phone._messages[i]
            if isMouseIn(px + 25, myY, pw - 50, 48) then
                local rawNum = m.sender_number or ""
                if rawNum:find("Me %-> ") then
                    rawNum = rawNum:gsub("Me %-> ", "")
                end
                guiSetText(editSMSNumber, rawNum)
                playSoundFrontEnd(41)
                return
            end
            myY = myY + 54
        end

    -- Bank Clicks
    elseif Mzansi.Phone._currentScreen == "bank" then
        if isMouseIn(px + 25, py + 315, pw - 50, 38) then
            local target = guiGetText(editBankTarget)
            local amt = tonumber(guiGetText(editBankAmount)) or 0
            if string.len(target) > 0 and amt > 0 then
                triggerServerEvent("mzansi:phone:bankTransfer", localPlayer, target, amt)
                guiSetText(editBankTarget, "")
                guiSetText(editBankAmount, "")
            end
            return
        end

    -- Emergency Clicks
    elseif Mzansi.Phone._currentScreen == "emergency" then
        if isMouseIn(px + 25, py + 110, pw - 50, 90) then
            triggerServerEvent("mzansi:phone:call", localPlayer, "10111")
            return
        elseif isMouseIn(px + 25, py + 225, pw - 50, 90) then
            triggerServerEvent("mzansi:phone:call", localPlayer, "10177")
            return
        end

    -- Contacts Clicks
    elseif Mzansi.Phone._currentScreen == "contacts" then
        if isMouseIn(px + 25, py + 200, pw - 50, 32) then
            local name = guiGetText(editContactName)
            local num = guiGetText(editContactNumber)
            if string.len(name) > 0 and string.len(num) > 0 then
                triggerServerEvent("mzansi:phone:addContact", localPlayer, name, num)
                guiSetText(editContactName, "")
                guiSetText(editContactNumber, "")
            end
            return
        end

        local cy = py + 265
        for i = 1, math.min(#Mzansi.Phone._contacts, 3) do
            local c = Mzansi.Phone._contacts[i]
            -- Call contact
            if isMouseIn(px + pw - 105, cy + 10, 45, 28) then
                triggerServerEvent("mzansi:phone:call", localPlayer, c.number)
                return
            -- Delete contact
            elseif isMouseIn(px + pw - 55, cy + 10, 25, 28) then
                triggerServerEvent("mzansi:phone:deleteContact", localPlayer, c.id)
                return
            end
            cy = cy + 54
        end
    end
end)

-- Server Event Listeners
addEvent("mzansi:phone:receiveData", true)
addEventHandler("mzansi:phone:receiveData", root, function(num, cash, bank)
    Mzansi.Phone._myNumber = num or "082 --- ----"
    Mzansi.Phone._cash = cash or 0
    Mzansi.Phone._bank = bank or 0
end)

addEvent("mzansi:phone:updateBank", true)
addEventHandler("mzansi:phone:updateBank", root, function(newBank)
    Mzansi.Phone._bank = newBank
end)

addEvent("mzansi:phone:outgoingCall", true)
addEventHandler("mzansi:phone:outgoingCall", root, function(targetNumber)
    Mzansi.Phone._activeCall = { number = targetNumber, name = "Connecting...", state = "calling" }
    Mzansi.Phone.openScreen("call")
    playSoundFrontEnd(40)
end)

addEvent("mzansi:phone:incomingCall", true)
addEventHandler("mzansi:phone:incomingCall", root, function(callerNumber, callerName)
    Mzansi.Phone._activeCall = { number = callerNumber, name = callerName, state = "ringing" }
    if not Mzansi.Phone._visible then
        Mzansi.Phone.toggle()
    end
    Mzansi.Phone.openScreen("call")
    playSoundFrontEnd(40)
end)

addEvent("mzansi:phone:callConnected", true)
addEventHandler("mzansi:phone:callConnected", root, function(otherNumber)
    if Mzansi.Phone._activeCall then
        Mzansi.Phone._activeCall.state = "connected"
        playSoundFrontEnd(41)
    end
end)

addEvent("mzansi:phone:callEnded", true)
addEventHandler("mzansi:phone:callEnded", root, function()
    Mzansi.Phone._activeCall = nil
    playSoundFrontEnd(42)
    Mzansi.Phone.openScreen("home")
end)

addEvent("mzansi:phone:callFailed", true)
addEventHandler("mzansi:phone:callFailed", root, function(reason)
    Mzansi.Phone._activeCall = nil
    Mzansi.Phone.openScreen("home")
end)

addEvent("mzansi:phone:newSMS", true)
addEventHandler("mzansi:phone:newSMS", root, function(senderNum, msg)
    table.insert(Mzansi.Phone._messages, 1, { sender_number = senderNum, message = msg })
    playSoundFrontEnd(41)
end)

addEvent("mzansi:phone:smsSent", true)
addEventHandler("mzansi:phone:smsSent", root, function(targetNum, msg)
    table.insert(Mzansi.Phone._messages, 1, { sender_number = "Me -> " .. targetNum, message = msg })
end)

addEvent("mzansi:phone:contactsList", true)
addEventHandler("mzansi:phone:contactsList", root, function(contacts)
    Mzansi.Phone._contacts = contacts or {}
end)

addEvent("mzansi:phone:messagesList", true)
addEventHandler("mzansi:phone:messagesList", root, function(messages)
    Mzansi.Phone._messages = messages or {}
end)

addEvent("mzansi:phone:conferenceConnected", true)
addEventHandler("mzansi:phone:conferenceConnected", root, function(roomSize)
    if Mzansi.Phone._activeCall then
        Mzansi.Phone._activeCall.state = "connected"
        Mzansi.Phone._activeCall.isConference = true
        Mzansi.Phone._activeCall.memberCount = roomSize
        Mzansi.Phone._activeCall.name = "Conference (" .. tostring(roomSize) .. " Members)"
    else
        Mzansi.Phone._activeCall = { number = "GROUP-CALL", name = "Conference (" .. tostring(roomSize) .. " Members)", state = "connected", isConference = true, memberCount = roomSize }
        if not Mzansi.Phone._visible then
            Mzansi.Phone.toggle()
        end
        Mzansi.Phone.openScreen("call")
    end
    playSoundFrontEnd(41)
end)

-- Native Voice Chat Monitoring (MTA Voice key is typically 'Z')
addEventHandler("onClientPlayerVoiceStart", localPlayer, function()
    Mzansi.Phone._isSpeaking = true
end)

addEventHandler("onClientPlayerVoiceStop", localPlayer, function()
    Mzansi.Phone._isSpeaking = false
end)

-- Command Handlers
-- /phone already registered in onClientResourceStart (with login/typing guard)
addCommandHandler("call", function(cmd, targetNum)
    if targetNum then
        triggerServerEvent("mzansi:phone:call", localPlayer, targetNum)
    else
        Mzansi.Phone.toggle()
    end
end)

-- Modern Phone Subsystems Handlers
local clientPhoneEvents = {
    "mzansi:phone:gpsData",
    "mzansi:phone:locationShared",
    "mzansi:phone:postCreated",
    "mzansi:phone:nearbyPost",
    "mzansi:phone:socialFeed",
    "mzansi:phone:postUpdated",
    "mzansi:photoTaken",
    "mzansi:phone:gallery",
    "mzansi:phone:appInstalled",
    "mzansi:phone:appUninstalled",
    "mzansi:phone:voiceMessage",
    "mzansi:phone:weather",
    "mzansi:phone:calcResult",
    "mzansi:phone:flashlightToggled",
    "mzansi:phone:compass",
    "mzansi:phone:noteSaved",
    "mzansi:phone:notesList",
    "mzansi:phone:noteDeleted",
    "mzansi:phone:spaceData",
    "mzansi:phone:deepSeaData",
}

for _, ev in ipairs(clientPhoneEvents) do
    addEvent(ev, true)
    addEventHandler(ev, root, function(data1, data2)
        Mzansi.Phone._eventData = Mzansi.Phone._eventData or {}
        Mzansi.Phone._eventData[ev] = data1
    end)
end
