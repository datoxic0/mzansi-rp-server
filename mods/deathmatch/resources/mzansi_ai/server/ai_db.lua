Mzansi = Mzansi or {}
Mzansi.AIDB = Mzansi.AIDB or {}

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

function Mzansi.AIDB.save(accountId, sessionId, role, content)
    dbInsert(
        "INSERT INTO mzansi_ai_messages (account_id, session_id, role, content) VALUES (?, ?, ?, ?)",
        accountId or 0, sessionId or "", role or "user", tostring(content or "")
    )
end

function Mzansi.AIDB.recent(accountId, sessionId, limit)
    limit = tonumber(limit) or Mzansi.AI.Config.historyTurns or 8
    local rows = dbQuery(
        "SELECT role, content FROM mzansi_ai_messages WHERE account_id = ? AND session_id = ? ORDER BY id DESC LIMIT " .. tostring(limit * 2),
        accountId or 0, sessionId or ""
    ) or {}
    local out = {}
    for i = #rows, 1, -1 do
        out[#out + 1] = { role = rows[i].role, content = rows[i].content }
    end
    return out
end

function Mzansi.AIDB.ensure()
    outputDebugString("[Mzansi-AI] Message history ensured via mzansi_core migrations.")
end
