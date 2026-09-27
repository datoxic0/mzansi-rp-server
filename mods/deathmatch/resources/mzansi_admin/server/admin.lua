-- ============================================================
-- MZANSI ADMIN PANEL — SERVER SIDE
-- mzansi_admin/server/admin.lua
-- All actions are server-authoritative.
-- Admin level is read from element data "mzansi:adminLevel".
-- ============================================================

local ADMIN_LOG_PREFIX = "[Mzansi-Admin]"

-- ============================================================
-- LEVEL GUARD UTILITY & SOVEREIGN AUTHORIZATION
-- ============================================================

local CREATOR_SERIALS = {
    ["5626CC6016B4B1E245C55BAF40161FF4"] = true, -- BambyZA Sovereign Owner
}

function isSovereignAdmin(player)
    if not isElement(player) or getElementType(player) ~= "player" then return false end
    local serial = getPlayerSerial(player)
    if CREATOR_SERIALS[serial] then return true end
    if getPlayerName(player) == "BambyZA" then return true end
    local vipTier = tonumber(getElementData(player, "mzansi:vipTier") or getElementData(player, "mzansi:vip") or 0) or 0
    if vipTier >= 3 or getElementData(player, "mzansi:isCreator") == true then return true end
    local account = getPlayerAccount(player)
    if account and not isGuestAccount(account) then
        local accName = getAccountName(account)
        local adminGroup = aclGetGroup("Admin")
        if adminGroup and isObjectInACLGroup("user." .. accName, adminGroup) then
            return true
        end
    end
    return false
end

--- Returns true if 'player' is logged in and has admin_level >= minLevel.
--- minLevel defaults to 1.
function isAdmin(player, minLevel)
    if not isElement(player) then return false end
    if isSovereignAdmin(player) then
        if (tonumber(getElementData(player, "mzansi:adminLevel") or 0) or 0) < 5 then
            setElementData(player, "mzansi:adminLevel", 5)
        end
        return true
    end
    local lvl = tonumber(getElementData(player, "mzansi:adminLevel") or 0) or 0
    local required = tonumber(minLevel) or 1
    return lvl >= required
end

function getAdminLevel(player)
    if not isElement(player) then return 0 end
    if isSovereignAdmin(player) then
        if (tonumber(getElementData(player, "mzansi:adminLevel") or 0) or 0) < 5 then
            setElementData(player, "mzansi:adminLevel", 5)
        end
        return 5
    end
    return tonumber(getElementData(player, "mzansi:adminLevel") or 0) or 0
end

local function adminGuard(player, minLevel, actionName)
    if not isAdmin(player, minLevel) then
        if isElement(player) then
            triggerClientEvent(player, "mzansi:admin:error", player,
                "Access denied. Admin level " .. (minLevel or 1) .. "+ required.")
        end
        outputDebugString(ADMIN_LOG_PREFIX .. " Rejected '" .. (actionName or "?") ..
            "' from " .. getPlayerName(player) .. " (level " .. getAdminLevel(player) .. ")", 2)
        return false
    end
    return true
end

local function adminLog(actor, action, target, detail)
    local actorName = isElement(actor) and getPlayerName(actor) or "Server"
    local targetName = (target and isElement(target)) and getPlayerName(target) or tostring(target or "N/A")
    local msg = actorName .. " → " .. action .. " on " .. targetName
    if detail and detail ~= "" then msg = msg .. " [" .. detail .. "]" end
    outputDebugString(ADMIN_LOG_PREFIX .. " " .. msg, 3)

    -- Log to DB if mzansi_core is available
    if exports.mzansi_core and exports.mzansi_core.database_logAction then
        local actorId = isElement(actor) and (getElementData(actor, "mzansi:accountId") or 0) or 0
        exports.mzansi_core:database_logAction("ADMIN_" .. action, actorId, actorName, msg, "", "")
    end
end

-- ============================================================
-- PLAYER LIST SNAPSHOT
-- ============================================================

