# Dossier 08: Trading Bots Corpus (Model Library)
**Mode**: Zero-Temperature Deep Research
**Physical Targets** (all EXISTS):
- `E:\Coding-and-Programming\Algo-Trading\Forex-Trading\` (forex swarm + alphavault backtest engine)
- `G:\Coding-and-Programming\AlgorithmicTrading Bot\`
- `G:\Coding-and-Programming\crypto-trade-fortress-main\`
- `G:\Coding-and-Programming\Crypto\`
- Deep-dive: `alphavault\backtest\engine.py` strategies L149–330; Luno paper engine; Fortress risk manager

**Status**: Audited (dossier summary of corpus extraction)

---

## 1. Corpus Inventory (what exists)

| Project | Role | Standout modules |
|---------|------|------------------|
| Forex-Trading / alphavault | Backtest + strategies | `engine.py` 12+ strategies (MA-cross, RSI, MACD, Bollinger, Ichimoku, Supertrend, ROC, Z-score, Donchian, ensemble), metrics L744–773 (Sharpe, DD, win rate) |
| Luno-Siya-Bot (under Crypto tree) | Live+sim exchange bot | `simulateMarketData.js:385–426`, `paperTrading.js:14–38` (slippage, commission, fills), signal weights 0.4/0.3/0.3 |
| crypto-trade-fortress | Hardened bot | risk manager: max DD 15%, daily loss 5%, cooldown, confidence gate |
| AlgorithmicTrading Bot | Multi-strategy runner | config-driven strategy selection, tests |
| Crypto (general) | libs/adapters | exchange adapters patterns |

---

## 2. What MTA Can Reuse (Lua portability)

| Component | Portability | Notes |
|-----------|-------------|-------|
| Indicator math (SMA/EMA/RSI/MACD/BB/ATR/Supertrend/Ichimoku) | **High (~90%)** | pure numeric loops; port to `shared/indicators.lua` with unit fixtures |
| Signal strategies | **High (~85%)** | same; deterministic given indicator series |
| Risk manager | **High (~90%)** | config thresholds + counters |
| Paper fill engine | **Medium (~70%)** | commission/slippage/fill% logic port; exchange APIs DO NOT |
| Backtest harness | **Medium** | port to offline Python/Lua CLI for tuning; in-game uses live paper ticks only |
| Exchange adapters (Alpaca/Oanda/Binance/Luno) | **0% for game** | discarded for in-game (closed economy) |
| WebSocket live feeds | **0% in client; optional server sidecar** | MTA `fetchRemote` poll instead (server) |
| Risk/position sizing | High | |

**Summary**: ~70% of the *quant core* is portable Lua; ~30% infrastructure/exchange stays out.

---

## 3. Explicit Non-Goals

- No real-money trading from game server.
- No storing exchange API keys.
- No copying licensed strategy blogs verbatim — reimplement formulas.

---

## 4. Recommended Port Order (for implementation mandate)

1. `shared/market_indicators.lua` + golden-vector tests
2. `server/market_sim.lua` (price process) 
3. `server/strategy_engine.lua` (signals + risk)
4. `server/paper_portfolio.lua` (fills, fees, NAV hooks)
5. UI watchlist/orders
6. Hedge fund wrappers (Dossier 04)
7. Reserve interactions (Dossier 05)

---

## 5. Verification Strategy

- Golden tests: fixed input series → indicator values match Python reference within epsilon
- Fuzz risk manager: random equity curves → always trips max-DD
- 1k synthetic trades → fee conservation identity holds (cash_in - cash_out - fees = Δbalance)

## 6. Angels

- **Golden Vector Angel**: CI-style Lua tests before enabling strategies in production
- **Key-Free Angel**: forbid exchange credential patterns in resources
