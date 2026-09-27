Mzansi = Mzansi or {}
Mzansi.Streaming = Mzansi.Streaming or {}

Mzansi.Streaming.VehicleModels = {
    { id = 1, name = "Toyota Corolla Quest", model = 562, region = "Johannesburg" },
    { id = 2, name = "VW Polo Vivo", model = 496, region = "Cape Town" },
    { id = 3, name = "Ford Ranger XL", model = 577, region = "Pretoria" },
    { id = 4, name = "Toyota Hilux", model = 571, region = "Durban" },
}

Mzansi.Streaming.ObjectModels = {
    { id = 1, name = "Johannesburg CBD Tower", model = 1449, region = "Johannesburg" },
    { id = 2, name = "Cape Town Harbour Yard", model = 1437, region = "Cape Town" },
    { id = 3, name = "Pretoria Government Block", model = 1471, region = "Pretoria" },
}

function Mzansi.Streaming.loadVehicleModel(modelId)
    if not modelId then
        return false
    end
    outputDebugString("[Mzansi-ZA] Streaming vehicle model: " .. tostring(modelId), 3)
    return true
end

function Mzansi.Streaming.loadObjectModel(modelId)
    if not modelId then
        return false
    end
    outputDebugString("[Mzansi-ZA] Streaming object model: " .. tostring(modelId), 3)
    return true
end

function Mzansi.Streaming.getVehicleModels(region)
    local result = {}
    for _, model in ipairs(Mzansi.Streaming.VehicleModels) do
        if not region or model.region == region then
            table.insert(result, model)
        end
    end
    return result
end

function Mzansi.Streaming.getObjectModels(region)
    local result = {}
    for _, model in ipairs(Mzansi.Streaming.ObjectModels) do
        if not region or model.region == region then
            table.insert(result, model)
        end
    end
    return result
end

addEvent("mzansi:stream:vehicles", true)
addEventHandler("mzansi:stream:vehicles", root, function(region)
    triggerClientEvent(client, "mzansi:stream:vehicles:response", client, Mzansi.Streaming.getVehicleModels(region))
end)

addEvent("mzansi:stream:objects", true)
addEventHandler("mzansi:stream:objects", root, function(region)
    triggerClientEvent(client, "mzansi:stream:objects:response", client, Mzansi.Streaming.getObjectModels(region))
end)
