Mzansi = Mzansi or {}
Mzansi.UIBridge = Mzansi.UIBridge or {}

function Mzansi.UIBridge.openBank()
    triggerServerEvent("mzansi:bank:request", localPlayer)
end

function Mzansi.UIBridge.openMdt()
    triggerServerEvent("mzansi:mdt:search", localPlayer, "")
end

function Mzansi.UIBridge.createCharacter(data)
    triggerServerEvent("mzansi:createCharacter", localPlayer, data)
end

addEvent("mzansi:bank:response", true)
addEventHandler("mzansi:bank:response", localPlayer, function(data)
    outputDebugString("[Mzansi-ZA] Bank response received: " .. tostring(data.balance), 3)
end)

addEvent("mzansi:mdt:response", true)
addEventHandler("mzansi:mdt:response", localPlayer, function(data)
    outputDebugString("[Mzansi-ZA] MDT response received: " .. tostring(#data), 3)
end)

addEvent("mzansi:registrationResult", true)
addEventHandler("mzansi:registrationResult", localPlayer, function(data)
    outputDebugString("[Mzansi-ZA] Registration response: " .. tostring(data.success), 3)
    if data and data.result then
        outputChatBox("[Mzansi-ZA] " .. tostring(data.result), 255, 215, 0)
    end
end)

addEventHandler("onClientBrowserDocumentReady", root, function(browser)
    if browser then
        triggerEvent("mzansi:uiBrowserReady", localPlayer, browser)
    end
end)
