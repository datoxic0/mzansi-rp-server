-- ============================================================
-- MZANSI ADMIN PANEL — CLIENT SIDE
-- mzansi_admin/client/admin_panel.lua
-- Pure dxDraw panel — no CEF, no GUI widgets.
-- F7 or /admin command toggles the panel.
-- Server must confirm admin level before rendering.
-- ============================================================

local Admin = {}
Admin._visible        = false
Admin._accessGranted  = false
Admin._adminLevel     = 0
Admin._currentTab     = "players"   -- "players" | "server"
Admin._players        = {}          -- snapshot from server
Admin._selectedSerial = nil         -- serial of selected player row
Admin._scrollOffset   = 0          -- rows scrolled down in player list
Admin._notification   = { text = "", color = { 255, 255, 255 }, expiry = 0 }
Admin._input          = {           -- action input overlay
    active  = false,
    action  = nil,   -- "kick" | "ban" | "giveCash" | "setJob" | "setAdminLevel"
    label   = "",
    value   = "",
}
Admin._frozenPlayers  = {}          -- serial -> true for frozen players

-- ============================================================
-- CONSTANTS
-- ============================================================

local W, H        = 980, 600
local TAB_H       = 38
local HEADER_H    = 54
local COL_WIDTHS  = { 150, 160, 90, 80, 80, 80, 70, 70 }  -- Name|Char|Cash|Bank|Job|Faction|AdminLvl|Ping
local COL_LABELS  = { "Player", "Character", "Cash", "Bank", "Job", "Faction", "Lvl", "Ping" }

local JOB_NAMES = {
    [0]  = "Unemployed", [1]  = "SAPS Officer",   [2]  = "EMS Medic",
    [3]  = "Mechanic",   [4]  = "Trucker",         [5]  = "Fisherman",
    [6]  = "Farmer",     [7]  = "Taxi Driver",     [8]  = "Bus Driver",
    [9]  = "Miner",      [10] = "Pilot",            [11] = "Delivery",
    [12] = "Biz Owner",
}

local FACTION_NAMES = {
    [0] = "Civilian", [1] = "SAPS", [2] = "EMS", [3] = "SANDF", [4] = "News",
}

-- ============================================================
-- HELPERS
-- ============================================================

local function mx_in(px, py, pw, ph)
    local cx, cy = getCursorPosition()
    if not cx or not cy then return false end
    local sw, sh = guiGetScreenSize()
    cx, cy = cx * sw, cy * sh
    return cx >= px and cx <= px + pw and cy >= py and cy <= py + ph
end

local function formatMoney(n)
    n = math.floor(tonumber(n) or 0)
    local s = tostring(n)
    local pos = #s - 2
    while pos > 1 do
        s = s:sub(1, pos - 1) .. "," .. s:sub(pos)
        pos = pos - 3
    end
    return "R" .. s
end

local function notify(text, isError)
    Admin._notification.text   = text
    Admin._notification.color  = isError and { 255, 80, 80 } or { 60, 220, 100 }
    Admin._notification.expiry = getTickCount() + 4000
end

-- ============================================================
-- OPEN / CLOSE
-- ============================================================

function Admin.open()
    if isChatBoxInputActive() or isConsoleActive() then return end
    triggerServerEvent("mzansi:admin:requestOpen", localPlayer)
end

function Admin.close()
    Admin._visible        = false
    Admin._selectedSerial = nil
    Admin._input.active   = false
    Admin._scrollOffset   = 0
    showCursor(false)
end

function Admin.toggle()
    if Admin._visible then
        Admin.close()
    else
        Admin.open()
    end
end

-- Mutual exclusion close event (called by dashboard/phone/radio/freeroam open)
addEvent("mzansi:admin:close", false)
addEventHandler("mzansi:admin:close", localPlayer, function()
    if Admin._visible then Admin.close() end
end)

-- ============================================================
-- SERVER EVENTS
-- ============================================================

