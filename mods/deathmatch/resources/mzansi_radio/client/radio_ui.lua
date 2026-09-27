-- ============================================================
-- MZANSI RADIO: CLIENT UI CONTROLLER
-- Opens/closes CEF radio interface, keybinds, HUD hints
-- ============================================================

Mzansi = Mzansi or {}
Mzansi.Radio = Mzansi.Radio or {}
Mzansi.Radio.UI = Mzansi.Radio.UI or {}

local radioBrowser = nil
local radioWindow = nil
local uiOpen = false

function Mzansi.Radio.UI.isOpen()
    return uiOpen
end

function Mzansi.Radio.UI.open()
    if uiOpen then return end
    -- Close others FIRST (they may call showCursor(false))
    triggerEvent("mzansi:phone:close", localPlayer)
    triggerEvent("mzansi:dashboard:close", localPlayer)
    triggerEvent("mzansi:freeroam:close", localPlayer)
    triggerEvent("mzansi:admin:close", localPlayer)
    triggerEvent("mzansi:flight:close", localPlayer)
    triggerEvent("mzansi:market:close", localPlayer)
    triggerEvent("mzansi:bank:close", localPlayer)
    triggerEvent("mzansi:shop:closeUI", localPlayer)

    if not Mzansi.Radio.Config.useHTMLUI then
        -- Fallback: cycle stations with chat
        Mzansi.Radio.UI.quickCycle()
        return
    end

    local w, h = 720, 520
    local sw, sh = guiGetScreenSize()
    radioWindow = guiCreateWindow((sw - w) / 2, (sh - h) / 2, w, h, "Mzansi Radio - South Africa On Air", false)
    guiWindowSetSizable(radioWindow, false)
    guiSetAlpha(radioWindow, 0.95)

    radioBrowser = guiCreateBrowser(0, 25, w, h - 25, true, false, false, radioWindow)
    local browser = guiGetBrowser(radioBrowser)

    addEventHandler("onClientBrowserCreated", browser, function()
        loadBrowserURL(browser, "http://mta/local/ui/radio.html")
        -- Push initial data
        triggerServerEvent("mzansi:radio:requestStations", resourceRoot, "all", "")
    end)

    addEventHandler("onClientBrowserNavigate", browser, function(url)
        -- no-op
    end)

    uiOpen = true
    showCursor(true)
end

function Mzansi.Radio.UI.close()
    if not uiOpen then return end
    if radioWindow and isElement(radioWindow) then
        destroyElement(radioWindow)
    end
    radioWindow = nil
    radioBrowser = nil
    uiOpen = false
    showCursor(false)
end

function Mzansi.Radio.UI.toggle()
    if uiOpen then
        Mzansi.Radio.UI.close()
    else
        Mzansi.Radio.UI.open()
    end
end

-- Export wrappers
function openRadioUI()
    Mzansi.Radio.UI.open()
end

function closeRadioUI()
    Mzansi.Radio.UI.close()
end

-- Mutual exclusion close event (called by dashboard/phone/freeroam open)
addEvent("mzansi:radio:close", false)
addEventHandler("mzansi:radio:close", localPlayer, function()
    Mzansi.Radio.UI.close()
end)

-- Receive station list from server -> forward to CEF
addEvent("mzansi:radio:receiveStations", true)
addEventHandler("mzansi:radio:receiveStations", resourceRoot, function(list)
    if uiOpen and radioBrowser and isElement(radioBrowser) then
        local browser = guiGetBrowser(radioBrowser)
        if browser then
            local json = toJSON(list, true)
            executeBrowserJavaScript(browser, "window.__setStations && window.__setStations(" .. json .. ");")
        end
    end
end)

-- CEF -> MTA bridges (CEF must call mta.triggerEvent; Lua globals are NOT visible to CEF)
addEvent("mzansi:radio:uiReady", false)
addEventHandler("mzansi:radio:uiReady", resourceRoot, function()
    triggerServerEvent("mzansi:radio:requestStations", resourceRoot, "all", "")
end)

