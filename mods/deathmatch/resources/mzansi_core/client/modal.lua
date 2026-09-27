-- ============================================================
-- MZANSI CORE: SHARED MODAL / DIALOG / TOAST SYSTEM
-- client/modal.lua
-- All menus and modals across the server use this component.
-- ============================================================

Mzansi = Mzansi or {}
Mzansi.Modal = Mzansi.Modal or {}

local Modal = Mzansi.Modal
Modal._open = false
Modal._type = nil          -- "confirm" | "prompt" | "info" | "menu"
Modal._title = ""
Modal._body = ""
Modal._buttons = {}        -- { { label, color, onClick }, ... }
Modal._onConfirm = nil
Modal._onCancel = nil
Modal._inputValue = ""
Modal._inputActive = false
Modal._anim = 0            -- 0..1 scale-in animation
Modal._menuItems = {}      -- for "menu" type: { { label, desc, onSelect }, ... }
Modal._menuScroll = 0
Modal._menuSelected = 1

local FONT_TITLE = "default-bold"
local FONT_BODY  = "default"
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

-- ============================================================
-- PUBLIC API
-- ============================================================

--- Confirmation modal with Yes/No
function Modal.confirm(title, body, onConfirm, onCancel)
    Modal._open = true
    Modal._type = "confirm"
    Modal._title = title or "Confirm"
    Modal._body = body or ""
    Modal._onConfirm = onConfirm
    Modal._onCancel = onCancel
    Modal._anim = 0
    Modal._inputActive = false
    showCursor(true)
end

--- Prompt modal with text input
function Modal.prompt(title, body, defaultText, onSubmit, onCancel)
    Modal._open = true
    Modal._type = "prompt"
    Modal._title = title or "Input"
    Modal._body = body or ""
    Modal._inputValue = defaultText or ""
    Modal._inputActive = true
    Modal._onConfirm = onSubmit
    Modal._onCancel = onCancel
    Modal._anim = 0
    showCursor(true)
end

--- Information modal with single OK
function Modal.info(title, body, onClose)
    Modal._open = true
    Modal._type = "info"
    Modal._title = title or "Notice"
    Modal._body = body or ""
    Modal._onConfirm = onClose
    Modal._onCancel = onClose
    Modal._anim = 0
    showCursor(false)
end

--- Selection menu modal (list of items)
-- items: { { label="...", desc="...", onSelect=function() end }, ... }
function Modal.menu(title, items, onCancel)
    Modal._open = true
    Modal._type = "menu"
    Modal._title = title or "Select"
    Modal._menuItems = items or {}
    Modal._menuSelected = 1
    Modal._menuScroll = 0
    Modal._onCancel = onCancel
    Modal._anim = 0
    showCursor(true)
end

function Modal.close()
    Modal._open = false
    Modal._type = nil
    Modal._onConfirm = nil
    Modal._onCancel = nil
    Modal._inputActive = false
    Modal._menuItems = {}
    -- Only hide cursor if no other UI wants it (best-effort)
    if not (Mzansi.Dashboard and Mzansi.Dashboard._visible)
       and not (Mzansi.Phone and Mzansi.Phone._visible) then
        showCursor(false)
    end
end

function Modal.isOpen()
    return Modal._open
end

function Modal.getInput()
    return Modal._inputValue
end

-- ============================================================
-- DRAW
-- ============================================================

local function drawButton(label, x, y, w, h, baseColor, hovered)
    local r, g, b, a = baseColor[1], baseColor[2], baseColor[3], baseColor[4] or 255
    if hovered then
        r = math.min(255, r + 40)
        g = math.min(255, g + 40)
        b = math.min(255, b + 40)
    end
    dxDrawRectangle(x, y, w, h, tocolor(r, g, b, a))
    -- border
    dxDrawRectangle(x, y, w, 1, tocolor(255, 255, 255, 60))
    dxDrawRectangle(x, y + h - 1, w, 1, tocolor(0, 0, 0, 80))
    dxDrawText(label, x, y, x + w, y + h,
        tocolor(255, 255, 255, 255), 1.0, FONT_TITLE, "center", "center")
end