addEvent("mzansi:admin:openGranted", true)
addEventHandler("mzansi:admin:openGranted", root, function(adminLvl)
    Admin._accessGranted = true
    Admin._adminLevel    = tonumber(adminLvl) or 1
    Admin._visible       = true
    Admin._currentTab    = "players"
    Admin._scrollOffset  = 0
    -- Close others FIRST (they may call showCursor(false)), then claim cursor
    triggerEvent("mzansi:phone:close", localPlayer)
    triggerEvent("mzansi:dashboard:close", localPlayer)
    triggerEvent("mzansi:radio:close", localPlayer)
    triggerEvent("mzansi:freeroam:close", localPlayer)
    triggerEvent("mzansi:flight:close", localPlayer)
    triggerEvent("mzansi:market:close", localPlayer)
    triggerEvent("mzansi:bank:close", localPlayer)
    triggerEvent("mzansi:shop:closeUI", localPlayer)
    showCursor(true)
    -- Immediately request player list
    triggerServerEvent("mzansi:admin:requestPlayerList", localPlayer)
    playSoundFrontEnd(41)
end)

addEvent("mzansi:admin:openDenied", true)
addEventHandler("mzansi:admin:openDenied", root, function()
    outputChatBox("[Admin] Access denied. You are not an admin.", 255, 80, 80)
end)

addEvent("mzansi:admin:playerListResult", true)
addEventHandler("mzansi:admin:playerListResult", root, function(list)
    Admin._players = list or {}
    -- Re-validate selected serial still in list
    if Admin._selectedSerial then
        local found = false
        for _, p in ipairs(Admin._players) do
            if p.serial == Admin._selectedSerial then found = true; break end
        end
        if not found then Admin._selectedSerial = nil end
    end
end)

addEvent("mzansi:admin:success", true)
addEventHandler("mzansi:admin:success", root, function(msg)
    notify(msg, false)
    -- Refresh player list after any successful action
    setTimer(function()
        if Admin._visible then
            triggerServerEvent("mzansi:admin:requestPlayerList", localPlayer)
        end
    end, 500, 1)
end)

addEvent("mzansi:admin:error", true)
addEventHandler("mzansi:admin:error", root, function(msg)
    notify(msg, true)
end)

-- ============================================================
-- RENDER
-- ============================================================

addEventHandler("onClientRender", root, function()
    -- Notification banner (shown even when panel is closed)
    if Admin._notification.text ~= "" and getTickCount() < Admin._notification.expiry then
        local sw, sh = guiGetScreenSize()
        local col = Admin._notification.color
        local bw, bh = 500, 36
        local bx, by = (sw - bw) / 2, sh - 80
        dxDrawRectangle(bx, by, bw, bh, tocolor(10, 15, 25, 220), false)
        dxDrawRectangle(bx, by, bw, 2, tocolor(col[1], col[2], col[3], 255), false)
        dxDrawText(Admin._notification.text, bx, by, bx + bw, by + bh,
            tocolor(col[1], col[2], col[3], 255), 0.9, "default-bold", "center", "center")
    elseif getTickCount() >= Admin._notification.expiry then
        Admin._notification.text = ""
    end

    if not Admin._visible then return end

    local sw, sh = guiGetScreenSize()
    local px = (sw - W) / 2
    local py = (sh - H) / 2

    -- Backdrop
    dxDrawRectangle(0, 0, sw, sh, tocolor(5, 8, 14, 160), false)

    -- Panel background
    dxDrawRectangle(px, py, W, H, tocolor(10, 16, 26, 252), false)
    dxDrawRectangle(px, py, W, 3, tocolor(200, 50, 50, 255), false)   -- red admin accent

    -- Header
    dxDrawRectangle(px, py, W, HEADER_H, tocolor(16, 24, 40, 255), false)
    dxDrawText("⚡ MZANSI ADMIN PANEL  [Level " .. Admin._adminLevel .. "]",
        px + 20, py, px + W - 120, py + HEADER_H,
        tocolor(255, 80, 80, 255), 1.15, "default-bold", "left", "center")
    dxDrawText("F7 to Close",
        px + W - 110, py, px + W - 10, py + HEADER_H,
        tocolor(150, 160, 175, 200), 0.85, "default-bold", "right", "center")

    -- Refresh button
    local refHov = mx_in(px + W - 185, py + 12, 65, 28)
    dxDrawRectangle(px + W - 185, py + 12, 65, 28,
        refHov and tocolor(50, 140, 220, 255) or tocolor(30, 90, 160, 255), false)
    dxDrawText("↻ Refresh", px + W - 185, py + 12, px + W - 120, py + 40,
        tocolor(255, 255, 255, 255), 0.8, "default-bold", "center", "center")

    -- Tabs
    local tabs = { { id = "players", label = "Players Online" }, { id = "server", label = "Server Info" } }
    local tabX = px + 10
    local tabY = py + HEADER_H + 4
    local tabW = 160

    for _, tab in ipairs(tabs) do
        local isActive = Admin._currentTab == tab.id
        local isHov    = mx_in(tabX, tabY, tabW - 6, TAB_H - 4)
        local bg  = isActive and tocolor(200, 50, 50, 255) or
                    (isHov and tocolor(30, 50, 80, 255) or tocolor(18, 28, 44, 200))
        local txt = isActive and tocolor(255, 255, 255, 255) or tocolor(210, 220, 235, 255)
        dxDrawRectangle(tabX, tabY, tabW - 6, TAB_H - 4, bg, false)
        dxDrawText(tab.label, tabX, tabY, tabX + tabW - 6, tabY + TAB_H - 4,
            txt, 0.88, "default-bold", "center", "center")
        tabX = tabX + tabW
    end

    -- Content area
    local cx = px + 10
    local cy = py + HEADER_H + TAB_H + 8
    local cw = W - 20
    local ch = H - HEADER_H - TAB_H - 18

    if Admin._currentTab == "players" then
        Admin.renderPlayersTab(cx, cy, cw, ch)
    elseif Admin._currentTab == "server" then
        Admin.renderServerTab(cx, cy, cw, ch)
    end

    -- Input overlay (for action requiring text input)
    if Admin._input.active then
        Admin.renderInputOverlay(px, py)
    end
end)

