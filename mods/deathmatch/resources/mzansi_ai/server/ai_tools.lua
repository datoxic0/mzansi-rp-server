Mzansi = Mzansi or {}
Mzansi.AITools = Mzansi.AITools or {}

Mzansi.AITools.MAX_TOOL_ITERS = 8
Mzansi.AITools.MAX_SNIPPET = 2048
Mzansi.AITools.MAX_ROWS = 20

-- ToolJail Angel: absolute allowlist. Never expand without review.
Mzansi.AITools.Allow = {
    read_snippet = true,
    query_game_db = true,
    get_player_stats = true,
    list_open_bugs = true,
    tutor = true,
}

-- Path jail: only these resource roots + file suffixes
Mzansi.AITools.PathRoots = {
    "mzansi_core",
    "mzansi_jobs",
    "mzansi_market",
    "mzansi_ce",
    "mzansi_mech",
    "mzansi_lab",
    "mzansi_ai",
    "mzansi_inventory",
    "mzansi_housing",
    "mzansi_vehicles",
    "mzansi_gangs",
    "mzansi_crime",
    "mzansi_drugs",
    "mzansi_saps",
    "mzansi_ems",
    "mzansi_phone",
    "mzansi_admin",
    "mzansi_utils",
    "mzansi_intel",
    "mzansi_assets",
    "mzansi_vip",
    "mzansi_freeroam",
    "mzansi_living_world",
    "mzansi_radio",
    "mzansi_hud",
    "mzansi_anticheat",
    "mzansi_illegalmarket",
    "mzansi_maps",
}

Mzansi.AITools.SafeSuffixes = {
    [".lua"] = true,
    [".md"] = true,
    [".txt"] = true,
    [".csv"] = true,
    [".json"] = true,
    [".xml"] = true,
}

-- SQL table allowlist (SELECT only)
Mzansi.AITools.SqlTables = {
    mzansi_characters = true,
    mzansi_accounts = true,
    mzansi_ce_tickets = true,
    mzansi_mech_progress = true,
    mzansi_lab_designs = true,
    mzansi_market_positions = true,
    mzansi_inventory = true,
    mzansi_vehicles = true,
    mzansi_properties = true,
    mzansi_gangs = true,
    mzansi_gang_members = true,
    mzansi_business_ownership = true,
    mzansi_police_records = true,
    mzansi_ai_messages = true,
}

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

local function fail(err)
    return false, tostring(err)
end

local function ok(v)
    return true, v
end

local function accountOf(player)
    local acc = getPlayerAccount and getPlayerAccount(player)
    if not acc or isGuestAccount(acc) then return 0 end
    local name = getAccountName(acc)
    local rows = dbQuery("SELECT id FROM mzansi_accounts WHERE username = ? LIMIT 1", name)
    if rows and rows[1] then return tonumber(rows[1].id) or 0 end
    return 0
end

local function characterOf(player)
    local res = getResourceFromName("mzansi_core")
    if res and getResourceState(res) == "running" then
        local okc, char = pcall(function()
            return exports.mzansi_core:getCharacter(player)
        end)
        if okc then return char end
    end
    return nil
end

local function normalizeRelPath(path)
    if type(path) ~= "string" then return nil end
    path = path:gsub("\\", "/"):gsub("%.%.", "")
    path = path:gsub("^/+", "")
    if path:find(":", 1, true) then return nil end
    if path:find("%.%.") then return nil end
    return path
end

local function pathAllowed(rel)
    local resource = rel:match("^([^/]+)/")
    if not resource then return false end
    if not Mzansi.AITools.PathRoots[resource] then return false end
    local ext = rel:match("(%.[^./]+)$")
    if not ext then return false end
    ext = string.lower(ext)
    if not Mzansi.AITools.SafeSuffixes[ext] then return false end
    -- block secret-ish names
    local base = rel:match("([^/]+)$") or ""
    local lower = string.lower(base)
    if lower:find("secret") or lower:find("password") or lower:find("%.env")
       or lower:find("apikey") or lower:find("private") then
        return false
    end
    return true
end

