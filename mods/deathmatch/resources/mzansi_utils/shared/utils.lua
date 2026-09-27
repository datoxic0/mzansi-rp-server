Mzansi = Mzansi or {}
Mzansi.Utils = {}

function formatCurrency(amount)
    return "R " .. tostring(math.floor(amount or 0)):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end
Mzansi.Utils.formatCurrency = formatCurrency
Mzansi.Utils.formatMoney = formatCurrency

function getTimestamp()
    return getRealTime().timestamp
end
Mzansi.Utils.getTimestamp = getTimestamp

function getFormattedDate()
    return os.date("%Y-%m-%d %H:%M:%S")
end
Mzansi.Utils.date = getFormattedDate

function tableLength(tbl)
    local count = 0
    for _ in pairs(tbl or {}) do
        count = count + 1
    end
    return count
end
Mzansi.Utils.tableLength = tableLength

function randomString(length)
    length = length or 8
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    local result = {}
    for i = 1, length do
        local r = math.random(1, #chars)
        result[i] = chars:sub(r, r)
    end
    return table.concat(result)
end
Mzansi.Utils.randomString = randomString

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
Mzansi.Utils.getElementSpeed = getElementSpeed

function getDistanceBetween(x1, y1, z1, x2, y2, z2)
    if isElement(x1) and isElement(y1) then
        local px1, py1, pz1 = getElementPosition(x1)
        local px2, py2, pz2 = getElementPosition(y1)
        return getDistanceBetweenPoints3D(px1, py1, pz1, px2, py2, pz2)
    elseif isElement(x1) and type(y1) == "number" and type(z1) == "number" and type(x2) == "number" then
        local px1, py1, pz1 = getElementPosition(x1)
        return getDistanceBetweenPoints3D(px1, py1, pz1, y1, z1, x2)
    elseif type(x1) == "number" and type(y1) == "number" and type(z1) == "number" and type(x2) == "number" and type(y2) == "number" and type(z2) == "number" then
        return getDistanceBetweenPoints3D(x1, y1, z1, x2, y2, z2)
    end
    return 999999
end
Mzansi.Utils.distance = getDistanceBetween

function round(value, decimals)
    decimals = decimals or 0
    local power = 10 ^ decimals
    return math.floor(value * power + 0.5) / power
end
Mzansi.Utils.round = round

function clamp(value, min, max)
    return math.max(min, math.min(max, value))
end
Mzansi.Utils.clamp = clamp
