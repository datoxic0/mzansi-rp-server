Mzansi = Mzansi or {}
Mzansi.CE = Mzansi.CE or {}

addEvent("mzansi:ce:requestTickets", true)
addEvent("mzansi:ce:selectTicket", true)
addEvent("mzansi:ce:submitAnswer", true)
addEvent("mzansi:ce:submitSnippet", true)

local completed = {}

local function notify(player, msg, kind)
    local res = getResourceFromName("mzansi_core")
    if res and getResourceState(res) == "running" then
        pcall(function()
            exports.mzansi_core:sendNotification(player, msg, kind or "info")
        end)
    else
        outputChatBox("[CE] " .. tostring(msg), player, 220, 180, 60, false)
    end
end

local function getChar(player)
    local res = getResourceFromName("mzansi_core")
    if res and getResourceState(res) == "running" then
        local ok, char = pcall(function()
            return exports.mzansi_core:getCharacter(player)
        end)
        if ok then return char end
    end
    return nil
end

local function addBank(player, amount)
    local res = getResourceFromName("mzansi_core")
    if res and getResourceState(res) == "running" then
        local ok = pcall(function()
            return exports.mzansi_core:addBank(player, amount)
        end)
        return ok
    end
    return false
end

local function addXP(player, amount)
    local res = getResourceFromName("mzansi_core")
    if res and getResourceState(res) == "running" then
        local ok = pcall(function()
            return exports.mzansi_core:addXP(player, amount)
        end)
        return ok
    end
    return false
end

local function invAdd(player, item, qty)
    local res = getResourceFromName("mzansi_inventory")
    if res and getResourceState(res) == "running" then
        local ok = pcall(function()
            return exports.mzansi_inventory:addItem(player, item, qty or 1)
        end)
        return ok
    end
    return false
end

local function invHas(player, item, qty)
    local res = getResourceFromName("mzansi_inventory")
    if res and getResourceState(res) == "running" then
        local ok, result = pcall(function()
            return exports.mzansi_inventory:hasItem(player, item, qty or 1)
        end)
        if ok then return result end
    end
    return false
end

local function dbInsert(sql, ...)
    local args = { ... }
    local res = getResourceFromName("mzansi_core")
    if res and getResourceState(res) == "running" then
        local ok, id = pcall(function()
            return exports.mzansi_core:database_insert(sql, unpack(args))
        end)
        if ok then return id end
    end
    return nil
end

local function sanitizePublic(tickets)
    local out = {}
    for _, t in ipairs(tickets) do
        out[#out + 1] = {
            id = t.id,
            title = t.title,
            severity = t.severity,
            reward = t.reward,
            prompt = t.prompt,
            options = t.options,
        }
    end
    return out
end

function Mzansi.CE.listTickets()
    return sanitizePublic(Mzansi.CE.Tickets)
end

function Mzansi.CE.complete(player, ticketId, answerIndex)
    local char = getChar(player)
    if not char then
        notify(player, "No character loaded.", "error")
        return false
    end
    if char.job ~= (Mzansi.Enums and Mzansi.Enums.Job and Mzansi.Enums.Job.COMPUTER_ENGINEER or 13) then
        notify(player, "You must be a Computer Engineer.", "error")
        return false
    end
    local key = char.id .. ":" .. tostring(ticketId)
    if completed[key] then
        notify(player, "Ticket already completed.", "error")
        return false
    end
    local ticket = nil
    for _, t in ipairs(Mzansi.CE.Tickets) do
        if t.id == ticketId then
            ticket = t
            break
        end
    end
    if not ticket then
        notify(player, "Unknown ticket.", "error")
        return false
    end
    answerIndex = math.floor(tonumber(answerIndex) or -1)
    if answerIndex ~= ticket.answer then
        notify(player, "Incorrect diagnosis. Ticket remains open.", "error")
        return false
    end
    completed[key] = true
    addBank(player, ticket.reward or 500)
    addXP(player, 150)
    invAdd(player, "pc_toolkit", 1)
    dbInsert(
        "INSERT INTO mzansi_ce_tickets (character_id, title, severity, reward, status, completed_at) VALUES (?, ?, ?, ?, 'done', CURRENT_TIMESTAMP)",
        char.id, ticket.title, ticket.severity, ticket.reward
    )
    notify(player, "Ticket resolved: " .. ticket.title .. " (+" .. (ticket.reward or 0) .. ")", "success")
    triggerClientEvent(player, "mzansi:ce:setTickets", player, Mzansi.CE.listTickets(), completed[key] and nil or nil)
    return true
end

addEventHandler("mzansi:ce:requestTickets", root, function()
    local player = client or source
    triggerClientEvent(player, "mzansi:ce:setTickets", player, Mzansi.CE.listTickets())
end)

addEventHandler("mzansi:ce:submitAnswer", root, function(ticketId, answerIndex)
    local player = client or source
    Mzansi.CE.complete(player, ticketId, answerIndex)
end)

addEventHandler("mzansi:ce:submitSnippet", root, function(code)
    local player = client or source
    local ok, result = Mzansi.CE.evalSnippet(code)
    if ok then
        notify(player, "Snippet OK → " .. tostring(result), "success")
        addXP(player, 50)
        triggerClientEvent(player, "mzansi:ce:sandboxResult", player, true, tostring(result))
    else
        notify(player, "Rejected: " .. tostring(result), "error")
        triggerClientEvent(player, "mzansi:ce:sandboxResult", player, false, tostring(result))
    end
end)

function listTickets()
    return Mzansi.CE.listTickets()
end

function completeTicket(player, ticketId, answerIndex)
    return Mzansi.CE.complete(player, ticketId, answerIndex)
end

-- CE tutor callback for AI agent / copilot (P9)
function tutorHint(topic)
    local t = string.lower(tostring(topic or ""))
    local hints = {
        sql = "CE SQL tip: use parameterised queries via mzansi_core:database_query('SELECT ... WHERE id = ?', id). Never concatenate player input.",
        sandbox = "Sandbox denylist: io, os, require, debug, loadstring, setfenv, dofile, loadfile. Pure computation only.",
        event = "MTA events: addEvent(name, true) then addEventHandler. Always local source = client or source on server.",
        meta = "meta.xml: every script src must exist; exports need export function tags; shared type runs both sides.",
        job = "CE job 13: /cetickets for tickets, sandbox eval. Pay ~R6500 per activity cycle.",
        default = "Topics: sql, sandbox, event, meta, job. Example: /aiagent tutor sandbox",
    }
    return hints[t] or hints.default
end
