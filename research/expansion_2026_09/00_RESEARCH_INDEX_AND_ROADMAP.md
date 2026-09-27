# Dossier 00: Expansion Research Index & Roadmap
**Mode**: Zero-Temperature Deep Research Mandate
**Architect**: Siyabonga Blessing Phakathi
**Physical Target**: `E:\Games Library\GTA SA MP - Copy\server` (+ external refs on E:/G:)
**Status**: Audited (Phase 1–4 complete; Phase 5–6 pending approval)
**Folder**: `server\research\expansion_2026_09\`
**Date**: 2026-09-23

---

## 1. Research Charter

User mandate (verbatim scope):
1. In-game AI chatbot + agent (pattern from Msinga Campus Server)
2. Vehicle markets/shops in ALL provinces
3. Group banking for gangs (+ all group accounts)
4. Entrepreneurship + entrepreneurship banking
5. Modern/technical jobs:
   - Computer Engineering (real scripting, real asset creation, real bug-fixing for game/server)
   - Mechatronics (logic gates, electrical/electronics circuits, PLCs, robots, robotics machinery)
6. Expand banking: group banking, investments, hedge funds (crypto, forex, options, stocks)
7. Central/Reserve Bank
8. Use trading bots as models; reference ASCAD, GTA assets, Lua Workshop, Virtual GPU
9. Deep research dossiers in a dedicated folder (this folder)

**Strict Non-Destructive Invariant**: Zero production Lua/XML/conf modifications during this research phase.

---

## 2. DART Classification

| Domain | Quadrant | Protocol |
|--------|----------|----------|
| Whole expansion program | **Complex** | Small experiments + specialist research |
| Gang banking schema bug | **Chaotic-adjacent / Clear fix** | Act first (schema mismatch is broken today) |
| Lua port of indicators/strategies | **Complicated** | Specialist + unit tests |
| AI sidecar bridge | **Complex** | Bounded experiments (rate limit, fallback) |
| Vehicle province shops | **Clear** | Checklist (reuse shop_config pattern) |
| CE / Mechatronics job UX | **Complex** | Iterate with player tests |

---

## 3. Document Map

| # | Dossier | Scope |
|---|---------|-------|
| 00 | THIS INDEX | Charter, DART, map, boundary audit |
| 01 | AI_CHATBOT_AND_AGENT | Msinga AI pattern → MTA port architecture |
| 02 | VEHICLE_MARKETS | All-province dealerships design |
| 03 | GROUP_BANKING_AND_ENTREPRENEURSHIP | Gang/business group accounts |
| 04 | HEDGE_FUNDS_AND_MARKETS | Crypto/forex/options/stocks + bot modeling |
| 05 | CENTRAL_RESERVE_BANK | Monetary policy / interbank layer |
| 06 | COMPUTER_ENGINEERING_JOB | Real scripting/asset/bugfix job |
| 07 | MECHATRONICS_JOB | Gates/circuits/PLC/robots from ASCAD |
| 08 | TRADING_BOTS_CORPUS | Full bot inventory + Lua portability |
| 09 | REFERENCE_PROJECTS | ASCAD, GTA assets, vGPU, Lua Workshop |
| 10 | PHYSICAL_CODEBASE_AUDIT | Mzansi gap analysis (evidence) |
| 11 | FAILURE_MODES_AND_INVARIANTS | Cross-cutting risks + Angel charges |
| 12 | UNIFIED_CONVERGENCE_SYNTHESIS | One engine design |
| — | `implementation_plan.md` | File-level plan (await approval) |

Prior research (separate cycle, not overwritten): `server\research\00..09, 11_*.md`, `implementation_plan*.md`.

---

## 4. Boundary Audit (Phase 1) — ALL PATHS VERIFIED ON DISK

| Path | Result |
|------|--------|
| `E:\Coding-and-Programming\Msinga-Campus-Server` | EXISTS (23 children; has `research\`) |
| `E:\Coding-and-Programming\ASCAD` | EXISTS (12 children) |
| `G:\Games\Gamez Materials\GTA - RockStar` | EXISTS (8 children) |
| `G:\Coding-and-Programming\Virtual GPU Project` | EXISTS |
| `G:\Coding-and-Programming\AlgorithmicTrading Bot` | EXISTS |
| `G:\Coding-and-Programming\crypto-trade-fortress-main` | EXISTS |
| `G:\Coding-and-Programming\Crypto` | EXISTS |
| `E:\Coding-and-Programming\Algo-Trading\Forex-Trading` | EXISTS |
| `E:\Games Library\GTA SA MP - Copy\server` | EXISTS |
| `...\mods\deathmatch\resources` | EXISTS (25 resource dirs) |
| Global-Skills `msinga_campus_server\SKILL.md` | EXISTS (16888 B) |
| Global-Skills `mtasa_mzansi_rp\SKILL.md` | EXISTS (14132 B) |

**Drives mounted**: C, D, E, F, G present. E: free ≈ 1.0 GB (tight). G: free ≈ 12.1 GB.

**Auth walls**: none — all local filesystem. No URL ingestion.

**Terminology**: Angel Standard enforced — no "daemon" in any dossier.

---

## 5. Strict Truth Protocol

- Every claim must cite `file:line` or empirical command output.
- Absence claims based on exhaustive grep with pattern documented.
- `.env` secrets never read; only `.env.example`.
- No invented APIs. MTA facts grounded in known MTA:SA server/client capabilities + existing codebase patterns.
