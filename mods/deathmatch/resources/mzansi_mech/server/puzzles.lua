Mzansi = Mzansi or {}
Mzansi.Mech = Mzansi.Mech or {}

addEvent("mzansi:mech:requestProgress", true)
addEvent("mzansi:mech:submitStage", true)

local function notify(player, msg, kind)
    local res = getResourceFromName("mzansi_core")
    if res and getResourceState(res) == "running" then
        pcall(function()
            exports.mzansi_core:sendNotification(player, msg, kind or "info")
        end)
    else
        outputChatBox("[MECH] " .. tostring(msg), player, 220, 180, 60, false)
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

function Mzansi.Mech.getProgress(charId)
    local rows = dbQuery(
        "SELECT * FROM mzansi_mech_progress WHERE character_id = ? LIMIT 1",
        charId
    )
    if rows and rows[1] then return rows[1] end
    return { character_id = charId, stage = 0, score = 0 }
end

local function validateAnswer(stage, payload)
    if stage.kind == "truth" then
        if type(payload.outputs) ~= "table" then return false end
        for i, pair in ipairs(stage.inputs) do
            local expected = Mzansi.Mech.gateEval(stage.gate, pair[1], pair[2])
            local got = tonumber(payload.outputs[i]) or -1
            if math.floor(got) ~= expected then
                return false, "row " .. i .. " mismatch for " .. stage.gate
            end
        end
        return true
    elseif stage.kind == "sequence" then
        if type(payload.sequence) ~= "table" then return false end
        if #payload.sequence ~= #stage.sequence then return false, "length" end
        for i, v in ipairs(stage.sequence) do
            if math.floor(tonumber(payload.sequence[i]) or -1) ~= v then
                return false, "step " .. i
            end
        end
        return true
    elseif stage.kind == "value" then
        local v = tonumber(payload.value)
        if not v then return false, "not a number" end
        if math.abs(v - stage.target) > (stage.tolerance or 0.5) then
            return false, "out of tolerance"
        end
        return true
    elseif stage.kind == "order" then
        if stage.safety then
            if payload.safety ~= true and payload.safety ~= 1 and payload.safety ~= "on" then
                return false, "safety interlock must be engaged first"
            end
        end
        if type(payload.order) ~= "table" then return false end
        if #payload.order ~= #stage.order then return false, "length" end
        for i, v in ipairs(stage.order) do
            if math.floor(tonumber(payload.order[i]) or -1) ~= v then
                return false, "path step " .. i
            end
        end
        return true
    end
    return false, "unknown stage kind"
end

function Mzansi.Mech.submit(player, stageId, payload)
    local char = getChar(player)
    if not char then
        notify(player, "No character loaded.", "error")
        return false
    end
    if char.job ~= (Mzansi.Enums and Mzansi.Enums.Job and Mzansi.Enums.Job.MECHATRONIC_TECH or 14) then
        notify(player, "You must be a Mechatronics Technician.", "error")
        return false
    end
    local stage = nil
    for _, s in ipairs(Mzansi.Mech.Stages) do
        if s.id == stageId then
            stage = s
            break
        end
    end
    if not stage then
        notify(player, "Unknown stage.", "error")
        return false
    end
    local prog = Mzansi.Mech.getProgress(char.id)
    local current = tonumber(prog.stage) or 0
    if stage.id ~= current + 1 then
        notify(player, "Complete stage " .. (current + 1) .. " first.", "error")
        return false
    end

    local ok, err = validateAnswer(stage, payload or {})
    if not ok then
        notify(player, "Incorrect: " .. tostring(err or "answer"), "error")
        triggerClientEvent(player, "mzansi:mech:result", player, false, tostring(err or "answer"))
        return false
    end

    addBank(player, stage.payout or 0)
    addXP(player, 120)
    if stage.reward_item then
        invAdd(player, stage.reward_item, 1)
    end
    if current + 1 >= 1 then
        if prog.character_id and prog.stage ~= nil then
            dbUpdate(
                "UPDATE mzansi_mech_progress SET stage = ?, score = score + 1, updated_at = CURRENT_TIMESTAMP WHERE character_id = ?",
                stage.id, char.id
            )
        else
            dbInsert(
                "INSERT INTO mzansi_mech_progress (character_id, stage, score) VALUES (?, ?, 1)",
                char.id, stage.id
            )
        end
    end

    local rewardMsg = "Stage " .. stage.id .. " passed (+" .. (stage.payout or 0) .. ")"
    if stage.reward_item then
        rewardMsg = rewardMsg .. " + " .. stage.reward_item
    end
    notify(player, rewardMsg, "success")
    triggerClientEvent(player, "mzansi:mech:result", player, true, rewardMsg)
    triggerClientEvent(player, "mzansi:mech:setProgress", player, Mzansi.Mech.getProgress(char.id))
    return true
end

addEventHandler("mzansi:mech:requestProgress", root, function()
    local player = client or source
    local char = getChar(player)
    if not char then return end
    triggerClientEvent(player, "mzansi:mech:setProgress", player, Mzansi.Mech.getProgress(char.id))
end)

addEventHandler("mzansi:mech:submitStage", root, function(stageId, payload)
    local player = client or source
    Mzansi.Mech.submit(player, stageId, payload)
end)

function getProgress(player)
    local char = getChar(player)
    if not char then return nil end
    return Mzansi.Mech.getProgress(char.id)
end

function submitStage(player, stageId, payload)
    return Mzansi.Mech.submit(player, stageId, payload)
end

-- Mech tutor callback for AI agent (P9)
function tutorHint(stage)
    local n = tonumber(stage)
    local s = Mzansi.Mech and Mzansi.Mech.Stages and n and Mzansi.Mech.Stages[n]
    if s then
        return "Stage " .. tostring(n) .. ": " .. tostring(s.title or "") ..
            " - " .. tostring(s.kind or "") .. ". Inputs " ..
            tostring(s.inputs and #s.inputs or 0) .. "."
    end
    return "Mechatronics /mech: truth, sequence, value, order kinds. Server validates. Job 14."
end