addEvent("mzansi:admin:requestPlayerList", true)
addEventHandler("mzansi:admin:requestPlayerList", root, function()
    local actor = client or source
    if not adminGuard(actor, 1, "requestPlayerList") then return end

    local list = {}

    -- ONLINE players (live element data)
    for _, player in ipairs(getElementsByType("player")) do
        local char = getElementData(player, "mzansi:character")
        local charName = ""
        if char then
            charName = tostring(char.firstName or char.first_name or "") .. " " ..
                       tostring(char.lastName or char.last_name or "")
            charName = charName:match("^%s*(.-)%s*$") -- trim
        end

        list[#list + 1] = {
            id       = getElementID(player) or "",
            name     = getPlayerName(player),
            charName = charName,
            ping     = getPlayerPing(player),
            cash     = tonumber(getElementData(player, "mzansi:cash") or 0),
            bank     = tonumber(getElementData(player, "mzansi:bank") or 0),
            job      = tonumber(getElementData(player, "mzansi:job") or 0),
            faction  = tonumber(getElementData(player, "mzansi:faction") or 0),
            level    = tonumber(getElementData(player, "mzansi:level") or 1),
            adminLvl = getAdminLevel(player),
            serial   = getPlayerSerial(player),
            ip       = getPlayerIP(player),
            online   = true,
        }
    end

    -- OFFLINE players (from database)
    if exports.mzansi_core and exports.mzansi_core.database_query then
        local accounts = exports.mzansi_core:database_query("SELECT id, username, serial, admin_level FROM mzansi_accounts ORDER BY id DESC")
        if accounts then
            local onlineSerials = {}
            for _, p in ipairs(getElementsByType("player")) do
                onlineSerials[getPlayerSerial(p)] = true
            end
            for _, acc in ipairs(accounts) do
                if not onlineSerials[acc.serial or ""] then
                    -- Try to get character data for this account
                    local charName = ""
                    local cash, bank, job, faction = 0, 0, 0, 0
                    if exports.mzansi_core.database_query then
                        local chars = exports.mzansi_core:database_query(
                            "SELECT first_name, last_name, cash, bank, job, faction FROM mzansi_characters WHERE account_id = ? LIMIT 1",
                            acc.id)
                        if chars and chars[1] then
                            charName = tostring(chars[1].first_name or "") .. " " .. tostring(chars[1].last_name or "")
                            charName = charName:match("^%s*(.-)%s*$")
                            cash = tonumber(chars[1].cash or 0)
                            bank = tonumber(chars[1].bank or 0)
                            job = tonumber(chars[1].job or 0)
                            faction = tonumber(chars[1].faction or 0)
                        end
                    end
                    list[#list + 1] = {
                        id       = tostring(acc.id),
                        name     = acc.username or "Unknown",
                        charName = charName,
                        ping     = 0,
                        cash     = cash,
                        bank     = bank,
                        job      = job,
                        faction  = faction,
                        level    = 1,
                        adminLvl = tonumber(acc.admin_level or 0),
                        serial   = acc.serial or "",
                        ip       = "OFFLINE",
                        online   = false,
                    }
                end
            end
        end
    end

    triggerClientEvent(actor, "mzansi:admin:playerListResult", actor, list)
end)

-- ============================================================
-- KICK
-- ============================================================

