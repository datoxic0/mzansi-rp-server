-- ==============================================================
-- MZANSI CORE — CLIENT HUD (GTA V STYLE OVERHAUL)
-- Rectangular GTA V radar frame, bottom HP/Armor stat bars,
-- top-right financial hub (Rand currency & bank), digital speedo
-- ==============================================================
Mzansi = Mzansi or {}
Mzansi.HUD = {}
Mzansi.HUD._visible = true
Mzansi.HUD._notifications = {}

function Mzansi.HUD.show(visible)
    Mzansi.HUD._visible = visible
    showChat(visible)
    showCursor(false)
end

-- ================================================================
-- Hide Native Juvenile GTA SA HUD Components
-- Eliminates fist weapon icon, clock, red bar, and redundant $00000000
-- ================================================================
local NATIVE_COMPONENTS_TO_HIDE = {
    "armour", "health", "money", "clock", "weapon", "ammo", "breath", "wanted", "area_name"
}

local function hideNativeHUD()
    for _, comp in ipairs(NATIVE_COMPONENTS_TO_HIDE) do
        setPlayerHudComponentVisible(comp, false)
    end
end
addEventHandler("onClientResourceStart", resourceRoot, hideNativeHUD)

-- ================================================================
-- Top-Right Financial Hub & Player Status (GTA V Style)
-- Clean Rand currency, bank balance, weapon ammo, in-game time
-- ================================================================
local function renderTopRightHUD(screenW, screenH)
    local cash = getElementData(localPlayer, "mzansi:cash") or 0
    local bank = getElementData(localPlayer, "mzansi:bank") or 0

    -- Synchronize native player money
    if getPlayerMoney() ~= cash then
        setPlayerMoney(cash, true)
    end

    local topX = screenW - 320
    local topY = 24

    -- Modern Green Rand Currency (GTA V Style)
    local cashStr = Mzansi.Util.formatMoney(cash)
    -- Shadow
    dxDrawText(cashStr, topX + 2, topY + 2, screenW - 22, topY + 36, tocolor(0, 0, 0, 200), 1.6, "default-bold", "right", "top")
    -- Fill
    dxDrawText(cashStr, topX, topY, screenW - 24, topY + 34, tocolor(85, 230, 110, 255), 1.6, "default-bold", "right", "top")

    -- Bank balance underneath (sleek cool blue)
    local bankStr = "Bank: " .. Mzansi.Util.formatMoney(bank)
    dxDrawText(bankStr, topX + 1, topY + 37, screenW - 23, topY + 55, tocolor(0, 0, 0, 180), 0.95, "default-bold", "right", "top")
    dxDrawText(bankStr, topX, topY + 36, screenW - 24, topY + 54, tocolor(150, 205, 255, 230), 0.95, "default-bold", "right", "top")

    local nextY = topY + 58

    -- Clean Weapon & Ammo Display (only when holding a weapon)
    local weapon = getPedWeapon(localPlayer)
    if weapon and weapon > 0 then
        local totalAmmo = getPedTotalAmmo(localPlayer) or 0
        local clipAmmo  = getPedAmmoInClip(localPlayer) or 0
        local weaponName = getWeaponNameFromID(weapon) or "Weapon"
        local reserve = math.max(0, totalAmmo - clipAmmo)
        local ammoStr = string.format("%s   %d / %d", weaponName, clipAmmo, reserve)

        dxDrawText(ammoStr, topX + 1, nextY + 1, screenW - 23, nextY + 21, tocolor(0, 0, 0, 180), 0.9, "default-bold", "right", "top")
        dxDrawText(ammoStr, topX, nextY, screenW - 24, nextY + 20, tocolor(230, 235, 245, 230), 0.9, "default-bold", "right", "top")
        nextY = nextY + 22
    end

    -- Clean In-Game Time
    local h, m = getTime()
    local timeStr = string.format("%02d:%02d", h, m)
    dxDrawText(timeStr, topX + 1, nextY + 1, screenW - 23, nextY + 21, tocolor(0, 0, 0, 160), 0.85, "default-bold", "right", "top")
    dxDrawText(timeStr, topX, nextY, screenW - 24, nextY + 20, tocolor(200, 205, 215, 200), 0.85, "default-bold", "right", "top")
    nextY = nextY + 22

    -- Wanted Level Stars
    local wanted = getPlayerWantedLevel()
    if wanted and wanted > 0 then
        local starSize = 16
        local starGap = 4
        local totalStarW = (starSize * 6) + (starGap * 5)
        local starStartX = screenW - 24 - totalStarW
        for i = 1, 6 do
            local sx = starStartX + (i - 1) * (starSize + starGap)
            local starCol = i <= wanted and tocolor(255, 200, 0, 240) or tocolor(60, 60, 60, 150)
            dxDrawText("★", sx, nextY, sx + starSize, nextY + starSize, starCol, 1.2, "default-bold", "center", "center")
        end
    end
