Mzansi = Mzansi or {}
Mzansi.CEF = Mzansi.CEF or {}

local browser = nil

function Mzansi.CEF.show(uiType)
    if not browser then
        browser = createBrowser(1280, 720, true, true)
    end

    local url = "http://mta/local/ui/index.html?type=" .. tostring(uiType)
    loadBrowserURL(browser, url)
    showCursor(true)
end

addEvent("mzansi:showBankUI", true)
addEventHandler("mzansi:showBankUI", localPlayer, function()
    Mzansi.CEF.show("bank")
end)

addEvent("mzansi:showMdtUI", true)
addEventHandler("mzansi:showMdtUI", localPlayer, function()
    Mzansi.CEF.show("mdt")
end)

addEvent("mzansi:showRegisterUI", true)
addEventHandler("mzansi:showRegisterUI", localPlayer, function()
    Mzansi.CEF.show("register")
end)

addEvent("mzansi:showPropertyUI", true)
addEventHandler("mzansi:showPropertyUI", localPlayer, function()
    Mzansi.CEF.show("property")
end)
