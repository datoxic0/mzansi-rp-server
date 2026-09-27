Mzansi = Mzansi or {}
Mzansi.AIBridge = Mzansi.AIBridge or {}

addEvent("mzansi:ai:chat", true)
addEvent("mzansi:ai:history", true)
addEvent("mzansi:ai:agentRun", true)

local rateBuckets = {}
local dailyCount = 0
local dailyDay = 0

local function notify(player, msg, kind)
    local res = getResourceFromName("mzansi_core")
    if res and getResourceState(res) == "running" then
        pcall(function()
            exports.mzansi_core:sendNotification(player, msg, kind or "info")
        end)
    end
end

local function accountOf(player)
    local acc = getPlayerAccount and getPlayerAccount(player)
    if not acc or isGuestAccount(acc) then return 0 end
    local name = getAccountName(acc)
    local rows = nil
    local res = getResourceFromName("mzansi_core")
    if res and getResourceState(res) == "running" then
        local ok, r = pcall(function()
            return exports.mzansi_core:database_query(
                "SELECT id FROM mzansi_accounts WHERE username = ? LIMIT 1", name
            )
        end)
        if ok then rows = r end
    end
    if rows and rows[1] then return tonumber(rows[1].id) or 0 end
    return 0
end

local function allow(accountId)
    local now = os.time()
    local minute = math.floor(now / 60)
    local day = math.floor(now / 86400)
    if dailyDay ~= day then
        dailyDay = day
        dailyCount = 0
    end
    if dailyCount >= (Mzansi.AI.Config.dailyBudget or 200) then
        return false, "daily AI budget reached"
    end
    local b = rateBuckets[accountId]
    if not b or b.minute ~= minute then
        rateBuckets[accountId] = { minute = minute, count = 1 }
        dailyCount = dailyCount + 1
        return true
    end
    if b.count >= (Mzansi.AI.Config.rateLimitPerMin or 20) then
        return false, "rate limit 20/min"
    end
    b.count = b.count + 1
    dailyCount = dailyCount + 1
    return true
end

local function reflexReply(message)
    local lower = string.lower(tostring(message or ""))
    if lower:find("job") or lower:find("work") then
        return "Open Dashboard > Jobs, apply, then /job work for activity stops. CE id 13 and Mechatronics id 14 are live."
    elseif lower:find("market") or lower:find("btc") or lower:find("forex") then
        return "Paper markets only: /markets for crypto/forex/stocks. No real exchange keys. Hedge funds under Funds tab."
    elseif lower:find("bank") or lower:find("transfer") then
        return "Bank UI: Overview/Transfer/Loans/History/Groups. Groups tab handles gang/business accounts."
    elseif lower:find("mech") or lower:find("plc") or lower:find("gate") then
        return "Mechatronics: apply job 14, then /mech for gate/PLC stages. Server evaluates answers."
    elseif lower:find("ce") or lower:find("ticket") or lower:find("bug") then
        return "Computer Engineer: apply job 13, then /cetickets. Sandbox rejects io/os/require/debug."
    elseif lower:find("lab") or lower:find("circuit") or lower:find("schematic") then
        return "Circuit lab: /lab for ASCADS challenges (jobs 13/14). Validate + Submit for payouts."
    elseif lower:find("vehicle") or lower:find("shop") then
        return "Province vehicle shops: markers on map or /vehicleshop near a shop blip."
    else
        return "Mzansi copilot (reflex): ask about jobs, banking, paper markets, CE tickets, mechatronics, or /lab circuits."
    end
end

local function remoteComplete(messages, callback)
    local cfg = Mzansi.AI.Config
    if cfg.mode ~= "remote" or cfg.provider_url == "" then
        callback(false, nil, "remote disabled")
        return
    end
    local bodyTable = {
        model = cfg.provider_model,
        messages = messages,
        max_tokens = cfg.max_tokens,
        temperature = cfg.temperature,
    }
    local encoded = toJSON(bodyTable)
    encoded = encoded:gsub("^%[", ""):gsub("%]$", "")
    fetchRemote(cfg.provider_url, {}, function(data, statusCode)
        if statusCode ~= 200 or not data or data == "" then
            callback(false, nil, "http_" .. tostring(statusCode))
            return
        end
        local ok, parsed = pcall(fromJSON, data)
        if not ok or not parsed then
            callback(false, nil, "bad_json")
            return
        end
        local content = parsed.choices
            and parsed.choices[1]
            and parsed.choices[1].message
            and parsed.choices[1].message.content
        if content and content ~= "" then
            callback(true, content, nil)
        else
            callback(false, nil, "empty_completion")
        end
    end, bodyTable, false, "Authorization: Bearer " .. (cfg.provider_key or ""), "Content-Type: application/json")
end

