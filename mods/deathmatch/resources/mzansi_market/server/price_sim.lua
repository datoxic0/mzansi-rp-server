Mzansi = Mzansi or {}
Mzansi.MarketSim = Mzansi.MarketSim or {}

local INSTRUMENTS = {
    { symbol = "BTCZAR", class = "crypto", base = 980000, vol = 0.012, drift = 0.0004 },
    { symbol = "ETHZAR", class = "crypto", base = 54000, vol = 0.014, drift = 0.0003 },
    { symbol = "USDZAR", class = "forex", base = 18.4, vol = 0.002, drift = 0.0 },
    { symbol = "EURZAR", class = "forex", base = 20.1, vol = 0.002, drift = 0.0 },
    { symbol = "GBPZAR", class = "forex", base = 23.5, vol = 0.002, drift = 0.0 },
    { symbol = "MSCIVAR", class = "stocks", base = 14500, vol = 0.006, drift = 0.0002 },
    { symbol = "ANGVAR", class = "stocks", base = 820, vol = 0.005, drift = 0.0002 },
    { symbol = "NPNVAR", class = "stocks", base = 3600, vol = 0.005, drift = 0.0002 },
    { symbol = "GOLD", class = "commodity", base = 4200, vol = 0.003, drift = 0.0001 },
    { symbol = "PLAT", class = "commodity", base = 1800, vol = 0.004, drift = 0.0001 },
    { symbol = "BRENT", class = "commodity", base = 95, vol = 0.008, drift = 0.0 },
    { symbol = "BTC-OPT-5", class = "options", base = 4200, vol = 0.02, drift = 0.0 },
}

local quotes = {}
local candles = {}
local regimes = {}
local historyLen = 120

local function gauss()
    local u1 = math.random()
    local u2 = math.random()
    if u1 < 1e-12 then u1 = 1e-12 end
    return math.sqrt(-2 * math.log(u1)) * math.cos(2 * math.pi * u2)
end

function Mzansi.MarketSim.init()
    math.randomseed(tonumber(tostring({}):match("0x(%x+)") or tostring(getTickCount())) or getTickCount())
    for _, inst in ipairs(INSTRUMENTS) do
        quotes[inst.symbol] = {
            symbol = inst.symbol,
            class = inst.class,
            price = inst.base,
            open = inst.base,
            high = inst.base,
            low = inst.base,
            prev = inst.base,
            change_pct = 0,
            vol = inst.vol,
            drift = inst.drift,
        }
        regimes[inst.symbol] = "normal"
        candles[inst.symbol] = {}
        for i = 1, historyLen do
            local p = inst.base * (1 + gauss() * inst.vol * 0.3)
            table.insert(candles[inst.symbol], { o = p, h = p, l = p, c = p, v = math.random(10, 200) })
        end
        quotes[inst.symbol].price = candles[inst.symbol][#candles[inst.symbol]].c
        quotes[inst.symbol].prev = quotes[inst.symbol].price
    end
    outputDebugString("[Mzansi-Market] Price process Angel online (" .. #INSTRUMENTS .. " instruments).")
end

function Mzansi.MarketSim.tick()
    for _, inst in ipairs(INSTRUMENTS) do
        local q = quotes[inst.symbol]
        if q then
            if math.random() < 0.04 then
                regimes[inst.symbol] = regimes[inst.symbol] == "calm" and "stressed" or "calm"
            end
            local volMul = regimes[inst.symbol] == "stressed" and 2.5 or (regimes[inst.symbol] == "calm" and 0.6 or 1.0)

            if math.random() < 0.03 then
                local shock = (math.random() > 0.5 and 1 or -1) * q.vol * 6
                q.price = q.price * (1 + shock)
            end

            local step = q.drift + gauss() * q.vol * volMul
            local nextPrice = q.price * (1 + step)
            if nextPrice < 0.01 then nextPrice = 0.01 end

            q.prev = q.price
            q.price = nextPrice
            q.high = math.max(q.high, nextPrice)
            q.low = math.min(q.low, nextPrice)
            q.change_pct = ((nextPrice - q.prev) / q.prev) * 100

            local series = candles[inst.symbol]
            local bar = series[#series]
            bar.c = nextPrice
            bar.h = math.max(bar.h, nextPrice)
            bar.l = math.min(bar.l, nextPrice)
            bar.v = bar.v + math.random(1, 15)

            if math.random() < 0.2 then
                table.insert(series, { o = nextPrice, h = nextPrice, l = nextPrice, c = nextPrice, v = math.random(5, 80) })
                if #series > historyLen then
                    table.remove(series, 1)
                end
                q.open = nextPrice
                q.high = nextPrice
                q.low = nextPrice
            end
        end
    end
end

function Mzansi.MarketSim.getQuotes()
    local out = {}
    for sym, q in pairs(quotes) do
        out[#out + 1] = {
            symbol = q.symbol,
            class = q.class,
            price = q.price,
            prev = q.prev,
            change_pct = q.change_pct,
            high = q.high,
            low = q.low,
            regime = regimes[sym] or "normal",
        }
    end
    table.sort(out, function(a, b) return a.symbol < b.symbol end)
    return out
end

function Mzansi.MarketSim.getPrice(symbol)
    local q = quotes[symbol]
    if not q then return nil end
    return q.price
end

function Mzansi.MarketSim.getCloses(symbol, n)
    local series = candles[symbol]
    if not series then return {} end
    n = tonumber(n) or 50
    local out = {}
    local start = math.max(1, #series - n + 1)
    for i = start, #series do
        out[#out + 1] = series[i].c
    end
    return out
end

function Mzansi.MarketSim.getInstrument(symbol)
    for _, inst in ipairs(INSTRUMENTS) do
        if inst.symbol == symbol then return inst end
    end
    return nil
end

function Mzansi.MarketSim.listSymbols()
    local out = {}
    for _, inst in ipairs(INSTRUMENTS) do
        out[#out + 1] = inst.symbol
    end
    return out
end

setTimer(function()
    Mzansi.MarketSim.tick()
end, 5000, 0)

addEventHandler("onResourceStart", resourceRoot, function()
    Mzansi.MarketSim.init()
end)
