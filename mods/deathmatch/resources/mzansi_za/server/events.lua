Mzansi = Mzansi or {}
Mzansi.Events = Mzansi.Events or {}

addEventHandler("onPlayerLogin", root, function(_, account)
    outputDebugString("[Mzansi-ZA] Player logged in: " .. getPlayerName(source), 3)
    triggerClientEvent(source, "mzansi:loginReady", source)
end)

addEventHandler("onPlayerQuit", root, function(reason)
    outputDebugString("[Mzansi-ZA] Player disconnected: " .. getPlayerName(source) .. " - " .. tostring(reason), 3)
end)

addEventHandler("onResourceStart", resourceRoot, function()
    Mzansi.ACL.register()
    Mzansi.Spawn.init()
end)