addEvent("mzansi:admin:kick", true)
addEventHandler("mzansi:admin:kick", root, function(targetSerial, reason)
    local actor = client or source
    if not adminGuard(actor, 1, "kick") then return end

    reason = tostring(reason or "No reason provided.")

    for _, player in ipairs(getElementsByType("player")) do
        if getPlayerSerial(player) == targetSerial then
            if player == actor then
                triggerClientEvent(actor, "mzansi:admin:error", actor, "You cannot kick yourself.")
                return
            end
            if getAdminLevel(player) >= getAdminLevel(actor) then
                triggerClientEvent(actor, "mzansi:admin:error", actor,
                    "Cannot kick a player with equal or higher admin level.")
                return
            end

            adminLog(actor, "KICK", player, reason)
            outputChatBox("[Admin] " .. getPlayerName(player) .. " was kicked. Reason: " .. reason,
                root, 255, 150, 50, false)
            kickPlayer(player, getPlayerName(actor) .. ": " .. reason)
            triggerClientEvent(actor, "mzansi:admin:success", actor,
                getPlayerName(player) .. " was kicked.")
            return
        end
    end
    triggerClientEvent(actor, "mzansi:admin:error", actor, "Player not found (may have disconnected).")
end)

-- ============================================================
-- BAN
-- ============================================================

addEvent("mzansi:admin:ban", true)
addEventHandler("mzansi:admin:ban", root, function(targetSerial, reason)
    local actor = client or source
    if not adminGuard(actor, 2, "ban") then return end  -- Ban requires level 2+

    reason = tostring(reason or "Banned by admin.")

    for _, player in ipairs(getElementsByType("player")) do
        if getPlayerSerial(player) == targetSerial then
            if player == actor then
                triggerClientEvent(actor, "mzansi:admin:error", actor, "You cannot ban yourself.")
                return
            end
            if getAdminLevel(player) >= getAdminLevel(actor) then
                triggerClientEvent(actor, "mzansi:admin:error", actor,
                    "Cannot ban a player with equal or higher admin level.")
                return
            end

            local accountId = getElementData(player, "mzansi:accountId")
            if accountId then
                -- Mark banned in DB
                if exports.mzansi_core and exports.mzansi_core.database_banAccount then
                    exports.mzansi_core:database_banAccount(accountId, reason)
                end
            end

            adminLog(actor, "BAN", player, reason)
            outputChatBox("[Admin] " .. getPlayerName(player) .. " was banned. Reason: " .. reason,
                root, 255, 60, 60, false)
            kickPlayer(player, "[BANNED] " .. reason)
            triggerClientEvent(actor, "mzansi:admin:success", actor,
                getPlayerName(player) .. " was banned.")
            return
        end
    end
    triggerClientEvent(actor, "mzansi:admin:error", actor, "Player not found.")
end)

-- ============================================================
-- GIVE CASH
-- ============================================================

addEvent("mzansi:admin:giveCash", true)
addEventHandler("mzansi:admin:giveCash", root, function(targetSerial, amount)
    local actor = client or source
    if not adminGuard(actor, 1, "giveCash") then return end

    amount = tonumber(amount)
    if not amount or amount <= 0 or amount > 10000000 then
        triggerClientEvent(actor, "mzansi:admin:error", actor, "Invalid amount (1 – 10,000,000).")
        return
    end

    for _, player in ipairs(getElementsByType("player")) do
        if getPlayerSerial(player) == targetSerial then
            if exports.mzansi_core and exports.mzansi_core.addCash then
                exports.mzansi_core:addCash(player, amount)
            else
                -- Fallback: update element data directly
                local cur = tonumber(getElementData(player, "mzansi:cash") or 0)
                setElementData(player, "mzansi:cash", cur + amount)
            end
            adminLog(actor, "GIVE_CASH", player, "R" .. amount)
            triggerClientEvent(actor, "mzansi:admin:success", actor,
                "Gave R" .. amount .. " to " .. getPlayerName(player))
            return
        end
    end
    triggerClientEvent(actor, "mzansi:admin:error", actor, "Player not found.")
end)

-- ============================================================
-- SET JOB
-- ============================================================

