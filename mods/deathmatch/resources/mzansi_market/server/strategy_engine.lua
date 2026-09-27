Mzansi = Mzansi or {}
Mzansi.Strategy = Mzansi.Strategy or {}

Mzansi.Strategy.RISK = {
    maxPositionPct = 0.25,
    maxDrawdown = 0.15,
    dailyLossPct = 0.05,
    maxOpenPositions = 5,
    confidenceGate = 0.55,
    commissionRate = 0.001,
    slippageBps = 5,
}

local equityPeak = 100000
local dayStartEquity = 100000
local dayId = 0

function Mzansi.Strategy.resetRisk(startEquity)
    equityPeak = startEquity or 100000
    dayStartEquity = equityPeak
    dayId = tonumber(tostring(getTickCount()):sub(-4)) or 0
end

function Mzansi.Strategy.checkCircuitBreaker(equity)
    if equity <= 0 then return false, "zero_equity" end
    local dd = (equityPeak - equity) / equityPeak
    if dd >= Mzansi.Strategy.RISK.maxDrawdown then
        return false, "max_drawdown"
    end
    local dailyLoss = (dayStartEquity - equity) / dayStartEquity
    if dailyLoss >= Mzansi.Strategy.RISK.dailyLossPct then
        return false, "daily_loss"
    end
    if equity > equityPeak then
        equityPeak = equity
    end
    return true, "ok"
end

function Mzansi.Strategy.smaSignal(closes)
    local sma = Mzansi.Indicators.sma(closes, 10)
    local ema = Mzansi.Indicators.ema(closes, 10)
    if not sma or not ema or #closes < 2 then return nil, 0 end
    local last = closes[#closes]
    if last > sma and ema >= sma then
        return "buy", 0.62
    elseif last < sma and ema <= sma then
        return "sell", 0.60
    end
    return "hold", 0.5
end

function Mzansi.Strategy.rsiSignal(closes)
    local rsi = Mzansi.Indicators.rsi(closes, 14)
    if rsi < 30 then return "buy", 0.65 end
    if rsi > 70 then return "sell", 0.65 end
    return "hold", 0.5
end

function Mzansi.Strategy.macdSignal(closes)
    local macd = Mzansi.Indicators.macd(closes)
    if not macd then return "hold", 0.5 end
    if macd > 0 then return "buy", 0.58 end
    if macd < 0 then return "sell", 0.58 end
    return "hold", 0.5
end

function Mzansi.Strategy.ensemble(closes)
    local votes = { Mzansi.Strategy.smaSignal(closes), Mzansi.Strategy.rsiSignal(closes), Mzansi.Strategy.macdSignal(closes) }
    local score = 0
    local conf = 0
    local weights = { 0.4, 0.3, 0.3 }
    for i, signal in ipairs(votes) do
        local action, c = signal[1], signal[2]
        local w = weights[i] or 0.33
        conf = conf + (c or 0.5) * w
        if action == "buy" then
            score = score + w
        elseif action == "sell" then
            score = score - w
        end
    end
    if conf < Mzansi.Strategy.RISK.confidenceGate then
        return "hold", conf
    end
    if score > 0.15 then return "buy", conf end
    if score < -0.15 then return "sell", conf end
    return "hold", conf
end

function Mzansi.Strategy.fillPrice(side, marketPrice, qty)
    local slip = marketPrice * (Mzansi.Strategy.RISK.slippageBps / 10000)
    if side == "buy" then
        return marketPrice + slip
    end
    return math.max(marketPrice - slip, 0.01)
end

function Mzansi.Strategy.commission(notional)
    return math.max(math.floor(notional * Mzansi.Strategy.RISK.commissionRate), 1)
end

function Mzansi.Strategy.positionSize(equity, price)
    if not equity or not price or price <= 0 then return 0 end
    local notional = equity * Mzansi.Strategy.RISK.maxPositionPct
    return math.floor(notional / price)
end