-- ============================================================
-- PLAYERS TAB
-- ============================================================

local ROW_H       = 30
local MAX_VISIBLE = 12

function Admin.renderPlayersTab(cx, cy, cw, ch)
    -- Column headers
    local hx = cx
    for i, label in ipairs(COL_LABELS) do
        local cw2 = COL_WIDTHS[i]
        dxDrawRectangle(hx, cy, cw2 - 2, 26, tocolor(20, 32, 52, 255), false)
        dxDrawText(label, hx + 6, cy, hx + cw2 - 2, cy + 26,
            tocolor(200, 50, 50, 255), 0.8, "default-bold", "left", "center")
        hx = hx + cw2
    end

    -- Row count indicator
    local totalPlayers = #Admin._players
    local onlineCount = 0
    for _, p in ipairs(Admin._players) do
        if p.online then onlineCount = onlineCount + 1 end
    end
    dxDrawText("Online: " .. onlineCount .. "  |  Total: " .. totalPlayers, cx + cw - 200, cy, cx + cw, cy + 26,
        tocolor(180, 190, 205, 200), 0.8, "default", "right", "center")

    -- Player rows
    local ry = cy + 28
    local maxRows = math.min(MAX_VISIBLE, totalPlayers - Admin._scrollOffset)
    for i = 1, maxRows do
        local idx = i + Admin._scrollOffset
        local p   = Admin._players[idx]
        if not p then break end

        local isSelected = (Admin._selectedSerial == p.serial)
        local isHov      = mx_in(cx, ry, cw - 180, ROW_H)
        local isOffline  = not p.online
        local rowBg = isSelected and tocolor(180, 40, 40, 220) or
                      (isHov and tocolor(28, 44, 68, 240) or
                      (isOffline and tocolor(10, 14, 22, 200) or
                      (i % 2 == 0 and tocolor(16, 26, 42, 220) or tocolor(12, 20, 34, 220))))

        dxDrawRectangle(cx, ry, cw - 180, ROW_H, rowBg, false)

        -- Cells
        local rx = cx
        local cells = {
            { p.name,                          COL_WIDTHS[1] },
            { p.charName ~= "" and p.charName or "(No char)", COL_WIDTHS[2] },
            { formatMoney(p.cash),             COL_WIDTHS[3] },
            { formatMoney(p.bank),             COL_WIDTHS[4] },
            { JOB_NAMES[p.job] or "?",         COL_WIDTHS[5] },
            { FACTION_NAMES[p.faction] or "?", COL_WIDTHS[6] },
            { tostring(p.adminLvl),            COL_WIDTHS[7] },
            { p.online and (tostring(p.ping) .. "ms") or "OFFLINE", COL_WIDTHS[8] },
        }
        for _, cell in ipairs(cells) do
            local txtCol = isOffline and tocolor(120, 130, 145, 180) or
                          (isHov and tocolor(10, 20, 14, 255) or tocolor(220, 228, 240, 255))
            dxDrawText(cell[1], rx + 6, ry, rx + cell[2] - 2, ry + ROW_H,
                txtCol, 0.78, "default", "left", "center", false, false, false, true)
            rx = rx + cell[2]
        end

        ry = ry + ROW_H
    end

    -- Scroll indicators
    if Admin._scrollOffset > 0 then
        dxDrawText("▲ Scroll Up", cx, cy + 28 + MAX_VISIBLE * ROW_H + 4, cx + 100, cy + 28 + MAX_VISIBLE * ROW_H + 22,
            tocolor(180, 190, 205, 200), 0.78, "default-bold", "left", "top")
    end
    if Admin._scrollOffset + MAX_VISIBLE < totalPlayers then
        dxDrawText("▼ Scroll Down", cx + 110, cy + 28 + MAX_VISIBLE * ROW_H + 4,
            cx + 260, cy + 28 + MAX_VISIBLE * ROW_H + 22,
            tocolor(180, 190, 205, 200), 0.78, "default-bold", "left", "top")
    end

    -- Right side: Selected player details + action buttons
    local detX = cx + cw - 170
    local detY = cy

    if Admin._selectedSerial then
        local sel = nil
        for _, p in ipairs(Admin._players) do
            if p.serial == Admin._selectedSerial then sel = p; break end
        end

        if sel then
            dxDrawRectangle(detX, detY, 168, ch, tocolor(14, 22, 36, 240), false)
            dxDrawRectangle(detX, detY, 168, 2, tocolor(200, 50, 50, 255), false)
            dxDrawText("SELECTED PLAYER", detX + 4, detY + 6, detX + 164, detY + 22,
                tocolor(200, 50, 50, 255), 0.78, "default-bold", "center", "top")
            dxDrawText(sel.name, detX + 4, detY + 24, detX + 164, detY + 40,
                tocolor(255, 255, 255, 255), 0.82, "default-bold", "center", "top")

            local infoLines = {
                "Status: " .. (sel.online and "ONLINE" or "OFFLINE"),
                "Char: " .. (sel.charName ~= "" and sel.charName or "—"),
                "Cash: " .. formatMoney(sel.cash),
                "Bank: " .. formatMoney(sel.bank),
                "Job: " .. (JOB_NAMES[sel.job] or "?"),
                "Faction: " .. (FACTION_NAMES[sel.faction] or "?"),
                "Admin Lvl: " .. sel.adminLvl,
                "Ping: " .. (sel.online and (sel.ping .. "ms") or "N/A"),
                "Serial: " .. sel.serial:sub(1, 10) .. "...",
                "IP: " .. sel.ip,
            }
            local ily = detY + 44
            for _, line in ipairs(infoLines) do
                dxDrawText(line, detX + 6, ily, detX + 162, ily + 14,
                    tocolor(190, 200, 215, 255), 0.72, "default", "left", "top", false, false, false, true)
                ily = ily + 15
            end

            -- Action buttons
            local isFrozen = Admin._frozenPlayers[sel.serial] or false
            local actions = {
                { label = "Kick",        action = "kick",          minLvl = 1, onlineOnly = true },
                { label = "Ban",         action = "ban",           minLvl = 2, onlineOnly = false },
                { label = "Give Cash",   action = "giveCash",      minLvl = 1, onlineOnly = true },
                { label = "Set Job",     action = "setJob",        minLvl = 1, onlineOnly = true },
                { label = "TP To",       action = "teleportTo",    minLvl = 1, onlineOnly = true },
                { label = "Bring Here",  action = "bringHere",     minLvl = 1, onlineOnly = true },
                { label = "Heal",        action = "heal",          minLvl = 1, onlineOnly = true },
                { label = isFrozen and "Unfreeze" or "Freeze", action = "freeze", minLvl = 1, color = isFrozen and { 220, 180, 40 } or { 180, 180, 60 }, onlineOnly = true },
                { label = "Set Adm Lvl", action = "setAdminLevel", minLvl = 5, onlineOnly = false },
            }

            local aby = ily + 6
            for _, act in ipairs(actions) do
                if Admin._adminLevel >= act.minLvl and (not act.onlineOnly or sel.online) then
                    local c = act.color
                    local hov = mx_in(detX + 4, aby, 160, 26)
                    dxDrawRectangle(detX + 4, aby, 160, 26,
                        hov and tocolor(c[1], c[2], c[3], 255) or tocolor(c[1], c[2], c[3], 160), false)
                    dxDrawText(act.label, detX + 4, aby, detX + 164, aby + 26,
                        tocolor(255, 255, 255, 255), 0.82, "default-bold", "center", "center")
                    aby = aby + 30
                end
            end
        end
    else
        dxDrawRectangle(detX, detY, 168, ch, tocolor(14, 22, 36, 200), false)
        dxDrawText("← Select a player\n   to see details\n   and actions", detX + 4, detY + 40, detX + 164, detY + 100,
            tocolor(150, 160, 175, 200), 0.82, "default", "center", "top")
    end
