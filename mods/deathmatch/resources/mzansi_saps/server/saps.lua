Mzansi = Mzansi or {}
Mzansi.SAPS = {}
Mzansi.SAPS._activeDispatches = {}
Mzansi.SAPS._activeCalls = {}

addEvent("mzansi:saps:arrest", true)
addEvent("mzansi:saps:cuff", true)
addEvent("mzansi:saps:uncuff", true)
addEvent("mzansi:saps:ticket", true)
addEvent("mzansi:saps:frisk", true)
addEvent("mzansi:saps:dispatch", true)
addEvent("mzansi:saps:respondDispatch", true)
addEvent("mzansi:saps:mdtSearch", true)
addEvent("mzansi:saps:mdtAddRecord", true)
addEvent("mzansi:saps:mdtWarrant", true)

function Mzansi.SAPS.isOfficer(source)
    local char = Mzansi.Characters.getCharacter(source)
    return char and char.faction == Mzansi.Enums.Faction.SAPS
end

function isOfficer(player)
    return Mzansi.SAPS.isOfficer(player) or false
end

function Mzansi.SAPS.getOfficersOnline()
    local officers = {}
    for _, player in ipairs(getElementsByType("player")) do
        if Mzansi.SAPS.isOfficer(player) then
            officers[#officers + 1] = player
        end
    end
    return officers
end

function Mzansi.SAPS.cuffPlayer(source, target)
    if not Mzansi.SAPS.isOfficer(source) then
        Mzansi.Util.sendNotification(source, "You are not a police officer.", "error")
        return false
    end

    if not target or not isElement(target) then
        Mzansi.Util.sendNotification(source, "Invalid target.", "error")
        return false
    end

    local x, y, z = getElementPosition(source)
    local tx, ty, tz = getElementPosition(target)
    if Mzansi.Util.distance(x, y, z, tx, ty, tz) > Mzansi.Config.Police.handcuffRange then
        Mzansi.Util.sendNotification(source, "Target too far away.", "error")
        return false
    end

    local isCuffed = getElementData(target, "mzansi:cuffed")
    setElementData(target, "mzansi:cuffed", not isCuffed)

    if not isCuffed then
        toggleControl(target, "fire", false)
        toggleControl(target, "aim_weapon", false)
        toggleControl(target, "jump", false)
        setPedWeaponSlot(target, 0)
        Mzansi.Util.sendNotification(source, "Player handcuffed.", "success")
        Mzansi.Util.sendNotification(target, "You have been handcuffed by an officer.", "warning")
    else
        toggleControl(target, "fire", true)
        toggleControl(target, "aim_weapon", true)
        toggleControl(target, "jump", true)
        Mzansi.Util.sendNotification(source, "Player uncuffed.", "success")
        Mzansi.Util.sendNotification(target, "You have been uncuffed.", "info")
    end

    return true
end

function Mzansi.SAPS.arrestPlayer(source, target, jailTime)
    if not Mzansi.SAPS.isOfficer(source) then
        Mzansi.Util.sendNotification(source, "You are not a police officer.", "error")
        return false
    end

    local char = Mzansi.Characters.getCharacter(target)
    if not char then
        Mzansi.Util.sendNotification(source, "Invalid target.", "error")
        return false
    end

    local x, y, z = getElementPosition(source)
    local tx, ty, tz = getElementPosition(target)
    if Mzansi.Util.distance(x, y, z, tx, ty, tz) > Mzansi.Config.Police.arrestRange then
        Mzansi.Util.sendNotification(source, "Target too far away.", "error")
        return false
    end

    jailTime = tonumber(jailTime) or 300
    jailTime = Mzansi.Util.clamp(jailTime, 60, 7200)

    char.jailTime = jailTime
    setElementData(target, "mzansi:jailTime", jailTime)

    local officerName = Mzansi.Util.getPlayerFullName(source)
    local charName = Mzansi.Characters.getCharacterField(target, "firstName") .. " " .. Mzansi.Characters.getCharacterField(target, "lastName")

    Mzansi.Database.insert(
        "INSERT INTO mzansi_police_records (character_id, officer_id, charge, description, jail_time) VALUES (?, ?, ?, ?, ?)",
        char.id,
        Mzansi.Characters.getCharacterField(source, "id") or 0,
        "Arrest",
        "Arrested by " .. officerName,
        jailTime
    )

    Mzansi.Database.logAction("ARREST", char.id, charName, "Arrested by " .. officerName, "Jail: " .. jailTime .. "s", "")

    setElementData(target, "mzansi:cuffed", false)
    toggleControl(target, "fire", true)
    toggleControl(target, "aim_weapon", true)
    toggleControl(target, "jump", true)

    spawnPlayer(target, 1547.5, -1675.5, 13.5, 0, 0, 0, 0, 0)
    setElementHealth(target, 100)
    setCameraTarget(target, target)
    fadeCamera(target, true, 1.0)
    setTimer(function()
        if isElement(target) then
            setCameraTarget(target, target)
            setElementFrozen(target, true)
            setElementData(target, "mzansi:inJail", true)
        end
    end, 500, 1)

    Mzansi.Util.sendNotification(source, "Player arrested for " .. jailTime .. " seconds.", "success")
    Mzansi.Util.sendNotification(target, "You have been arrested for " .. jailTime .. " seconds.", "error")

    for _, officer in ipairs(Mzansi.SAPS.getOfficersOnline()) do
        if officer ~= source then
            Mzansi.Util.sendNotification(officer, officerName .. " arrested " .. charName .. " for " .. jailTime .. "s.", "info")
        end
    end

    return true
end

function Mzansi.SAPS.issueTicket(source, target, amount, reason)
    if not Mzansi.SAPS.isOfficer(source) then
        Mzansi.Util.sendNotification(source, "You are not a police officer.", "error")
        return false
    end

    amount = tonumber(amount) or Mzansi.Config.Police.ticketMin
    amount = Mzansi.Util.clamp(amount, Mzansi.Config.Police.ticketMin, Mzansi.Config.Police.ticketMax)

    local char = Mzansi.Characters.getCharacter(target)
    if not char then
        Mzansi.Util.sendNotification(source, "Invalid target.", "error")
        return false
    end

    if char.cash < amount then
        Mzansi.Util.sendNotification(source, "Player cannot afford this ticket.", "error")
        return false
    end

    Mzansi.Characters.removeCash(target, amount)
    Mzansi.Characters.addBank(source, math.floor(amount * 0.1))

    local officerName = Mzansi.Util.getPlayerFullName(source)
    local charName = char.firstName .. " " .. char.lastName

    Mzansi.Database.insert(
        "INSERT INTO mzansi_police_records (character_id, officer_id, charge, description, fine) VALUES (?, ?, ?, ?, ?)",
        char.id,
        Mzansi.Characters.getCharacterField(source, "id") or 0,
        "Traffic Violation",
        reason or "No reason provided",
        amount
    )

    Mzansi.Util.sendNotification(source, "Ticket issued: " .. Mzansi.Util.formatMoney(amount), "success")
    Mzansi.Util.sendNotification(target, "You received a ticket of " .. Mzansi.Util.formatMoney(amount) .. " from " .. officerName .. ".", "warning")

    return true
end

function Mzansi.SAPS.friskPlayer(source, target)
    if not Mzansi.SAPS.isOfficer(source) then return false end

    local x, y, z = getElementPosition(source)
    local tx, ty, tz = getElementPosition(target)
    if Mzansi.Util.distance(x, y, z, tx, ty, tz) > Mzansi.Config.Police.handcuffRange then
        Mzansi.Util.sendNotification(source, "Target too far away.", "error")
        return false
    end

    triggerClientEvent(source, "mzansi:saps:friskResult", source, target)
    Mzansi.Util.sendNotification(target, "You are being searched.", "warning")
    return true
end

function Mzansi.SAPS.createDispatch(source, type, x, y, z, description)
    local dispatch = {
        id = #Mzansi.SAPS._activeDispatches + 1,
        type = type,
        reporter = source,
        x = x,
        y = y,
        z = z,
        description = description,
        timestamp = getRealTime().timestamp,
        status = "active",
    }

    Mzansi.SAPS._activeDispatches[dispatch.id] = dispatch

    for _, officer in ipairs(Mzansi.SAPS.getOfficersOnline()) do
        Mzansi.Util.sendNotification(officer, "DISPATCH: " .. type .. " at " .. description, "warning")
        triggerClientEvent(officer, "mzansi:saps:newDispatch", officer, dispatch)
    end

    Mzansi.Database.logAction("DISPATCH", 0, "SYSTEM", type, description, "")
    return dispatch.id
end

function Mzansi.SAPS.respondToDispatch(source, dispatchId)
    local dispatch = Mzansi.SAPS._activeDispatches[dispatchId]
    if not dispatch then
        Mzansi.Util.sendNotification(source, "Dispatch not found.", "error")
        return false
    end

    dispatch.status = "responding"
    dispatch.responder = source

    local responderName = Mzansi.Util.getPlayerFullName(source)
    for _, officer in ipairs(Mzansi.SAPS.getOfficersOnline()) do
        Mzansi.Util.sendNotification(officer, responderName .. " is responding to dispatch #" .. dispatchId, "info")
    end

    return true
end

function Mzansi.SAPS.clearDispatch(source, dispatchId)
    local dispatch = Mzansi.SAPS._activeDispatches[dispatchId]
    if not dispatch then return false end

    dispatch.status = "cleared"
    Mzansi.SAPS._activeDispatches[dispatchId] = nil

    Mzansi.Util.sendNotification(source, "Dispatch #" .. dispatchId .. " cleared.", "success")
    return true
end

addEventHandler("mzansi:saps:cuff", root, function(target)
    local source = client or source
    Mzansi.SAPS.cuffPlayer(source, target)
end)

addEventHandler("mzansi:saps:arrest", root, function(target, jailTime)
    local source = client or source
    Mzansi.SAPS.arrestPlayer(source, target, jailTime)
end)

addEventHandler("mzansi:saps:ticket", root, function(target, amount, reason)
    local source = client or source
    Mzansi.SAPS.issueTicket(source, target, amount, reason)
end)

addEventHandler("mzansi:saps:frisk", root, function(target)
    local source = client or source
    Mzansi.SAPS.friskPlayer(source, target)
end)

addEventHandler("mzansi:saps:dispatch", root, function(type, x, y, z, description)
    local source = client or source
    Mzansi.SAPS.createDispatch(source, type, x, y, z, description)
end)

addEventHandler("mzansi:saps:respondDispatch", root, function(dispatchId)
    local source = client or source
    Mzansi.SAPS.respondToDispatch(source, dispatchId)
end)

addEventHandler("mzansi:saps:mdtSearch", root, function(query)
    local source = client or source
    if not Mzansi.SAPS.isOfficer(source) then return end

    local results = Mzansi.Database.query(
        "SELECT * FROM mzansi_characters WHERE first_name LIKE ? OR last_name LIKE ? OR id = ?",
        "%" .. query .. "%", "%" .. query .. "%", tonumber(query) or 0
    )

    triggerClientEvent(source, "mzansi:saps:mdtResult", source, results or {})
end)

addEventHandler("mzansi:saps:mdtAddRecord", root, function(charId, charge, description, fine, jailTime)
    local source = client or source
    if not Mzansi.SAPS.isOfficer(source) then return end

    local officerId = Mzansi.Characters.getCharacterField(source, "id")
    Mzansi.Database.insert(
        "INSERT INTO mzansi_police_records (character_id, officer_id, charge, description, fine, jail_time) VALUES (?, ?, ?, ?, ?, ?)",
        charId, officerId, charge, description or "", fine or 0, jailTime or 0
    )

    Mzansi.Util.sendNotification(source, "Record added successfully.", "success")
end)

addEventHandler("mzansi:saps:mdtWarrant", root, function(charId, reason)
    local source = client or source
    if not Mzansi.SAPS.isOfficer(source) then return end

    local char = Mzansi.Database.query("SELECT * FROM mzansi_characters WHERE id = ? LIMIT 1", charId)
    if char and #char > 0 then
        Mzansi.Database.update(
            "UPDATE mzansi_characters SET wanted_level = ? WHERE id = ?",
            Mzansi.Enums.WantedLevel.HIGH, charId
        )
        Mzansi.Util.sendNotification(source, "Warrant issued for " .. char[1].first_name .. " " .. char[1].last_name, "success")
    end
end)

addEventHandler("onResourceStart", resourceRoot, function()
    outputDebugString("[Mzansi-SAPS] SAPS system loaded.")
end)
