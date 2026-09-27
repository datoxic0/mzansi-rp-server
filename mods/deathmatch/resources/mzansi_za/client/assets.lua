Mzansi = Mzansi or {}
Mzansi.Assets = Mzansi.Assets or {}

local assetList = {
    "south_african_vehicles",
    "south_african_buildings",
    "city_lights",
}

function Mzansi.Assets.load()
    for _, asset in ipairs(assetList) do
        outputDebugString("[Mzansi-ZA] Loading asset: " .. asset, 3)
    end
end

addEventHandler("onClientResourceStart", resourceRoot, function()
    Mzansi.Assets.load()
end)