end

-- ============================================================
-- SERVER TAB
-- ============================================================

function Admin.renderServerTab(cx, cy, cw, ch)
    local serverName = "Mzansi Roleplay"
    local online     = #Admin._players
    local lines = {
        { label = "Server Name",      val = serverName },
        { label = "Players Online",   val = tostring(online) },
        { label = "Your Admin Level", val = tostring(Admin._adminLevel) },
        { label = "Admin Commands",   val = "/admin  •  F7" },
        { label = "Freeroam Menu",    val = "/ngamla  •  F8" },
        { label = "Notes",            val = "Use /ngamla to spawn vehicles, weapons and objects." },
    }

    local ly = cy + 20
    for _, line in ipairs(lines) do
        dxDrawText(line.label, cx + 20, ly, cx + 200, ly + 24,
            tocolor(200, 50, 50, 255), 0.9, "default-bold", "left", "center")
        dxDrawText(line.val, cx + 210, ly, cx + cw - 20, ly + 24,
            tocolor(220, 230, 240, 255), 0.9, "default", "left", "center")
        ly = ly + 28
    end
end

-- ============================================================
-- INPUT OVERLAY (for actions requiring text entry)
-- ============================================================

function Admin.renderInputOverlay(px, py)
    local ow, oh = 420, 160
    local ox = px + (W - ow) / 2
    local oy = py + (H - oh) / 2

    dxDrawRectangle(0, 0, guiGetScreenSize(), guiGetScreenSize(), tocolor(0, 0, 0, 120), false)
    dxDrawRectangle(ox, oy, ow, oh, tocolor(14, 22, 36, 252), false)
    dxDrawRectangle(ox, oy, ow, 3, tocolor(200, 50, 50, 255), false)

    dxDrawText(Admin._input.label, ox + 16, oy + 14, ox + ow - 16, oy + 38,
        tocolor(220, 230, 240, 255), 1.0, "default-bold", "left", "center")

    -- Input field
    dxDrawRectangle(ox + 16, oy + 50, ow - 32, 36, tocolor(20, 32, 50, 255), false)
    dxDrawRectangle(ox + 16, oy + 50, ow - 32, 2, tocolor(200, 50, 50, 200), false)
    local displayVal = Admin._input.value == "" and "Type here..." or Admin._input.value
    local valCol = Admin._input.value == "" and tocolor(100, 110, 130, 200) or tocolor(255, 255, 255, 255)
    dxDrawText(displayVal .. (math.floor(getTickCount() / 500) % 2 == 0 and "|" or ""),
        ox + 22, oy + 50, ox + ow - 22, oy + 86,
        valCol, 0.92, "default", "left", "center")

    -- Confirm / Cancel buttons
    local cfHov = mx_in(ox + 16, oy + 100, 180, 36)
    dxDrawRectangle(ox + 16, oy + 100, 180, 36,
        cfHov and tocolor(50, 200, 80, 255) or tocolor(35, 140, 55, 255), false)
    dxDrawText("✓ CONFIRM", ox + 16, oy + 100, ox + 196, oy + 136,
        tocolor(255, 255, 255, 255), 0.9, "default-bold", "center", "center")

    local ccHov = mx_in(ox + 224, oy + 100, 180, 36)
    dxDrawRectangle(ox + 224, oy + 100, 180, 36,
        ccHov and tocolor(220, 60, 60, 255) or tocolor(150, 40, 40, 255), false)
    dxDrawText("✕ CANCEL", ox + 224, oy + 100, ox + 404, oy + 136,
        tocolor(255, 255, 255, 255), 0.9, "default-bold", "center", "center")
