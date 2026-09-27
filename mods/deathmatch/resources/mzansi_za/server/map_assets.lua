Mzansi = Mzansi or {}
Mzansi.MapAssets = Mzansi.MapAssets or {}

Mzansi.MapAssets.Registry = {
    {
        id = 1,
        name = "Johannesburg CBD Tower",
        type = "building",
        region = "Johannesburg",
        location = { x = 1500, y = -1600, z = 14 },
    },
    {
        id = 2,
        name = "Cape Town Harbour Pier",
        type = "dock",
        region = "Cape Town",
        location = { x = 2100, y = -2600, z = 8 },
    },
    {
        id = 3,
        name = "Pretoria Government Offices",
        type = "government",
        region = "Pretoria",
        location = { x = 1700, y = -1450, z = 12 },
    },
    {
        id = 4,
        name = "Durban Auto Garage",
        type = "garage",
        region = "Durban",
        location = { x = 1400, y = -1700, z = 12 },
    },
}

function Mzansi.MapAssets.getAll()
    return Mzansi.MapAssets.Registry
end

function Mzansi.MapAssets.getByRegion(region)
    local result = {}
    for _, asset in ipairs(Mzansi.MapAssets.Registry) do
        if not region or asset.region == region then
            table.insert(result, asset)
        end
    end
    return result
end

addEvent("mzansi:mapassets:list", true)
addEventHandler("mzansi:mapassets:list", root, function(region)
    triggerClientEvent(client, "mzansi:mapassets:response", client, Mzansi.MapAssets.getByRegion(region))
end)
