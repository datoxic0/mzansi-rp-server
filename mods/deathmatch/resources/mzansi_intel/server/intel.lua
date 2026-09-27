-- ============================================================
-- MZANSI INTEL: SERVER
-- Access control + contact snapshots
-- ============================================================

Mzansi = Mzansi or {}
Mzansi.Intel = Mzansi.Intel or {}

local function hasIntelAccess(player)
    if not isElement(player) then return false end
    if getPlayerName(player) == "BambyZA" then return true end
    -- creator/admin via mzansi_core account element data (set at accounts.lua on login)
    local lvl = getElementData(player, "mzansi:adminLevel") or 0
    return tonumber(lvl) >= Mzansi.Intel.Config.minAdminLevel
end

addEvent("mzansi:intel:requestAccess", true)
addEventHandler("mzansi:intel:requestAccess", root, function()
    local src = client or source
    if not isElement(src) then return end
    local ok = hasIntelAccess(src)
    triggerClientEvent(src, "mzansi:intel:accessResult", resourceRoot, ok)
    if not ok then
        outputChatBox("#FF4444[INTEL] #FFFFFFAccess denied. Admin or Creator only.", src, 255, 255, 255, true)
    end
end)

addCommandHandler("eye", function(player)
    if not isElement(player) then return end
    if not hasIntelAccess(player) then
        outputChatBox("#FF4444[INTEL] #FFFFFFAccess denied. Admin or Creator only.", player, 255, 255, 255, true)
        return
    end
    triggerClientEvent(player, "mzansi:intel:toggle", resourceRoot)
end)

addEventHandler("onResourceStart", resourceRoot, function()
    outputServerLog("[mzansi_intel] God's Eye View situational layer online. Command: /eye")
end)