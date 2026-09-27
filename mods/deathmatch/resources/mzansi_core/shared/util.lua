Mzansi = Mzansi or {}
Mzansi.Util = {}

function Mzansi.Util.round(value, decimals)
    decimals = decimals or 0
    local power = 10 ^ decimals
    return math.floor(value * power + 0.5) / power
end

function Mzansi.Util.clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

function Mzansi.Util.lerp(a, b, t)
    return a + (b - a) * t
end

function getElementSpeed(element, unit)
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
_G.getElementSpeed = getElementSpeed
Mzansi.Util.getElementSpeed = getElementSpeed

function Mzansi.Util.distance(x1, y1, z1, x2, y2, z2)
    -- Handle element arguments
    if isElement(x1) and isElement(y1) then
        local px1, py1, pz1 = getElementPosition(x1)
        local px2, py2, pz2 = getElementPosition(y1)
        return getDistanceBetweenPoints3D(px1, py1, pz1, px2, py2, pz2)
    elseif isElement(x1) and type(y1) == "number" and type(z1) == "number" and type(x2) == "number" then
        local px1, py1, pz1 = getElementPosition(x1)
        return getDistanceBetweenPoints3D(px1, py1, pz1, y1, z1, x2)
    elseif type(x1) == "number" and type(y1) == "number" and type(z1) == "number" and type(x2) == "number" and type(y2) == "number" and type(z2) == "number" then
        return getDistanceBetweenPoints3D(x1, y1, z1, x2, y2, z2)
    elseif type(x1) == "number" and type(y1) == "number" and type(z1) == "number" and type(x2) == "number" and not y2 then
        -- Truncated 4-arg fallback
        local dx = z1 - x1
        local dy = x2 - y1
        return math.sqrt(dx * dx + dy * dy)
    end
    return 999999
end

function Mzansi.Util.distance2D(x1, y1, x2, y2)
    if isElement(x1) and isElement(y1) then
        local px1, py1 = getElementPosition(x1)
        local px2, py2 = getElementPosition(y1)
        return getDistanceBetweenPoints2D(px1, py1, px2, py2)
    elseif isElement(x1) and type(y1) == "number" and type(z1) == "number" then
        local px1, py1 = getElementPosition(x1)
        return getDistanceBetweenPoints2D(px1, py1, y1, z1)
    elseif type(x1) == "number" and type(y1) == "number" and type(x2) == "number" and type(y2) == "number" then
        return getDistanceBetweenPoints2D(x1, y1, x2, y2)
    end
    return 999999
end

function Mzansi.Util.tableCount(tbl)
    local count = 0
    for _ in pairs(tbl or {}) do
        count = count + 1
    end
    return count
end

function Mzansi.Util.tableMerge(base, override)
    local result = {}
    for k, v in pairs(base or {}) do
        result[k] = v
    end
    for k, v in pairs(override or {}) do
        result[k] = v
    end
    return result
end

function Mzansi.Util.tableShallowCopy(tbl)
    local result = {}
    for k, v in pairs(tbl or {}) do
        result[k] = v
    end
    return result
end