end

-- ============================================================
-- CLICK HANDLER
-- ============================================================

addEventHandler("onClientClick", root, function(button, state)
    if button ~= "left" or state ~= "down" then return end
    if not Admin._visible then return end

    local sw, sh = guiGetScreenSize()
    local px = (sw - W) / 2
    local py = (sh - H) / 2

    -- Input overlay eats all clicks when active
    if Admin._input.active then
        local ow, oh = 420, 160
        local ox = px + (W - ow) / 2
        local oy = py + (H - oh) / 2

        -- Confirm
        if mx_in(ox + 16, oy + 100, 180, 36) then
            Admin.confirmInput()
            return
        end
        -- Cancel
        if mx_in(ox + 224, oy + 100, 180, 36) then
            Admin._input.active = false
            Admin._input.value  = ""
            return
        end
        return  -- swallow all other clicks
    end

    -- Refresh button
    if mx_in(px + W - 185, py + 12, 65, 28) then
        triggerServerEvent("mzansi:admin:requestPlayerList", localPlayer)
        playSoundFrontEnd(40)
        return
    end

    -- Tabs
    local tabs = { { id = "players" }, { id = "server" } }
    local tabX = px + 10
    local tabY  = py + HEADER_H + 4
    for _, tab in ipairs(tabs) do
        if mx_in(tabX, tabY, 154, TAB_H - 4) then
            Admin._currentTab  = tab.id
            Admin._scrollOffset = 0
            Admin._selectedSerial = nil
            playSoundFrontEnd(40)
            return
        end
        tabX = tabX + 160
    end

    if Admin._currentTab ~= "players" then return end

    local cx = px + 10
    local cy = py + HEADER_H + TAB_H + 8

    -- Player rows
    local rowY = cy + 28
    for i = 1, MAX_VISIBLE do
        local idx = i + Admin._scrollOffset
        local p   = Admin._players[idx]
        if not p then break end

        local cw = W - 20
        if mx_in(cx, rowY, cw - 180, ROW_H) then
            Admin._selectedSerial = (Admin._selectedSerial == p.serial) and nil or p.serial
            playSoundFrontEnd(40)
            return
        end
        rowY = rowY + ROW_H
    end

    -- Scroll
    local scrollY = cy + 28 + MAX_VISIBLE * ROW_H + 4
    if mx_in(cx, scrollY, 100, 18) and Admin._scrollOffset > 0 then
        Admin._scrollOffset = Admin._scrollOffset - 1
        return
    end
    if mx_in(cx + 110, scrollY, 150, 18) and Admin._scrollOffset + MAX_VISIBLE < #Admin._players then
        Admin._scrollOffset = Admin._scrollOffset + 1
        return
    end

    -- Action buttons (only if a player is selected)
    if not Admin._selectedSerial then return end

    local sel = nil
    for _, p in ipairs(Admin._players) do
        if p.serial == Admin._selectedSerial then sel = p; break end
    end
    if not sel then return end

    local detX = px + (W - 20) - 170 + 10   -- same as detX in render
    local detY = cy

    local sel_info_lines = 10   -- lines before buttons (including Status line)
    local aby = detY + 44 + sel_info_lines * 15 + 6

    local actions = {
        { label = "Kick",        action = "kick",          minLvl = 1, onlineOnly = true },
        { label = "Ban",         action = "ban",           minLvl = 2, onlineOnly = false },
        { label = "Give Cash",   action = "giveCash",      minLvl = 1, onlineOnly = true },
        { label = "Set Job",     action = "setJob",        minLvl = 1, onlineOnly = true },
        { label = "TP To",       action = "teleportTo",    minLvl = 1, onlineOnly = true },
        { label = "Bring Here",  action = "bringHere",     minLvl = 1, onlineOnly = true },
        { label = "Heal",        action = "heal",          minLvl = 1, onlineOnly = true },
        { label = Admin._frozenPlayers[sel.serial] and "Unfreeze" or "Freeze", action = "freeze", minLvl = 1, onlineOnly = true },
        { label = "Set Adm Lvl", action = "setAdminLevel", minLvl = 5, onlineOnly = false },
    }

    for _, act in ipairs(actions) do
        if Admin._adminLevel >= act.minLvl and (not act.onlineOnly or sel.online) then
            if mx_in(detX + 4, aby, 160, 26) then
                Admin.triggerAction(act.action, sel)
                playSoundFrontEnd(40)
                return
            end
            aby = aby + 30
        end
    end
end)

