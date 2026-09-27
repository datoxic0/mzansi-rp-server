Mzansi = Mzansi or {}
Mzansi.ContentLoader = Mzansi.ContentLoader or {}

addEvent("mzansi:vehicles:response", true)
addEventHandler("mzansi:vehicles:response", localPlayer, function(data)
    outputDebugString("[Mzansi-ZA] Vehicle pool loaded: " .. tostring(#data), 3)
end)

addEvent("mzansi:businesses:response", true)
addEventHandler("mzansi:businesses:response", localPlayer, function(data)
    outputDebugString("[Mzansi-ZA] Business pool loaded: " .. tostring(#data), 3)
end)

addEvent("mzansi:mapassets:response", true)
addEventHandler("mzansi:mapassets:response", localPlayer, function(data)
    outputDebugString("[Mzansi-ZA] Map asset pool loaded: " .. tostring(#data), 3)
end)

function Mzansi.ContentLoader.requestVehicles(region)
    triggerServerEvent("mzansi:vehicles:list", localPlayer, region)
end

function Mzansi.ContentLoader.requestBusinesses(region)
    triggerServerEvent("mzansi:businesses:list", localPlayer, region)
end

function Mzansi.ContentLoader.requestMapAssets(region)
    triggerServerEvent("mzansi:mapassets:list", localPlayer, region)
end
