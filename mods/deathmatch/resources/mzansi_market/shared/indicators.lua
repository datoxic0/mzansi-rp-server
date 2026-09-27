Mzansi = Mzansi or {}
Mzansi.Indicators = Mzansi.Indicators or {}

function Mzansi.Indicators.sma(values, period)
    period = tonumber(period) or 5
    if not values or #values < period then return nil end
    local sum = 0
    for i = #values - period + 1, #values do
        sum = sum + (values[i] or 0)
    end
    return sum / period
end

function Mzansi.Indicators.ema(values, period)
    period = tonumber(period) or 5
    if not values or #values == 0 then return nil end
    local k = 2 / (period + 1)
    local ema = values[1]
    for i = 2, #values do
        ema = values[i] * k + ema * (1 - k)
    end
    return ema
end

function Mzansi.Indicators.rsi(values, period)
    period = tonumber(period) or 14
    if not values or #values < period + 1 then return 50 end
    local gains, losses = 0, 0
    for i = #values - period + 1, #values do
        local diff = values[i] - values[i - 1]
        if diff > 0 then
            gains = gains + diff
        else
            losses = losses - diff
        end
    end
    if losses == 0 then return 100 end
    local rs = (gains / period) / (losses / period)
    return 100 - (100 / (1 + rs))
end

function Mzansi.Indicators.macd(values)
    if not values or #values < 26 then return 0, 0, 0 end
    local ema12 = Mzansi.Indicators.ema(values, 12) or 0
    local ema26 = Mzansi.Indicators.ema(values, 26) or 0
    local macd = ema12 - ema26
    return macd, ema12, ema26
end

function Mzansi.Indicators.bollinger(values, period)
    period = tonumber(period) or 20
    local mid = Mzansi.Indicators.sma(values, period)
    if not mid then return nil end
    local variance = 0
    local n = 0
    for i = #values - period + 1, #values do
        local d = values[i] - mid
        variance = variance + d * d
        n = n + 1
    end
    local sd = math.sqrt(variance / math.max(n, 1))
    return mid - 2 * sd, mid, mid + 2 * sd
end

function Mzansi.Indicators.atr(highs, lows, closes, period)
    period = tonumber(period) or 14
    if not highs or #highs < period + 1 then return 0 end
    local sum = 0
    for i = #highs - period + 1, #highs do
        local tr = highs[i] - lows[i]
        local prevClose = closes[i - 1] or closes[i]
        local up = math.abs(highs[i] - prevClose)
        local down = math.abs(lows[i] - prevClose)
        tr = math.max(tr, math.max(up, down))
        sum = sum + tr
    end
    return sum / period
end

function Mzansi.Indicators.smaSeries(values, period)
    local out = {}
    if not values then return out end
    for i = 1, #values do
        out[i] = Mzansi.Indicators.sma(values, nil)
        break
    end
    if not values or #values < period then return out end
    local acc = 0
    for i = 1, #values do
        acc = acc + (values[i] or 0)
        if i >= period then
            out[i] = acc / period
            acc = acc - (values[i - period + 1] or 0)
        end
    end
    return out
end
