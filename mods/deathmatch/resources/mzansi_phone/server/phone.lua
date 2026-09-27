Mzansi = Mzansi or {}
Mzansi.Phone = {}
Mzansi.Phone._activeCalls = {}
Mzansi.Phone._groupCalls = {}
Mzansi.Phone._playerGroup = {}
Mzansi.Phone._db = nil

-- ============================================================
-- MODERN PHONE APPS SYSTEM (GTA 5/6 Style)
-- ============================================================

Mzansi.Phone.Apps = {}

-- App Registry: Modern smartphone apps
local PHONE_APPS = {
    -- Core System Apps
    { id = "phone", name = "Phone", icon = "📞", category = "core", system = true },
    { id = "messages", name = "Messages", icon = "💬", category = "core", system = true },
    { id = "contacts", name = "Contacts", icon = "👥", category = "core", system = true },
    { id = "settings", name = "Settings", icon = "⚙️", category = "core", system = true },

    -- Financial Apps
    { id = "banking", name = "Capitec Bank", icon = "🏦", category = "finance", color = { 0, 150, 255 } },
    { id = "crypto", name = "Crypto Wallet", icon = "₿", category = "finance", color = { 255, 200, 0 } },
    { id = "wallet", name = "Mzansi Wallet", icon = "💳", category = "finance", color = { 0, 200, 100 } },

    -- Navigation & Transport
    { id = "gps", name = "GPS Navigation", icon = "🗺️", category = "nav", color = { 255, 100, 0 } },
    { id = "uber", name = "Uber / Bolt", icon = "🚗", category = "nav", color = { 0, 100, 200 } },
    { id = "flight", name = "ACSA Flights", icon = "✈️", category = "nav", color = { 100, 50, 200 } },
    { id = "subway", name = "Metro/Subway", icon = "🚇", category = "nav", color = { 200, 0, 100 } },

    -- Social & Communication
    { id = "lifeblog", name = "LifeBlog", icon = "📱", category = "social", color = { 255, 50, 150 } },
    { id = "twatter", name = "Twatter", icon = "🐦", category = "social", color = { 0, 170, 255 } },
    { id = "facelook", name = "FaceLook", icon = "👍", category = "social", color = { 50, 80, 200 } },
    { id = "instantgram", name = "InstantGram", icon = "📸", category = "social", color = { 200, 50, 100 } },
    { id = "whatsup", name = "WhatsUp", icon = "💚", category = "social", color = { 50, 200, 100 } },

    -- Entertainment
    { id = "music", name = "Music Player", icon = "🎵", category = "entertainment", color = { 200, 0, 200 } },
    { id = "radio", name = "Radio SA", icon = "📻", category = "entertainment", color = { 255, 150, 0 } },
    { id = "games", name = "Mobile Games", icon = "🎮", category = "entertainment", color = { 100, 200, 50 } },
    { id = "netflix", name = "StreamFlix", icon = "🎬", category = "entertainment", color = { 220, 20, 60 } },

    -- Utility Apps
    { id = "camera", name = "Camera", icon = "📷", category = "utility", color = { 100, 100, 100 } },
    { id = "gallery", name = "Gallery", icon = "🖼️", category = "utility" },
    { id = "notes", name = "Notes", icon = "📝", category = "utility" },
    { id = "calendar", name = "Calendar", icon = "📅", category = "utility" },
    { id = "weather", name = "Weather SA", icon = "🌤️", category = "utility", color = { 100, 200, 255 } },
    { id = "calculator", name = "Calculator", icon = "🔢", category = "utility" },
    { id = "flashlight", name = "Flashlight", icon = "🔦", category = "utility" },
    { id = "compass", name = "Compass", icon = "🧭", category = "utility" },

    -- Government & Services
    { id = "gov", name = "GovZA Services", icon = "🏛️", category = "gov", color = { 0, 100, 50 } },
    { id = "saps", name = "SAPS App", icon = "👮", category = "gov", color = { 0, 50, 150 } },
    { id = "ems", name = "EMS Assist", icon = "🚑", category = "gov", color = { 200, 0, 0 } },
    { id = "traffic", name = "Traffic Fines", icon = "🚦", category = "gov" },
    { id = "homeaffairs", name = "Home Affairs", icon = "📋", category = "gov" },

    -- Shopping & Food
    { id = "takealot", name = "Takealot", icon = "📦", category = "shopping", color = { 0, 150, 100 } },
    { id = "uber_eats", name = "Uber Eats", icon = "🍔", category = "shopping", color = { 0, 200, 100 } },
    { id = "checkers", name = "Checkers Sixty60", icon = "🛒", category = "shopping", color = { 0, 100, 200 } },
    { id = "woolworths", name = "Woolworths", icon = "🛍️", category = "shopping", color = { 50, 50, 150 } },

    -- RP Specific Apps
    { id = "jobs", name = "Job Center", icon = "💼", category = "rp", color = { 100, 150, 50 } },
    { id = "properties", name = "Property Finder", icon = "🏠", category = "rp", color = { 150, 100, 50 } },
    { id = "vehicles", name = "Vehicle Market", icon = "🚙", category = "rp", color = { 200, 150, 0 } },
    { id = "gangs", name = "Gang Hub", icon = "👥", category = "rp", color = { 150, 0, 150 } },
    { id = "darkweb", name = "DarkWeb", icon = "🌑", category = "rp", color = { 50, 0, 50 }, restricted = true },
    { id = "police_mdt", name = "Police MDT", icon = "💻", category = "rp", restricted = true, faction = 1 },
    { id = "ems_mdt", name = "EMS MDT", icon = "🏥", category = "rp", restricted = true, faction = 2 },

    -- Space & Deep Sea (New!)
    { id = "space_tracker", name = "Space Tracker", icon = "🚀", category = "special", color = { 100, 100, 255 }, dimension = 40 },
    { id = "iss_tracker", name = "ISS Tracker", icon = "🛰️", category = "special", dimension = 40 },
    { id = "mars_weather", name = "Mars Weather", icon = "🪐", category = "special", dimension = 40 },
    { id = "deepsea_sonar", name = "DeepSea Sonar", icon = "🌊", category = "special", color = { 0, 100, 200 }, dimension = 50 },
    { id = "submarine_nav", name = "Sub Nav System", icon = "⚓", category = "special", dimension = 50 },
    { id = "trench_map", name = "Trench Map", icon = "🗺️", category = "special", dimension = 50 },
}

