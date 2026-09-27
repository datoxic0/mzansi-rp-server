Mzansi = Mzansi or {}
Mzansi.AntiCheat = {}
Mzansi.AntiCheat._warnings = {}
Mzansi.AntiCheat._lastPosition = {}
Mzansi.AntiCheat._spawnGrace = {}

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

addEvent("mzansi:anticheat:report", true)

-- Sovereign admins are exempt from all anti-cheat checks
local SOVEREIGN_SERIALS = { ["5626CC6016B4B1E245C55BAF40161FF4"] = true }
local function isSovereignAdmin(player)
    local serial = getPlayerSerial(player)
    if SOVEREIGN_SERIALS[serial] then return true end
    local name = getPlayerName(player)
    if name == "BambyZA" then return true end
    local adminLevel = getElementData(player, "mzansi:adminLevel") or 0
    return adminLevel >= 4
end

function Mzansi.AntiCheat.checkSpeed(player)
    if isSovereignAdmin(player) then return end
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then return end

    local speed = getElementSpeed(vehicle, "kmh")
    -- Threshold 260 km/h — Infernus (GTA SA's fastest car) tops at ~240 km/h legitimately
    if speed > 260 then
        Mzansi.AntiCheat.flag(player, "Speed Hack", "Speed: " .. math.floor(speed) .. " km/h")
    end
end

function Mzansi.AntiCheat.checkPosition(player)
    if isSovereignAdmin(player) then return end
    if Mzansi.AntiCheat._spawnGrace[player] then return end
    local x, y, z = getElementPosition(player)
    local last = Mzansi.AntiCheat._lastPosition[player]

    if last then
        local dist = 0
        if Mzansi.Util and Mzansi.Util.distance then
            dist = Mzansi.Util.distance(x, y, z, last.x, last.y, last.z)
        else
            dist = math.sqrt((x-last.x)^2 + (y-last.y)^2 + (z-last.z)^2)
        end
        if dist > 50 and not getPedOccupiedVehicle(player) then
            Mzansi.AntiCheat.flag(player, "Teleport Hack", "Distance: " .. math.floor(dist))
        end
    end

    Mzansi.AntiCheat._lastPosition[player] = { x = x, y = y, z = z }
end

function Mzansi.AntiCheat.checkHealth(player)
    if isSovereignAdmin(player) then return end
    if Mzansi.AntiCheat._spawnGrace[player] then return end
    local health = getElementHealth(player)
    local last = Mzansi.AntiCheat._lastHealth and Mzansi.AntiCheat._lastHealth[player]

    if last and health > last + 10 then
        Mzansi.AntiCheat.flag(player, "Health Hack", "Health: " .. math.floor(health))
    end

    Mzansi.AntiCheat._lastHealth = Mzansi.AntiCheat._lastHealth or {}
    Mzansi.AntiCheat._lastHealth[player] = health
end

function Mzansi.AntiCheat.flag(player, type, details)
    local name = getPlayerName(player)
    local ip = getPlayerIP(player)

    if not Mzansi.AntiCheat._warnings[player] then
        Mzansi.AntiCheat._warnings[player] = 0
    end

    Mzansi.AntiCheat._warnings[player] = Mzansi.AntiCheat._warnings[player] + 1

    if Mzansi.Database and Mzansi.Database.logAction then
        Mzansi.Database.logAction("ANTICHEAT", 0, name, type, details .. " (Warning #" .. Mzansi.AntiCheat._warnings[player] .. ")", ip)
    end

    outputDebugString("[ANTI-CHEAT] " .. name .. " flagged for: " .. type .. " - " .. details, 2)

    if Mzansi.AntiCheat._warnings[player] >= 3 then
        -- Try ban first; fall back to kick if ACL doesn't allow banPlayer
        local banOk = banPlayer(player, false, 0, 1, "Anti-Cheat: " .. type)
        if not banOk then
            kickPlayer(player, "Anti-Cheat: " .. type .. " (" .. details .. ")")
        end
    else
        triggerClientEvent(player, "mzansi:anticheat:warning", player, type, Mzansi.AntiCheat._warnings[player])
    end
end

addEventHandler("mzansi:anticheat:report", root, function(type, details)
    local source = client or source
    Mzansi.AntiCheat.flag(source, type, details)
end)

addEventHandler("onPlayerJoin", root, function()
    Mzansi.AntiCheat._warnings[source] = 0
    Mzansi.AntiCheat._lastPosition[source] = nil
    Mzansi.AntiCheat._spawnGrace[source] = true
    setTimer(function()
        if isElement(source) then
            Mzansi.AntiCheat._spawnGrace[source] = nil
            local x, y, z = getElementPosition(source)
            Mzansi.AntiCheat._lastPosition[source] = { x = x, y = y, z = z }
            Mzansi.AntiCheat._lastHealth = Mzansi.AntiCheat._lastHealth or {}
            Mzansi.AntiCheat._lastHealth[source] = getElementHealth(source)
        end
    end, 10000, 1)
end)

addEventHandler("onPlayerQuit", root, function()
    Mzansi.AntiCheat._warnings[source] = nil
    Mzansi.AntiCheat._lastPosition[source] = nil
    if Mzansi.AntiCheat._lastHealth then
        Mzansi.AntiCheat._lastHealth[source] = nil
    end
end)

addEventHandler("onResourceStart", resourceRoot, function()
    setTimer(function()
        if not Mzansi.Util then return end
        for _, player in ipairs(getElementsByType("player")) do
            Mzansi.AntiCheat.checkSpeed(player)
            Mzansi.AntiCheat.checkPosition(player)
            Mzansi.AntiCheat.checkHealth(player)
        end
    end, 1000, 0)
    outputDebugString("[Mzansi-AntiCheat] Anti-cheat system loaded.")
end)