-- ============================================================
-- ACTION DISPATCH
-- ============================================================

function Admin.triggerAction(action, player)
    local directActions = {
        teleportTo = function()
            triggerServerEvent("mzansi:admin:teleportTo", localPlayer, player.serial)
        end,
        bringHere = function()
            triggerServerEvent("mzansi:admin:bringHere", localPlayer, player.serial)
        end,
        heal = function()
            triggerServerEvent("mzansi:admin:heal", localPlayer, player.serial)
        end,
        freeze = function()
            local isFrozen = not Admin._frozenPlayers[player.serial]
            Admin._frozenPlayers[player.serial] = isFrozen
            triggerServerEvent("mzansi:admin:freeze", localPlayer, player.serial, isFrozen)
        end,
    }

    local inputActions = {
        kick          = "Enter kick reason:",
        ban           = "Enter ban reason (Level 2+ required):",
        giveCash      = "Enter amount to give (e.g. 5000):",
        setJob        = "Enter job ID (0=Unemployed, 1=SAPS, 2=EMS, 3=Mechanic, 4=Trucker...):  ",
        setAdminLevel = "Enter new admin level (0-10, must be lower than yours):",
    }

    if directActions[action] then
        directActions[action]()
    elseif inputActions[action] then
        Admin._input.active = true
        Admin._input.action = action
        Admin._input.label  = inputActions[action]
        Admin._input.value  = ""
    end