addEvent("mzansi:radio:uiTune", false)
addEventHandler("mzansi:radio:uiTune", resourceRoot, function(stationId)
    local vol = (Mzansi.Radio.Client and Mzansi.Radio.Client.getVolume and Mzansi.Radio.Client.getVolume()) or 0.7
    triggerServerEvent("mzansi:radio:tune", resourceRoot, stationId, { volume = vol })
end)

addEvent("mzansi:radio:uiPlayCustom", false)
addEventHandler("mzansi:radio:uiPlayCustom", resourceRoot, function(streamUrl, streamTitle)
    if not streamUrl or streamUrl == "" then return end
    local vol = (Mzansi.Radio.Client and Mzansi.Radio.Client.getVolume and Mzansi.Radio.Client.getVolume()) or 0.7
    local customStation = {
        id = "web_custom",
        name = streamTitle or "Internet Web Stream",
        streamUrl = streamUrl,
        category = "internet",
        frequency = "WEB",
        genre = "Live Stream"
    }
    if Mzansi.Radio.Client and Mzansi.Radio.Client.playStation then
        Mzansi.Radio.Client.playStation(customStation, vol)
    end
    outputChatBox("#00FF66[RADIO] #FFFFFFStreaming: #FFD700" .. tostring(customStation.name), 255, 255, 255, true)
end)

addEvent("mzansi:radio:uiStop", false)
addEventHandler("mzansi:radio:uiStop", resourceRoot, function()
    triggerServerEvent("mzansi:radio:stop", resourceRoot)
    if Mzansi.Radio.Client and Mzansi.Radio.Client.stopPersonal then
        Mzansi.Radio.Client.stopPersonal()
    end
end)

addEvent("mzansi:radio:uiVolume", false)
addEventHandler("mzansi:radio:uiVolume", resourceRoot, function(vol)
    triggerServerEvent("mzansi:radio:setVolume", resourceRoot, tonumber(vol) or 0.7)
end)

addEvent("mzansi:radio:uiSearch", false)
addEventHandler("mzansi:radio:uiSearch", resourceRoot, function(query, category)
    triggerServerEvent("mzansi:radio:requestStations", resourceRoot, category or "all", query or "")
end)

addEvent("mzansi:radio:uiClose", false)
addEventHandler("mzansi:radio:uiClose", resourceRoot, function()
    Mzansi.Radio.UI.close()
end)

-- Keybind: F6 opens radio (lowercase required by MTA bindKey)
bindKey("f6", "down", function()
    if Mzansi.Util and Mzansi.Util.bindBlocked and Mzansi.Util.bindBlocked() then return end
    Mzansi.Radio.UI.toggle()
end)

addCommandHandler("radio", function()
    Mzansi.Radio.UI.toggle()
end)

-- Quick cycle for non-HTML fallback / fast switching
local quickIndex = 0
function Mzansi.Radio.UI.quickCycle()
    local stations = Mzansi.Radio.Stations
    quickIndex = (quickIndex % #stations) + 1
    local s = stations[quickIndex]
    local vol = (Mzansi.Radio.Client and Mzansi.Radio.Client.getVolume and Mzansi.Radio.Client.getVolume()) or 0.7
    triggerServerEvent("mzansi:radio:tune", resourceRoot, s.id, { volume = vol })
end

bindKey("mouse3", "down", function() -- middle mouse = quick cycle
    if not uiOpen then
        Mzansi.Radio.UI.quickCycle()
    end
end)

-- HUD hint on vehicle enter
addEventHandler("onClientPlayerVehicleEnter", localPlayer, function(veh, seat)
    if seat == 0 then
        outputChatBox("#0096FF[RADIO] #FFFFFFPress #0096FFF6#FFFFFF for radio UI. Middle-click to quick-cycle.", 255, 255, 255, true)
    end
end)