addEventHandler("onClientRender", root, function()
    if not Modal._open then return end

    -- Animate in
    Modal._anim = math.min(1, Modal._anim + 0.12)
    local a = Modal._anim

    local sx, sy = screen()
    local mx, my = getCursorPosition()
    if mx and my then mx, my = mx * sx, my * sy end

    -- Dim backdrop
    dxDrawRectangle(0, 0, sx, sy, tocolor(0, 0, 0, math.floor(140 * a)))

    -- Panel dimensions
    local pw, ph
    if Modal._type == "menu" then
        pw, ph = 480, math.min(520, 80 + #Modal._menuItems * 44)
    else
        pw, ph = 460, 240
    end
    local px = (sx - pw) / 2
    local py = (sy - ph) / 2

    -- Panel background with scale-in
    local scale = 0.85 + 0.15 * a
    local cx, cy = sx / 2, sy / 2
    local sw, sh = pw * scale, ph * scale
    local bx, by = cx - sw / 2, cy - sh / 2

    -- Shadow
    dxDrawRectangle(bx + 6, by + 6, sw, sh, tocolor(0, 0, 0, math.floor(100 * a)))
    -- Panel
    dxDrawRectangle(bx, by, sw, sh, tocolor(12, 18, 32, math.floor(245 * a)))
    -- Top accent bar
    dxDrawRectangle(bx, by, sw, 4, tocolor(0, 200, 255, math.floor(255 * a)))
    -- Border
    dxDrawRectangle(bx, by, sw, 1, tocolor(0, 200, 255, math.floor(120 * a)))
    dxDrawRectangle(bx, by + sh - 1, sw, 1, tocolor(0, 200, 255, math.floor(80 * a)))
    dxDrawRectangle(bx, by, 1, sh, tocolor(0, 200, 255, math.floor(80 * a)))
    dxDrawRectangle(bx + sw - 1, by, 1, sh, tocolor(0, 200, 255, math.floor(80 * a)))

    local contentX = bx + 24
    local contentW = sw - 48
    local cursorY = by + 22

    -- Title
    dxDrawText(Modal._title, contentX, cursorY, contentX + contentW, cursorY + 28,
        tocolor(0, 220, 255, math.floor(255 * a)), 1.15, FONT_TITLE, "left", "top")
    cursorY = cursorY + 32

    -- Separator
    dxDrawRectangle(contentX, cursorY, contentW, 1, tocolor(255, 255, 255, 40))
    cursorY = cursorY + 12

    if Modal._type == "menu" then
        -- Menu items
        local itemH = 44
        local visible = math.floor((sh - 140) / itemH)
        local maxScroll = math.max(0, #Modal._menuItems - visible)
        if Modal._menuScroll > maxScroll then Modal._menuScroll = maxScroll end

        for i = 1, math.min(visible, #Modal._menuItems) do
            local idx = Modal._menuScroll + i
            local item = Modal._menuItems[idx]
            if not item then break end
            local iy = cursorY + (i - 1) * (itemH + 4)
            local isSelected = (idx == Modal._menuSelected)
            local isHover = mx and my and mouseIn(contentX, iy, contentW, itemH)

            -- Item bg
            local bg = isSelected and { 0, 80, 120, 220 } or (isHover and { 30, 50, 70, 200 } or { 20, 28, 44, 180 })
            dxDrawRectangle(contentX, iy, contentW, itemH, tocolor(bg[1], bg[2], bg[3], bg[4] * a))
            if isSelected then
                dxDrawRectangle(contentX, iy, 3, itemH, tocolor(0, 220, 255, 255 * a))
            end

            dxDrawText(item.label or ("Item " .. idx), contentX + 12, iy + 4, contentX + contentW - 12, iy + 24,
                tocolor(255, 255, 255, 255 * a), 1.0, FONT_TITLE, "left", "top")
            if item.desc then
                dxDrawText(item.desc, contentX + 12, iy + 22, contentX + contentW - 12, iy + itemH - 2,
                    tocolor(160, 180, 200, 220 * a), 0.9, FONT_SMALL, "left", "top")
            end
        end

        -- Scroll hint
        if #Modal._menuItems > visible then
            dxDrawText(string.format("Scroll: %d/%d  |  UP/DOWN select  |  ENTER confirm  |  ESC cancel",
                Modal._menuSelected, #Modal._menuItems),
                contentX, by + sh - 36, contentX + contentW, by + sh - 12,
                tocolor(120, 150, 170, 200 * a), 0.9, FONT_SMALL, "center", "center")
        else
            dxDrawText("UP/DOWN select  |  ENTER confirm  |  ESC cancel",
                contentX, by + sh - 36, contentX + contentW, by + sh - 12,
                tocolor(120, 150, 170, 200 * a), 0.9, FONT_SMALL, "center", "center")
        end
        return
    end

    -- Body text (word-wrapped)
    dxDrawText(Modal._body, contentX, cursorY, contentX + contentW, cursorY + 90,
        tocolor(220, 230, 240, 255 * a), 1.0, FONT_BODY, "left", "top", true, true, false)
    cursorY = cursorY + 100

    -- Input field for prompt
    if Modal._type == "prompt" then
        local iw, ih = contentW, 36
        local iy = cursorY
        local inputHover = mx and my and mouseIn(contentX, iy, iw, ih)
        dxDrawRectangle(contentX, iy, iw, ih, tocolor(8, 12, 22, 240 * a))
        dxDrawRectangle(contentX, iy, iw, 1, tocolor(Modal._inputActive and 0 or 80, Modal._inputActive and 200 or 100, 255, 200 * a))
        local display = Modal._inputValue
        if Modal._inputActive and math.floor(getTickCount() / 400) % 2 == 0 then
            display = display .. "|"
        end
        if display == "" and not Modal._inputActive then
            dxDrawText("Type here...", contentX + 10, iy, contentX + iw - 10, iy + ih,
                tocolor(100, 120, 140, 180 * a), 1.0, FONT_BODY, "left", "center")
        else
            dxDrawText(display, contentX + 10, iy, contentX + iw - 10, iy + ih,
                tocolor(255, 255, 255, 255 * a), 1.0, FONT_BODY, "left", "center")
        end
        cursorY = cursorY + 50
    end

    -- Buttons
    local btnW, btnH = 130, 40
    local btnGap = 16
    local btnY = by + sh - btnH - 24

    if Modal._type == "confirm" then
        local totalW = btnW * 2 + btnGap
        local startX = bx + (sw - totalW) / 2

        local noHover = mx and my and mouseIn(startX, btnY, btnW, btnH)
        local yesHover = mx and my and mouseIn(startX + btnW + btnGap, btnY, btnW, btnH)
        drawButton("Cancel", startX, btnY, btnW, btnH, { 70, 80, 100, 255 }, noHover)
        drawButton("Confirm", startX + btnW + btnGap, btnY, btnW, btnH, { 0, 160, 90, 255 }, yesHover)

        Modal._btnNo  = { startX, btnY, btnW, btnH }
        Modal._btnYes = { startX + btnW + btnGap, btnY, btnW, btnH }
    elseif Modal._type == "prompt" then
        local totalW = btnW * 2 + btnGap
        local startX = bx + (sw - totalW) / 2
        local noHover = mx and my and mouseIn(startX, btnY, btnW, btnH)
        local yesHover = mx and my and mouseIn(startX + btnW + btnGap, btnY, btnW, btnH)
        drawButton("Cancel", startX, btnY, btnW, btnH, { 70, 80, 100, 255 }, noHover)
        drawButton("Submit", startX + btnW + btnGap, btnY, btnW, btnH, { 0, 120, 200, 255 }, yesHover)
        Modal._btnNo  = { startX, btnY, btnW, btnH }
        Modal._btnYes = { startX + btnW + btnGap, btnY, btnW, btnH }
    elseif Modal._type == "info" then
        local startX = bx + (sw - btnW) / 2
        local okHover = mx and my and mouseIn(startX, btnY, btnW, btnH)
        drawButton("OK", startX, btnY, btnW, btnH, { 0, 120, 200, 255 }, okHover)
        Modal._btnYes = { startX, btnY, btnW, btnH }
        Modal._btnNo = nil
    end
end)

-- ============================================================
-- INPUT
-- ============================================================

addEventHandler("onClientClick", root, function(button, state)
    if not Modal._open or state ~= "down" then return end
    if button ~= "left" then return end

    if Modal._type == "menu" then
        -- Click selection handled in key handler; click also selects
        return
    end

    local sx, sy = screen()
    local mx, my = getCursorPosition()
    if not mx or not my then return end
    mx, my = mx * sx, my * sy

    if Modal._btnYes and mx >= Modal._btnYes[1] and mx <= Modal._btnYes[1] + Modal._btnYes[3]
       and my >= Modal._btnYes[2] and my <= Modal._btnYes[2] + Modal._btnYes[4] then
        local cb = Modal._onConfirm
        local val = Modal._inputValue
        Modal.close()
        if cb then cb(val) end
        cancelEvent()
        return
    end

    if Modal._btnNo and mx >= Modal._btnNo[1] and mx <= Modal._btnNo[1] + Modal._btnNo[3]
       and my >= Modal._btnNo[2] and my <= Modal._btnNo[2] + Modal._btnNo[4] then
        local cb = Modal._onCancel
        Modal.close()
        if cb then cb() end
        cancelEvent()
        return
    end

    -- Click on input field for prompt
    if Modal._type == "prompt" then
        -- Approximate: activate input if click is in panel upper half
        Modal._inputActive = true
    end
end)

addEventHandler("onClientKey", root, function(key, pressed)
    if not Modal._open then return end
    if not pressed then return end

    if key == "escape" then
        local cb = Modal._onCancel
        Modal.close()
        if cb then cb() end
        cancelEvent()
        return
    end

    if Modal._type == "menu" then
        if key == "arrow_u" or key == "up" then
            Modal._menuSelected = math.max(1, Modal._menuSelected - 1)
            -- auto-scroll
            if Modal._menuSelected <= Modal._menuScroll then
                Modal._menuScroll = Modal._menuSelected - 1
            end
            cancelEvent()
        elseif key == "arrow_d" or key == "down" then
            Modal._menuSelected = math.min(#Modal._menuItems, Modal._menuSelected + 1)
            cancelEvent()
        elseif key == "pgup" then
            Modal._menuSelected = math.max(1, Modal._menuSelected - 5)
            cancelEvent()
        elseif key == "pgdn" then
            Modal._menuSelected = math.min(#Modal._menuItems, Modal._menuSelected + 5)
            cancelEvent()
        elseif key == "return" or key == "enter" then
            local item = Modal._menuItems[Modal._menuSelected]
            local cb = item and item.onSelect
            Modal.close()
            if cb then cb() end
            cancelEvent()
        elseif key == "mouse_wheel_up" then
            Modal._menuScroll = math.max(0, Modal._menuScroll - 1)
            cancelEvent()
        elseif key == "mouse_wheel_down" then
            local maxScroll = math.max(0, #Modal._menuItems - 8)
            Modal._menuScroll = math.min(maxScroll, Modal._menuScroll + 1)
            cancelEvent()
        end
        return
    end

    if Modal._type == "prompt" then
        if key == "backspace" then
            if #Modal._inputValue > 0 then
                Modal._inputValue = Modal._inputValue:sub(1, -2)
            end
            cancelEvent()
        elseif key == "return" or key == "enter" then
            local cb = Modal._onConfirm
            local val = Modal._inputValue
            Modal.close()
            if cb then cb(val) end
            cancelEvent()
        end
        return
    end

    if Modal._type == "confirm" or Modal._type == "info" then
        if key == "return" or key == "enter" then
            local cb = Modal._onConfirm
            Modal.close()
            if cb then cb() end
            cancelEvent()
        end
    end
end)

addEventHandler("onClientCharacter", root, function(char)
    if not Modal._open or Modal._type ~= "prompt" then return end
    if not Modal._inputActive then return end
    if #Modal._inputValue < 64 then
        Modal._inputValue = Modal._inputValue .. char
    end
    cancelEvent()
end)

-- ============================================================
-- SHORTCUT HELPERS (common dialogs)
-- ============================================================

function Modal.confirmDelete(name, onYes)
    Modal.confirm("Confirm Delete",
        "Are you sure you want to delete \"" .. tostring(name) .. "\"?\nThis action cannot be undone.",
        onYes, nil)
end

function Modal.confirmTeleport(placeName, onYes)
    Modal.confirm("Teleport",
        "Travel to " .. tostring(placeName) .. "?",
        onYes, nil)
end

function Modal.confirmSpawn(modelId, modelName, onYes)
    Modal.confirm("Spawn Vehicle",
        "Spawn " .. tostring(modelName) .. " (ID " .. tostring(modelId) .. ")?",
        onYes, nil)
end

function Modal.keybindHelp()
    Modal.info("Keyboard Shortcuts",
        "F1  - Scoreboard (default GTA)\n" ..
        "F2  - Mzansi Dashboard\n" ..
        "F3  - Flight Board (ACSA)\n" ..
        "F4  - Gangs & Turfs quick-open\n" ..
        "F6  - Radio UI\n" ..
        "F7  - Admin Panel\n" ..
        "F8  - Creator / Freeroam Menu\n" ..
        "F9 / NumLock  - Phone\n" ..
        "F10 / ScrollLock - Bank\n" ..
        "E   - Interact (activities)\n" ..
        "X   - Close dashboard\n" ..
        "SPACE - Skip cutscene (during cinematics)\n" ..
        "MMB - Quick radio cycle\n" ..
        "1-8 - Weapon slots (default GTA)\n" ..
        "\nCommands: /flight  /skip  /eye  /track  /dive  /help  /gps  /phone  /bankui")
end

outputDebugString("[Mzansi-Core] Shared Modal/Dialog system loaded.")