-- Helper: Get Character Data (must be defined before first use)
local function getChar(player)
    if not isElement(player) then return nil end
    local ok, char = pcall(function()
        return exports.mzansi_core:getCharacter(player)
    end)
    if ok then return char end
    return nil
end

function Mzansi.Phone.Apps.getAllApps(player)
    local char = getChar(player)
    if not char then return {} end

    local apps = {}
    local job = tonumber(char.job) or 0
    local faction = tonumber(char.faction) or 0
    local adminLevel = tonumber(getElementData(player, "mzansi:adminLevel") or 0)
    local isCreator = getElementData(player, "mzansi:creator")
    local playerDim = getElementDimension(player)

    for _, app in ipairs(PHONE_APPS) do
        local canAccess = true

        -- Check restrictions
        if app.restricted then
            canAccess = false
            if app.faction and faction == app.faction then canAccess = true end
            if adminLevel >= 1 then canAccess = true end
            if isCreator then canAccess = true end
        end

        -- Check dimension-specific apps
        if app.dimension and playerDim ~= app.dimension then
            canAccess = false
        end

        -- Job-specific apps
        if app.job and job ~= app.job then
            canAccess = false
        end

        if canAccess then
            table.insert(apps, app)
        end
    end

    return apps
end

function Mzansi.Phone.Apps.getAppById(appId)
    for _, app in ipairs(PHONE_APPS) do
        if app.id == appId then return app end
    end
    return nil
end