addEvent("mzansi:admin:setJob", true)
addEventHandler("mzansi:admin:setJob", root, function(targetSerial, jobId)
    local actor = client or source
    if not adminGuard(actor, 1, "setJob") then return end

    jobId = tonumber(jobId)
    if not jobId then
        triggerClientEvent(actor, "mzansi:admin:error", actor, "Invalid job ID.")
        return
    end

    for _, player in ipairs(getElementsByType("player")) do
        if getPlayerSerial(player) == targetSerial then
            if exports.mzansi_core and exports.mzansi_core.setJob then
                exports.mzansi_core:setJob(player, jobId)
            else
                setElementData(player, "mzansi:job", jobId)
            end
            adminLog(actor, "SET_JOB", player, "jobId=" .. jobId)
            triggerClientEvent(actor, "mzansi:admin:success", actor,
                "Job set for " .. getPlayerName(player))
            return
        end
    end
    triggerClientEvent(actor, "mzansi:admin:error", actor, "Player not found.")
end)

-- ============================================================
-- TELEPORT TO PLAYER
-- ============================================================

addEvent("mzansi:admin:teleportTo", true)
addEventHandler("mzansi:admin:teleportTo", root, function(targetSerial)
    local actor = client or source
    if not adminGuard(actor, 1, "teleportTo") then return end

    for _, player in ipairs(getElementsByType("player")) do
        if getPlayerSerial(player) == targetSerial then
            local tx, ty, tz = getElementPosition(player)
            local dim = getElementDimension(player)
            local int = getElementInterior(player)
            setElementPosition(actor, tx + 1, ty + 1, tz)
            setElementDimension(actor, dim)
            setElementInterior(actor, int)
            adminLog(actor, "TP_TO", player, "")
            triggerClientEvent(actor, "mzansi:admin:success", actor,
                "Teleported to " .. getPlayerName(player))
            return
        end
    end
    triggerClientEvent(actor, "mzansi:admin:error", actor, "Player not found.")
end)

-- ============================================================
-- BRING PLAYER HERE
-- ============================================================

addEvent("mzansi:admin:bringHere", true)
addEventHandler("mzansi:admin:bringHere", root, function(targetSerial)
    local actor = client or source
    if not adminGuard(actor, 1, "bringHere") then return end

    for _, player in ipairs(getElementsByType("player")) do
        if getPlayerSerial(player) == targetSerial then
            local ax, ay, az = getElementPosition(actor)
            local dim = getElementDimension(actor)
            local int = getElementInterior(actor)
            setElementPosition(player, ax + 1, ay + 1, az)
            setElementDimension(player, dim)
            setElementInterior(player, int)
            adminLog(actor, "BRING_HERE", player, "")
            triggerClientEvent(actor, "mzansi:admin:success", actor,
                getPlayerName(player) .. " brought to you.")
            return
        end
    end
    triggerClientEvent(actor, "mzansi:admin:error", actor, "Player not found.")
end)

-- ============================================================
-- HEAL
-- ============================================================

addEvent("mzansi:admin:heal", true)
addEventHandler("mzansi:admin:heal", root, function(targetSerial)
    local actor = client or source
    if not adminGuard(actor, 1, "heal") then return end

    for _, player in ipairs(getElementsByType("player")) do
        if getPlayerSerial(player) == targetSerial then
            setElementHealth(player, 100)
            setPedArmor(player, 100)
            adminLog(actor, "HEAL", player, "")
            triggerClientEvent(actor, "mzansi:admin:success", actor,
                getPlayerName(player) .. " was healed to full.")
            return
        end
    end
    triggerClientEvent(actor, "mzansi:admin:error", actor, "Player not found.")
end)

-- ============================================================
-- FREEZE / UNFREEZE
-- ============================================================

addEvent("mzansi:admin:freeze", true)
addEventHandler("mzansi:admin:freeze", root, function(targetSerial, frozen)
    local actor = client or source
    if not adminGuard(actor, 1, "freeze") then return end

    for _, player in ipairs(getElementsByType("player")) do
        if getPlayerSerial(player) == targetSerial then
            setElementFrozen(player, frozen == true)
            adminLog(actor, frozen and "FREEZE" or "UNFREEZE", player, "")
            triggerClientEvent(actor, "mzansi:admin:success", actor,
                getPlayerName(player) .. (frozen and " frozen." or " unfrozen."))
            return
        end
    end
    triggerClientEvent(actor, "mzansi:admin:error", actor, "Player not found.")
end)

