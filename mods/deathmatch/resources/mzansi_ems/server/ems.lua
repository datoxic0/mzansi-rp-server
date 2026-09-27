Mzansi = Mzansi or {}
Mzansi.EMS = {}

addEvent("mzansi:ems:heal", true)
addEvent("mzansi:ems:revive", true)
addEvent("mzansi:ems:drag", true)
addEvent("mzansi:ems:loadInAmbulance", true)

function Mzansi.EMS.isMedic(source)
    local char = Mzansi.Characters.getCharacter(source)
    return char and char.faction == Mzansi.Enums.Faction.EMS
end

function isMedic(player)
    return Mzansi.EMS.isMedic(player) or false
end

function Mzansi.EMS.getMedicsOnline()
    local medics = {}
    for _, player in ipairs(getElementsByType("player")) do
        if Mzansi.EMS.isMedic(player) then
            medics[#medics + 1] = player
        end
    end
    return medics
end

function Mzansi.EMS.healPlayer(source, target)
    if not Mzansi.EMS.isMedic(source) then
        Mzansi.Util.sendNotification(source, "You are not a medic.", "error")
        return false
    end

    local x, y, z = getElementPosition(source)
    local tx, ty, tz = getElementPosition(target)
    if Mzansi.Util.distance(x, y, z, tx, ty, tz) > Mzansi.Config.EMS.healRange then
        Mzansi.Util.sendNotification(source, "Patient too far away.", "error")
        return false
    end

    local char = Mzansi.Characters.getCharacter(target)
    if not char then return false end

    if char.cash < Mzansi.Config.EMS.healCost then
        Mzansi.Util.sendNotification(source, "Patient cannot afford healing.", "error")
        return false
    end

    Mzansi.Characters.removeCash(target, Mzansi.Config.EMS.healCost)
    setElementHealth(target, 100)
    setPedArmor(target, 0)

    local medicName = Mzansi.Util.getPlayerFullName(source)
    local patientName = char.firstName .. " " .. char.lastName

    Mzansi.Util.sendNotification(source, "Patient healed for " .. Mzansi.Util.formatMoney(Mzansi.Config.EMS.healCost) .. ".", "success")
    Mzansi.Util.sendNotification(target, "You have been healed by " .. medicName .. ". Cost: " .. Mzansi.Util.formatMoney(Mzansi.Config.EMS.healCost), "info")

    Mzansi.Characters.addXP(source, 50)
    Mzansi.Database.logAction("HEAL", char.id, patientName, "Healed by " .. medicName, "Cost: " .. Mzansi.Config.EMS.healCost, "")

    return true
end

function Mzansi.EMS.revivePlayer(source, target)
    if not Mzansi.EMS.isMedic(source) then
        Mzansi.Util.sendNotification(source, "You are not a medic.", "error")
        return false
    end

    local x, y, z = getElementPosition(source)
    local tx, ty, tz = getElementPosition(target)
    if Mzansi.Util.distance(x, y, z, tx, ty, tz) > Mzansi.Config.EMS.healRange then
        Mzansi.Util.sendNotification(source, "Patient too far away.", "error")
        return false
    end

    local char = Mzansi.Characters.getCharacter(target)
    if not char then return false end

    if char.cash < Mzansi.Config.EMS.reviveCost then
        Mzansi.Util.sendNotification(source, "Patient cannot afford revival.", "error")
        return false
    end

    Mzansi.Characters.removeCash(target, Mzansi.Config.EMS.reviveCost)
    spawnPlayer(target, getElementPosition(target))
    setCameraTarget(target, target)
    fadeCamera(target, true, 1.0)
    setTimer(function()
        if isElement(target) then
            setElementHealth(target, 50)
            setPedArmor(target, 0)
            setCameraTarget(target, target)
        end
    end, 500, 1)

    local medicName = Mzansi.Util.getPlayerFullName(source)
    local patientName = char.firstName .. " " .. char.lastName

    -- Skippable EMS revival cutscene on the patient
    setTimer(function()
        if isElement(target) then
            triggerClientEvent(target, "mzansi:cutscene:scene", resourceRoot, {
                kind = "revive",
                phase = "revive",
                data = { medic = medicName },
            })
        end
    end, 600, 1)

    Mzansi.Util.sendNotification(source, "Patient revived for " .. Mzansi.Util.formatMoney(Mzansi.Config.EMS.reviveCost) .. ".", "success")
    Mzansi.Util.sendNotification(target, "You have been revived by " .. medicName .. ". Cost: " .. Mzansi.Util.formatMoney(Mzansi.Config.EMS.reviveCost), "info")

    Mzansi.Characters.addXP(source, 100)
    Mzansi.Database.logAction("REVIVE", char.id, patientName, "Revived by " .. medicName, "Cost: " .. Mzansi.Config.EMS.reviveCost, "")

    return true
end

function Mzansi.EMS.loadIntoAmbulance(source, target)
    if not Mzansi.EMS.isMedic(source) then return false end

    local vehicle = getPedOccupiedVehicle(source)
    if not vehicle or getElementModel(vehicle) ~= 416 then
        Mzansi.Util.sendNotification(source, "You must be in an ambulance.", "error")
        return false
    end

    local x, y, z = getElementPosition(source)
    local tx, ty, tz = getElementPosition(target)
    if Mzansi.Util.distance(x, y, z, tx, ty, tz) > 10 then
        Mzansi.Util.sendNotification(source, "Patient too far away.", "error")
        return false
    end

    warpPedIntoVehicle(target, vehicle, 2)
    setElementData(target, "mzansi:inAmbulance", true)

    local medicName = Mzansi.Util.getPlayerFullName(source)
    Mzansi.Util.sendNotification(source, "Patient loaded into ambulance.", "success")
    Mzansi.Util.sendNotification(target, "You have been loaded into an ambulance by " .. medicName, "info")

    return true
end

function Mzansi.EMS.handleDown()
    local char = Mzansi.Characters.getCharacter(source)
    if not char then return end

    setElementHealth(source, 0)
    setPedArmor(source, 0)
    toggleControl(source, "fire", false)
    toggleControl(source, "aim_weapon", false)

    Mzansi.Util.sendNotification(source, "You are injured! Wait for a medic.", "error")

    for _, medic in ipairs(Mzansi.EMS.getMedicsOnline()) do
        local x, y, z = getElementPosition(source)
        Mzansi.Util.sendNotification(medic, "Patient down at " .. getZoneName(source) .. "!", "warning")
        triggerClientEvent(medic, "mzansi:ems:downMarker", medic, x, y, z, char.firstName .. " " .. char.lastName)
    end

    setTimer(function()
        if isElement(source) and getElementHealth(source) <= 0 then
            spawnPlayer(source, 1176.8, -1323.0, 13.5, 0, 0, 0, 0, 0)
            setCameraTarget(source, source)
            fadeCamera(source, true, 1.0)
            setTimer(function()
                if isElement(source) then
                    setElementHealth(source, 50)
                    setCameraTarget(source, source)
                    Mzansi.Util.sendNotification(source, "You woke up at the hospital.", "info")
                end
            end, 500, 1)
        end
    end, 60000, 1)
end

addEventHandler("mzansi:ems:heal", root, function(target)
    local source = client or source
    Mzansi.EMS.healPlayer(source, target)
end)

addEventHandler("mzansi:ems:revive", root, function(target)
    local source = client or source
    Mzansi.EMS.revivePlayer(source, target)
end)

addEventHandler("mzansi:ems:loadInAmbulance", root, function(target)
    local source = client or source
    Mzansi.EMS.loadIntoAmbulance(source, target)
end)

addEventHandler("onPlayerDamage", root, function()
    if getElementHealth(source) <= 0 then
        Mzansi.EMS.handleDown()
    end
end)

addEventHandler("onResourceStart", resourceRoot, function()
    outputDebugString("[Mzansi-EMS] EMS system loaded.")
end)