-- Initialize SQLite Database for Phone Persistence
function Mzansi.Phone.initDB()
    Mzansi.Phone._db = dbConnect("sqlite", ":/phone.db")
    if Mzansi.Phone._db then
        dbExec(Mzansi.Phone._db, [[
            CREATE TABLE IF NOT EXISTS phone_contacts (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                owner_id INTEGER NOT NULL,
                name TEXT NOT NULL,
                number TEXT NOT NULL
            );
        ]])
        dbExec(Mzansi.Phone._db, [[
            CREATE TABLE IF NOT EXISTS phone_messages (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                sender_id INTEGER NOT NULL,
                sender_number TEXT NOT NULL,
                receiver_number TEXT NOT NULL,
                message TEXT NOT NULL,
                sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
        ]])
        outputDebugString("[Mzansi-Phone] SQLite database connected and tables initialized.")
    else
        outputDebugString("[Mzansi-Phone] Failed to connect to SQLite database!", 1)
    end
end

-- Generate a clean South African mobile number (082 / 071 / 083)
function Mzansi.Phone.getNumber(player)
    local char = getChar(player)
    if not char then return "082 000 0000" end
    local id = tonumber(char.id) or tonumber(char.characterId) or 1
    local prefix = (id % 3 == 0) and "082" or ((id % 3 == 1) and "071" or "083")
    local mid = string.format("%03d", (id * 137) % 900 + 100)
    local last = string.format("%04d", (id * 359) % 9000 + 1000)
    return prefix .. " " .. mid .. " " .. last
end

function getNumber(player)
    return Mzansi.Phone.getNumber(player)
end

-- Find Online Player by Number
function Mzansi.Phone.getPlayerByNumber(number)
    local cleanTarget = string.gsub(tostring(number or ""), "%s+", "")
    for _, player in ipairs(getElementsByType("player")) do
        local pNum = string.gsub(Mzansi.Phone.getNumber(player), "%s+", "")
        if pNum == cleanTarget then
            return player
        end
    end
    return nil
end

-- 1. Call System
function Mzansi.Phone.call(player, targetNumber)
    local char = getChar(player)
    if not char then return end

    local callerNumber = Mzansi.Phone.getNumber(player)
    local cleanTarget = string.gsub(tostring(targetNumber or ""), "%s+", "")
    local cleanCaller = string.gsub(callerNumber, "%s+", "")

    if cleanTarget == cleanCaller then
        Mzansi.Util.sendNotification(player, "You cannot call your own number!", "error")
        return
    end

    -- Check for special service numbers
    if cleanTarget == "911" or cleanTarget == "10111" then
        Mzansi.Phone.callEmergency(player, "SAPS Police")
        return
    elseif cleanTarget == "10177" then
        Mzansi.Phone.callEmergency(player, "EMS Ambulance")
        return
    elseif cleanTarget == "411" or cleanTarget == "taxi" then
        Mzansi.Phone.hailTaxi(player)
        return
    end

    local targetPlayer = Mzansi.Phone.getPlayerByNumber(targetNumber)
    if not targetPlayer then
        Mzansi.Util.sendNotification(player, "The number " .. targetNumber .. " is currently unavailable or switched off.", "warning")
        triggerClientEvent(player, "mzansi:phone:callFailed", player, "Unavailable")
        return
    end

    if Mzansi.Phone._activeCalls[player] or Mzansi.Phone._activeCalls[targetPlayer] then
        Mzansi.Util.sendNotification(player, "Line is busy. Please try again later.", "warning")
        triggerClientEvent(player, "mzansi:phone:callFailed", player, "Line Busy")
        return
    end

    -- Initiate Call
    local callData = {
        caller = player,
        receiver = targetPlayer,
        callerNumber = callerNumber,
        receiverNumber = targetNumber,
        startTime = nil,
        status = "ringing"
    }

    Mzansi.Phone._activeCalls[player] = callData
    Mzansi.Phone._activeCalls[targetPlayer] = callData

    local fn = char.first_name or char.firstName or "Unknown"
    local ln = char.last_name or char.lastName or "Citizen"
    local callerName = fn .. " " .. ln

    triggerClientEvent(player, "mzansi:phone:outgoingCall", player, targetNumber)
    triggerClientEvent(targetPlayer, "mzansi:phone:incomingCall", targetPlayer, callerNumber, callerName)
    Mzansi.Util.sendNotification(player, "Calling " .. targetNumber .. "...", "info")
end

function Mzansi.Phone.answer(player)
    local call = Mzansi.Phone._activeCalls[player]
    if not call or call.status ~= "ringing" then return end

    call.status = "connected"
    call.startTime = getTickCount()

    -- Route Voice Chat natively through Phone line
    if setPlayerVoiceBroadcastTo then
        setPlayerVoiceBroadcastTo(call.caller, call.receiver)
        setPlayerVoiceBroadcastTo(call.receiver, call.caller)
    end

    triggerClientEvent(call.caller, "mzansi:phone:callConnected", call.caller, call.receiverNumber)
    triggerClientEvent(call.receiver, "mzansi:phone:callConnected", call.receiver, call.callerNumber)

    Mzansi.Util.sendNotification(call.caller, "Call connected! Live phone voice routing active.", "success")
    Mzansi.Util.sendNotification(call.receiver, "Call connected! Live phone voice routing active.", "success")
end

function Mzansi.Phone.hangup(player)
    -- Check if player is in a Group / Conference call first
    if Mzansi.Phone._playerGroup[player] then
        Mzansi.Phone.leaveGroupCall(player)
        return
    end

    local call = Mzansi.Phone._activeCalls[player]
    if not call then return end

    local other = (call.caller == player) and call.receiver or call.caller
    Mzansi.Phone._activeCalls[call.caller] = nil
    Mzansi.Phone._activeCalls[call.receiver] = nil

    -- Clear native voice routes
    if setPlayerVoiceBroadcastTo then
        if isElement(call.caller) then setPlayerVoiceBroadcastTo(call.caller, nil) end
        if isElement(call.receiver) then setPlayerVoiceBroadcastTo(call.receiver, nil) end
    end

    if isElement(player) then
        triggerClientEvent(player, "mzansi:phone:callEnded", player)
        Mzansi.Util.sendNotification(player, "Call ended.", "info")
    end
    if isElement(other) then
        triggerClientEvent(other, "mzansi:phone:callEnded", other)
        Mzansi.Util.sendNotification(other, "Call disconnected.", "info")
    end
end

-- Conference / Group Voice Call Engine
function Mzansi.Phone.createOrAddToConference(hostPlayer, targetNumber)
    local char = getChar(hostPlayer)
    if not char then return end

    local cleanTarget = string.gsub(tostring(targetNumber or ""), "%s+", "")
    local targetPlayer = Mzansi.Phone.getPlayerByNumber(targetNumber)
    if not targetPlayer or targetPlayer == hostPlayer then
        Mzansi.Util.sendNotification(hostPlayer, "Citizen unavailable for conference call.", "warning")
        return
    end

    local groupId = Mzansi.Phone._playerGroup[hostPlayer]
    if not groupId then
        -- Convert 1-on-1 call or create new conference room
        groupId = "CONF_" .. tostring(getTickCount()) .. "_" .. tostring(math.random(100, 999))
        local group = {
            id = groupId,
            host = hostPlayer,
            members = { [hostPlayer] = true },
            numbers = { [hostPlayer] = Mzansi.Phone.getNumber(hostPlayer) }
        }

        local existingCall = Mzansi.Phone._activeCalls[hostPlayer]
        if existingCall and existingCall.status == "connected" then
            local partner = (existingCall.caller == hostPlayer) and existingCall.receiver or existingCall.caller
            if isElement(partner) then
                group.members[partner] = true
                group.numbers[partner] = Mzansi.Phone.getNumber(partner)
                Mzansi.Phone._playerGroup[partner] = groupId
                Mzansi.Phone._activeCalls[partner] = nil
            end
            Mzansi.Phone._activeCalls[hostPlayer] = nil
        end

        Mzansi.Phone._groupCalls[groupId] = group
        Mzansi.Phone._playerGroup[hostPlayer] = groupId
    end

    local group = Mzansi.Phone._groupCalls[groupId]
    if not group then return end

    group.members[targetPlayer] = true
    group.numbers[targetPlayer] = Mzansi.Phone.getNumber(targetPlayer)
    Mzansi.Phone._playerGroup[targetPlayer] = groupId

    -- Broadcast voice across all conference members
    local memberList = {}
    for m, _ in pairs(group.members) do
        if isElement(m) then table.insert(memberList, m) end
    end

    for _, m in ipairs(memberList) do
        if setPlayerVoiceBroadcastTo then
            setPlayerVoiceBroadcastTo(m, memberList)
        end
        triggerClientEvent(m, "mzansi:phone:conferenceConnected", m, groupId, #memberList)
        Mzansi.Util.sendNotification(m, "Conference Call: " .. #memberList .. " members connected! Voice routing active.", "info")
    end
end

function Mzansi.Phone.leaveGroupCall(player)
    local groupId = Mzansi.Phone._playerGroup[player]
    if not groupId then return end

    local group = Mzansi.Phone._groupCalls[groupId]
    Mzansi.Phone._playerGroup[player] = nil

    if setPlayerVoiceBroadcastTo and isElement(player) then
        setPlayerVoiceBroadcastTo(player, nil)
    end
    triggerClientEvent(player, "mzansi:phone:callEnded", player)
    Mzansi.Util.sendNotification(player, "Left conference call.", "info")

    if group then
        group.members[player] = nil
        group.numbers[player] = nil

        local remaining = {}
        for m, _ in pairs(group.members) do
            if isElement(m) then table.insert(remaining, m) end
        end

        if #remaining <= 1 then
            for _, m in ipairs(remaining) do
                Mzansi.Phone._playerGroup[m] = nil
                if setPlayerVoiceBroadcastTo then setPlayerVoiceBroadcastTo(m, nil) end
                triggerClientEvent(m, "mzansi:phone:callEnded", m)
                Mzansi.Util.sendNotification(m, "Conference call ended.", "info")
            end
            Mzansi.Phone._groupCalls[groupId] = nil
        else
            for _, m in ipairs(remaining) do
                if setPlayerVoiceBroadcastTo then setPlayerVoiceBroadcastTo(m, remaining) end
                triggerClientEvent(m, "mzansi:phone:conferenceConnected", m, groupId, #remaining)
            end
        end
    end
end

-- 2. SMS Messaging System
function Mzansi.Phone.sendSMS(player, targetNumber, message)
    local char = getChar(player)
    if not char then return end

    if not message or string.len(string.gsub(message, "%s+", "")) == 0 then
        Mzansi.Util.sendNotification(player, "Cannot send an empty SMS message!", "error")
        return
    end

    local senderNumber = Mzansi.Phone.getNumber(player)
    local cleanTarget = string.gsub(tostring(targetNumber or ""), "%s+", "")

    -- Save to DB
    if Mzansi.Phone._db then
        dbExec(Mzansi.Phone._db, "INSERT INTO phone_messages (sender_id, sender_number, receiver_number, message) VALUES (?, ?, ?, ?)",
            char.id, senderNumber, targetNumber, message)
    end

    local targetPlayer = Mzansi.Phone.getPlayerByNumber(targetNumber)
    if targetPlayer then
        triggerClientEvent(targetPlayer, "mzansi:phone:newSMS", targetPlayer, senderNumber, message)
        Mzansi.Util.sendNotification(targetPlayer, "📩 New SMS from " .. senderNumber .. ": " .. message, "info")
    end

    Mzansi.Util.sendNotification(player, "SMS sent to " .. targetNumber .. "!", "success")
    triggerClientEvent(player, "mzansi:phone:smsSent", player, targetNumber, message)
end

function sendSMS(player, targetNumber, message)
    return Mzansi.Phone.sendSMS(player, targetNumber, message)
end

-- Export wrapper: phoneCall (named to avoid shadowing MTA builtin call())
function phoneCall(player, targetNumber)
    return Mzansi.Phone.call(player, targetNumber)
end

-- 3. Contacts System
function Mzansi.Phone.addContact(player, name, number)
    local char = getChar(player)
    if not char or not Mzansi.Phone._db then return end

    if not name or string.len(name) == 0 or not number or string.len(number) == 0 then
        Mzansi.Util.sendNotification(player, "Contact name and number are required!", "error")
        return
    end

    dbExec(Mzansi.Phone._db, "INSERT INTO phone_contacts (owner_id, name, number) VALUES (?, ?, ?)",
        char.id, name, number)
    Mzansi.Util.sendNotification(player, "Saved contact: " .. name .. " (" .. number .. ")", "success")
    Mzansi.Phone.requestContacts(player)
end

function Mzansi.Phone.deleteContact(player, contactId)
    local char = getChar(player)
    if not char or not Mzansi.Phone._db then return end

    dbExec(Mzansi.Phone._db, "DELETE FROM phone_contacts WHERE id = ? AND owner_id = ?", contactId, char.id)
    Mzansi.Util.sendNotification(player, "Contact deleted.", "info")
    Mzansi.Phone.requestContacts(player)
end

function Mzansi.Phone.requestContacts(player)
    local char = getChar(player)
    if not char or not Mzansi.Phone._db then return end

    dbQuery(function(qh)
        local result = dbPoll(qh, 0) or {}
        triggerClientEvent(player, "mzansi:phone:contactsList", player, result)
    end, Mzansi.Phone._db, "SELECT * FROM phone_contacts WHERE owner_id = ? ORDER BY name ASC", char.id)
end

function Mzansi.Phone.requestMessages(player)
    local char = getChar(player)
    if not char or not Mzansi.Phone._db then return end

    local myNumber = Mzansi.Phone.getNumber(player)
    dbQuery(function(qh)
        local result = dbPoll(qh, 0) or {}
        triggerClientEvent(player, "mzansi:phone:messagesList", player, result)
    end, Mzansi.Phone._db, "SELECT * FROM phone_messages WHERE sender_number = ? OR receiver_number = ? ORDER BY sent_at DESC LIMIT 30", myNumber, myNumber)
end

-- 4. Mobile Banking (Capitec / Standard Bank app)
function Mzansi.Phone.bankTransfer(player, targetNameOrId, amount)
    local char = getChar(player)
    if not char then return end

    amount = tonumber(amount) or 0
    if amount <= 0 then
        Mzansi.Util.sendNotification(player, "Invalid transfer amount!", "error")
        return
    end

    local bankBalance = tonumber(char.bank) or 0
    if bankBalance < amount then
        Mzansi.Util.sendNotification(player, "Insufficient bank funds! Balance: " .. Mzansi.Util.formatMoney(bankBalance), "error")
        return
    end

    -- Find Target Player
    local target = nil
    if tonumber(targetNameOrId) then
        target = getPlayerFromName(tostring(targetNameOrId)) or Mzansi.Phone.getPlayerByNumber(targetNameOrId)
    else
        for _, p in ipairs(getElementsByType("player")) do
            local tc = getChar(p)
            if tc then
                local fn = tc.first_name or tc.firstName or ""
                local ln = tc.last_name or tc.lastName or ""
                local fullName = (fn .. "_" .. ln):lower()
                local spaceName = (fn .. " " .. ln):lower()
                if fullName:find(targetNameOrId:lower(), 1, true) or spaceName:find(targetNameOrId:lower(), 1, true) then
                    target = p
                    break
                end
            end
        end
    end

    if not target or target == player then
        Mzansi.Util.sendNotification(player, "Recipient citizen not found or invalid!", "error")
        return
    end

    -- Transfer Funds
    exports.mzansi_core:removeBank(player, amount)
    exports.mzansi_core:addBank(target, amount)

    local targetChar = getChar(target)
    local tfn = targetChar and (targetChar.first_name or targetChar.firstName) or ""
    local tln = targetChar and (targetChar.last_name or targetChar.lastName) or ""
    local targetName = (#tfn > 0 and #tln > 0) and (tfn .. " " .. tln) or getPlayerName(target)

    local sfn = char.first_name or char.firstName or ""
    local sln = char.last_name or char.lastName or ""
    local senderName = (#sfn > 0 and #sln > 0) and (sfn .. " " .. sln) or getPlayerName(player)

    Mzansi.Util.sendNotification(player, "Successfully transferred " .. Mzansi.Util.formatMoney(amount) .. " to " .. targetName .. "!", "success")
    Mzansi.Util.sendNotification(target, "Received " .. Mzansi.Util.formatMoney(amount) .. " EFT transfer from " .. senderName .. "!", "success")

    -- Refresh client view
    triggerClientEvent(player, "mzansi:phone:updateBank", player, (bankBalance - amount))
end

-- 5. Emergency 911 Call
function Mzansi.Phone.callEmergency(player, serviceName)
    local x, y, z = getElementPosition(player)
    local zone = getZoneName(x, y, z)
    local char = getChar(player)
    local fn = char and (char.first_name or char.firstName) or ""
    local ln = char and (char.last_name or char.lastName) or ""
    local name = (#fn > 0 and #ln > 0) and (fn .. " " .. ln) or getPlayerName(player)

    outputChatBox("═══════════════════════════════════════════════════════", root, 255, 60, 60)
    outputChatBox("[EMERGENCY 911] Caller: " .. name .. " • Service: " .. serviceName, root, 255, 80, 80)
    outputChatBox("[Location] " .. zone .. " • Immediate assistance requested!", root, 240, 240, 240)
    outputChatBox("═══════════════════════════════════════════════════════", root, 255, 60, 60)

    Mzansi.Util.sendNotification(player, "Emergency beacon dispatched to " .. serviceName .. " at " .. zone .. "!", "success")
    triggerClientEvent(player, "mzansi:phone:callEnded", player)
end

-- 6. Hail Taxi
function Mzansi.Phone.hailTaxi(player)
    local x, y, z = getElementPosition(player)
    local zone = getZoneName(x, y, z)
    outputChatBox("[TAXI DISPATCH] 🚕 New passenger pickup request at " .. zone .. "!", root, 255, 200, 0)
    Mzansi.Util.sendNotification(player, "Taxi dispatched to " .. zone .. "! A driver has been notified.", "info")
    triggerClientEvent(player, "mzansi:phone:callEnded", player)
end

-- Remote Event Listeners
addEvent("mzansi:phone:call", true)
addEventHandler("mzansi:phone:call", root, function(targetNumber)
    Mzansi.Phone.call(client or source, targetNumber)
end)

addEvent("mzansi:phone:answer", true)
addEventHandler("mzansi:phone:answer", root, function()
    Mzansi.Phone.answer(client or source)
end)

addEvent("mzansi:phone:hangup", true)
addEventHandler("mzansi:phone:hangup", root, function()
    Mzansi.Phone.hangup(client or source)
end)

addEvent("mzansi:phone:sms", true)
addEventHandler("mzansi:phone:sms", root, function(targetNumber, message)
    Mzansi.Phone.sendSMS(client or source, targetNumber, message)
end)

addEvent("mzansi:phone:addContact", true)
addEventHandler("mzansi:phone:addContact", root, function(name, number)
    Mzansi.Phone.addContact(client or source, name, number)
end)

addEvent("mzansi:phone:deleteContact", true)
addEventHandler("mzansi:phone:deleteContact", root, function(contactId)
    Mzansi.Phone.deleteContact(client or source, contactId)
end)

addEvent("mzansi:phone:getContacts", true)
addEventHandler("mzansi:phone:getContacts", root, function()
    Mzansi.Phone.requestContacts(client or source)
end)

addEvent("mzansi:phone:getMessages", true)
addEventHandler("mzansi:phone:getMessages", root, function()
    Mzansi.Phone.requestMessages(client or source)
end)

addEvent("mzansi:phone:bankTransfer", true)
addEventHandler("mzansi:phone:bankTransfer", root, function(target, amount)
    Mzansi.Phone.bankTransfer(client or source, target, amount)
end)

addEvent("mzansi:phone:requestData", true)
addEventHandler("mzansi:phone:requestData", root, function()
    local player = client or source
    local char = getChar(player)
    local myNum = Mzansi.Phone.getNumber(player)
    local cash = char and char.cash or 0
    local bank = char and char.bank or 0
    triggerClientEvent(player, "mzansi:phone:receiveData", player, myNum, cash, bank)
end)

-- ============================================================
-- MODERN PHONE FEATURES - GTA 5/6 Style
-- ============================================================

-- GPS & Location Services
Mzansi.Phone._locationCache = {}

function Mzansi.Phone.requestGPS(player)
    if not isElement(player) then return end
    local x, y, z = getElementPosition(player)
    local zone = getZoneName(x, y, z)
    local street = getZoneName(x, y, z, true)
    local dim = getElementDimension(player)
    local int = getElementInterior(player)

    triggerClientEvent(player, "mzansi:phone:gpsData", player, {
        x = x, y = y, z = z,
        zone = zone,
        street = street,
        dimension = dim,
        interior = int,
        timestamp = getRealTime().timestamp
    })
end

function Mzansi.Phone.shareLocation(player, targetNumber)
    local char = getChar(player)
    if not char then return end

    local targetPlayer = Mzansi.Phone.getPlayerByNumber(targetNumber)
    if not targetPlayer then
        Mzansi.Util.sendNotification(player, "Cannot share location - recipient unavailable.", "error")
        return
    end

    local x, y, z = getElementPosition(player)
    local zone = getZoneName(x, y, z)

    triggerClientEvent(targetPlayer, "mzansi:phone:locationShared", targetPlayer, {
        sender = Mzansi.Phone.getNumber(player),
        senderName = (char.first_name or "") .. " " .. (char.last_name or ""),
        x = x, y = y, z = z,
        zone = zone,
        timestamp = getRealTime().timestamp
    })

    Mzansi.Util.sendNotification(player, "Location shared with " .. targetNumber, "success")
end

-- Social Media System (LifeBlog, Twatter, etc.)
Mzansi.Phone._socialPosts = {}
Mzansi.Phone._socialCache = {}

function Mzansi.Phone.createSocialPost(player, appId, content, mediaType, mediaData)
    local char = getChar(player)
    if not char then return end

    local postId = "POST_" .. getTickCount() .. "_" .. math.random(1000, 9999)
    local authorName = (char.first_name or "") .. " " .. (char.last_name or "")
    local authorHandle = "@" .. (char.first_name or "user"):lower() .. (char.last_name or ""):lower()

    local post = {
        id = postId,
        appId = appId,
        authorId = char.id,
        authorName = authorName,
        authorHandle = authorHandle,
        content = content,
        mediaType = mediaType, -- "image", "video", "location", "voice"
        mediaData = mediaData,
        likes = 0,
        retweets = 0,
        replies = 0,
        timestamp = getRealTime().timestamp,
        likedBy = {},
        location = { getElementPosition(player) }
    }

    Mzansi.Phone._socialPosts[postId] = post

    -- Cache for feed
    if not Mzansi.Phone._socialCache[appId] then
        Mzansi.Phone._socialCache[appId] = {}
    end
    table.insert(Mzansi.Phone._socialCache[appId], 1, postId)
    -- Keep only last 100 posts per app
    while #Mzansi.Phone._socialCache[appId] > 100 do
        table.remove(Mzansi.Phone._socialCache[appId])
    end

    triggerClientEvent(player, "mzansi:phone:postCreated", player, post)
    Mzansi.Util.sendNotification(player, "Posted to " .. appId .. "!", "success")

    -- Broadcast to nearby players (local feed)
    for _, p in ipairs(getElementsByType("player")) do
        if p ~= player then
            local px, py, pz = getElementPosition(p)
            local dist = getDistanceBetweenPoints3D(px, py, pz, post.location[1], post.location[2], post.location[3])
            if dist < 500 then -- Local feed radius
                triggerClientEvent(p, "mzansi:phone:nearbyPost", p, post)
            end
        end
    end
end

function Mzansi.Phone.getSocialFeed(player, appId, offset, limit)
    offset = offset or 0
    limit = limit or 20

    local cache = Mzansi.Phone._socialCache[appId] or {}
    local posts = {}

    for i = offset + 1, math.min(offset + limit, #cache) do
        local postId = cache[i]
        local post = Mzansi.Phone._socialPosts[postId]
        if post then
            table.insert(posts, post)
        end
    end

    triggerClientEvent(player, "mzansi:phone:socialFeed", player, appId, posts, offset)
end

function Mzansi.Phone.likePost(player, postId)
    local char = getChar(player)
    if not char then return end

    local post = Mzansi.Phone._socialPosts[postId]
    if not post then return end

    local playerId = char.id
    if post.likedBy[playerId] then
        -- Unlike
        post.likedBy[playerId] = nil
        post.likes = post.likes - 1
        Mzansi.Util.sendNotification(player, "Post unliked.", "info")
    else
        -- Like
        post.likedBy[playerId] = true
        post.likes = post.likes + 1
        Mzansi.Util.sendNotification(player, "Post liked!", "success")
    end

    -- Update all viewers
    for _, p in ipairs(getElementsByType("player")) do
        triggerClientEvent(p, "mzansi:phone:postUpdated", p, postId, { likes = post.likes })
    end
end

-- Camera & Gallery System
Mzansi.Phone._playerPhotos = {}

function Mzansi.Phone.takePhoto(player, photoData)
    local char = getChar(player)
    if not char then return end

    local photoId = "PHOTO_" .. getTickCount() .. "_" .. math.random(1000, 9999)
    local x, y, z = getElementPosition(player)
    local zone = getZoneName(x, y, z)

    local photo = {
        id = photoId,
        ownerId = char.id,
        data = photoData, -- base64 or reference
        location = { x = x, y = y, z = z, zone = zone },
        timestamp = getRealTime().timestamp,
        filters = {},
        isPublic = false
    }

    if not Mzansi.Phone._playerPhotos[char.id] then
        Mzansi.Phone._playerPhotos[char.id] = {}
    end
    table.insert(Mzansi.Phone._playerPhotos[char.id], 1, photo)

    triggerClientEvent(player, "mzansi:photoTaken", player, photo)
    Mzansi.Util.sendNotification(player, "Photo saved to Gallery!", "success")
end

function Mzansi.Phone.getGallery(player)
    local char = getChar(player)
    if not char then return end

    local photos = Mzansi.Phone._playerPhotos[char.id] or {}
    triggerClientEvent(player, "mzansi:phone:gallery", player, photos)
end

-- App Store / App Management
function Mzansi.Phone.getAppStore(player)
    local apps = Mzansi.Phone.Apps.getAllApps(player)
    triggerClientEvent(player, "mzansi:phone:appStore", player, apps)
end

function Mzansi.Phone.installApp(player, appId)
    local char = getChar(player)
    if not char then return end

    local app = Mzansi.Phone.Apps.getAppById(appId)
    if not app then
        Mzansi.Util.sendNotification(player, "App not found!", "error")
        return
    end

    -- Check if already installed (track via element data)
    local installed = getElementData(player, "mzansi:installedApps") or {}
    if installed[appId] then
        Mzansi.Util.sendNotification(player, "App already installed!", "info")
        return
    end

    installed[appId] = { installedAt = getRealTime().timestamp, version = "1.0.0" }
    setElementData(player, "mzansi:installedApps", installed)

    triggerClientEvent(player, "mzansi:phone:appInstalled", player, app)
    Mzansi.Util.sendNotification(player, app.name .. " installed!", "success")
end

function Mzansi.Phone.uninstallApp(player, appId)
    local installed = getElementData(player, "mzansi:installedApps") or {}
    if not installed[appId] then
        Mzansi.Util.sendNotification(player, "App not installed!", "error")
        return
    end

    -- Don't allow uninstalling system apps
    local app = Mzansi.Phone.Apps.getAppById(appId)
    if app and app.system then
        Mzansi.Util.sendNotification(player, "Cannot uninstall system app!", "error")
        return
    end

    installed[appId] = nil
    setElementData(player, "mzansi:installedApps", installed)

    triggerClientEvent(player, "mzansi:phone:appUninstalled", player, appId)
    Mzansi.Util.sendNotification(player, "App uninstalled.", "info")
end

-- Voice Messages
function Mzansi.Phone.sendVoiceMessage(player, targetNumber, voiceData, duration)
    local char = getChar(player)
    if not char then return end

    local targetPlayer = Mzansi.Phone.getPlayerByNumber(targetNumber)
    if not targetPlayer then
        Mzansi.Util.sendNotification(player, "Recipient unavailable!", "error")
        return
    end

    triggerClientEvent(targetPlayer, "mzansi:phone:voiceMessage", targetPlayer, {
        from = Mzansi.Phone.getNumber(player),
        fromName = (char.first_name or "") .. " " .. (char.last_name or ""),
        data = voiceData,
        duration = duration,
        timestamp = getRealTime().timestamp
    })

    Mzansi.Util.sendNotification(player, "Voice message sent!", "success")
end

-- Weather App Integration
function Mzansi.Phone.getWeather(player)
    local x, y, z = getElementPosition(player)
    local zone = getZoneName(x, y, z)

    -- Simulated weather based on time and location
    local hour = getRealTime().hour
    local weatherTypes = { "Sunny", "Partly Cloudy", "Cloudy", "Light Rain", "Heavy Rain", "Thunderstorm", "Fog" }
    local weather = weatherTypes[math.random(1, #weatherTypes)]
    local temp = math.random(15, 35)
    local humidity = math.random(30, 90)
    local wind = math.random(0, 30)

    -- Night time cooler
    if hour >= 20 or hour <= 6 then
        temp = temp - math.random(5, 10)
    end

    triggerClientEvent(player, "mzansi:phone:weather", player, {
        location = zone,
        weather = weather,
        temperature = temp,
        humidity = humidity,
        windSpeed = wind,
        forecast = {
            { day = "Today", high = temp, low = temp - 5, weather = weather },
            { day = "Tomorrow", high = temp + math.random(-3, 3), low = temp - 8, weather = weatherTypes[math.random(1, #weatherTypes)] },
            { day = "Day 3", high = temp + math.random(-5, 5), low = temp - 10, weather = weatherTypes[math.random(1, #weatherTypes)] },
        }
    })
end

-- Calculator App
function Mzansi.Phone.calculate(player, expression)
    -- Simple safe evaluation (in real implementation, use a proper expression parser)
    local result = "Error"
    -- For safety, just return a mock result
    triggerClientEvent(player, "mzansi:phone:calcResult", player, expression, result)
end

-- Flashlight Toggle
Mzansi.Phone._flashlightState = {}

function Mzansi.Phone.toggleFlashlight(player)
    local state = not (Mzansi.Phone._flashlightState[player] or false)
    Mzansi.Phone._flashlightState[player] = state

    -- Attach a light to player
    if state then
        local light = createMarker(0, 0, 0, "corona", 1.0, 255, 255, 200, 255)
        attachElements(light, player, 0, 1, 1)
        setElementData(player, "mzansi:flashlight", light)
        Mzansi.Util.sendNotification(player, "Flashlight ON", "success")
    else
        local light = getElementData(player, "mzansi:flashlight")
        if isElement(light) then destroyElement(light) end
        removeElementData(player, "mzansi:flashlight")
        Mzansi.Util.sendNotification(player, "Flashlight OFF", "info")
    end

    triggerClientEvent(player, "mzansi:phone:flashlightToggled", player, state)
end

-- Compass
function Mzansi.Phone.getCompass(player)
    if not isElement(player) then return end
    local rot = getPedRotation(player)
    local heading = ""
    if rot >= 337.5 or rot < 22.5 then heading = "N"
    elseif rot < 67.5 then heading = "NE"
    elseif rot < 112.5 then heading = "E"
    elseif rot < 157.5 then heading = "SE"
    elseif rot < 202.5 then heading = "S"
    elseif rot < 247.5 then heading = "SW"
    elseif rot < 292.5 then heading = "W"
    else heading = "NW" end

    triggerClientEvent(player, "mzansi:phone:compass", player, { rotation = rot, heading = heading })
end

-- Notes App
Mzansi.Phone._playerNotes = {}

function Mzansi.Phone.saveNote(player, noteId, title, content)
    local char = getChar(player)
    if not char then return end

    if not Mzansi.Phone._playerNotes[char.id] then
        Mzansi.Phone._playerNotes[char.id] = {}
    end

    if not noteId then
        noteId = "NOTE_" .. getTickCount()
    end

    Mzansi.Phone._playerNotes[char.id][noteId] = {
        id = noteId,
        title = title or "Untitled",
        content = content or "",
        created = getRealTime().timestamp,
        modified = getRealTime().timestamp
    }

    triggerClientEvent(player, "mzansi:phone:noteSaved", player, Mzansi.Phone._playerNotes[char.id][noteId])
    Mzansi.Util.sendNotification(player, "Note saved!", "success")
end

function Mzansi.Phone.getNotes(player)
    local char = getChar(player)
    if not char then return end

    local notes = Mzansi.Phone._playerNotes[char.id] or {}
    triggerClientEvent(player, "mzansi:phone:notesList", player, notes)
end

function Mzansi.Phone.deleteNote(player, noteId)
    local char = getChar(player)
    if not char or not Mzansi.Phone._playerNotes[char.id] then return end

    Mzansi.Phone._playerNotes[char.id][noteId] = nil
    triggerClientEvent(player, "mzansi:phone:noteDeleted", player, noteId)
    Mzansi.Util.sendNotification(player, "Note deleted.", "info")
end

-- Space/Deep Sea Special Apps
function Mzansi.Phone.getSpaceData(player)
    if getElementDimension(player) ~= 40 then
        Mzansi.Util.sendNotification(player, "Space apps only available in orbit!", "warning")
        return
    end

    triggerClientEvent(player, "mzansi:phone:spaceData", player, {
        altitude = getElementPosition(player) and select(3, getElementPosition(player)) or 500,
        gravity = 0.001,
        orbitalVelocity = 7800, -- m/s
        issPosition = { x = math.random(-1000, 1000), y = math.random(-1000, 1000), z = 408000 },
        moonPhase = math.random(1, 8),
        solarFlareActivity = math.random(1, 10),
        suitIntegrity = 100,
        oxygenLevel = 100
    })
end

function Mzansi.Phone.getDeepSeaData(player)
    if getElementDimension(player) ~= 50 then
        Mzansi.Util.sendNotification(player, "Deep sea apps only available underwater!", "warning")
        return
    end

    local x, y, z = getElementPosition(player)
    local depth = math.abs(z)

    triggerClientEvent(player, "mzansi:phone:deepSeaData", player, {
        depth = depth,
        pressure = depth * 0.1, -- bar
        temperature = math.max(2, 25 - (depth / 500)),
        salinity = 35,
        currentSpeed = math.random(0, 5),
        sonarContacts = {
            { type = "thermal_vent", distance = math.random(100, 1000), bearing = math.random(0, 360) },
            { type = "marine_life", distance = math.random(50, 500), bearing = math.random(0, 360) },
            { type = "wreckage", distance = math.random(200, 2000), bearing = math.random(0, 360) }
        },
        hullIntegrity = 100,
        oxygenTanks = 100,
        batteryLevel = 100
    })
end

-- Event Handlers for Modern Features
addEvent("mzansi:phone:requestGPS", true)
addEventHandler("mzansi:phone:requestGPS", root, function()
    Mzansi.Phone.requestGPS(client or source)
end)

addEvent("mzansi:phone:shareLocation", true)
addEventHandler("mzansi:phone:shareLocation", root, function(targetNumber)
    Mzansi.Phone.shareLocation(client or source, targetNumber)
end)

addEvent("mzansi:phone:createPost", true)
addEventHandler("mzansi:phone:createPost", root, function(appId, content, mediaType, mediaData)
    Mzansi.Phone.createSocialPost(client or source, appId, content, mediaType, mediaData)
end)

addEvent("mzansi:phone:getFeed", true)
addEventHandler("mzansi:phone:getFeed", root, function(appId, offset, limit)
    Mzansi.Phone.getSocialFeed(client or source, appId, offset, limit)
end)

addEvent("mzansi:phone:likePost", true)
addEventHandler("mzansi:phone:likePost", root, function(postId)
    Mzansi.Phone.likePost(client or source, postId)
end)

addEvent("mzansi:phone:takePhoto", true)
addEventHandler("mzansi:phone:takePhoto", root, function(photoData)
    Mzansi.Phone.takePhoto(client or source, photoData)
end)

addEvent("mzansi:phone:getGallery", true)
addEventHandler("mzansi:phone:getGallery", root, function()
    Mzansi.Phone.getGallery(client or source)
end)

addEvent("mzansi:phone:getAppStore", true)
addEventHandler("mzansi:phone:getAppStore", root, function()
    Mzansi.Phone.getAppStore(client or source)
end)

addEvent("mzansi:phone:installApp", true)
addEventHandler("mzansi:phone:installApp", root, function(appId)
    Mzansi.Phone.installApp(client or source, appId)
end)

addEvent("mzansi:phone:uninstallApp", true)
addEventHandler("mzansi:phone:uninstallApp", root, function(appId)
    Mzansi.Phone.uninstallApp(client or source, appId)
end)

addEvent("mzansi:phone:sendVoice", true)
addEventHandler("mzansi:phone:sendVoice", root, function(targetNumber, voiceData, duration)
    Mzansi.Phone.sendVoiceMessage(client or source, targetNumber, voiceData, duration)
end)

addEvent("mzansi:phone:getWeather", true)
addEventHandler("mzansi:phone:getWeather", root, function()
    Mzansi.Phone.getWeather(client or source)
end)

addEvent("mzansi:phone:calculate", true)
addEventHandler("mzansi:phone:calculate", root, function(expression)
    Mzansi.Phone.calculate(client or source, expression)
end)

addEvent("mzansi:phone:toggleFlashlight", true)
addEventHandler("mzansi:phone:toggleFlashlight", root, function()
    Mzansi.Phone.toggleFlashlight(client or source)
end)

addEvent("mzansi:phone:getCompass", true)
addEventHandler("mzansi:phone:getCompass", root, function()
    Mzansi.Phone.getCompass(client or source)
end)

addEvent("mzansi:phone:saveNote", true)
addEventHandler("mzansi:phone:saveNote", root, function(noteId, title, content)
    Mzansi.Phone.saveNote(client or source, noteId, title, content)
end)

addEvent("mzansi:phone:getNotes", true)
addEventHandler("mzansi:phone:getNotes", root, function()
    Mzansi.Phone.getNotes(client or source)
end)

addEvent("mzansi:phone:deleteNote", true)
addEventHandler("mzansi:phone:deleteNote", root, function(noteId)
    Mzansi.Phone.deleteNote(client or source, noteId)
end)

addEvent("mzansi:phone:getSpaceData", true)
addEventHandler("mzansi:phone:getSpaceData", root, function()
    Mzansi.Phone.getSpaceData(client or source)
end)

addEvent("mzansi:phone:getDeepSeaData", true)
addEventHandler("mzansi:phone:getDeepSeaData", root, function()
    Mzansi.Phone.getDeepSeaData(client or source)
end)

-- Clean up flashlight on quit
addEventHandler("onPlayerQuit", root, function()
    local light = getElementData(source, "mzansi:flashlight")
    if isElement(light) then destroyElement(light) end
    Mzansi.Phone._flashlightState[source] = nil
    Mzansi.Phone.hangup(source)
end)

addEvent("mzansi:phone:conference", true)
addEventHandler("mzansi:phone:conference", root, function(targetNumber)
    Mzansi.Phone.createOrAddToConference(client or source, targetNumber)
end)

addEvent("mzansi:phone:leaveConference", true)
addEventHandler("mzansi:phone:leaveConference", root, function()
    Mzansi.Phone.leaveGroupCall(client or source)
end)

addCommandHandler("conference", function(player, cmd, targetNum)
    if targetNum then
        Mzansi.Phone.createOrAddToConference(player, targetNum)
    else
        outputChatBox("[Mzansi-Phone] Syntax: /conference <mobileNumber>", player, 200, 170, 50)
    end
end)

-- Clean up on disconnect
addEventHandler("onPlayerQuit", root, function()
    Mzansi.Phone.hangup(source)
end)

addEventHandler("onResourceStart", resourceRoot, function()
    Mzansi.Phone.initDB()
end)
