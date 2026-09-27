# Dossier 04: Hedge Funds, Markets (Crypto/Forex/Options/stocks) & Bot Modeling
**Mode**: Zero-Temperature Deep Research
**Physical Targets** (all verified):
- Mzansi: `mzansi_core/shared/market_config.lua` (Investments L93,103), `server/asset_market.lua` (invest/withdraw/claimInterest), `server/banking.lua` loan tiers, `activity_system.lua:47` (Forex = NPC flavor only)
- Bots: `G:\...\AlgorithmicTrading Bot\`, `G:\...\crypto-trade-fortress-main\`, `E:\...\Algo-Trading\Forex-Trading\`, `G:\...\Crypto\`
- Full corpus detail: Dossier 08

**Status**: Audited

---

## 1. Current Mzansi State

| Capability | Status | Evidence |
|------------|--------|----------|
| Fixed-interest investment pool | EXISTS | `market_config.lua` Investments + `asset_market.lua` claimInterest |
| Price dynamics | ABSENT | no ticker/price series code |
| Crypto / real forex / options / stocks | ABSENT | grep hedge/forex/crypto/option functional = 0 (forex NPC label only) |
| Hedge funds | ABSENT | no fund entities |
| Central reserve (monetary policy) | ABSENT | see Dossier 05 |

**PARTIAL.**

---

## 2. Closed-Economy Market Design (no real money)

### 2.1 Principles

1. **Closed loop**: prices generated in-server (random-walk + volatility regime) — pattern from `Luno-Siya-Bot\src\core\tradingBot.js:385–426` (`simulateMarketData`).
2. **Paper fills**: slippage, commission, fillProbability — `paperTrading.js:14–38`.
3. **Never** call live Alpaca/Luno/OANDA/Binance from the game (credentials/MEV/etc. discarded — Dossier 08 §7).

### 2.2 Asset classes (in-game only)

| Class | Instruments (examples) | Model source |
|-------|------------------------|--------------|
| Crypto | BTCZAR, ETHZAR, custom tokens | random-walk + event shocks |
| Forex | majors + ZAR crosses | mean-reverting GBM-lite |
| Stocks | fictional JSE-like basket | earnings events + drift |
| Options | call/put on above | Black-Scholes-lite or fixed premium ladder |
| Commodities | gold, platinum, oil | slower OU process |

### 2.3 Strategy engine (Lua, pure math) — port from bots

Portable per Dossier 08 (~70%):
- Indicators: SMA/EMA/RSI/MACD/Bollinger/ATR/Supertrend/Ichimoku/ADX/z-score/Donchian
- Strategies: MA cross, RSI mean-rev, MACD hist, Bollinger breakout, ensemble vote (Luno signalGenerator weights 0.4/0.3/0.3)
- Risk: max position %, SL/TP, max drawdown 15%, daily loss 5%, max open positions, cooldown, confidence gate
- Paper engine: commission, slippage, partial fill

Run as **server Angel timer** (e.g. 60s candle batch) — not per-frame.

### 2.4 Hedge funds

Entity:

```
mzansi_funds(id, name, sponsor_char_id, sponsor_type, aum, nav, strategy, status)
mzansi_fund_members(fund_id, char_id, unit_balance, joined_at)
mzansi_fund_tx(...)
```

- Sponsor: player, business, or gang (links Dossier 03 group accounts)
- Minimum ticket; NAV updated on candle tick from paper P&L
- Redemptions with T+n delay (realism)
- Leaderboard: Sharpe/return from bot metrics (`backtest/engine.py:744–773` formulas)

### 2.5 Broker UI

New tabs on asset_market_ui or dedicated `/markets`:
- Watchlist, order ticket (limit/market), positions, fund browse, price chart (DX polyline from last N ticks)

---

## 3. Failure Modes

| Mode | Remediation |
|------|------------|
| Inflation explosion | money supply Angel: reserve bank (05) + sink taxes |
| RNG predictability | seed from server entropy + time; not exposed to clients |
| Tick table bloat | OHLCV rollup; keep raw ticks N hours |
| Player exploit (clock skew) | server-authoritative timestamps only |
| Strategy too strong | risk circuit breakers + max leverage 1.0 |

---

## 4. Verification

- Unit-test indicators in Lua (fixtures from bot test files where JS tests exist: `Luno-Siya-Bot\tests\unit\*`)
- Paper portfolio: 1000 simulated trades → metrics finite, no negative balance without margin rules
- luac -p + meta audit

## 5. Angels

- **Price Process Angel**: candle generation + shock events
- **Risk Angel**: circuit breakers (drawdown/daily loss)
- **Fund NAV Angel**: atomic unit pricing updates
- **Sink Angel**: fees/taxes burned or moved to reserve
