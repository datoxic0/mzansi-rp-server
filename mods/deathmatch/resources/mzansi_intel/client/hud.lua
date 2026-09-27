-- ============================================================
-- MZANSI INTEL: PRODUCTION HUD — God's Eye View Situational Layer
-- client/hud.lua
-- Military-grade contacts roster, detection boxes, trails, radar
-- ============================================================

Mzansi = Mzansi or {}
Mzansi.Intel = Mzansi.Intel or {}

local hudVisible = false
local FONT_H   = "default-bold"
local FONT_B   = "default"
local FONT_S   = "default-small"
local FONT_C   = "courier-bold"

local kindColor = {
    aircraft = { 0, 229, 255 },
    rotor    = { 255, 200, 0 },
    vessel   = { 0, 255, 128 },
    sub      = { 120, 80, 255 },
    ground   = { 255, 255, 255 },
    unknown  = { 180, 180, 180 },
}

local kindLabel = {
    aircraft = "AIR",
    rotor    = "ROT",
    vessel   = "SEA",
    sub      = "SUB",
    ground   = "GND",
    unknown  = "UNK",
}

function toggleIntelHUD()
    hudVisible = not hudVisible
    return hudVisible
end

addEvent("mzansi:intel:uiToggle", true)
addEventHandler("mzansi:intel:uiToggle", resourceRoot, function(state)
    hudVisible = state
end)

-- ============================================================
-- CORNER-BOX DRAW HELPER
-- ============================================================
local function drawCornerBox(x, y, size, col, alpha, thick)
    thick = thick or 2
    local arm = math.floor(size * 0.35)
    local c = tocolor(col[1], col[2], col[3], alpha)
    -- TL
    dxDrawLine(x, y, x + arm, y, c, thick)
    dxDrawLine(x, y, x, y + arm, c, thick)
    -- TR
    dxDrawLine(x + size, y, x + size - arm, y, c, thick)
    dxDrawLine(x + size, y, x + size, y + arm, c, thick)
    -- BL
    dxDrawLine(x, y + size, x + arm, y + size, c, thick)
    dxDrawLine(x, y + size, x, y + size - arm, c, thick)
    -- BR
    dxDrawLine(x + size, y + size, x + size - arm, y + size, c, thick)
    dxDrawLine(x + size, y + size, x + size, y + size - arm, c, thick)
end

