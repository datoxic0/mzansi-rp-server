Mzansi = Mzansi or {}
Mzansi.Util = Mzansi.Util or {}

function Mzansi.Util.round(value, decimals)
    decimals = decimals or 0
    local power = 10 ^ decimals
    return math.floor(value * power + 0.5) / power
end

function Mzansi.Util.safeName(value)
    return tostring(value or ""):gsub("[^%w_]", "_")
end

function Mzansi.Util.tableCount(tbl)
    local count = 0
    for _ in pairs(tbl or {}) do
        count = count + 1
    end
    return count
end

function Mzansi.Util.getPlayerIdentifier(player)
    local account = getAccountName(getPlayerAccount(player))
    if account and account ~= "" then
        return account
    end
    return getPlayerSerial(player)
end
