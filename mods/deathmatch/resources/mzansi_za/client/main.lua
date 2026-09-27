Mzansi = Mzansi or {}
Mzansi.Client = Mzansi.Client or {}

local uiVisible = false
local currentUI = nil

addEvent("mzansi:loginReady", true)
addEvent("mzansi:characterReceived", true)
addEvent("mzansi:characterSaved", true)
addEvent("mzansi:openUI", true)
addEvent("mzansi:openRegister", true)

addEventHandler("mzansi:openUI", root, function(uiType)
    currentUI = uiType
    uiVisible = true
    showCursor(true)
    if uiType == "bank" then
        triggerEvent("mzansi:showBankUI", localPlayer)
    elseif uiType == "mdt" then
        triggerEvent("mzansi:showMdtUI", localPlayer)
    elseif uiType == "property" then
        triggerEvent("mzansi:showPropertyUI", localPlayer)
    end
end)

addEventHandler("mzansi:openRegister", root, function()
    uiVisible = true
    showCursor(true)
    triggerEvent("mzansi:showRegisterUI", localPlayer)
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
    outputDebugString("[Mzansi-ZA] Client loaded.", 3)
end)
