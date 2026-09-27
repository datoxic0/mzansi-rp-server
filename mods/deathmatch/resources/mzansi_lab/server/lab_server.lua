Mzansi = Mzansi or {}
Mzansi.LabServer = Mzansi.LabServer or {}

addEvent("mzansi:lab:listChallenges", true)
addEvent("mzansi:lab:submit", true)
addEvent("mzansi:lab:saveDraft", true)
addEvent("mzansi:lab:requestProgress", true)

local completedCache = {}

local function notify(player, msg, kind)
    local res = getResourceFromName("mzansi_core")
    if res and getResourceState(res) == "running" then
        pcall(function()
            exports.mzansi_core:sendNotification(player, msg, kind or "info")
        end)
    else
        outputChatBox("[LAB] " .. tostring(msg), player, 80, 180, 220, false)
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

local function dbQuery(sql, ...)
    local args = { ... }
    local res = getResourceFromName("mzansi_core")
    if res and getResourceState(res) == "running" then
        local ok, rows = pcall(function()
            return exports.mzansi_core:database_query(sql, unpack(args))
        end)
        if ok then return rows end
    end
    return nil
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

local function dbUpdate(sql, ...)
    local args = { ... }
    local res = getResourceFromName("mzansi_core")
    if res and getResourceState(res) == "running" then
        local ok = pcall(function()
            return exports.mzansi_core:database_update(sql, unpack(args))
        end)
        return ok
    end
    return false
end

local function jobAllowed(char, challenge)
    if not char then return false end
    local j = tonumber(char.job) or 0
    if j == (challenge.job or -1) then return true end
    if challenge.alt_job and j == challenge.alt_job then return true end
    -- Admin / open lab access for testing: job 0 stays blocked, others free if challenge.job nil
    if not challenge.job then return true end
    return false
end

