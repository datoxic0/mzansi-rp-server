# Dossier 12: Unified Convergence Synthesis
**Mode**: Phase 6 culminating blueprint
**Prerequisite**: Dossiers 00–11 complete
**Status**: **AWAITING USER APPROVAL — no production code**

---

## 1. One Sentence

Govern Mzansi as a single **Economic Operating System**: AI tutor/agent on top, dual labor market (service jobs + CE/mechatronics engineers) feeding a closed multi-asset market, cleared by group accounts and a reserve bank — all built on the existing validated activity/banking/UI framework.

---

## 2. Layered Architecture (target)

```
L5  AI Layer (mzansi_ai)            — chat, tasks, tutor, safe tools
L4  Professions                     — existing jobs + CE(13) + Mechatronics(14)
L3  Markets                         — shops all provinces, vehicles, securities, hedge funds
L2  Finance Core                    — personal bank, group accounts, business banking, reserve bank
L1  Platform                        — mzansi_core (config, DB, enums, exports), inventory, validators
```

Dependency rule: build **bottom-up** for L1–L2, but user-visible spikes can go vertical (thin slice) per phase.

---

## 3. Phased Delivery (proposal)

| Phase | Name | Contents | Restart class |
|------:|------|----------|---------------|
| **P0** | Stabilize | Fix gang `treasury` SQL (D2); replace residual `Mzansi.Inventory.*` in crime/drugs/illegalmarket (D1) with export guards | Full (core if touched) or partial per resources |
| **P1** | Group + business banking | `mzansi_group_accounts` + tx ledger; activate `business_ownership`; bank UI Groups tab; fix ranks | Full (core banking) |
| **P2** | Vehicle province shops | shop_config-style matrix; open/buy UI; stock fleet | Partial+core config |
| **P3** | Reserve bank v1 | policy rates wired to interest; wire `taxRate`; admin panel; supply snapshots | Full (core) |
| **P4** | Markets v1 | indicators + sim + paper portfolio + watchlist UI (stocks/crypto/forex flavor) | Partial (new resource) |
| **P5** | Hedge funds | fund entities, NAV, sponsor=gang/business links | Partial |
| **P6** | CE job 13 | tickets, checklist loops, sandbox spike behind flag | Partial (jobs + new ce res) |
| **P7** | Mechatronics 14 | puzzle engine stages 1–10, crafts | Partial |
| **P8** | AI v1 | `mzansi_ai` server bridge + CEF chat + rate limit + reflex fallback | Partial |
| **P9** | AI agents v2 | allowlisted tools, sessions table, TASKS presets | Partial |

Each phase: write code → run three validators → in-game test → user checkpoint.

---

## 4. Vertical Slice (if user wants fastest "wow")

**P0 + P2 + P8-mini**: fix bank bug, multi-province car shop, basic `/ai` chat. Demonstrates mandate breadth with least coupling.

---

## 5. Skill / Governance Recap

- DART: Complex overall → small experiments per phase
- ESSENTIAL loaded: job-os-governor, deep-research, strict-truth, agentic-guardrails, dynamic-drive-resolver
- Domain: mtasa-mzansi-rp (SKILL.md path), msinga-campus-server (AI pattern) — from Global-Skills
- GAP: no dedicated "MTA AI bridge" skill — candidate for future skill creation after P8 stabilizes (flag only)

---

## 6. What We Will NOT Do (this approval cycle)

- Modify production Lua/XML/mtaserver.conf
- Read secret `.env`
- Embed ASCAD/GTA proprietary sources
- Live exchange connectivity
- Player-writable production files

---

## 7. Decision Needed From You

1. Approve `implementation_plan.md` as written?
2. Phase order: stabilize-first (P0→P9) vs vertical slice (P4 §4)?
3. AI: Mode A (Lua fetchRemote) vs Mode B (Node sidecar)?
4. Confirm whether "Lua Workshop" has a specific path to add to boundary audit.
