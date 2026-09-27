-- ============================================================
-- MZANSI RADIO: CLIENT CORE
-- Custom playback engine - NO conflict with GTA SA vehicle radio.
-- Uses sound elements + CEF for stream playback.
-- ============================================================

Mzansi = Mzansi or {}
Mzansi.Radio = Mzansi.Radio or {}
Mzansi.Radio.Client = Mzansi.Radio.Client or {}

local currentSound = nil       -- personal stream sound element
local currentStation = nil
local currentVolume = Mzansi.Radio.Config and Mzansi.Radio.Config.defaultVolume or 0.7
local radioEnabled = false

-- Vehicle radio: vehicle -> { sound, station, volume }
local vehicleSounds = {}

-- Disable native GTA vehicle radio when custom radio active
local function disableGameRadio()
    if not Mzansi.Radio.Config.disableGameRadio then return end
    -- MTA doesn't play SA's own radio by default; ensure we don't conflict
    setPlayerHudComponentVisible("radar", true)
end

function Mzansi.Radio.Client.stopPersonal()
    if currentSound and isElement(currentSound) then
        destroyElement(currentSound)
    end
    currentSound = nil
    currentStation = nil
    radioEnabled = false
end

function Mzansi.Radio.Client.getVolume()
    return currentVolume
end

function Mzansi.Radio.Client.playStation(station, volume)
    if not station or not station.streamUrl then return false end
    Mzansi.Radio.Client.stopPersonal()

    volume = math.max(0, math.min(1, tonumber(volume) or currentVolume))
    currentVolume = volume

    local sound = playSound(station.streamUrl)
    if not sound then
        outputChatBox("#FF4444[RADIO] #FFFFFFFailed to start stream: " .. tostring(station.name), 255, 255, 255, true)
        return false
    end
    setSoundVolume(sound, volume)
    setSoundMinDistance(sound, 1.0)
    setSoundMaxDistance(Mzansi.Radio.Config.radioRange or 50.0)

    currentSound = sound
    currentStation = station
    radioEnabled = true
    disableGameRadio()
    return true
end

function Mzansi.Radio.Client.setVolume(volume)
    volume = math.max(0, math.min(1, tonumber(volume) or 0))
    currentVolume = volume
    if currentSound and isElement(currentSound) then
        setSoundVolume(currentSound, volume)
    end
end

function Mzansi.Radio.Client.getNowPlaying()
    if not radioEnabled or not currentStation then return nil end
    return currentStation
end

function Mzansi.Radio.Client.isEnabled()
    return radioEnabled
end

-- ---------- Server events ----------
addEvent("mzansi:radio:nowPlaying", true)
addEventHandler("mzansi:radio:nowPlaying", resourceRoot, function(station, volume)
    Mzansi.Radio.Client.playStation(station, volume)
end)

addEvent("mzansi:radio:stopped", true)
addEventHandler("mzansi:radio:stopped", resourceRoot, function()
    Mzansi.Radio.Client.stopPersonal()
end)

addEvent("mzansi:radio:volumeChanged", true)
addEventHandler("mzansi:radio:volumeChanged", resourceRoot, function(volume)
    Mzansi.Radio.Client.setVolume(volume)
end)

addEvent("mzansi:radio:error", true)
addEventHandler("mzansi:radio:error", resourceRoot, function(msg)
    outputChatBox("#FF4444[RADIO] #FFFFFF" .. tostring(msg), 255, 255, 255, true)
end)

addEvent("mzansi:radio:tribute", true)
addEventHandler("mzansi:radio:tribute", resourceRoot, function(payload)
    if payload and payload.message then
        outputChatBox("#FFD700[CIT RADIO] #FFFFFF" .. payload.message, 255, 255, 255, true)
    end
end)

-- Auto-tune CIT when server requests
addEvent("mzansi:radio:tuneCit", true)
addEventHandler("mzansi:radio:tuneCit", resourceRoot, function()
    triggerServerEvent("mzansi:radio:tune", resourceRoot, "cit_radio", { volume = currentVolume })
end)

-- ---------- Vehicle broadcast (3D positional) ----------
addEvent("mzansi:radio:vehicleBroadcast", true)
addEventHandler("mzansi:radio:vehicleBroadcast", resourceRoot, function(veh, station, volume)
    if not isElement(veh) then return end

    -- Stop existing sound for this vehicle
    if vehicleSounds[veh] and vehicleSounds[veh].sound and isElement(vehicleSounds[veh].sound) then
        destroyElement(vehicleSounds[veh].sound)
        vehicleSounds[veh] = nil
    end

    if not station then return end
    if not station.streamUrl then return end

    local sound = playSound3D(station.streamUrl, 0, 0, 0, veh)
    if sound then
        setSoundVolume(sound, math.max(0, math.min(1, tonumber(volume) or 0.5)))
        setSoundMinDistance(sound, 3.0)
        setSoundMaxDistance(Mzansi.Radio.Config.radioRange or 50.0)
        attachElements(sound, veh, 0, 0, 0.5)
        vehicleSounds[veh] = { sound = sound, station = station, volume = volume }
    end
end)

-- Clean up vehicle sounds when vehicle removed
addEventHandler("onClientElementDestroy", root, function()
    if getElementType(source) == "vehicle" and vehicleSounds[source] then
        if vehicleSounds[source].sound and isElement(vehicleSounds[source].sound) then
            destroyElement(vehicleSounds[source].sound)
        end
        vehicleSounds[source] = nil
    end
end)

-- Player enter vehicle: resume that vehicle's station
addEventHandler("onClientPlayerVehicleEnter", localPlayer, function(veh, seat)
    if seat ~= 0 and seat ~= 1 then return end
    -- Vehicle sound already handled by broadcast; nothing extra needed
end)

-- Cleanup on resource stop
addEventHandler("onClientResourceStop", resourceRoot, function()
    Mzansi.Radio.Client.stopPersonal()
    for veh, data in pairs(vehicleSounds) do
        if data.sound and isElement(data.sound) then
            destroyElement(data.sound)
        end
    end
    vehicleSounds = {}
end)

addEvent("mzansi:radio:citInfo", true)
addEventHandler("mzansi:radio:citInfo", root, function(data)
    Mzansi.Radio.Client._citInfo = data
end)