local function encodeCircuit(circuit)
    -- Minimal JSON encoder for circuit tables
    local function enc(v)
        local t = type(v)
        if t == "number" then
            if v ~= math.floor(v) then return string.format("%.6f", v) end
            return tostring(v)
        elseif t == "boolean" then
            return v and "true" or "false"
        elseif t == "string" then
            local s = v:gsub("\\", "\\\\"):gsub('"', '\\"'):gsub("\n", "\\n"):gsub("\r", "\\r"):gsub("\t", "\\t")
            return '"' .. s .. '"'
        elseif t == "table" then
            local isArray = true
            local n = 0
            for k in pairs(v) do
                n = n + 1
                if type(k) ~= "number" then isArray = false break end
            end
            if isArray and n == #v then
                local parts = {}
                for _, item in ipairs(v) do parts[#parts + 1] = enc(item) end
                return "[" .. table.concat(parts, ",") .. "]"
            else
                local parts = {}
                for k, item in pairs(v) do
                    parts[#parts + 1] = enc(tostring(k)) .. ":" .. enc(item)
                end
                return "{" .. table.concat(parts, ",") .. "}"
            end
        end
        return "null"
    end
    local ok, json = pcall(enc, circuit)
    if ok then return json end
    return "{}"
end

function Mzansi.LabServer.publicChallenges(char)
    local out = {}
    for _, c in ipairs(Mzansi.Lab.Challenges) do
        local key = char and (char.id .. ":" .. c.id) or nil
        out[#out + 1] = {
            id = c.id,
            title = c.title,
            brief = c.brief,
            job = c.job,
            palette = c.palette,
            inputs = c.inputs,
            outputs = c.outputs,
            min_gates = c.min_gates,
            max_gates = c.max_gates,
            payout = c.payout,
            concepts = c.concepts,
            completed = key and completedCache[key] or false,
        }
    end
    return out
end

function Mzansi.LabServer.loadCompleted(charId)
    local rows = dbQuery(
        "SELECT challenge_id FROM mzansi_lab_designs WHERE character_id = ? AND status = 'passed'",
        charId
    ) or {}
    for _, r in ipairs(rows) do
        completedCache[charId .. ":" .. r.challenge_id] = true
    end
end

function Mzansi.LabServer.isCompleted(charId, challengeId)
    local key = charId .. ":" .. challengeId
    if completedCache[key] ~= nil then return completedCache[key] end
    local rows = dbQuery(
        "SELECT status FROM mzansi_lab_designs WHERE character_id = ? AND challenge_id = ? LIMIT 1",
        charId, challengeId
    )
    local done = rows and rows[1] and rows[1].status == "passed"
    completedCache[key] = done and true or false
    return completedCache[key]
end

function Mzansi.LabServer.saveDesign(charId, challengeId, circuit, status, score)
    local json = encodeCircuit(circuit or {})
    local existing = dbQuery(
        "SELECT id FROM mzansi_lab_designs WHERE character_id = ? AND challenge_id = ? LIMIT 1",
        charId, challengeId
    )
    if existing and existing[1] then
        dbUpdate(
            "UPDATE mzansi_lab_designs SET circuit_json = ?, status = ?, score = ?, updated_at = CURRENT_TIMESTAMP WHERE character_id = ? AND challenge_id = ?",
            json, status or "draft", score or 0, charId, challengeId
        )
    else
        dbInsert(
            "INSERT INTO mzansi_lab_designs (character_id, challenge_id, circuit_json, status, score) VALUES (?, ?, ?, ?, ?)",
            charId, challengeId, json, status or "draft", score or 0
        )
    end
end

function Mzansi.LabServer.submit(player, challengeId, circuit)
    local char = getChar(player)
    if not char then
        notify(player, "No character loaded.", "error")
        return false
    end
    local challenge = Mzansi.Lab.getChallenge(challengeId)
    if not challenge then
        notify(player, "Unknown challenge.", "error")
        return false
    end
    if not jobAllowed(char, challenge) then
        notify(player, "Requires job " .. tostring(challenge.job) .. " (Computer Engineer or Mechatronics).", "error")
        return false
    end
    if Mzansi.LabServer.isCompleted(char.id, challengeId) then
        notify(player, "Challenge already passed. Design saved.", "info")
        Mzansi.LabServer.saveDesign(char.id, challengeId, circuit, "passed", 100)
        triggerClientEvent(player, "mzansi:lab:result", player, true, "Already completed — design saved.", challengeId)
        return true
    end

    local ok, reason, rows, gcount = Mzansi.LabEngine.validateAgainstChallenge(circuit, challenge)
    if not ok then
        Mzansi.LabServer.saveDesign(char.id, challengeId, circuit, "failed", 0)
        notify(player, "Validation failed: " .. tostring(reason), "error")
        triggerClientEvent(player, "mzansi:lab:result", player, false, tostring(reason), challengeId)
        return false
    end

    local score = 100
    local minG = challenge.min_gates or 1
    if gcount and gcount > minG then
        score = math.max(70, 100 - (gcount - minG) * 3)
    end

    completedCache[char.id .. ":" .. challengeId] = true
    Mzansi.LabServer.saveDesign(char.id, challengeId, circuit, "passed", score)

    addBank(player, challenge.payout or 500)
    addXP(player, challenge.xp or 100)
    if challenge.reward_item then
        invAdd(player, challenge.reward_item, 1)
    end

    local msg = string.format(
        "PASSED %s (score %d, %d gates) +R%d +%d XP",
        challenge.title, score, gcount or 0, challenge.payout or 0, challenge.xp or 0
    )
    notify(player, msg, "success")
    triggerClientEvent(player, "mzansi:lab:result", player, true, msg, challengeId)
    triggerClientEvent(player, "mzansi:lab:setChallenges", player, Mzansi.LabServer.publicChallenges(char))
    return true
end

function Mzansi.LabServer.validateOnly(challengeId, circuit)
    local challenge = Mzansi.Lab.getChallenge(challengeId)
    if not challenge then return false, "unknown challenge" end
    return Mzansi.LabEngine.validateAgainstChallenge(circuit, challenge)
end

addEventHandler("mzansi:lab:listChallenges", root, function()
    local player = client or source
    local char = getChar(player)
    if char and not completedCache[char.id .. ":__loaded"] then
        Mzansi.LabServer.loadCompleted(char.id)
        completedCache[char.id .. ":__loaded"] = true
    end
    triggerClientEvent(player, "mzansi:lab:setChallenges", player, Mzansi.LabServer.publicChallenges(char))
end)

addEventHandler("mzansi:lab:submit", root, function(challengeId, circuit)
    local player = client or source
    Mzansi.LabServer.submit(player, challengeId, circuit)
end)

addEventHandler("mzansi:lab:saveDraft", root, function(challengeId, circuit)
    local player = client or source
    local char = getChar(player)
    if not char then return end
    Mzansi.LabServer.saveDesign(char.id, challengeId, circuit, "draft", 0)
    triggerClientEvent(player, "mzansi:lab:draftSaved", player, true)
end)

addEventHandler("mzansi:lab:requestProgress", root, function()
    local player = client or source
    local char = getChar(player)
    if not char then return end
    Mzansi.LabServer.loadCompleted(char.id)
    triggerClientEvent(player, "mzansi:lab:setChallenges", player, Mzansi.LabServer.publicChallenges(char))
end)

function listChallenges()
    local char = getChar(source)
    return Mzansi.LabServer.publicChallenges(char)
end

function submitCircuit(challengeId, circuit)
    return Mzansi.LabServer.submit(source, challengeId, circuit)
end

function validateCircuit(challengeId, circuit)
    return Mzansi.LabServer.validateOnly(challengeId, circuit)
end

function getProgress()
    local char = getChar(source)
    if not char then return {} end
    Mzansi.LabServer.loadCompleted(char.id)
    local out = {}
    for _, c in ipairs(Mzansi.Lab.Challenges) do
        out[c.id] = Mzansi.LabServer.isCompleted(char.id, c.id)
    end
    return out
end

addEventHandler("onResourceStart", resourceRoot, function()
    outputDebugString("[Mzansi-Lab] Circuit lab online — ASCADS engines (VEO-SA-NC-1.0, licensor project).")
end)
