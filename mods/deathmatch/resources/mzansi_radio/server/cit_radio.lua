-- ============================================================
-- MZANSI RADIO: CIT RADIO TRIBUTE MODULE
-- Dedicated CIT Radio handling + tribute messaging
-- ============================================================

Mzansi = Mzansi or {}
Mzansi.Radio = Mzansi.Radio or {}
Mzansi.Radio.CIT = Mzansi.Radio.CIT or {}

local CIT_STATION = Mzansi.Radio.CitRadio

function Mzansi.Radio.CIT.getStream()
    if not CIT_STATION then return nil end
    return CIT_STATION.streamUrl
end

function Mzansi.Radio.CIT.getTributeText()
    return Mzansi.Radio.Config.citRadioMessage
end

-- Broadcast the tribute to all players (admin command /joincit or automatic)
function Mzansi.Radio.CIT.broadcastTribute(target)
    local msg = Mzansi.Radio.Config.citRadioMessage
    local line = "#FFD700[CIT RADIO TRIBUTE] #FFFFFF" .. msg
    if target and isElement(target) then
        outputChatBox(line, target, 255, 255, 255, true)
    else
        outputChatBox(line, root, 255, 255, 255, true)
    end
end

-- Export for other resources
function getCitRadioStream()
    return Mzansi.Radio.CIT.getStream()
end

addCommandHandler("cittribute", function(player)
    if not isElement(player) then return end
    Mzansi.Radio.CIT.broadcastTribute(player)
end)

addCommandHandler("joincit", function(player)
    if not isElement(player) then return end
    if not Mzansi.Radio.Config.citRadioEnabled then
        outputChatBox("#FF4444[RADIO] #FFFFFFCIT Radio is currently disabled.", player, 255, 255, 255, true)
        return
    end
    -- Route through normal tune so vehicle broadcast + tribute fires
    playerRadioTune = playerRadioTune -- no-op; actual tune via event
    triggerClientEvent(player, "mzansi:radio:tuneCit", resourceRoot)
    outputChatBox("#FFD700[RADIO] #FFFFFFConnecting to #FFD700CIT Radio#FFFFFF...", player, 255, 255, 255, true)
end)

addEventHandler("onResourceStart", resourceRoot, function()
    if Mzansi.Radio.Config.citRadioEnabled and CIT_STATION then
        outputServerLog("[mzansi_radio] CIT Radio stream: " .. tostring(CIT_STATION.streamUrl))
        -- Announce tribute once on startup
        setTimer(function()
            Mzansi.Radio.CIT.broadcastTribute(nil)
        end, 5000, 1)
    end
end)