end

-- ================================================================
-- GTA V Style Rectangular Radar Frame & Stat Bars
-- Rectangular radar casing, bottom Health & Armor bars, location strip
-- ================================================================
local RADAR_W = 240
local RADAR_H = 140

local function renderGTAVRadar(screenW, screenH)
    -- Position at bottom-left corner
    local rx = 24
    local ry = screenH - RADAR_H - 45

    -- Dark glass backing
    dxDrawRectangle(rx - 2, ry - 2, RADAR_W + 4, RADAR_H + 4, tocolor(12, 16, 24, 210), false)
    -- Sleek 1px dark charcoal border
    dxDrawRectangle(rx - 2, ry - 2, RADAR_W + 4, 1, tocolor(255, 255, 255, 35), false) -- top
    dxDrawRectangle(rx - 2, ry + RADAR_H + 1, RADAR_W + 4, 1, tocolor(255, 255, 255, 35), false) -- bottom
    dxDrawRectangle(rx - 2, ry - 2, 1, RADAR_H + 4, tocolor(255, 255, 255, 35), false) -- left
    dxDrawRectangle(rx + RADAR_W + 1, ry - 2, 1, RADAR_H + 4, tocolor(255, 255, 255, 35), false) -- right

    -- Location Banner Strip (above radar)
    local px, py, pz = getElementPosition(localPlayer)
    local zoneName = getZoneName(px, py, pz) or "San Andreas"
    local cityName = getZoneName(px, py, pz, true) or "Mzansi"

    -- Free State Government Sanctuary Peninsula (Bayside / Tierra Robada North)
    if px >= -2650 and px <= -2050 and py >= 2150 and py <= 2600 then
        cityName = "FREE STATE"
        zoneName = "GOVERNMENT SANCTUARY"
    end

    dxDrawRectangle(rx - 2, ry - 24, RADAR_W + 4, 22, tocolor(15, 20, 28, 230), false)
    dxDrawRectangle(rx - 2, ry - 24, RADAR_W + 4, 1, tocolor(255, 255, 255, 30), false)
    dxDrawText(string.upper(cityName .. "  •  " .. zoneName),
        rx + 6, ry - 24, rx + RADAR_W - 6, ry - 2,
        tocolor(225, 230, 240, 240), 0.8, "default-bold", "left", "center", true)

    -- GTA V Stat Bars (under radar)
    local barY  = ry + RADAR_H + 4
    local barH  = 8
    local gap   = 4
    local barW  = math.floor((RADAR_W - gap) / 2)

    -- 1. Health Bar (Left half - Green)
    local health = math.max(0, math.min(100, getElementHealth(localPlayer)))
    local hpPct  = health / 100
    local hpCol  = health < 25 and tocolor(230, 60, 60, 240) or tocolor(46, 204, 113, 240)
    -- Dark background track
    dxDrawRectangle(rx, barY, barW, barH, tocolor(20, 45, 28, 220), false)
    -- Health fill
    if hpPct > 0 then
        dxDrawRectangle(rx, barY, math.floor(barW * hpPct), barH, hpCol, false)
    end

    -- 2. Armor Bar (Right half - Blue)
    local armor = math.max(0, math.min(100, getPedArmor(localPlayer)))
    local apPct = armor / 100
    -- Dark background track
    dxDrawRectangle(rx + barW + gap, barY, barW, barH, tocolor(15, 32, 55, 220), false)
    -- Armor fill
    if apPct > 0 then
        dxDrawRectangle(rx + barW + gap, barY, math.floor(barW * apPct), barH, tocolor(52, 152, 219, 240), false)
    end

    -- 3. Oxygen / Stamina Bar (Subtle bottom line when swimming or sprinting)
    local breath = getPedOxygenLevel(localPlayer) or 1000
    if breath < 990 or isElementInWater(localPlayer) then
        local breathPct = math.max(0, math.min(1, breath / 1000))
        dxDrawRectangle(rx, barY + barH + 2, RADAR_W, 3, tocolor(10, 30, 40, 220), false)
        dxDrawRectangle(rx, barY + barH + 2, math.floor(RADAR_W * breathPct), 3, tocolor(26, 188, 156, 240), false)
    end

    -- Player Character Pill (Sleek minimalist sub-strip)
    local character = getElementData(localPlayer, "mzansi:character")
    if character then
        local name = (character.firstName or "") .. " " .. (character.lastName or "")
        local jobName = (Mzansi.Config and Mzansi.Config.Jobs and Mzansi.Config.Jobs[character.job] and Mzansi.Config.Jobs[character.job].name) or "Citizen"
        local levelText = "Lvl " .. (character.level or 1)
        dxDrawText(name .. "  •  " .. jobName .. " (" .. levelText .. ")",
            rx, barY + barH + 6, rx + RADAR_W, barY + barH + 22,
            tocolor(170, 185, 205, 200), 0.75, "default", "left", "center", true)
    end
