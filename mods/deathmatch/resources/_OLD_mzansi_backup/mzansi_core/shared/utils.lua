-- Mzansi-ZA Shared Utilities
-- Common helper functions for both client and server

local Utils = {}

-- String utilities
function Utils.trim(str)
    return str:match("^%s*(.-)%s*$")
end

function Utils.split(str, delimiter)
    local result = {}
    local pattern = "([^" .. delimiter .. "]+)"
    for match in str:gmatch(pattern) do
        table.insert(result, match)
    end
    return result
end

function Utils.startsWith(str, prefix)
    return str:sub(1, #prefix) == prefix
end

function Utils.endsWith(str, suffix)
    return str:sub(-#suffix) == suffix
end

function Utils.capitalize(str)
    return str:sub(1, 1):upper() .. str:sub(2):lower()
end

function Utils.titleCase(str)
    local result = ""
    for word in str:gmatch("%S+") do
        result = result .. Utils.capitalize(word) .. " "
    end
    return Utils.trim(result)
end

-- Number utilities
function Utils.round(num, decimals)
    local mult = 10 ^ (decimals or 0)
    return math.floor(num * mult + 0.5) / mult
end

function Utils.clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

function Utils.lerp(a, b, t)
    return a + (b - a) * t
end

function Utils.formatNumber(num)
    local formatted = tostring(num)
    local k = 3
    while k < #formatted do
        formatted = formatted:sub(1, #formatted - k) .. "," .. formatted:sub(#formatted - k + 1)
        k = k + 4
    end
    return formatted
end

function Utils.formatCurrency(amount)
    return "R" .. Utils.formatNumber(Utils.round(amount, 2))
end

function Utils.parseCurrency(str)
    local num = str:gsub("[R,%s]", "")
    return tonumber(num) or 0
end

-- Table utilities
function Utils.tableLength(tbl)
    local count = 0
    for _ in pairs(tbl) do count = count + 1 end
    return count
end

function Utils.tableContains(tbl, value)
    for _, v in pairs(tbl) do
        if v == value then return true end
    end
    return false
end

function Utils.tableKeys(tbl)
    local keys = {}
    for k in pairs(tbl) do table.insert(keys, k) end
    return keys
end

function Utils.tableValues(tbl)
    local values = {}
    for _, v in pairs(tbl) do table.insert(values, v) end
    return values
end

function Utils.tableMerge(target, source)
    for k, v in pairs(source) do
        if type(v) == "table" and type(target[k]) == "table" then
            Utils.tableMerge(target[k], v)
        else
            target[k] = v
        end
    end
    return target
end

function Utils.tableCopy(tbl)
    local copy = {}
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            copy[k] = Utils.tableCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

function Utils.shuffleTable(tbl)
    local result = Utils.tableCopy(tbl)
    for i = #result, 2, -1 do
        local j = math.random(i)
        result[i], result[j] = result[j], result[i]
    end
    return result
end

-- Time utilities
function Utils.formatTime(ms)
    local seconds = math.floor(ms / 1000)
    local minutes = math.floor(seconds / 60)
    local hours = math.floor(minutes / 60)
    local days = math.floor(hours / 24)
    
    if days > 0 then
        return string.format("%dd %dh %dm", days, hours % 24, minutes % 60)
    elseif hours > 0 then
        return string.format("%dh %dm %ds", hours, minutes % 60, seconds % 60)
    elseif minutes > 0 then
        return string.format("%dm %ds", minutes, seconds % 60)
    else
        return string.format("%ds", seconds)
    end
end

function Utils.getTimeString()
    local time = getRealTime()
    return string.format("%02d:%02d:%02d", time.hour, time.minute, time.second)
end

function Utils.getDateString()
    local time = getRealTime()
    return string.format("%04d-%02d-%02d", time.year + 1900, time.month + 1, time.monthday)
end

function Utils.getDateTimeString()
    return Utils.getDateString() .. " " .. Utils.getTimeString()
end

function Utils.msToMidnight()
    local time = getRealTime()
    local msUntilMidnight = ((24 - time.hour - 1) * 3600 + (60 - time.minute - 1) * 60 + (60 - time.second)) * 1000
    return msUntilMidnight
end

-- Position utilities
function Utils.getDistance2D(x1, y1, x2, y2)
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

function Utils.getDistance3D(x1, y1, z1, x2, y2, z2)
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2 + (z2 - z1) ^ 2)
end

function Utils.getPositionFromElement(element)
    return { x = getElementPosition(element) }
end

function Utils.setPositionFromTable(element, pos)
    setElementPosition(element, pos.x, pos.y, pos.z)
    if pos.rot then setElementRotation(element, 0, 0, pos.rot) end
    if pos.interior then setElementInterior(element, pos.interior) end
    if pos.dimension then setElementDimension(element, pos.dimension) end
end

function Utils.isPositionInRange(x1, y1, z1, x2, y2, z2, range)
    return Utils.getDistance3D(x1, y1, z1, x2, y2, z2) <= range
end

-- Color utilities
function Utils.toColor(r, g, b, a)
    return tocolor(r or 255, g or 255, b or 255, a or 255)
end

function Utils.fromColor(color)
    local r, g, b, a = fromcolor(color)
    return { r = r, g = g, b = b, a = a }
end

function Utils.hexToColor(hex)
    hex = hex:gsub("#", "")
    local r = tonumber(hex:sub(1, 2), 16)
    local g = tonumber(hex:sub(3, 4), 16)
    local b = tonumber(hex:sub(5, 6), 16)
    local a = tonumber(hex:sub(7, 8), 16) or 255
    return Utils.toColor(r, g, b, a)
end

function Utils.colorToHex(r, g, b, a)
    return string.format("#%02X%02X%02X%02X", r, g, b, a or 255)
end

-- Validation utilities
function Utils.isValidEmail(email)
    return email:match("^[%w%._%+-]+@[%w%-]+%.%w+$") ~= nil
end

function Utils.isValidPhoneNumber(phone)
    -- South African format: 0XX XXX XXXX or +27 XX XXX XXXX
    return phone:match("^0%d{2}%s?%d{3}%s?%d{4}$") or phone:match("^%+27%d{2}%s?%d{3}%s?%d{4}$") ~= nil
end

function Utils.isValidSAIDNumber(id)
    -- South African ID number validation (Luhn algorithm)
    if #id ~= 13 then return false end
    local sum = 0
    for i = 1, 13 do
        local digit = tonumber(id:sub(i, i))
        if not digit then return false end
        if i % 2 == 0 then
            digit = digit * 2
            if digit > 9 then digit = digit - 9 end
        end
        sum = sum + digit
    end
    return sum % 10 == 0
end

function Utils.sanitizeInput(input, maxLength)
    if not input then return "" end
    input = Utils.trim(input)
    if maxLength and #input > maxLength then
        input = input:sub(1, maxLength)
    end
    -- Remove control characters
    input = input:gsub("[\0-\31\127]", "")
    return input
end

-- JSON utilities (wrapper for MTA's toJSON/fromJSON)
function Utils.toJSON(data, compact)
    return toJSON(data, compact == true)
end

function Utils.fromJSON(str)
    return fromJSON(str)
end

-- Math utilities
function Utils.vectorLength(x, y, z)
    return math.sqrt(x * x + y * y + (z or 0) * (z or 0))
end

function Utils.vectorNormalize(x, y, z)
    local len = Utils.vectorLength(x, y, z)
    if len == 0 then return 0, 0, 0 end
    return x / len, y / len, (z or 0) / len
end

function Utils.angleBetween(x1, y1, x2, y2)
    return math.atan2(y2 - y1, x2 - x1)
end

function Utils.rotatePoint(x, y, cx, cy, angle)
    local rad = math.rad(angle)
    local cos = math.cos(rad)
    local sin = math.sin(rad)
    local dx = x - cx
    local dy = y - cy
    return cx + dx * cos - dy * sin, cy + dx * sin + dy * cos
end

-- Permission utilities
function Utils.hasPermission(player, permission)
    return hasObjectPermissionTo(player, permission, false)
end

function Utils.getAdminLevel(player)
    local account = getPlayerAccount(player)
    if not account or isGuestAccount(account) then return 0 end
    local level = getAccountData(account, "admin_level") or 0
    return tonumber(level)
end

function Utils.isAdmin(player, level)
    return Utils.getAdminLevel(player) >= (level or 1)
end

-- Debug/logging utilities
function Utils.debugPrint(...)
    if _G.DEBUG_MODE then
        outputDebugString("[MZANSI DEBUG] " .. table.concat({...}, " "), 3)
    end
end

function Utils.logInfo(msg)
    outputDebugString("[MZANSI INFO] " .. msg, 0)
end

function Utils.logWarning(msg)
    outputDebugString("[MZANSI WARNING] " .. msg, 1)
end

function Utils.logError(msg)
    outputDebugString("[MZANSI ERROR] " .. msg, 2)
end

-- Element utilities
function Utils.getElementsByTypeInRange(elementType, x, y, z, range)
    local elements = getElementsByType(elementType)
    local result = {}
    for _, el in ipairs(elements) do
        if Utils.isPositionInRange(x, y, z, getElementPosition(el), range) then
            table.insert(result, el)
        end
    end
    return result
end

function Utils.getNearbyPlayers(x, y, z, range)
    return Utils.getElementsByTypeInRange("player", x, y, z, range)
end

function Utils.getNearbyVehicles(x, y, z, range)
    return Utils.getElementsByTypeInRange("vehicle", x, y, z, range)
end

-- Random utilities
function Utils.randomString(length, charset)
    charset = charset or "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    local result = ""
    for i = 1, length do
        local idx = math.random(1, #charset)
        result = result .. charset:sub(idx, idx)
    end
    return result
end

function Utils.randomPhoneNumber()
    -- SA format: 0XX XXX XXXX
    local prefixes = {"06", "07", "08", "071", "072", "073", "074", "076", "078", "079", "081", "082", "083", "084"}
    local prefix = prefixes[math.random(#prefixes)]
    local num = math.random(1000000, 9999999)
    return prefix .. " " .. string.format("%03d %04d", math.floor(num / 10000), num % 10000)
end

function Utils.generateIDNumber()
    -- Generate a valid SA ID number (not for real use, just format)
    local date = string.format("%02d%02d%02d", math.random(40, 99), math.random(1, 12), math.random(1, 28))
    local gender = math.random(0, 1) == 0 and "0" or "5"
    local sequence = string.format("%03d", math.random(0, 999))
    local citizenship = math.random(0, 1)
    local uniform = math.random(0, 9)
    
    local partial = date .. gender .. sequence .. citizenship .. uniform
    -- Calculate check digit (Luhn)
    local sum = 0
    for i = 1, #partial do
        local digit = tonumber(partial:sub(i, i))
        if i % 2 == 0 then
            digit = digit * 2
            if digit > 9 then digit = digit - 9 end
        end
        sum = sum + digit
    end
    local check = (10 - (sum % 10)) % 10
    return partial .. check
end

-- Export globally
_G.Utils = Utils

return Utils