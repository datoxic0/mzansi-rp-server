-- custom_coronas client: direct export + event fallback
local coronas = {}

function createCorona(x, y, z, size, r, g, b, a, nostart)
    if not x or not y or not z then return false end
    local id = tostring(math.random(100000, 999999)) .. "_" .. tostring(getTickCount())
    local light = createMarker(tonumber(x) or 0, tonumber(y) or 0, tonumber(z) or 0, "corona",
        tonumber(size) or 1.0, tonumber(r) or 1, tonumber(g) or 1, tonumber(b) or 1,
        (tonumber(a) or 1) * 0.6)
    if light then
        coronas[id] = light
        return id
    end
    return false
end

function destroyCorona(id)
    if id and coronas[id] and isElement(coronas[id]) then
        destroyElement(coronas[id])
        coronas[id] = nil
        return true
    end
    return false
end

addEvent("custom_coronas:create", true)
addEvent("custom_coronas:destroy", true)

addEventHandler("custom_coronas:create", root, function(id, x, y, z, size, r, g, b, a)
    createCorona(x, y, z, size, r, g, b, a)
end)

addEventHandler("custom_coronas:destroy", root, function(id)
    destroyCorona(id)
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    for _, el in pairs(coronas) do
        if isElement(el) then destroyElement(el) end
    end
    coronas = {}
end)