end

-- ================================================================
-- Vehicle Speedometer — Sleek Minimalist Digital Dashboard
-- Single source of vehicle telemetry
-- ================================================================
function Mzansi.HUD.renderVehicleHUD(vehicle, screenW, screenH)
    local hudW = 215
    local hudH = 95
    local hudX = screenW - hudW - 25
    local hudY = screenH - hudH - 25

    -- Dark glass container
    dxDrawRectangle(hudX, hudY, hudW, hudH, tocolor(12, 16, 24, 210), true)
    dxDrawRectangle(hudX, hudY, hudW, 1, tocolor(255, 255, 255, 30), true)

    local speed  = getElementSpeed(vehicle, "kmh")
    local fuel   = getElementData(vehicle, "mzansi:fuel") or 100
    local gear   = getVehicleCurrentGear(vehicle)
    local locked = getElementData(vehicle, "mzansi:locked")
    local engine = getVehicleEngineState(vehicle)

    -- Vehicle Name
    dxDrawText(string.upper(getVehicleName(vehicle)), hudX + 12, hudY + 8, hudX + hudW - 12, hudY + 24, tocolor(225, 230, 240, 240), 0.85, "default-bold", "left", "top", true)

    -- Digital Speedometer
    local speedColor = speed < 80 and tocolor(240, 245, 255, 255) or (speed < 140 and tocolor(241, 196, 15, 255) or tocolor(231, 76, 60, 255))
    dxDrawText(tostring(math.floor(speed)), hudX + 12, hudY + 28, hudX + 90, hudY + 62, speedColor, 1.5, "default-bold", "left", "center")
    dxDrawText("KM/H", hudX + 78, hudY + 38, hudX + 130, hudY + 58, tocolor(160, 175, 195, 200), 0.75, "default-bold", "left", "center")
    dxDrawText("GEAR " .. gear, hudX + 130, hudY + 38, hudX + hudW - 12, hudY + 58, tocolor(160, 175, 195, 200), 0.75, "default-bold", "right", "center")

    -- Fuel Gauge
    dxDrawRectangle(hudX + 12, hudY + 64, hudW - 24, 5, tocolor(25, 32, 45, 220), true)
    local fuelColor = fuel > 30 and tocolor(46, 204, 113, 220) or tocolor(231, 76, 60, 220)
    dxDrawRectangle(hudX + 12, hudY + 64, math.floor(((fuel / 100) * (hudW - 24))), 5, fuelColor, true)

    -- Status Badges
    local lockStr = locked and "🔒 LOCKED" or "🔓 UNLOCKED"
    local lockCol = locked and tocolor(231, 76, 60, 220) or tocolor(46, 204, 113, 220)
    dxDrawText(lockStr, hudX + 12, hudY + 74, hudX + 100, hudY + 90, lockCol, 0.75, "default-bold", "left", "center")

    local engStr = engine and "⚡ ENGINE ON" or "⚡ OFF"
    local engCol = engine and tocolor(46, 204, 113, 220) or tocolor(160, 170, 185, 200)
    dxDrawText(engStr, hudX + 110, hudY + 74, hudX + hudW - 12, hudY + 90, engCol, 0.75, "default-bold", "right", "center")
