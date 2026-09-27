-- ============================================================
-- MZANSI RADIO: SERVER CORE
-- Station registry, selection sync, persistence
-- ============================================================

Mzansi = Mzansi or {}
Mzansi.Radio = Mzansi.Radio or {}

-- Per-player radio state: source -> { stationId, volume, playing, muted }
local playerRadio = {}

local function log(msg)
    outputServerLog("[mzansi_radio] " .. tostring(msg))
end

-- ---------- Exports (shared) ----------
function getStationList(category, query)
    if query and query ~= "" then
        return Mzansi.Radio.Util.listToDTO(Mzansi.Radio.Util.searchStations(query))
    end
    if category and category ~= "" then
        return Mzansi.Radio.Util.listToDTO(Mzansi.Radio.Util.getStationsByCategory(category))
    end
    return Mzansi.Radio.Util.listToDTO(Mzansi.Radio.Util.getStationsByCategory("all"))
end

function getCurrentStation(player)
    local pid = player and player ~= client and player or client or source
    if not isElement(pid) then return nil end
    local st = playerRadio[pid]
    if not st or not st.stationId then return nil end
    return Mzansi.Radio.Util.stationToDTO(Mzansi.Radio.Util.getStationById(st.stationId))
end

function setRadioStation(player, stationId)
    if not isElement(player) then return false end
    local station = Mzansi.Radio.Util.getStationById(stationId)
    if not station or not station.enabled then return false end
    if not Mzansi.Radio.Util.isHttpsUrl(station.streamUrl) then return false end
    playerRadio[player] = playerRadio[player] or {}
    playerRadio[player].stationId = station.id
    playerRadio[player].volume = Mzansi.Radio.Config.defaultVolume
    playerRadio[player].playing = true
    playerRadio[player].muted = false
    triggerClientEvent(player, "mzansi:radio:nowPlaying", resourceRoot, Mzansi.Radio.Util.stationToDTO(station), playerRadio[player].volume)
    return true
end

function toggleRadio(player)
    if not isElement(player) then return false end
    local st = playerRadio[player]
    if st and st.playing then
        playerRadio[player] = { stationId = nil, playing = false, volume = 0, muted = false }
        triggerClientEvent(player, "mzansi:radio:stopped", resourceRoot)
        return false
    else
        return setRadioStation(player, Mzansi.Radio.Stations[1].id)
    end
end

-- ---------- Events ----------
addEvent("mzansi:radio:requestStations", true)
addEventHandler("mzansi:radio:requestStations", root, function(category, query)
    local src = client or source
    if not isElement(src) then return end
    local list = getStationList(category, query)
    triggerClientEvent(src, "mzansi:radio:receiveStations", resourceRoot, list)
end)

addEvent("mzansi:radio:tune", true)
addEventHandler("mzansi:radio:tune", root, function(stationId, opts)
    local src = client or source
    if not isElement(src) then return end

    local station = Mzansi.Radio.Util.getStationById(stationId)
    if not station or not station.enabled then
        triggerClientEvent(src, "mzansi:radio:error", resourceRoot, "Station unavailable: " .. tostring(stationId))
        return
    end

    if not Mzansi.Radio.Util.isHttpsUrl(station.streamUrl) then
        triggerClientEvent(src, "mzansi:radio:error", resourceRoot, "Station stream is not a valid HTTPS URL.")
        return
    end

    opts = opts or {}
    playerRadio[src] = playerRadio[src] or {}
    playerRadio[src].stationId = station.id
    playerRadio[src].volume = tonumber(opts.volume) or Mzansi.Radio.Config.defaultVolume
    playerRadio[src].playing = true
    playerRadio[src].muted = false

    -- CIT tribute broadcast on first tune
    if station.type == "cit" and Mzansi.Radio.Config.citRadioTribute then
        triggerClientEvent(src, "mzansi:radio:tribute", resourceRoot, {
            station = Mzansi.Radio.Util.stationToDTO(station),
            message = Mzansi.Radio.Config.citRadioMessage,
        })
        outputChatBox("#FFD700[RADIO] #FFFFFFNow playing: #FFD700CIT Radio#FFFFFF. " .. Mzansi.Radio.Config.citRadioMessage, src, 255, 255, 255, true)
    else
        outputChatBox("#0096FF[RADIO] #FFFFFFTuned to: #0096FF" .. station.name .. " #FFFFFF(" .. tostring(station.freq) .. ")", src, 255, 255, 255, true)
    end

    -- Broadcast to vehicle passengers if in a vehicle
    if Mzansi.Radio.Config.vehicleRadioEnabled and isPedInVehicle(src) then
        local veh = getPedOccupiedVehicle(src)
        if veh then
            triggerClientEvent(root, "mzansi:radio:vehicleBroadcast", resourceRoot, veh, station, playerRadio[src].volume)
        end
    end

    triggerClientEvent(src, "mzansi:radio:nowPlaying", resourceRoot, Mzansi.Radio.Util.stationToDTO(station), playerRadio[src].volume)
end)

addEvent("mzansi:radio:stop", true)
addEventHandler("mzansi:radio:stop", root, function()
    local src = client or source
    if not isElement(src) then return end
    playerRadio[src] = { stationId = nil, playing = false, volume = 0, muted = false }
    if Mzansi.Radio.Config.vehicleRadioEnabled and isPedInVehicle(src) then
        local veh = getPedOccupiedVehicle(src)
        if veh then
            triggerClientEvent(root, "mzansi:radio:vehicleBroadcast", resourceRoot, veh, nil, 0)
        end
    end
    triggerClientEvent(src, "mzansi:radio:stopped", resourceRoot)
    outputChatBox("#0096FF[RADIO] #FFFFFFRadio off.", src, 255, 255, 255, true)
end)

addEvent("mzansi:radio:setVolume", true)
addEventHandler("mzansi:radio:setVolume", root, function(volume)
    local src = client or source
    if not isElement(src) then return end
    volume = math.max(0, math.min(1, tonumber(volume) or 0))
    playerRadio[src] = playerRadio[src] or {}
    playerRadio[src].volume = volume
    triggerClientEvent(src, "mzansi:radio:volumeChanged", resourceRoot, volume)
end)

-- ---------- Cleanup ----------
addEventHandler("onPlayerQuit", root, function()
    playerRadio[source] = nil
end)

-- ---------- CIT Radio info endpoint ----------
addEvent("mzansi:radio:getCitInfo", true)
addEventHandler("mzansi:radio:getCitInfo", root, function()
    local src = client or source
    if not isElement(src) then return end
    triggerClientEvent(src, "mzansi:radio:citInfo", resourceRoot, {
        station = Mzansi.Radio.Util.stationToDTO(Mzansi.Radio.CitRadio),
        tribute = Mzansi.Radio.Config.citRadioMessage,
        enabled = Mzansi.Radio.Config.citRadioEnabled,
    })
end)

addEventHandler("onResourceStart", resourceRoot, function()
    log("SA Radio System online. Stations loaded: " .. #Mzansi.Radio.Stations)
    log("CIT Radio integration: " .. (Mzansi.Radio.Config.citRadioEnabled and "ENABLED" or "DISABLED"))
end)