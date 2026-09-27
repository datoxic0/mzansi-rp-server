Mzansi = Mzansi or {}
Mzansi.MarketDB = Mzansi.MarketDB or {}

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

function Mzansi.MarketDB.ensureTables()
    outputDebugString("[Mzansi-Market] Market tables ensured via mzansi_core migrations.")
end

function Mzansi.MarketDB.listPositions()
    return dbQuery("SELECT character_id, symbol, qty, avg_price, realized_pnl FROM mzansi_market_positions") or {}
end

addEventHandler("onResourceStart", resourceRoot, function()
    Mzansi.MarketDB.ensureTables()
end)