end

-- ================================================================
-- Notification Toasts
-- ================================================================
function Mzansi.HUD.notify(message, ntype)
    ntype = ntype or "info"
    local colors = {
        info    = { r = 52,  g = 152, b = 219 },
        success = { r = 46,  g = 204, b = 113 },
        error   = { r = 231, g = 76,  b = 60  },
        warning = { r = 241, g = 196, b = 15  },
    }
    local color = colors[ntype] or colors.info
    table.insert(Mzansi.HUD._notifications, {
        message = message, color = color,
        time = getTickCount(), alpha = 255,
    })
    if #Mzansi.HUD._notifications > 5 then
        table.remove(Mzansi.HUD._notifications, 1)
    end
end

local function renderNotifications(screenW)
    local now     = getTickCount()
    local yOffset = 0

    for i = #Mzansi.HUD._notifications, 1, -1 do
        local n       = Mzansi.HUD._notifications[i]
        local elapsed = now - n.time

        if elapsed > 5000 then
            n.alpha = n.alpha - 5
            if n.alpha <= 0 then
                table.remove(Mzansi.HUD._notifications, i)
                break
            end
        end

        local alpha = math.max(0, n.alpha)
        local msgW  = dxGetTextWidth(n.message, 1, "default-bold") + 24
        local msgX  = screenW - msgW - 24
        local msgY  = 20 + yOffset

        dxDrawRectangle(msgX, msgY, msgW, 30, tocolor(12, 16, 24, alpha * 0.85), true)
        dxDrawRectangle(msgX, msgY, 3, 30, tocolor(n.color.r, n.color.g, n.color.b, alpha), true)
        dxDrawText(n.message, msgX + 12, msgY, msgX + msgW, msgY + 30,
            tocolor(240, 245, 255, alpha), 0.95, "default-bold", "left", "center")
        yOffset = yOffset + 36
    end
end

-- ================================================================
-- Master Render Loop
-- ================================================================
local lastHideTick = 0

addEventHandler("onClientRender", root, function()
    if not Mzansi.HUD._visible then return end

    -- Keep native SA HUD hidden
    local now = getTickCount()
    if now - lastHideTick > 500 then
        hideNativeHUD()
        lastHideTick = now
    end

    local screenW, screenH = guiGetScreenSize()

    -- 1. GTA V Radar frame & Stat bars (bottom-left)
    renderGTAVRadar(screenW, screenH)

    -- 2. GTA V Top-Right Financial Hub & Weapon Status
    renderTopRightHUD(screenW, screenH)

    -- 3. Vehicle Speedometer (if in vehicle)
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if vehicle then
        Mzansi.HUD.renderVehicleHUD(vehicle, screenW, screenH)
    end

    -- 4. Notification Toasts
    renderNotifications(screenW)
end)

-- ================================================================
-- Events
-- ================================================================
addEvent("mzansi:notification", true)
addEventHandler("mzansi:notification", root, function(message, ntype)
    Mzansi.HUD.notify(message, ntype)
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
    hideNativeHUD()
    outputDebugString("[Mzansi-HUD] Clean GTA V style rectangular radar & financial HUD loaded.")
end)
