-- ============================================================
-- MZANSI RADIO: VEHICLE RADIO
-- 3D positional radio for vehicles without touching game radio
-- ============================================================

Mzansi = Mzansi or {}
Mzansi.Radio = Mzansi.Radio or {}

-- vehicle element -> { stationId, volume, driver }
local vehicleRadio = {}

addEvent("mzansi:radio:vehicleTune", true)
addEventHandler("mzansi:radio:vehicleTune", root, function(stationId, volume)
    local src = client or source
    if not isElement(src) then return end
    if not isPedInVehicle(src) then
        outputChatBox("#FF4444[RADIO] #FFFFFFYou must be in a vehicle to use vehicle radio.", src, 255, 255, 255, true)
        return
    end
    local veh = getPedOccupiedVehicle(src)
    if not veh then return end

    -- Only driver or front passenger controls the radio (realistic)
    local seat = getPedVehicleSeat(src)
    if seat ~= 0 and seat ~= 1 then
        outputChatBox("#FF4444[RADIO] #FFFFFFOnly the driver or front passenger can control the radio.", src, 255, 255, 255, true)
        return
    end

    local station = Mzansi.Radio.Util.getStationById(stationId)
    if station then
        vehicleRadio[veh] = {
            stationId = station.id,
            volume = math.max(0, math.min(1, tonumber(volume) or Mzansi.Radio.Config.defaultVolume)),
            driver = src,
        }
        triggerClientEvent(root, "mzansi:radio:vehicleBroadcast", resourceRoot, veh, station, vehicleRadio[veh].volume)
        outputChatBox("#0096FF[VEHICLE RADIO] #FFFFFFNow playing: #0096FF" .. station.name, src, 255, 255, 255, true)
    else
        vehicleRadio[veh] = nil
        triggerClientEvent(root, "mzansi:radio:vehicleBroadcast", resourceRoot, veh, nil, 0)
    end
end)

addEvent("mzansi:radio:vehicleStop", true)
addEventHandler("mzansi:radio:vehicleStop", root, function()
    local src = client or source
    if not isElement(src) or not isPedInVehicle(src) then return end
    local veh = getPedOccupiedVehicle(src)
    if not veh then return end
    vehicleRadio[veh] = nil
    triggerClientEvent(root, "mzansi:radio:vehicleBroadcast", resourceRoot, veh, nil, 0)
end)

-- When player exits vehicle, stop their personal stream if vehicle was source
addEventHandler("onPlayerVehicleExit", root, function(veh)
    -- personal stream continues; vehicle stream handled client-side on enter
end)

-- Clear vehicle radio when vehicle is destroyed
addEventHandler("onVehicleExploded", root, function()
    vehicleRadio[source] = nil
    triggerClientEvent(root, "mzansi:radio:vehicleBroadcast", resourceRoot, source, nil, 0)
end)

addEventHandler("onResourceStop", resourceRoot, function()
    for veh, data in pairs(vehicleRadio) do
        if isElement(veh) then
            triggerClientEvent(root, "mzansi:radio:vehicleBroadcast", resourceRoot, veh, nil, 0)
        end
    end
    vehicleRadio = {}
end)