end

function Admin.confirmInput()
    local action = Admin._input.action
    local value  = Admin._input.value
    local serial = Admin._selectedSerial

    if not serial or value == "" then
        Admin._input.active = false
        Admin._input.value  = ""
        return
    end

    Admin._input.active = false
    Admin._input.value  = ""

    if action == "kick" then
        triggerServerEvent("mzansi:admin:kick", localPlayer, serial, value)
    elseif action == "ban" then
        triggerServerEvent("mzansi:admin:ban", localPlayer, serial, value)
    elseif action == "giveCash" then
        triggerServerEvent("mzansi:admin:giveCash", localPlayer, serial, tonumber(value))
    elseif action == "setJob" then
        triggerServerEvent("mzansi:admin:setJob", localPlayer, serial, tonumber(value))
    elseif action == "setAdminLevel" then
        triggerServerEvent("mzansi:admin:setAdminLevel", localPlayer, serial, tonumber(value))
    end
end

-- ============================================================
-- KEYBOARD — text input when overlay is active
-- ============================================================

addEventHandler("onClientKey", root, function(key, pressed)
    if not pressed then return end
    if not Admin._visible then return end
    if not Admin._input.active then return end

    if key == "backspace" then
        if #Admin._input.value > 0 then
            Admin._input.value = Admin._input.value:sub(1, -2)
        end
    elseif key == "return" or key == "enter" then
        Admin.confirmInput()
    elseif key == "escape" then
        Admin._input.active = false
        Admin._input.value  = ""
    end
    cancelEvent()
end)

addEventHandler("onClientCharacter", root, function(char)
    if not Admin._visible then return end
    if not Admin._input.active then return end
    if #Admin._input.value < 64 then
        Admin._input.value = Admin._input.value .. char
    end
    cancelEvent()
end)

-- Scroll wheel
addEventHandler("onClientKey", root, function(key, pressed)
    if not pressed then return end
    if not Admin._visible or Admin._currentTab ~= "players" then return end
    if Admin._input.active then return end

    if key == "mouse_wheel_up" and Admin._scrollOffset > 0 then
        Admin._scrollOffset = Admin._scrollOffset - 1
    elseif key == "mouse_wheel_down" and Admin._scrollOffset + MAX_VISIBLE < #Admin._players then
        Admin._scrollOffset = Admin._scrollOffset + 1
    end
end)

-- ============================================================
-- KEYBINDS
-- ============================================================

bindKey("f7", "down", function()
    if Mzansi.Util and Mzansi.Util.bindBlocked and Mzansi.Util.bindBlocked() then return end
    if not Admin._visible then
        Admin.open()
    else
        Admin.close()
    end
end)

addCommandHandler("admin", function()
    Admin.toggle()
end)
