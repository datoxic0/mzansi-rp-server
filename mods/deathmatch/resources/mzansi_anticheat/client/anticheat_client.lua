Mzansi = Mzansi or {}
Mzansi.AntiCheat = Mzansi.AntiCheat or {}

addEvent("mzansi:anticheat:warning", true)

addEventHandler("mzansi:anticheat:warning", root, function(type, count)
    outputChatBox("[ANTI-CHEAT] Warning: " .. type .. " (Warning " .. count .. "/3)", 255, 50, 50)
    outputChatBox("[ANTI-CHEAT] Further violations will result in a ban.", 255, 100, 50)
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
    outputDebugString("[Mzansi-AntiCheat] Anti-cheat client loaded.")
end)
