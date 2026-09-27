# Implementation Plan — Mzansi Expansion (2026-09)
**Status**: DRAFT — **awaiting user approval. No production files modified by research phase.**
**Research source**: `server\research\expansion_2026_09\` (dossiers 00–12)
**Validators (baseline green)**: LUA OK=20 FAIL=0 · META SRC 92/0 missing · XML OK=3

---

## Job Description (execution)

- **Outcome**: Phased delivery of AI, all-province vehicle shops, group/business banking, reserve bank, multi-asset markets/hedge funds, CE + Mechatronics jobs — each phase validator-green and playtested.
- **Tool Boundaries**: edit only under `mods\deathmatch\resources\mzansi_*` (+ conf startup entries when new resources added); use Global-Skills patterns; no exchange keys; no ASCAD source copies.
- **Verification Protocol**: three validators + targeted in-game checks per phase; stop & escalate on Stop Conditions (Dossier 11 §3).
- **DART**: Complex → Small Experiments / Specialist per phase.
- **Skill Triage**: ESSENTIAL job-os-governor, deep-research, strict-truth, agentic-guardrails, dynamic-drive-resolver; RECOMMENDED mtasa-mzansi-rp + msinga-campus-server (AI); LUXURY sentient-architect/enorch; GAP: future `mta-ai-bridge` skill.

---

## Change Taxonomy

`[NEW]` new file · `[MODIFY]` edit · `[DELETE]` remove · `[TEST]` validator/test only

---

## P0 — Stabilize (do first)

| Op | File | Work |
|----|------|------|
| MODIFY | `mzansi_gangs/server/gangs.lua` | `balance`→`treasury` (or migration); load treasury on init; rank-gated withdraw; tx log |
| MODIFY | `mzansi_gangs/server/database.lua` | assert/migrate money column |
| MODIFY | `mzansi_crime/server/*.lua` (grep hits) | replace `Mzansi.Inventory.*` with `exports.mzansi_inventory` guards |
| MODIFY | `mzansi_drugs/server/*.lua` | same |
| MODIFY | `mzansi_illegalmarket/server/*.lua` | same |
| TEST | validators ×3 | must stay green |

## P1 — Group + entrepreneurship banking

| Op | File | Work |
|----|------|------|
| NEW | `mzansi_core/server/group_accounts.lua` | accounts + transactions CRUD, ranks, settlement |
| MODIFY | `mzansi_core/server/database.lua` | tables + `runMigrations` |
| MODIFY | `mzansi_core/server/banking.lua` | Groups tab status payload |
| MODIFY | `mzansi_core/client/banking_ui.lua` | Groups UI (closeOthers already includes bank) |
| MODIFY | `mzansi_core/meta.xml` | script tags |
| MODIFY | `mzansi_gangs/server/gangs.lua` | back onto group_accounts or keep treasury + mirror |
| MODIFY | housing/business hooks | credit `mzansi_business_ownership` + group account |
| NEW | `mzansi_core/shared/group_config.lua` | ranks, limits, interest flags |

## P2 — All-province vehicle markets

| Op | File | Work |
|----|------|------|
| NEW | `mzansi_core/shared/vehicle_shop_config.lua` | province matrix, coords, fleets (stock IDs) |
| MODIFY | `mzansi_core/server/world_populator.lua` | loop shops; keep existing DEALERSHIP |
| MODIFY | `mzansi_core/server/asset_market.lua` | open catalog events, buy path (reuse createPlayerVehicle) |
| NEW | `mzansi_core/client/vehicle_shop_ui.lua` | DX/CEF UI, wheel via onClientKey, closeOthers |
| MODIFY | `mzansi_core/client/dashboard.lua` | GPS entries |
| MODIFY | `mzansi_core/meta.xml` | registrations |
| TEST | buy/fuel/maxVehicles per province | |

## P3 — Reserve bank v1

| Op | File | Work |
|----|------|------|
| NEW | `mzansi_core/server/reserve_bank.lua` | policy table, apply interest, supply snapshot, admin ops, audit |
| MODIFY | `mzansi_core/server/database.lua` | `mzansi_reserve_policy`, `mzansi_money_supply` |
| MODIFY | `mzansi_core/server/banking.lua` | policy_rate → interest/APR; wire `taxRate` |
| MODIFY | `mzansi_jobs/server/jobs.lua` | payday uses policy (remove hard-coded only-interest path carefully) |
| NEW | `mzansi_core/client/reserve_ui.lua` | admin panel |
| MODIFY | `mzansi_core/meta.xml` | tags |

## P4 — Markets v1 (crypto/forex/stocks paper)

| Op | File | Work |
|----|------|------|
| NEW | `mzansi_market/shared/indicators.lua` | port from alphavault engine |
| NEW | `mzansi_market/server/price_sim.lua` | random-walk/OU candles |
| NEW | `mzansi_market/server/strategy_engine.lua` | signals + Fortress-style risk |
| NEW | `mzansi_market/server/paper_portfolio.lua` | fills, fees, positions |
| NEW | `mzansi_market/server/market_db.lua` | OHLCV rollups |
| NEW | `mzansi_market/client/market_ui.lua` | watchlist/tickets |
| NEW | `mzansi_market/meta.xml` | |
| MODIFY | `mtaserver.conf` | `<resource src="mzansi_market" startup="1" …>` |
| TEST | golden indicator vectors; fee identity; DD circuit breaker | |

## P5 — Hedge funds

| Op | File | Work |
|----|------|------|
| NEW | `mzansi_market/server/funds.lua` | funds, units, NAV, redeem delay |
| MODIFY | `mzansi_market` DB/UI | fund browse, sponsor links (gang/business acct) |

## P6 — Computer Engineering job (id 13)

| Op | File | Work |
|----|------|------|
| MODIFY | `mzansi_core/shared/enums.lua` | `COMPUTER_ENGINEER=13` |
| MODIFY | `mzansi_core/shared/job_config.lua` | job def + application |
| MODIFY | `mzansi_jobs/shared/job_config.lua` | Activities[13] + tickets config |
| MODIFY | `mzansi_jobs/server/jobs.lua` | ticket ledger, payouts |
| NEW | `mzansi_ce/server/sandbox.lua` | allowlist evaluator |
| NEW | `mzansi_ce/client/ce_ui.lua` | board + editor CEF |
| NEW | `mzansi_ce/meta.xml` | |
| MODIFY | `mtaserver.conf` | startup if split resource |

## P7 — Mechatronics job (id 14)

| Op | File | Work |
|----|------|------|
| MODIFY | enums + job_config | id 14 + skill |
| NEW | `mzansi_mech/server/puzzles.lua` | truth table, ladder, arm, scoring |
| NEW | `mzansi_mech/client/puzzle_ui.lua` | DX/CEF stages |
| NEW | `mzansi_mech/shared/curriculum.lua` | stages 1–10 (original) |
| NEW | `mzansi_mech/meta.xml` | |
| MODIFY | inventory shared items | toolkit/module items if missing |

## P8 — AI v1 (Mode A recommended default)

| Op | File | Work |
|----|------|------|
| NEW | `mzansi_ai/server/ai_bridge.lua` | rate limit, session rebuild, fetchRemote provider, reflex fallback |
| NEW | `mzansi_ai/server/ai_db.lua` | messages table |
| NEW | `mzansi_ai/client/ai_ui.lua` | CEF chat (Msinga AICopilotPage patterns) |
| NEW | `mzansi_ai/shared/ai_config.lua` | provider base URL, model, TASKS presets (no secrets) |
| NEW | `mzansi_ai/meta.xml` | |
| MODIFY | `mtaserver.conf` | startup |
| SECURE | key storage | sidecar/server-only; never meta/client |

**Mode B option**: Node sidecar port of `ai_service.js` (providers, audit, TASKS) — pick if Phase 8 approved.

## P9 — AI agents v2

| Op | File | Work | Status |
|----|------|------|--------|
| MODIFY | `mzansi_ai/server/ai_bridge.lua` | tool loop MAX 8, allowlist | DONE |
| NEW | `mzansi_ai/server/ai_tools.lua` | read_snippet, query_game_db, get_player_stats, list_open_bugs, tutor | DONE |
| MODIFY | CE/Mech integration | tutorHint exports + AI tutor tool | DONE |
| MODIFY | `mzansi_ai/client/ai_ui.lua` | `/aiagent` command | DONE |
| MODIFY | `mzansi_ai/meta.xml` | ai_tools script + listTools/runTool exports | DONE |

**P9 COMPLETE** — luac-OK, meta OK, tools smoke PASS (allowlist + path jail + SQL table reject).

---

## Order & Checkpoints

1. P0 (stabilize) — **mandatory first**
2. Then any order among P1, P2, P8 (parallel-safe if different resources)
3. P3 after P1 (policy applies to real products)
4. P4 → P5 sequential
5. P6/P7 after P1 (payouts to accounts OK even if solo)
6. P9 last

**User checkpoint after every phase**: validators + short playtest notes before next phase.

---

## Validation Commands (each phase)

```powershell
bash powershell -ExecutionPolicy Bypass -File "C:\Users\ASIKHU~1\AppData\Local\Temp\opencode\validate_all.lua.ps1"
bash powershell -ExecutionPolicy Bypass -File "C:\Users\ASIKHU~1\AppData\Local\Temp\opencode\validate_meta_src.ps1"
bash powershell -ExecutionPolicy Bypass -File "C:\Users\ASIKHU~1\AppData\Local\Temp\opencode\validate_xml_batch.ps1"
```

Counts: expect LUA=20+new files OK, META missing=0, XML OK=3+. Update counts as files are added.

---

## Out of Scope Until Explicit Request

- Real exchange APIs, real-money anything
- ASCAD source embedding / commercial use
- SP GTA mod installation into MTA
- Auto-commit (no git repo)
- Lua Workshop path until user confirms
