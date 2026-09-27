Mzansi = Mzansi or {}
Mzansi.HUD = Mzansi.HUD or {}

local function getElementSpeed(element, unit)
    if not isElement(element) then return 0 end
    unit = unit or "kmh"
    local vx, vy, vz = getElementVelocity(element)
    if not vx then return 0 end
    local speed = (vx * vx + vy * vy + vz * vz) ^ 0.5
    if unit == "kmh" or unit == 1 or unit == "kph" then
        return speed * 180
    elseif unit == "mph" or unit == 2 then
        return speed * 111.847
    else
        return speed
    end
end

Mzansi.HUD._visible = true
Mzansi.HUD._speedUnits = "kmh"

function Mzansi.HUD.toggle()
    Mzansi.HUD._visible = not Mzansi.HUD._visible
    showChat(Mzansi.HUD._visible)
end

function Mzansi.HUD.renderSpeedometer()
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if not vehicle then return end

    local screenW, screenH = guiGetScreenSize()
    local cx, cy = screenW - 100, screenH - 100
    local radius = 70

    dxDrawCircle(cx, cy, radius, 0, 360, tocolor(0, 0, 0, 180), tocolor(200, 170, 50, 100), 32, 1, true)

    local speed = getElementSpeed(vehicle, Mzansi.HUD._speedUnits)
    local maxSpeed = 200
    local angle = -135 + (speed / maxSpeed) * 270
    angle = math.min(angle, 135)

    local rad = math.rad(angle - 90)
    local needleX = cx + math.cos(rad) * (radius - 15)
    local needleY = cy + math.sin(rad) * (radius - 15)
    dxDrawLine(cx, cy, needleX, needleY, tocolor(255, 50, 50, 255), 2)

    dxDrawText(math.floor(speed), cx - 25, cy - 10, cx + 25, cy + 10, tocolor(255, 255, 255, 255), 1.2, "default-bold", "center", "center")
    dxDrawText("km/h", cx - 20, cy + 12, cx + 20, cy + 28, tocolor(200, 200, 200, 150), 0.7, "default", "center", "center")

    local fuel = getElementData(vehicle, "mzansi:fuel") or 100
    dxDrawRectangle(cx - 40, cy + 35, 80, 8, tocolor(50, 50, 0, 200), true)
    dxDrawRectangle(cx - 40, cy + 35, (fuel / 100) * 80, 8, tocolor(200, 180, 0, 220), true)
    dxDrawText(math.floor(fuel) .. "%", cx - 20, cy + 35, cx + 20, cy + 43, tocolor(255, 255, 255, 200), 0.7, "default-bold", "center", "center")
end

function Mzansi.HUD.renderCompass()
    if not Mzansi.HUD._visible then return end

    local screenW, screenH = guiGetScreenSize()
    local cx = screenW / 2
    local headings = { "N", "NW", "W", "SW", "S", "SE", "E", "NE" }
    local heading = math.floor(getPedRotation(localPlayer) / 45) % 8 + 1

    dxDrawText(headings[heading], cx - 15, 10, cx + 15, 30, tocolor(200, 170, 50, 200), 1, "default-bold", "center", "center")
end

addEventHandler("onClientRender", root, function()
    if not Mzansi.HUD._visible then return end
    -- Mzansi.HUD.renderSpeedometer() -- Disabled: Unified digital speedometer handled by mzansi_core HUD
    Mzansi.HUD.renderCompass()
end)

addCommandHandler("hud", function()
    Mzansi.HUD.toggle()
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
    outputDebugString("[Mzansi-HUD] HUD client loaded.")
end)
