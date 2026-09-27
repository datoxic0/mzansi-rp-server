--[[
    Mzansi Roleplay - Ngamla (GQonqa) VIP & Monetization Server Subsystem
    
    Architectural Scope:
    1. VIP Persistence & Database Engine.
    2. Executive Privileges, Multipliers & Daily Grants.
    3. Developer / Creator Sovereign Cheat & Godmode Interface (/gqonqa & "gqonqa" keystrokes).
    4. Luxury VIP Fleet Management & Vehicle Spawner.
    5. Angel: Ngamla VIP & Creator Registry Governor.
]]

Mzansi = Mzansi or {}
Mzansi.VIP = Mzansi.VIP or {}

local _db = nil
local _vipCache = {} -- [player] = { tier = 1..3, expiry = timestamp, points = 0, lastDaily = "YYYY-MM-DD" }
local _vipVehicles = {} -- [player] = vehicleElement
local _angelGovernorTimer = nil

--------------------------------------------------------------------------------
-- 1. DATABASE PERSISTENCE & INITIALIZATION
--------------------------------------------------------------------------------

local function initDatabase()
    -- Connect to MySQL/MariaDB database
    _db = dbConnect("mysql", "dbname=mzansi_rp;host=127.0.0.1;port=3306;charset=utf8", "root", "", "share=1")
    if not _db then
        outputDebugString("[Mzansi-VIP] WARNING: Could not connect to MySQL! Falling back to internal SQLite.", 2)
        _db = dbConnect("sqlite", "vip.db")
    else
        outputDebugString("[Mzansi-VIP] Connected to MariaDB database for VIP persistence.", 3)
    end

    if _db then
        local query = [[
            CREATE TABLE IF NOT EXISTS mzansi_vip (
                id INT AUTO_INCREMENT PRIMARY KEY,
                account_id INT NOT NULL,
                tier INT DEFAULT 1,
                points INT DEFAULT 0,
                expiry TIMESTAMP NULL,
                last_daily DATE NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                UNIQUE KEY unique_account (account_id)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
        ]]
        dbExec(_db, query)
        outputDebugString("[Mzansi-VIP] Database table 'mzansi_vip' verified.", 3)
    end
end

--------------------------------------------------------------------------------
-- 2. VIP CACHE & LIFECYCLE MANAGEMENT
--------------------------------------------------------------------------------

function Mzansi.VIP.loadPlayerVIP(player)
    if not isElement(player) then return end
    local account = getPlayerAccount(player)
    local serial = getPlayerSerial(player)

    -- Auto-check Creator Serial
    if Mzansi.VIP.Config.ownerSerials[serial] then
        _vipCache[player] = {
            tier = 3,
            points = 999999,
            expiry = nil,
            lastDaily = nil,
            isCreator = true
        }
        setElementData(player, "mzansi:vip", 3)
        setElementData(player, "mzansi:creator", true)
        outputDebugString("[Mzansi-VIP] Creator identified via serial for " .. getPlayerName(player) .. " (Tier 3 Active)", 3)
        return
    end

    -- If normal player, query database
    local accountId = getElementData(player, "mzansi:accountId")
    if accountId and _db then
        dbQuery(function(qh)
            local result = dbPoll(qh, 0)
            if result and #result > 0 then
                local row = result[1]
                _vipCache[player] = {
                    tier = tonumber(row.tier) or 1,
                    points = tonumber(row.points) or 0,
                    expiry = row.expiry,
                    lastDaily = row.last_daily,
                    isCreator = false
                }
                setElementData(player, "mzansi:vip", tonumber(row.tier) or 1)
                outputDebugString("[Mzansi-VIP] Loaded VIP Tier " .. tostring(row.tier) .. " for " .. getPlayerName(player), 3)
            end
        end, _db, "SELECT * FROM mzansi_vip WHERE account_id = ? LIMIT 1", accountId)
    end
end

function Mzansi.VIP.isPlayerVIP(player)
    if not isElement(player) then return false, 0 end
    local v = _vipCache[player]
    if v and v.tier and v.tier > 0 then
        return true, v.tier
    end
    return false, 0
end

function Mzansi.VIP.isPlayerCreator(player)
    if not isElement(player) then return false end
    local serial = getPlayerSerial(player)
    if Mzansi.VIP.Config.ownerSerials[serial] then
        return true
    end
    local accName = getAccountName(getPlayerAccount(player))
    if isObjectInACLGroup("user." .. accName, aclGetGroup("Admin")) then
        return true
    end
    local v = _vipCache[player]
    return (v and v.isCreator) or false
end

function Mzansi.VIP.setPlayerVIP(player, tier, durationDays)
    if not isElement(player) then return false end
    tier = tonumber(tier) or 1
    if tier < 1 then tier = 1 end
    if tier > 3 then tier = 3 end

    local accountId = getElementData(player, "mzansi:accountId")
    _vipCache[player] = _vipCache[player] or {}
    _vipCache[player].tier = tier

    setElementData(player, "mzansi:vip", tier)

    if accountId and _db then
        local q = "INSERT INTO mzansi_vip (account_id, tier) VALUES (?, ?) ON DUPLICATE KEY UPDATE tier = ?"
        dbExec(_db, q, accountId, tier, tier)
    end

    local cfg = Mzansi.VIP.Config.tiers[tier]
    outputChatBox("════════════════════════════════════════════════════", player, cfg.color[1], cfg.color[2], cfg.color[3])
    outputChatBox("⭐ Congratulations! You have been granted " .. cfg.name .. "! ⭐", player, 255, 255, 255)
    outputChatBox("Type /vip to view your exclusive perks, vehicles, and daily grant.", player, 200, 200, 200)
    outputChatBox("════════════════════════════════════════════════════", player, cfg.color[1], cfg.color[2], cfg.color[3])
    playSoundFrontEnd(player, 41)
    return true
end

--------------------------------------------------------------------------------
-- 3. DEVELOPER CREATOR CHEAT & GODMODE ENGINE ("GQONQA")
--------------------------------------------------------------------------------

local function activateGodmodeCheat(player)
    if not Mzansi.VIP.isPlayerCreator(player) then
        outputDebugString("[Mzansi-VIP] Unauthorized cheat activation attempt by " .. getPlayerName(player) .. " (" .. getPlayerSerial(player) .. ")", 2)
        return false
    end

    -- Toggle Godmode
    local currentGod = getElementData(player, "mzansi:godmode") or false
    local newGod = not currentGod
    setElementData(player, "mzansi:godmode", newGod)

    -- Full Health & Armor Refresh
    setElementHealth(player, 100)
    setPedArmor(player, 100)

    -- Set Lifetime Tier 3 Creator VIP
    _vipCache[player] = _vipCache[player] or {}
    _vipCache[player].tier = 3
    _vipCache[player].isCreator = true
    setElementData(player, "mzansi:vip", 3)
    setElementData(player, "mzansi:creator", true)

    -- Sound effect & UI Notice
    playSoundFrontEnd(player, 41)
    outputChatBox("════════════════════════════════════════════════════", player, 255, 215, 0)
    outputChatBox("👑 [GQONQA CHEAT ACTIVATED] Sovereign Creator Mode!", player, 255, 255, 255)
    outputChatBox("  ➤ Godmode (Invulnerability): " .. (newGod and "ON (Immune to all damage)" or "OFF"), player, 100, 240, 140)
    outputChatBox("  ➤ Health & Armor: 100% Full", player, 100, 200, 255)
    outputChatBox("  ➤ VIP Status: Ngamla Executive (Tier 3 Lifetime)", player, 255, 215, 0)
    outputChatBox("  ➤ Creator Commands: /gqonqa [veh | money | tp | fix | nitro]", player, 200, 170, 50)
    outputChatBox("════════════════════════════════════════════════════", player, 255, 215, 0)

    if exports.mzansi_core and exports.mzansi_core.sendNotification then
        exports.mzansi_core:sendNotification(player, "GQONQA Creator Mode: " .. (newGod and "GODMODE ON" or "GODMODE OFF"), "success")
    end
    return true
end

-- Keystroke cheat listener event from client
addEvent("mzansi:vip:activateCheat", true)
addEventHandler("mzansi:vip:activateCheat", root, function()
    local player = client or source
    activateGodmodeCheat(player)
end)

-- Command handler: /GQONQA or /gqonqa
addCommandHandler("gqonqa", function(player, cmd, action, arg1, arg2)
    if not Mzansi.VIP.isPlayerCreator(player) then
        outputChatBox("Access denied: You do not possess sovereign creator authorization.", player, 240, 60, 60)
        return
    end

    if not action then
        activateGodmodeCheat(player)
        return
    end

    action = string.lower(action)

    -- Spawning any vehicle
    if action == "veh" or action == "car" then
        local model = tonumber(arg1) or getVehicleModelFromName(tostring(arg1)) or 411
        local x, y, z = getElementPosition(player)
        local rx, ry, rz = getElementRotation(player)

        if isElement(_vipVehicles[player]) then
            destroyElement(_vipVehicles[player])
            _vipVehicles[player] = nil
        end

        local veh = createVehicle(model, x + 2.0, y + 2.0, z + 0.5, 0, 0, rz)
        if veh then
            _vipVehicles[player] = veh
            warpPedIntoVehicle(player, veh)
            setVehicleColor(veh, 255, 215, 0, 20, 20, 20)
            outputChatBox("[GQONQA] Spawned vehicle: " .. getVehicleName(veh) .. " (Model " .. model .. ")", player, 100, 235, 140)
            playSoundFrontEnd(player, 41)
        end

    -- Currency injection
    elseif action == "money" or action == "cash" then
        local amount = tonumber(arg1) or 100000
        if exports.mzansi_core and exports.mzansi_core.addCash then
            exports.mzansi_core:addCash(player, amount)
            outputChatBox("[GQONQA] Injected R" .. amount .. " cash directly to wallet.", player, 100, 235, 140)
            playSoundFrontEnd(player, 41)
        end

    -- Instant Teleportation across all provinces and dimensions
    elseif action == "tp" then
        local destKey = string.lower(arg1 or "")
        local target = Mzansi.VIP.Config.teleports[destKey]
        if target then
            fadeCamera(player, false, 0.5)
            setTimer(function()
                if isElement(player) then
                    local veh = getPedOccupiedVehicle(player)
                    local elem = veh or player
                    setElementPosition(elem, target.x, target.y, target.z)
                    setElementDimension(elem, target.dim or 0)
                    setElementInterior(elem, 0)
                    fadeCamera(player, true, 0.8)
                    outputChatBox("[GQONQA] Teleported to: " .. target.name .. " (Dim " .. (target.dim or 0) .. ")", player, 200, 170, 50)
                    playSoundFrontEnd(player, 41)
                end
            end, 600, 1)
        else
            outputChatBox("[GQONQA] Available destinations: ct, dbn, jhb, vc, lc, island, robben", player, 240, 200, 50)
        end

    -- Instant Repair
    elseif action == "fix" or action == "repair" then
        local veh = getPedOccupiedVehicle(player)
        if veh then
            fixVehicle(veh)
            setVehicleEngineState(veh, true)
            outputChatBox("[GQONQA] Vehicle fully repaired and detailed.", player, 100, 235, 140)
            playSoundFrontEnd(player, 41)
        else
            setElementHealth(player, 100)
            setPedArmor(player, 100)
            outputChatBox("[GQONQA] Health & Armor replenished.", player, 100, 235, 140)
        end

    -- Nitro Boost
    elseif action == "nitro" then
        local veh = getPedOccupiedVehicle(player)
        if veh then
            addVehicleUpgrade(veh, 1010) -- 10x Nitro
            outputChatBox("[GQONQA] 10x Nitro upgrade installed.", player, 100, 235, 140)
            playSoundFrontEnd(player, 41)
        end

    -- Grant VIP to citizen
    elseif action == "setvip" then
        local targetName = arg1
        local tier = tonumber(arg2) or 1
        local targetPlayer = targetName and getPlayerFromName(targetName)
        if targetPlayer then
            Mzansi.VIP.setPlayerVIP(targetPlayer, tier, 30)
            outputChatBox("[GQONQA] Granted VIP Tier " .. tier .. " to " .. getPlayerName(targetPlayer), player, 100, 235, 140)
        else
            outputChatBox("Usage: /gqonqa setvip <PlayerName> <tier>", player, 240, 60, 60)
        end
    end
end)

-- Protect Godmode players from damage
addEventHandler("onPlayerDamage", root, function(attacker, weapon, bodypart, loss)
    if getElementData(source, "mzansi:godmode") then
        cancelEvent()
        setElementHealth(source, 100)
    end
end)

--------------------------------------------------------------------------------
-- 4. VIP LUXURY VEHICLE SPAWNER & PLAYER PERKS
--------------------------------------------------------------------------------

addCommandHandler("vipveh", function(player, cmd, modelArg)
    local isVip, tier = Mzansi.VIP.isPlayerVIP(player)
    if not isVip then
        outputChatBox("You require Ngamla VIP status to access the luxury fleet! Type /vip for info.", player, 240, 60, 60)
        return
    end

    local cfg = Mzansi.VIP.Config.tiers[tier]
    if not modelArg then
        outputChatBox("════════════════════════════════════════════════════", player, 255, 215, 0)
        outputChatBox("⭐ " .. cfg.name .. " Luxury Fleet Spawner ⭐", player, 255, 255, 255)
        outputChatBox("Available Vehicles (Type /vipveh <name>):", player, 200, 200, 200)
        for _, m in ipairs(cfg.vehicles) do
            outputChatBox("  ➤ " .. getVehicleNameFromModel(m) .. " (ID: " .. m .. ")", player, 200, 170, 50)
        end
        outputChatBox("════════════════════════════════════════════════════", player, 255, 215, 0)
        return
    end

    local model = tonumber(modelArg) or getVehicleModelFromName(modelArg)
    if not model then
        outputChatBox("Invalid vehicle model or name! Type /vipveh to view your allowed fleet.", player, 240, 60, 60)
        return
    end

    -- Check if model is allowed for this tier
    local allowed = false
    for _, m in ipairs(cfg.vehicles) do
        if m == model then
            allowed = true
            break
        end
    end

    if not allowed and not Mzansi.VIP.isPlayerCreator(player) then
        outputChatBox("This vehicle is reserved for a higher Ngamla VIP tier!", player, 240, 60, 60)
        return
    end

    -- Clean previous vehicle
    if isElement(_vipVehicles[player]) then
        destroyElement(_vipVehicles[player])
        _vipVehicles[player] = nil
    end

    local x, y, z = getElementPosition(player)
    local rx, ry, rz = getElementRotation(player)
    local veh = createVehicle(model, x + 2.0, y + 2.0, z + 0.5, 0, 0, rz)
    if veh then
        _vipVehicles[player] = veh
        setVehicleColor(veh, cfg.color[1], cfg.color[2], cfg.color[3], 255, 255, 255)
        warpPedIntoVehicle(player, veh)
        playSoundFrontEnd(player, 41)
        outputChatBox("[VIP Fleet] Spawned " .. getVehicleName(veh) .. " with gold metallic finish.", player, 100, 235, 140)
    end
end)

-- VIP Vehicle Repair
addCommandHandler("vrepair", function(player)
    local isVip = Mzansi.VIP.isPlayerVIP(player)
    if not isVip then
        outputChatBox("You require Ngamla VIP status to use /vrepair.", player, 240, 60, 60)
        return
    end

    local veh = getPedOccupiedVehicle(player)
    if not veh then
        outputChatBox("You must be driving a vehicle to repair it.", player, 240, 60, 60)
        return
    end

    fixVehicle(veh)
    playSoundFrontEnd(player, 41)
    outputChatBox("[VIP] Your vehicle has been repaired and polished.", player, 100, 235, 140)
end)

-- VIP Flip
addCommandHandler("vflip", function(player)
    local isVip = Mzansi.VIP.isPlayerVIP(player)
    if not isVip then return end

    local veh = getPedOccupiedVehicle(player)
    if veh then
        local rx, ry, rz = getElementRotation(veh)
        setElementRotation(veh, 0, 0, rz)
        playSoundFrontEnd(player, 41)
        outputChatBox("[VIP] Vehicle righted.", player, 100, 235, 140)
    end
end)

-- Daily Allowance Claim
addCommandHandler("vipclaim", function(player)
    local isVip, tier = Mzansi.VIP.isPlayerVIP(player)
    if not isVip then
        outputChatBox("Only Ngamla VIP citizens receive daily allowances.", player, 240, 60, 60)
        return
    end

    local cfg = Mzansi.VIP.Config.tiers[tier]
    local nowTime = getRealTime()
    local todayStr = string.format("%04d-%02d-%02d", nowTime.year + 1900, nowTime.month + 1, nowTime.monthday)

    local v = _vipCache[player]
    if v and v.lastDaily == todayStr then
        outputChatBox("[VIP] You have already claimed your daily grant for today! Check back tomorrow.", player, 240, 180, 50)
        return
    end

    v.lastDaily = todayStr
    local grant = cfg.dailyGrant

    if exports.mzansi_core and exports.mzansi_core.addBank then
        exports.mzansi_core:addBank(player, grant)
    end

    local accountId = getElementData(player, "mzansi:accountId")
    if accountId and _db then
        dbExec(_db, "UPDATE mzansi_vip SET last_daily = ? WHERE account_id = ?", todayStr, accountId)
    end

    playSoundFrontEnd(player, 41)
    outputChatBox("════════════════════════════════════════════════════", player, 255, 215, 0)
    outputChatBox("💰 Daily " .. cfg.name .. " Grant Claimed: R" .. grant .. " deposited into your bank!", player, 100, 235, 140)
    outputChatBox("════════════════════════════════════════════════════", player, 255, 215, 0)
end)

-- Dedicated VIP Chat Channel: /v <message>
addCommandHandler("v", function(player, cmd, ...)
    local isVip, tier = Mzansi.VIP.isPlayerVIP(player)
    if not isVip then
        outputChatBox("You must possess Ngamla status to use VIP Chat.", player, 240, 60, 60)
        return
    end

    local message = table.concat({ ... }, " ")
    if string.len(message) == 0 then
        outputChatBox("Usage: /v <message>", player, 200, 170, 50)
        return
    end

    local cfg = Mzansi.VIP.Config.tiers[tier]
    local pName = getPlayerName(player)
    local chatMsg = "[VIP - " .. cfg.name .. "] " .. pName .. ": " .. message

    for _, p in ipairs(getElementsByType("player")) do
        if Mzansi.VIP.isPlayerVIP(p) then
            outputChatBox(chatMsg, p, cfg.color[1], cfg.color[2], cfg.color[3])
        end
    end
end)

-- VIP Overview Command: /vip
addCommandHandler("vip", function(player)
    local isVip, tier = Mzansi.VIP.isPlayerVIP(player)
    if not isVip then
        outputChatBox("════════════════════════════════════════════════════", player, 255, 215, 0)
        outputChatBox("⭐ NGAMLA STATUS - VIP & LUXURY MONETIZATION ⭐", player, 255, 255, 255)
        outputChatBox("Live like a true boss with exclusive advantages:", player, 200, 200, 200)
        outputChatBox("  1. Up to +100% Salary Multiplier across all careers", player, 100, 235, 140)
        outputChatBox("  2. Full SANRAL Highway Tollgate Exemption (Free E-Tag)", player, 100, 235, 140)
        outputChatBox("  3. Free First-Class ACSA Domestic Flights (/fly)", player, 100, 235, 140)
        outputChatBox("  4. Luxury Vehicle Spawner (/vipveh) & Instant Repair (/vrepair)", player, 100, 235, 140)
        outputChatBox("  5. Daily Executive Cash Allowances (/vipclaim)", player, 100, 235, 140)
        outputChatBox("Contact server administration to unlock Ngamla Status.", player, 255, 215, 0)
        outputChatBox("════════════════════════════════════════════════════", player, 255, 215, 0)
    else
        local cfg = Mzansi.VIP.Config.tiers[tier]
        outputChatBox("════════════════════════════════════════════════════", player, cfg.color[1], cfg.color[2], cfg.color[3])
        outputChatBox("⭐ ACTIVE STATUS: " .. cfg.name .. " ⭐", player, 255, 255, 255)
        outputChatBox("  ➤ Salary Multiplier: +" .. tostring((cfg.salaryMultiplier - 1.0) * 100) .. "%", player, 100, 235, 140)
        outputChatBox("  ➤ Daily Cash Grant: R" .. cfg.dailyGrant .. " (/vipclaim)", player, 100, 235, 140)
        outputChatBox("  ➤ Commands: /vipveh, /vrepair, /vflip, /v <msg>", player, 200, 170, 50)
        outputChatBox("════════════════════════════════════════════════════", player, cfg.color[1], cfg.color[2], cfg.color[3])
    end
end)

--------------------------------------------------------------------------------
-- 5. CLEANUP & ANGEL GOVERNOR
--------------------------------------------------------------------------------

addEventHandler("onPlayerQuit", root, function()
    if isElement(_vipVehicles[source]) then
        destroyElement(_vipVehicles[source])
        _vipVehicles[source] = nil
    end
    _vipCache[source] = nil
end)

addEventHandler("onPlayerLogin", root, function()
    Mzansi.VIP.loadPlayerVIP(source)
end)

addEventHandler("onResourceStart", resourceRoot, function()
    outputDebugString("[Mzansi-VIP] Angel: Ngamla VIP & Creator Registry Governor initializing...", 3)
    initDatabase()

    for _, p in ipairs(getElementsByType("player")) do
        Mzansi.VIP.loadPlayerVIP(p)
    end

    -- Angel maintenance loop: audit active vehicles and cache
    _angelGovernorTimer = setTimer(function()
        for p, veh in pairs(_vipVehicles) do
            if not isElement(p) then
                if isElement(veh) then destroyElement(veh) end
                _vipVehicles[p] = nil
            end
        end
    end, 10000, 0)

    outputDebugString("[Mzansi-VIP] Ngamla VIP System & Sovereign Creator Interface Operational.", 3)
end)

addEventHandler("onResourceStop", resourceRoot, function()
    if isTimer(_angelGovernorTimer) then
        killTimer(_angelGovernorTimer)
        _angelGovernorTimer = nil
    end
    for p, veh in pairs(_vipVehicles) do
        if isElement(veh) then destroyElement(veh) end
    end
    _vipVehicles = {}
end)

-- Exported functions for cross-resource integration
function isPlayerVIP(player)
    return Mzansi.VIP.isPlayerVIP(player)
end

function isPlayerCreator(player)
    return Mzansi.VIP.isPlayerCreator(player)
end

function setPlayerVIP(player, tier, durationDays)
    return Mzansi.VIP.setPlayerVIP(player, tier, durationDays)
end
