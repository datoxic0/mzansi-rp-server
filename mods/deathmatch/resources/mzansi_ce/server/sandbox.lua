Mzansi = Mzansi or {}
Mzansi.CE = Mzansi.CE or {}

local FORBIDDEN = {
    ["os"] = true,
    ["io"] = true,
    ["require"] = true,
    ["debug"] = true,
    ["load"] = true,
    ["loadstring"] = true,
    ["dofile"] = true,
    ["loadfile"] = true,
    ["package"] = true,
    ["collectgarbage"] = true,
    ["getfenv"] = true,
    ["setfenv"] = true,
    ["rawset"] = true,
    ["rawget"] = true,
    ["coroutine"] = true,
}

local MAX_CODE_LEN = 800
local INSTRUCTION_BUDGET = 2000

function Mzansi.CE.rejectReason(code)
    if type(code) ~= "string" then return "code must be a string" end
    if #code == 0 then return "empty code" end
    if #code > MAX_CODE_LEN then return "code too long" end
    for word in code:gmatch("[%a_][%w_]*") do
        if FORBIDDEN[word] then
            return "forbidden identifier: " .. word
        end
    end
    if code:find("%.%s*os") or code:find("os%.") or code:find("io%.") then
        return "forbidden module access"
    end
    return nil
end

function Mzansi.CE.evalSnippet(code)
    local reason = Mzansi.CE.rejectReason(code)
    if reason then
        return false, reason
    end

    local env = setmetatable({
        math = math,
        string = string,
        table = table,
        pairs = pairs,
        ipairs = ipairs,
        select = select,
        tostring = tostring,
        tonumber = tonumber,
        type = type,
        print = function() end,
        result = nil,
    }, { __index = false, __newindex = false, __metatable = false })

    local wrapped = "local budget = " .. tostring(INSTRUCTION_BUDGET) .. "\n" .. code
    local chunk, err = loadstring(wrapped, "ce_sandbox")
    if not chunk then
        return false, "syntax error: " .. tostring(err)
    end
    setfenv(chunk, env)
    local ok, result = pcall(chunk)
    if not ok then
        return false, "runtime error: " .. tostring(result)
    end
    return true, result
end

function evalSnippet(code)
    return Mzansi.CE.evalSnippet(code)
end