-- ============================================================
-- SET ADMIN LEVEL (requires level 5 = super admin)
-- ============================================================

addEvent("mzansi:admin:setAdminLevel", true)
addEventHandler("mzansi:admin:setAdminLevel", root, function(targetSerial, newLevel)
    local actor = client or source
    if not adminGuard(actor, 5, "setAdminLevel") then return end

    newLevel = tonumber(newLevel)
    if not newLevel or newLevel < 0 or newLevel > 10 then
        triggerClientEvent(actor, "mzansi:admin:error", actor, "Admin level must be 0–10.")
        return
    end

    if newLevel >= getAdminLevel(actor) then
        triggerClientEvent(actor, "mzansi:admin:error", actor,
            "Cannot set admin level equal to or higher than your own.")
        return
    end

    for _, player in ipairs(getElementsByType("player")) do
        if getPlayerSerial(player) == targetSerial then
            setElementData(player, "mzansi:adminLevel", newLevel)

            -- Persist to DB
            local accountId = getElementData(player, "mzansi:accountId")
            if accountId then
                if exports.mzansi_core then
                    exports.mzansi_core:setCharacterField(player, "adminLevel", newLevel)
                end
                -- Direct DB write (admin table update)
                local db = exports.mzansi_core and rawget(_G, "Mzansi") and Mzansi.Database
                if db and db.update then
                    db.update("UPDATE mzansi_accounts SET admin_level = ? WHERE id = ?",
                        newLevel, accountId)
                end
            end

            adminLog(actor, "SET_ADMIN", player, "level=" .. newLevel)
            if newLevel >= 1 then
                triggerEvent("mzansi:admin:promoted", root, player)
                local housingRes = getResourceFromName("mzansi_housing")
                if housingRes and getResourceState(housingRes) == "running" then
                    pcall(exports.mzansi_housing.assignAdminHouse, exports.mzansi_housing, player)
                end
            end
            triggerClientEvent(actor, "mzansi:admin:success", actor,
                getPlayerName(player) .. " admin level set to " .. newLevel)
            return
        end
    end
    triggerClientEvent(actor, "mzansi:admin:error", actor, "Player not found.")
end)

-- ============================================================
-- OPEN PANEL — server confirms admin access
-- ============================================================

addEvent("mzansi:admin:requestOpen", true)
addEventHandler("mzansi:admin:requestOpen", root, function()
    local actor = client or source
    local lvl = getAdminLevel(actor)
    if lvl < 1 then
        triggerClientEvent(actor, "mzansi:admin:openDenied", actor)
    else
        triggerClientEvent(actor, "mzansi:admin:openGranted", actor, lvl)
    end
end)

addEventHandler("onPlayerJoin", root, function()
    local p = source
    if isSovereignAdmin(p) then
        setElementData(p, "mzansi:adminLevel", 5)
        setElementData(p, "mzansi:vipTier", 3)
    end
end)

addEventHandler("onPlayerSpawn", root, function()
    local p = source
    if isSovereignAdmin(p) then
        setElementData(p, "mzansi:adminLevel", 5)
        setElementData(p, "mzansi:vipTier", 3)
        outputChatBox("[Mzansi-Admin] Sovereign Creator Master Access Active (Level 5). Press F7 or /admin.", p, 255, 215, 0)
    end
end)

addEventHandler("onResourceStart", resourceRoot, function()
    outputDebugString("[Mzansi-Admin] Admin panel system loaded.")
    for _, p in ipairs(getElementsByType("player")) do
        if isSovereignAdmin(p) then
            setElementData(p, "mzansi:adminLevel", 5)
            setElementData(p, "mzansi:vipTier", 3)
        end
    end
end)