-- Parse optional tool-call envelope from model output.
-- Accepts: {"tool":"name","args":{...}}  or  TOOL name {json}
local function parseToolCall(text)
    if type(text) ~= "string" then return nil end
    local trimmed = text:gsub("^%s+", ""):gsub("%s+$", "")
    local j = trimmed:match("^({.*})$")
    if j then
        local ok, obj = pcall(fromJSON, j)
        if ok and type(obj) == "table" and type(obj.tool) == "string" then
            return obj.tool, type(obj.args) == "table" and obj.args or {}
        end
    end
    local tool, rest = trimmed:match("^TOOL%s+(%w+)%s+(%b{})$")
    if tool and rest then
        local ok, args = pcall(fromJSON, rest)
        if ok and type(args) == "table" then
            return tool, args
        end
        return tool, {}
    end
    return nil
end

local function toolSystemAddendum()
    local desc = Mzansi.AITools.describe()
    return "\n\nAGENT TOOLS (respond with a single JSON object ONLY when a tool is required):\n" ..
        '{"tool":"read_snippet|query_game_db|get_player_stats|list_open_bugs|tutor","args":{...}}\n' ..
        "Rules: " .. desc.rules ..
        "\nOtherwise reply as normal concise text. Never invent tool results."
end

local function runAgentLoop(player, accountId, sessionId, userText, callbackFinal)
    local cfg = Mzansi.AI.Config
    local history = Mzansi.AIDB.recent(accountId, sessionId, cfg.historyTurns)
    local messages = {
        { role = "system", content = cfg.systemPrompt .. toolSystemAddendum() },
    }
    for _, h in ipairs(history) do
        messages[#messages + 1] = { role = h.role, content = h.content }
    end
    messages[#messages + 1] = { role = "user", content = userText }

    local iters = 0
    local maxI = Mzansi.AITools.MAX_TOOL_ITERS or 8
    local usedTools = {}

    local function step()
        iters = iters + 1
        if iters > maxI then
            callbackFinal(true, "[agent] max tool iterations reached", usedTools)
            return
        end
        remoteComplete(messages, function(remoteOk, content, err)
            if not remoteOk then
                callbackFinal(false, nil, err or "remote_failed", usedTools)
                return
            end
            local toolName, toolArgs = parseToolCall(content)
            if not toolName then
                callbackFinal(true, content, nil, usedTools)
                return
            end
            if #usedTools >= maxI then
                callbackFinal(true, "[agent] tool budget exhausted; final: " .. tostring(content), nil, usedTools)
                return
            end
            local allowed, result = Mzansi.AITools.call(toolName, toolArgs, player)
            usedTools[#usedTools + 1] = { tool = toolName, ok = allowed and true or false }
            local payload
            if allowed then
                payload = { ok = true, result = result }
            else
                payload = { ok = false, error = tostring(result) }
            end
            local asJson = toJSON(payload)
            asJson = asJson:gsub("^%[", ""):gsub("%]$", "")
            messages[#messages + 1] = { role = "assistant", content = content }
            messages[#messages + 1] = {
                role = "user",
                content = "TOOL_RESULT " .. toolName .. ": " .. asJson ..
                    "\nContinue. If done, reply final text only (no more tools).",
            }
            step()
        end)
    end
    step()
end

function Mzansi.AIBridge.chat(player, sessionId, task, message)
    local accountId = accountOf(player)
    local okRate, rateMsg = allow(accountId)
    if not okRate then
        notify(player, "AI " .. rateMsg, "error")
        triggerClientEvent(player, "mzansi:ai:reply", player, "[rate-limited] " .. rateMsg)
        return false
    end

    sessionId = tostring(sessionId or ("s" .. accountId))
    local userText = Mzansi.AI.promptFor(task or "chat", message)
    Mzansi.AIDB.save(accountId, sessionId, "user", userText)

    local cfg = Mzansi.AI.Config
    if cfg.mode == "remote" and cfg.provider_url ~= "" then
        runAgentLoop(player, accountId, sessionId, userText, function(finalOk, finalText, err, tools)
            local reply
            if finalOk and finalText then
                reply = finalText
            else
                reply = reflexReply(message)
                if err and err ~= "remote disabled" then
                    reply = reply .. "\n[reflex fallback: " .. tostring(err) .. "]"
                end
            end
            if tools and #tools > 0 then
                local names = {}
                for _, t in ipairs(tools) do names[#names + 1] = t.tool end
                reply = reply .. "\n[tools: " .. table.concat(names, ", ") .. "]"
            end
            Mzansi.AIDB.save(accountId, sessionId, "assistant", reply)
            triggerClientEvent(player, "mzansi:ai:reply", player, reply)
        end)
    else
        local reply = reflexReply(message)
        -- Reflex path may still use safe tools for local intents
        local lower = string.lower(tostring(message or ""))
        if lower:find("my stats") or lower:find("my character") or lower:find("my job") then
            local okT, stats = Mzansi.AITools.call("get_player_stats", {}, player)
            if okT and stats then
                reply = reply .. string.format(
                    "\n[stats] %s · job %s · cash R%d · bank R%d · lab %d",
                    tostring(stats.name), tostring(stats.job),
                    tonumber(stats.cash) or 0, tonumber(stats.bank) or 0,
                    stats.lab and #stats.lab or 0
                )
            end
        elseif lower:find("open bug") or lower:find("open ticket") then
            local okT, payload = Mzansi.AITools.call("list_open_bugs", {}, player)
            if okT and payload then
                reply = reply .. "\n[open CE tickets: " .. tostring(payload.count or 0) .. "]"
            end
        elseif lower:find("tutor") or lower:find("ce tutor") then
            local subject = lower:find("mech") and "mech" or "ce"
            local word = lower:match("tutor%s+(%w+)") or "default"
            local okT, payload = Mzansi.AITools.call("tutor", { subject = subject, topic = word }, player)
            if okT and payload then
                reply = tostring(payload.hint or payload)
            end
        end
        Mzansi.AIDB.save(accountId, sessionId, "assistant", reply)
        triggerClientEvent(player, "mzansi:ai:reply", player, reply)
    end
    return true
end

-- Manual agent run: forces tool-capable path even in reflex if tools requested
addEventHandler("mzansi:ai:agentRun", root, function(sessionId, message)
    local player = client or source
    local accountId = accountOf(player)
    local okRate = allow(accountId)
    if not okRate then
        triggerClientEvent(player, "mzansi:ai:reply", player, "[rate-limited]")
        return
    end
    sessionId = tostring(sessionId or ("s" .. accountId))
    local userText = "AGENT: " .. tostring(message or "")
    Mzansi.AIDB.save(accountId, sessionId, "user", userText)

    -- Deterministic tool-first path for known intents (works offline / reflex mode)
    local lower = string.lower(tostring(message or ""))
    local reply
    if lower:find("bug") or lower:find("ticket") then
        local okT, payload = Mzansi.AITools.call("list_open_bugs", {}, player)
        if okT then
            local lines = { "Open CE tickets:" }
            for _, r in ipairs(payload.rows or {}) do
                lines[#lines + 1] = string.format(
                    "#%s [%s] %s (+R%s)",
                    tostring(r.id), tostring(r.severity or "?"),
                    tostring(r.title or ""), tostring(r.reward or 0)
                )
            end
            reply = table.concat(lines, "\n")
        else
            reply = "list_open_bugs failed: " .. tostring(payload)
        end
    elseif lower:find("tutor") or lower:find("hint") then
        local subject = "ce"
        local topic = "default"
        if lower:find("mech") then subject = "mech" end
        local word = lower:match("tutor%s+(%w+)") or lower:match("hint%s+(%w+)")
        if word and word ~= "tutor" and word ~= "hint" and word ~= "mech" then
            topic = word
        end
        local okT, payload = Mzansi.AITools.call("tutor", { subject = subject, topic = topic }, player)
        if okT and payload then
            reply = tostring(payload.hint or payload)
        else
            reply = "tutor failed: " .. tostring(payload)
        end
    elseif lower:find("stats") then
        local okT, stats = Mzansi.AITools.call("get_player_stats", {}, player)
        if okT and stats then
            reply = string.format(
                "%s · job %s · R%d cash · R%d bank · mech stage %s",
                tostring(stats.name), tostring(stats.job),
                tonumber(stats.cash) or 0, tonumber(stats.bank) or 0,
                tostring(stats.mech_stage or "-")
            )
        else
            reply = "get_player_stats failed: " .. tostring(stats)
        end
    else
        reply = "Agent ready. Try: 'list open bugs', 'my stats', 'tutor sandbox', or use /ai for chat."
    end

    Mzansi.AIDB.save(accountId, sessionId, "assistant", reply)
    triggerClientEvent(player, "mzansi:ai:reply", player, reply)
end)

addEventHandler("mzansi:ai:chat", root, function(sessionId, task, message)
    local player = client or source
    if type(message) ~= "string" or #message == 0 or #message > 800 then
        notify(player, "Invalid message length.", "error")
        return
    end
    Mzansi.AIBridge.chat(player, sessionId, task, message)
end)

addEventHandler("mzansi:ai:history", root, function(sessionId)
    local player = client or source
    local accountId = accountOf(player)
    triggerClientEvent(player, "mzansi:ai:setHistory", player, Mzansi.AIDB.recent(accountId, sessionId, 8))
end)

function getHistory(sessionId)
    local player = source
    local accountId = accountOf(player)
    return Mzansi.AIDB.recent(accountId, accountId and sessionId or sessionId, 8)
end

function chat(sessionId, task, message)
    return Mzansi.AIBridge.chat(source, sessionId, task, message)
end

function listTools()
    return Mzansi.AITools.describe()
end

function runTool(name, args)
    return Mzansi.AITools.call(name, args or {}, source)
end

addEventHandler("onResourceStart", resourceRoot, function()
    Mzansi.AIDB.ensure()
    outputDebugString("[Mzansi-AI] Mode A + agent tools v2 online (MAX " ..
        tostring(Mzansi.AITools.MAX_TOOL_ITERS) .. " iters).")
end)