function Mzansi.Util.tableKeys(tbl)
    local keys = {}
    for k in pairs(tbl or {}) do
        keys[#keys + 1] = k
    end
    return keys
end

function Mzansi.Util.tableContains(tbl, value)
    for _, v in pairs(tbl or {}) do
        if v == value then
            return true
        end
    end
    return false
end

function Mzansi.Util.tableFilter(tbl, predicate)
    local result = {}
    for k, v in pairs(tbl or {}) do
        if predicate(v, k) then
            result[#result + 1] = v
        end
    end
    return result
end

function Mzansi.Util.tableMap(tbl, transform)
    local result = {}
    for k, v in pairs(tbl or {}) do
        result[k] = transform(v, k)
    end
    return result
end

function Mzansi.Util.safeName(str)
    return tostring(str or ""):gsub("[^%w_]", "_"):sub(1, 32)
end

function Mzansi.Util.trim(str)
    return tostring(str or ""):match("^%s*(.-)%s*$")
end

function Mzansi.Util.split(str, delimiter)
    delimiter = delimiter or ","
    local result = {}
    for match in (str .. delimiter):gmatch("(.-)" .. delimiter) do
        result[#result + 1] = Mzansi.Util.trim(match)
    end
    return result
end

function Mzansi.Util.startsWith(str, start)
    return str:sub(1, #start) == start
end

function Mzansi.Util.endsWith(str, finish)
    return finish == "" or str:sub(-#finish) == finish
end

function Mzansi.Util.formatMoney(amount)
    local formatted = tostring(math.floor(math.abs(amount)))
    local k
    while true do
        formatted, k = formatted:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
        if k == 0 then break end
    end
    return (amount < 0 and "-" or "") .. "R" .. formatted
end

function Mzansi.Util.formatNumber(amount)
    local formatted = tostring(math.floor(math.abs(amount)))
    local k
    while true do
        formatted, k = formatted:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
        if k == 0 then break end
    end
    return (amount < 0 and "-" or "") .. formatted
end

function Mzansi.Util.formatTime(seconds)
    seconds = math.floor(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    if hours > 0 then
        return string.format("%02d:%02d:%02d", hours, minutes, secs)
    else
        return string.format("%02d:%02d", minutes, secs)
    end
end

function Mzansi.Util.timeAgo(timestamp)
    local diff = getRealTime().timestamp - timestamp
    if diff < 60 then
        return "just now"
    elseif diff < 3600 then
        return math.floor(diff / 60) .. " minutes ago"
    elseif diff < 86400 then
        return math.floor(diff / 3600) .. " hours ago"
    else
        return math.floor(diff / 86400) .. " days ago"
    end
end

function Mzansi.Util.generateId(length)
    length = length or 8
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    local result = {}
    for i = 1, length do
        local r = math.random(1, #chars)
        result[i] = chars:sub(r, r)
    end
    return table.concat(result)
end

function Mzansi.Util.generatePlate()
    local letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local plate = ""
    for i = 1, 3 do
        local r = math.random(1, #letters)
        plate = plate .. letters:sub(r, r)
    end
    plate = plate .. " "
    for i = 1, 4 do
        plate = plate .. math.random(0, 9)
    end
    return plate
end

function Mzansi.Util.getPlayerIdentifier(source)
    if not isElement(source) then return "invalid" end
    if type(getPlayerAccount) == "function" and type(getAccountName) == "function" then
        local acc = getPlayerAccount(source)
        if acc then
            local account = getAccountName(acc)
            if account and account ~= "" and account ~= "guest" then
                return "account:" .. account
            end
        end
    end
    if type(getPlayerSerial) == "function" then
        local s = (type(triggerServerEvent) == "function") and getPlayerSerial() or getPlayerSerial(source)
        if s and s ~= "" then
            return "serial:" .. s
        end
    end
    return "player:" .. tostring(source)
end

function Mzansi.Util.getPlayerFromIdentifier(identifier)
    if not identifier then return nil end
    if Mzansi.Util.startsWith(identifier, "account:") then
        local accountName = identifier:sub(9)
        if type(getAccount) == "function" and type(getAccountPlayer) == "function" then
            local account = getAccount(accountName)
            if account then
                return getAccountPlayer(account)
            end
        end
    elseif Mzansi.Util.startsWith(identifier, "serial:") then
        local serial = identifier:sub(8)
        if type(getPlayerSerial) == "function" and type(triggerClientEvent) == "function" then
            for _, player in ipairs(getElementsByType("player")) do
                if getPlayerSerial(player) == serial then
                    return player
                end
            end
        end
    end
    return nil
end

function Mzansi.Util.getPlayerName(player)
    local character = getElementData(player, "mzansi:character")
    if character then
        return (character.firstName or "Unknown") .. " " .. (character.lastName or "")
    end
    return getPlayerName(player) or "Unknown"
end

function Mzansi.Util.getPlayerFullName(player)
    local char = getElementData(player, "mzansi:character")
    if char then
        return (char.firstName or "Unknown") .. " " .. (char.lastName or "Unknown")
    end
    return "Unknown"
end

function Mzansi.Util.sendNotification(source, message, notifType)
    if not isElement(source) then return end
    notifType = notifType or "info"
    if type(triggerClientEvent) == "function" then
        triggerClientEvent(source, "mzansi:notification", source, message, notifType)
    elseif type(triggerEvent) == "function" then
        triggerEvent("mzansi:notification", source, message, notifType)
    end
end

function sendNotification(target, message, notifType)
    return Mzansi.Util.sendNotification(target, message, notifType)
end

function Mzansi.Util.sendNotificationToAll(message, notifType)
    notifType = notifType or "info"
    if type(triggerClientEvent) == "function" then
        triggerClientEvent(root, "mzansi:notification", root, message, notifType)
    elseif type(triggerEvent) == "function" then
        triggerEvent("mzansi:notification", root, message, notifType)
    end
end

function Mzansi.Util.getZoneName(x, y)
    for _, zone in ipairs(Mzansi.Config.Zones) do
        if x >= zone.minX and x <= zone.maxX and y >= zone.minY and y <= zone.maxY then
            return zone.name
        end
    end
    return "Unknown"
end

function Mzansi.Util.isValidEmail(email)
    return email:match("^[A-Za-z0-9._%+%-]+@[A-Za-z0-9.-]+%.[A-Za-z]+$") ~= nil
end

function Mzansi.Util.sanitizeInput(input)
    if type(input) ~= "string" then
        return tostring(input or "")
    end
    return input:gsub("[<>\"']", ""):sub(1, 256)
end

function Mzansi.Util.weightedRandom(items, weights)
    local total = 0
    for _, w in ipairs(weights) do
        total = total + w
    end
    local r = math.random() * total
    local cumulative = 0
    for i, w in ipairs(weights) do
        cumulative = cumulative + w
        if r <= cumulative then
            return items[i]
        end
    end
    return items[#items]
end

function Mzansi.Util.deepCopy(orig)
    local copy
    if type(orig) == "table" then
        copy = {}
        for k, v in pairs(orig) do
            copy[Mzansi.Util.deepCopy(k)] = Mzansi.Util.deepCopy(v)
        end
        setmetatable(copy, Mzansi.Util.deepCopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

function Mzansi.Util.serialize(tbl)
    return toJSON(tbl)
end

function Mzansi.Util.deserialize(str)
    return fromJSON(str)
end

-- Shared guard: true when gameplay keybinds must not fire
-- (login/typing/console/chat/GUI edit focused)
function Mzansi.Util.bindBlocked()
    if Mzansi.Login and Mzansi.Login._active then return true end
    if isChatBoxInputActive and isChatBoxInputActive() then return true end
    if isConsoleActive and isConsoleActive() then return true end
    if guiGetInputMode and guiGetInputMode() == "no_binds_when_editing" then
        if guiGetFocusedGUIElement and guiGetFocusedGUIElement() then return true end
    end
    return false
end

-- Global 3D circle drawing for interactive roleplay markers
if triggerServerEvent then
    function dxDrawCircle3D(x, y, z, radius, color, width, segments)
        segments = segments or 24
        width = width or 2
        local step = (math.pi * 2) / segments
        for i = 0, segments - 1 do
            local angle1 = i * step
            local angle2 = (i + 1) * step
            local x1 = x + math.cos(angle1) * radius
            local y1 = y + math.sin(angle1) * radius
            local x2 = x + math.cos(angle2) * radius
            local y2 = y + math.sin(angle2) * radius
            dxDrawLine3D(x1, y1, z, x2, y2, z, color or tocolor(200, 170, 50, 180), width)
        end
    end
end
