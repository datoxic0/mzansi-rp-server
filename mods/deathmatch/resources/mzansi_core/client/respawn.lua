-- ============================================================
-- Mzansi RP :: Respawn / Death Screen  (client-side)
-- ============================================================

local SCREEN_W, SCREEN_H = guiGetScreenSize()

-- State
local deathScreen = {
    active      = false,
    countdown   = 0,
    countdownRaw= 0,
    fee         = 0,
    elapsed     = 0,
    alpha       = 0,         -- current overlay alpha (0-200)
    targetAlpha = 200,
}

-- ── Rendering ────────────────────────────────────────────────
local function drawDeathScreen()
    if not deathScreen.active then return end

    local dt    = getTickCount()
    local pulse = math.abs(math.sin(dt / 600)) * 40  -- pulse the red

    -- Full-screen dark-red vignette
    dxDrawRectangle(0, 0, SCREEN_W, SCREEN_H,
        tocolor(80 + pulse, 0, 0, deathScreen.alpha))

    -- Vignette border gradient (darker edges)
    local border = 120
    dxDrawRectangle(0, 0, SCREEN_W, border,
        tocolor(0, 0, 0, 160))
    dxDrawRectangle(0, SCREEN_H - border, SCREEN_W, border,
        tocolor(0, 0, 0, 160))

    -- "WASTED" title
    local titleSize = 80
    dxDrawText("WASTED",
        0, SCREEN_H * 0.28,
        SCREEN_W, SCREEN_H * 0.28 + titleSize + 10,
        tocolor(220, 20, 20, 255),
        1.0, "default-bold",
        "center", "top", false, false, false, true)

    -- Subtitle
    dxDrawText("YOU HAVE BEEN SENT TO HOSPITAL",
        0, SCREEN_H * 0.28 + titleSize + 16,
        SCREEN_W, SCREEN_H * 0.28 + titleSize + 46,
        tocolor(200, 200, 200, 200),
        1.0, "default",
        "center", "top", false, false, false, true)

    -- Countdown circle background
    local cx, cy, cr = SCREEN_W / 2, SCREEN_H * 0.58, 52
    dxDrawCircle(cx, cy, cr, 0, 360, tocolor(0, 0, 0, 180), tocolor(0, 0, 0, 180), 40)

    -- Countdown arc (progress)
    local pct = deathScreen.countdown / deathScreen.countdownRaw
    if pct > 0 then
        dxDrawCircle(cx, cy, cr, -90, -90 + (pct * 360),
            tocolor(220, 50, 50, 220), tocolor(200, 30, 30, 220), 40)
    end

    -- Countdown number
    dxDrawText(tostring(math.ceil(deathScreen.countdown)),
        cx - cr, cy - cr,
        cx + cr, cy + cr,
        tocolor(255, 255, 255, 255),
        1.0, "default-bold",
        "center", "center", false, false, false, true)

    -- Hospital fee message
    if deathScreen.fee > 0 then
        dxDrawText("Medical Fee: R" .. deathScreen.fee .. " will be deducted",
            0, SCREEN_H * 0.70,
            SCREEN_W, SCREEN_H * 0.70 + 26,
            tocolor(255, 180, 50, 200),
            1.0, "default",
            "center", "top", false, false, false, true)
    end

    -- Bottom tip
    dxDrawText("Respawning at hospital...",
        0, SCREEN_H * 0.76,
        SCREEN_W, SCREEN_H * 0.76 + 22,
        tocolor(150, 150, 150, 180),
        1.0, "default",
        "center", "top", false, false, false, true)
end

-- ── Countdown tick (every 100ms) ─────────────────────────────
local countdownTimer = nil

local function tickCountdown()
    if not deathScreen.active then return end
    deathScreen.countdown = deathScreen.countdown - 0.1
    if deathScreen.countdown < 0 then deathScreen.countdown = 0 end
end

-- ── Events ───────────────────────────────────────────────────
addEvent("mzansi:respawn:startDeathScreen", true)
addEventHandler("mzansi:respawn:startDeathScreen", root, function(seconds, fee)
    deathScreen.active      = true
    deathScreen.countdown   = seconds or 8
    deathScreen.countdownRaw= seconds or 8
    deathScreen.fee         = fee or 0
    deathScreen.alpha       = 0

    -- Fade in the overlay
    animateVar(deathScreen, "alpha", 0, 200, 800)

    -- Lock camera on the ragdoll body with a cinematic pull-back
    setCameraMatrix(
        getElementPosition(localPlayer),
        getElementPosition(localPlayer)
    )

    -- Block all player input while dead
    toggleAllControls(false)
    toggleControl("screenshot", true)

    -- Start countdown timer
    if countdownTimer and isTimer(countdownTimer) then
        killTimer(countdownTimer)
    end
    countdownTimer = setTimer(tickCountdown, 100, 0)
end)

addEvent("mzansi:respawn:complete", true)
addEventHandler("mzansi:respawn:complete", root, function()
    -- Kill countdown
    if countdownTimer and isTimer(countdownTimer) then
        killTimer(countdownTimer)
        countdownTimer = nil
    end

    -- Restore controls
    toggleAllControls(true)

    -- Fade out the screen
    animateVar(deathScreen, "alpha", deathScreen.alpha, 0, 600)
    setTimer(function()
        deathScreen.active    = false
        deathScreen.countdown = 0
        deathScreen.fee       = 0
    end, 700, 1)
end)

-- ── Draw hook ────────────────────────────────────────────────
addEventHandler("onClientRender", root, drawDeathScreen)

-- ── animateVar helper (simple lerp via repeated timer) ───────
function animateVar(tbl, key, from, to, durationMs)
    tbl[key] = from
    local steps = 20
    local stepTime = durationMs / steps
    local stepVal  = (to - from) / steps
    local step = 0
    setTimer(function()
        step = step + 1
        tbl[key] = from + stepVal * step
        if step >= steps then tbl[key] = to end
    end, stepTime, steps)
end