function Mzansi.AITools.read_snippet(args, player)
    local rel = normalizeRelPath(args and args.path)
    if not rel then return fail("invalid path") end
    if not pathAllowed(rel) then return fail("path not allowlisted") end
    local abs = "mods/deathmatch/resources/" .. rel
    if not fileExists(abs) then return fail("file not found") end
    local f = fileOpen(abs)
    if not f then return fail("cannot open") end
    local size = fileGetSize(f) or 0
    local readLen = math.min(size, Mzansi.AITools.MAX_SNIPPET)
    local data = fileRead(f, readLen) or ""
    fileClose(f)
    return ok({ path = rel, bytes = #data, truncated = size > readLen, content = data })
end

function Mzansi.AITools.query_game_db(args, player)
    if type(args) ~= "table" then return fail("args required") end
    local table = tostring(args.table or "")
    if not Mzansi.AITools.SqlTables[table] then return fail("table not allowlisted") end
    local limit = tonumber(args.limit) or 10
    if limit < 1 then limit = 1 end
    if limit > Mzansi.AITools.MAX_ROWS then limit = Mzansi.AITools.MAX_ROWS end
    local cols = "*"
    if type(args.columns) == "string" and args.columns:match("^[%a_,%s]+$") then
        cols = args.columns
    end
    local sql = "SELECT " .. cols .. " FROM " .. table .. " LIMIT " .. tostring(limit)
    -- optional equality filter: column + value (plain strings only)
    if type(args.where_column) == "string" and args.where_column:match("^[%a_]+$")
       and Mzansi.AITools.SqlTables[table] then
        local allowedWhere = {
            id = true, character_id = true, account_id = true, status = true,
            username = true, symbol = true, stage = true, challenge_id = true,
            faction_id = true, gang_id = true,
        }
        if allowedWhere[args.where_column] and args.where_value ~= nil then
            local wv = args.where_value
            if type(wv) == "number" then
                sql = sql:gsub("LIMIT", "WHERE " .. args.where_column .. " = " .. wv .. " LIMIT")
            elseif type(wv) == "string" and wv:match("^[%w_%- ]+$") then
                sql = sql:gsub("LIMIT",
                    "WHERE " .. args.where_column .. " = '" .. wv .. "' LIMIT")
            end
        end
    end
    -- Hard reject any non-SELECT / multi-statement injection
    local upper = string.upper(sql)
    if not upper:match("^%s*SELECT") then return fail("non-select rejected") end
    if upper:find(";") or upper:find("INSERT") or upper:find("UPDATE")
       or upper:find("DELETE") or upper:find("DROP") or upper:find("ALTER")
       or upper:find("ATTACH") or upper:find("PRAGMA") then
        return fail("sql rejected")
    end
    local rows = dbQuery(sql)
    if not rows then return fail("query failed") end
    return ok({ table = table, count = #rows, rows = rows })
end

function Mzansi.AITools.get_player_stats(args, player)
    if not player or not isElement(player) then return fail("no player") end
    local char = characterOf(player)
    if not char then return fail("no character") end
    local stats = {
        name = char.name or char.character_name or "?",
        job = tonumber(char.job) or 0,
        cash = tonumber(char.cash) or 0,
        bank = tonumber(char.bank) or 0,
        faction = tonumber(char.faction) or 0,
        level = tonumber(char.level) or tonumber(char.xp_level) or 1,
        xp = tonumber(char.xp) or 0,
    }
    -- lab progress optional
    local labRows = dbQuery(
        "SELECT challenge_id, status, score FROM mzansi_lab_designs WHERE character_id = ? LIMIT 20",
        char.id
    ) or {}
    stats.lab = labRows
    local mech = dbQuery(
        "SELECT stage, score FROM mzansi_mech_progress WHERE character_id = ? LIMIT 1",
        char.id
    )
    if mech and mech[1] then
        stats.mech_stage = tonumber(mech[1].stage) or 0
        stats.mech_score = tonumber(mech[1].score) or 0
    end
    return ok(stats)
end

function Mzansi.AITools.list_open_bugs(args, player)
    local limit = 15
    local rows = dbQuery(
        "SELECT id, character_id, title, severity, reward, status, created_at " ..
        "FROM mzansi_ce_tickets WHERE status = 'open' ORDER BY id DESC LIMIT " .. tostring(limit)
    ) or {}
    return ok({ count = #rows, rows = rows })
end

-- Tutor: dispatch to CE or Mech tutorHint via resource exports (P9 integration)
function Mzansi.AITools.tutor(args, player)
    local subject = string.lower(tostring(args and args.subject or "ce"))
    local topic = args and (args.topic or args.stage or args.q) or "default"
    if subject == "mech" or subject == "mechatronics" then
        local res = getResourceFromName("mzansi_mech")
        if not res or getResourceState(res) ~= "running" then
            return fail("mzansi_mech not running")
        end
        local okCall, hint = pcall(function()
            return exports.mzansi_mech:tutorHint(topic)
        end)
        if okCall and hint then return ok({ subject = "mech", hint = tostring(hint) }) end
        return fail("mech tutor failed")
    end
    -- default CE
    local res = getResourceFromName("mzansi_ce")
    if not res or getResourceState(res) ~= "running" then
        return fail("mzansi_ce not running")
    end
    local okCall, hint = pcall(function()
        return exports.mzansi_ce:tutorHint(topic)
    end)
    if okCall and hint then return ok({ subject = "ce", hint = tostring(hint) }) end
    return fail("ce tutor failed")
end

local Dispatch = {
    read_snippet = Mzansi.AITools.read_snippet,
    query_game_db = Mzansi.AITools.query_game_db,
    get_player_stats = Mzansi.AITools.get_player_stats,
    list_open_bugs = Mzansi.AITools.list_open_bugs,
    tutor = Mzansi.AITools.tutor,
}

function Mzansi.AITools.call(name, args, player)
    if type(name) ~= "string" or not Mzansi.AITools.Allow[name] then
        return false, "tool not allowlisted: " .. tostring(name)
    end
    local fn = Dispatch[name]
    if not fn then return false, "tool missing" end
    local okCall, a, b = pcall(fn, args or {}, player)
    if not okCall then
        outputDebugString("[Mzansi-AI] tool error " .. name .. ": " .. tostring(a), 2)
        return false, "tool error"
    end
    -- tools return (true, payload) or (false, reason)
    return a, b
end

function Mzansi.AITools.describe()
    return {
        tools = {
            { name = "read_snippet", args = { path = "mzansi_jobs/shared/job_config.lua" } },
            { name = "query_game_db", args = { table = "mzansi_ce_tickets", limit = 10 } },
            { name = "get_player_stats", args = {} },
            { name = "list_open_bugs", args = {} },
            { name = "tutor", args = { subject = "ce|mech", topic = "sql|sandbox|stage" } },
        },
        rules = "Only allowlisted tools. Never shell. Never non-SELECT SQL. Own stats only.",
    }
end
