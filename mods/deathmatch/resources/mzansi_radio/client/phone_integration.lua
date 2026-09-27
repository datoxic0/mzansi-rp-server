-- ============================================================
-- MZANSI RADIO: PHONE INTEGRATION
-- Registers Radio SA as a phone app in mzansi_phone
-- ============================================================

Mzansi = Mzansi or {}
Mzansi.Radio = Mzansi.Radio or {}

addEventHandler("onClientResourceStart", resourceRoot, function()
    -- Wait for mzansi_phone to load its app registry
    setTimer(function()
        if Mzansi.Phone and Mzansi.Phone.Apps then
            if type(Mzansi.Phone.Apps.register) == "function" then
                Mzansi.Phone.Apps.register({
                    id = "radio_sa",
                    name = (Mzansi.Radio.Config and Mzansi.Radio.Config.phoneAppName) or "Radio SA",
                    icon = "📻",
                    color = { 0, 150, 255 },
                    category = "Media",
                    description = "Real South African radio stations + CIT Radio",
                    onOpen = function()
                        Mzansi.Radio.UI.open()
                    end,
                })
            end
        end
    end, 3000, 1)
end)

-- Also expose open via phone event if phone uses events
addEvent("mzansi:phone:openApp", true)
addEventHandler("mzansi:phone:openApp", root, function(appId)
    if appId == "radio_sa" then
        Mzansi.Radio.UI.open()
    end
end)