-- ============================================================
-- MAIN RENDER
-- ============================================================
addEventHandler("onClientRender", root, function()
    if not hudVisible then return end
    if not Mzansi.Intel or not Mzansi.Intel.isActive or not Mzansi.Intel.isActive() then return end

    local sx, sy = guiGetScreenSize()
    local contacts = getContacts and getContacts() or {}
    local cfg = Mzansi.Intel.Config
    local tick = getTickCount()

    -- ── TOP CENTER: Title bar ─────────────────────────────
    local titleY = 10
    dxDrawRectangle(sx / 2 - 260, titleY, 520, 52, tocolor(4, 10, 20, 200))
    dxDrawRectangle(sx / 2 - 260, titleY, 520, 2, tocolor(0, 229, 255, 255))
    dxDrawRectangle(sx / 2 - 260, titleY + 50, 520, 1, tocolor(0, 229, 255, 100))

    dxDrawText("GOD'S EYE VIEW  //  SITUATIONAL LAYER",
        sx / 2 - 255, titleY + 6, sx / 2 + 255, titleY + 28,
        tocolor(0, 229, 255, 255), 1.1, FONT_H, "center", "top")

    -- Status blink
    local blink = math.floor(tick / 500) % 2 == 0
    local statusCol = blink and { 0, 255, 100 } or { 0, 180, 70 }
    dxDrawText(string.format("STATUS: ONLINE  |  CONTACTS: %d  |  RANGE: %dm  |  REFRESH: %dms",
        #contacts, cfg.contactRadius, cfg.refreshMs),
        sx / 2 - 255, titleY + 30, sx / 2 + 255, titleY + 48,
        tocolor(statusCol[1], statusCol[2], statusCol[3], 230), 0.9, FONT_S, "center", "top")

    -- ── RIGHT PANEL: Contact roster ───────────────────────
    local rosterW = 360
    local rosterX = sx - rosterW - 16
    local rosterY = 76
    local rowH = 20
    local maxRows = math.min(#contacts, 28)
    local rosterH = 36 + maxRows * rowH + 30

    -- Panel bg
    dxDrawRectangle(rosterX, rosterY, rosterW, rosterH, tocolor(4, 10, 20, 195))
    dxDrawRectangle(rosterX, rosterY, 2, rosterH, tocolor(0, 229, 255, 220))

    -- Header
    dxDrawRectangle(rosterX + 2, rosterY, rosterW - 2, 28, tocolor(0, 40, 70, 230))
    dxDrawText("CONTACT ROSTER", rosterX + 10, rosterY + 4, rosterX + rosterW - 10, rosterY + 26,
        tocolor(0, 229, 255, 255), 1.0, FONT_H, "left", "center")

    -- Column headers
    local colKind = rosterX + 10
    local colName = rosterX + 52
    local colDist = rosterX + 250
    local colSpd  = rosterX + 300
    local headY = rosterY + 30
    dxDrawText("K  NAME                 DIST   SPD", colKind, headY, rosterX + rosterW - 8, headY + 14,
        tocolor(100, 140, 170, 200), 0.85, FONT_S, "left", "top")

    local tracked = Mzansi.Intel.getTracked and Mzansi.Intel.getTracked()

    for i = 1, maxRows do
        local c = contacts[i]
        if not c then break end
        local col = kindColor[c.kind] or kindColor.unknown
        local y = rosterY + 46 + (i - 1) * rowH
        local isTracked = (tracked == c.id)

        -- Row bg (zebra + tracked highlight)
        if isTracked then
            dxDrawRectangle(rosterX + 2, y - 2, rosterW - 4, rowH, tocolor(0, 60, 100, 200))
            dxDrawRectangle(rosterX + 2, y - 2, 3, rowH, tocolor(0, 229, 255, 255))
        elseif i % 2 == 0 then
            dxDrawRectangle(rosterX + 2, y - 2, rosterW - 4, rowH, tocolor(255, 255, 255, 8))
        end

        -- Kind badge
        local badge = kindLabel[c.kind] or "UNK"
        dxDrawText(badge, colKind, y, colKind + 40, y + rowH,
            tocolor(col[1], col[2], col[3], 255), 0.9, FONT_C, "left", "center")

        -- Name (truncated)
        local name = c.driver ~= "" and c.driver or c.label
        name = string.sub(name, 1, 18)
        dxDrawText((isTracked and "> " or "  ") .. name, colName, y, colDist - 4, y + rowH,
            tocolor(isTracked and 255 or 210, isTracked and 255 or 220, isTracked and 255 or 230, 255),
            0.9, FONT_S, "left", "center")

        -- Distance
        dxDrawText(string.format("%dm", c.dist), colDist, y, colSpd - 4, y + rowH,
            tocolor(180, 200, 220, 240), 0.9, FONT_S, "right", "center")

        -- Speed
        dxDrawText(string.format("%3d", math.floor(c.speed * 1.2)), colSpd, y, rosterX + rosterW - 8, y + rowH,
            tocolor(140, 200, 255, 240), 0.9, FONT_S, "right", "center")
    end

    -- Truncation note
    if #contacts > maxRows then
        dxDrawText(string.format("+ %d more contacts...", #contacts - maxRows),
            rosterX + 10, rosterY + rosterH - 24, rosterX + rosterW - 10, rosterY + rosterH - 6,
            tocolor(100, 140, 170, 200), 0.85, FONT_S, "left", "center")
    end

    -- ── LEFT PANEL: Tracked target detail ─────────────────
    if tracked and isElement(tracked) then
        local tx, ty, tz = getElementPosition(tracked)
        local px, py, pz = getElementPosition(localPlayer)
        local dist = getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz)
        local vx, vy, vz = getElementVelocity(tracked)
        local spd = math.floor(math.sqrt(vx*vx + vy*vy + vz*vz) * 180)
        local hp = math.floor(getElementHealth(tracked))
        local model = getElementModel(tracked)
        local _, label = nil, nil
        -- classify quickly
        local kind = "unknown"
        if cfg.planeModels[model] then kind = "aircraft"; label = cfg.planeModels[model]
        elseif cfg.heliModels[model] then kind = "rotor"; label = cfg.heliModels[model]
        elseif cfg.subModels and cfg.subModels[model] then kind = "sub"; label = cfg.subModels[model]
        elseif cfg.boatModels[model] then kind = "vessel"; label = cfg.boatModels[model]
        else kind = "ground"; label = getVehicleName(tracked) end
        local col = kindColor[kind] or kindColor.unknown

        local detW, detH = 300, 170
        local detX, detY = 16, 76
        dxDrawRectangle(detX, detY, detW, detH, tocolor(4, 10, 20, 195))
        dxDrawRectangle(detX, detY, 2, detH, tocolor(col[1], col[2], col[3], 255))
        dxDrawRectangle(detX + 2, detY, detW - 2, 28, tocolor(0, 40, 70, 230))
        dxDrawText("TRACKED TARGET", detX + 10, detY + 4, detX + detW - 10, detY + 26,
            tocolor(col[1], col[2], col[3], 255), 1.0, FONT_H, "left", "center")

        local lines = {
            { "CLASS",  string.upper(kindLabel[kind] or "UNK") .. "  " .. (label or "?") },
            { "MODEL",  tostring(model) },
            { "DIST",   string.format("%.0f m", dist) },
            { "SPEED",  string.format("%d km/h", spd * 1.2) },
            { "HEALTH", string.format("%d%%", math.min(100, math.floor(hp / 10))) },
            { "POS",    string.format("%.0f, %.0f, %.0f", tx, ty, tz) },
        }
        for j, line in ipairs(lines) do
            local ly = detY + 36 + (j - 1) * 20
            dxDrawText(line[1], detX + 12, ly, detX + 90, ly + 18,
                tocolor(100, 140, 170, 230), 0.9, FONT_S, "left", "top")
            dxDrawText(line[2], detX + 95, ly, detX + detW - 10, ly + 18,
                tocolor(230, 240, 255, 255), 0.9, FONT_C, "left", "top")
        end
    end

    -- ── WORLD OVERLAY: Detection boxes + labels ───────────
    if cfg.showDetectionBoxes then
        local px, py, pz = getElementPosition(localPlayer)
        for _, c in ipairs(contacts) do
            local sx2, sy2, sz2 = getScreenFromWorldPosition(c.x, c.y, c.z + 1.5, 0.15)
            if sx2 and sy2 and sz2 then
                local col = kindColor[c.kind] or kindColor.unknown
                local alpha = math.floor(230 * (1 - c.dist / cfg.contactRadius))
                if alpha > 50 then
                    local isTracked = (tracked == c.id)
                    local box = isTracked and 24 or 16
                    drawCornerBox(sx2 - box / 2, sy2 - box / 2, box, col, alpha, isTracked and 3 or 2)

                    -- Tracked: crosshair lines
                    if isTracked then
                        local cc = tocolor(col[1], col[2], col[3], alpha)
                        dxDrawLine(sx2 - 6, sy2, sx2 + 6, sy2, cc, 1)
                        dxDrawLine(sx2, sy2 - 6, sx2, sy2 + 6, cc, 1)
                    end

                    -- Label above box
                    local idLabel = string.format("%s %s", kindLabel[c.kind] or "?",
                        c.driver ~= "" and c.driver or c.label)
                    dxDrawText(idLabel, sx2 - 70, sy2 - box / 2 - 20, sx2 + 70, sy2 - box / 2 - 4,
                        tocolor(col[1], col[2], col[3], alpha), 0.85, FONT_S, "center", "bottom")

                    -- Distance under box
                    dxDrawText(string.format("%dm", c.dist), sx2 - 50, sy2 + box / 2 + 2, sx2 + 50, sy2 + box / 2 + 16,
                        tocolor(180, 200, 220, alpha), 0.8, FONT_S, "center", "top")
                end
            end
        end
    end

    -- ── TRAIL for tracked element ─────────────────────────
    local trailPts = Mzansi.Intel.getTrail and Mzansi.Intel.getTrail() or {}
    if #trailPts >= 2 then
        for i = 2, #trailPts do
            local a = trailPts[i - 1]
            local b = trailPts[i]
            local ax, ay = getScreenFromWorldPosition(a[1], a[2], a[3], 0.1)
            local bx2, by2 = getScreenFromWorldPosition(b[1], b[2], b[3], 0.1)
            if ax and ay and bx2 and by2 then
                local alpha = math.floor(200 * (i / #trailPts))
                dxDrawLine(ax, ay, bx2, by2, tocolor(0, 229, 255, alpha), 2)
            end
        end
    end

    -- ── BOTTOM: Keybind hint bar ──────────────────────────
    local hintY = sy - 36
    dxDrawRectangle(0, hintY, sx, 36, tocolor(4, 10, 20, 190))
    dxDrawRectangle(0, hintY, sx, 1, tocolor(0, 229, 255, 120))
    dxDrawText("/eye toggle  |  /track <#>  |  F6 radio  |  F7 admin  |  F8 creator  |  MMB quick-cycle",
        10, hintY + 4, sx - 10, hintY + 32,
        tocolor(140, 170, 190, 230), 0.9, FONT_S, "center", "center")
end)

-- Auto-track nearest aircraft on activate (wired to uiToggle event, not a separate autoTrack event)
addEventHandler("mzansi:intel:uiToggle", resourceRoot, function(state)
    if state then
        setTimer(function()
            if not Mzansi.Intel.isActive or not Mzansi.Intel.isActive() then return end
            local contacts = getContacts and getContacts() or {}
            -- Prefer aircraft, then rotor, then any
            for _, c in ipairs(contacts) do
                if c.kind == "aircraft" then Mzansi.Intel.setTracked(c.id); return end
            end
            for _, c in ipairs(contacts) do
                if c.kind == "rotor" then Mzansi.Intel.setTracked(c.id); return end
            end
            if contacts[1] then Mzansi.Intel.setTracked(contacts[1].id) end
        end, 1500, 1)
    end
end)

-- /track command
addCommandHandler("track", function(_, arg)
    if not Mzansi.Intel.isActive or not Mzansi.Intel.isActive() then
        outputChatBox("#00E5FF[INTEL] #FFFFFFGod's Eye View is offline. Use /eye first.", 255, 255, 255, true)
        return
    end
    local contacts = getContacts and getContacts() or {}
    if arg and arg ~= "" then
        local idx = tonumber(arg)
        if idx and contacts[idx] then
            Mzansi.Intel.setTracked(contacts[idx].id)
            outputChatBox("#00E5FF[INTEL] #FFFFFFTracking: " .. contacts[idx].label ..
                " (" .. contacts[idx].dist .. "m)", 255, 255, 255, true)
            return
        end
        outputChatBox("#FF6644[INTEL] #FFFFFFInvalid contact #. Use /track 1-28", 255, 255, 255, true)
        return
    end
    Mzansi.Intel.setTracked(nil)
    outputChatBox("#00E5FF[INTEL] #FFFFFFTracking cleared.", 255, 255, 255, true)
end)
