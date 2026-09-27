-- custom_coronas server stub (events only; client holds export impl)
addEvent("custom_coronas:create", true)
addEvent("custom_coronas:destroy", true)

function createCorona(x, y, z, size, r, g, b, a, nostart)
    if not x or not y or not z then return false end
    local coronaId = tostring(math.random(100000, 999999)) .. "_" .. tostring(getTickCount())
    triggerClientEvent(root, "custom_coronas:create", resourceRoot, coronaId, x, y, z, size or 1, r or 1, g or 1, b or 1, a or 1)
    return coronaId
end

function destroyCorona(coronaId)
    if not coronaId then return false end
    triggerClientEvent(root, "custom_coronas:destroy", resourceRoot, coronaId)
    return true
end

addEventHandler("onResourceStart", resourceRoot, function()
    outputDebugString("[custom_coronas] Stub loaded", 3)
end)
