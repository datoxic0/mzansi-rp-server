Mzansi = Mzansi or {}
Mzansi.Interaction = Mzansi.Interaction or {}

addEvent("mzansi:stream:vehicles:response", true)
addEventHandler("mzansi:stream:vehicles:response", localPlayer, function(data)
    outputDebugString("[Mzansi-ZA] Vehicle streaming response: " .. tostring(#data), 3)
end)

addEvent("mzansi:stream:objects:response", true)
addEventHandler("mzansi:stream:objects:response", localPlayer, function(data)
    outputDebugString("[Mzansi-ZA] Object streaming response: " .. tostring(#data), 3)
end)

addEvent("mzansi:properties:response", true)
addEventHandler("mzansi:properties:response", localPlayer, function(data)
    outputDebugString("[Mzansi-ZA] Property response: " .. tostring(#data), 3)
end)

function Mzansi.Interaction.requestStreaming(region)
    triggerServerEvent("mzansi:stream:vehicles", localPlayer, region)
    triggerServerEvent("mzansi:stream:objects", localPlayer, region)
end

function Mzansi.Interaction.requestProperties(region)
    triggerServerEvent("mzansi:properties:list", localPlayer, region)
end
