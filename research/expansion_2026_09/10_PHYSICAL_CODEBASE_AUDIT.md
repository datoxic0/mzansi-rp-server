# Dossier 10: Physical Codebase Audit — Mzansi Gap Analysis
**Mode**: Zero-Temperature (evidence-tight)
**Scope**: `E:\Games Library\GTA SA MP - Copy\server\mods\deathmatch\resources\mzansi_*`
**Status**: Audited (Phase 3 extraction; absolute paths verified)

---

## 1. Inventory Snapshot

25 resource dirs under `mods\deathmatch\resources` (session-established): core, jobs, inventory, banking assets via core, gangs, vehicles, phone, housing, hud, anticheat, crime, drugs, illegalmarket, maps, saps, ems, intel, radio, freeroam, admin, etc. `mtaserver.conf` startup list L356–378; `mzansi_core` **protected=1** (L356).

---

## 2. Mandate Capability Matrix

| # | Requirement | Status | Hard evidence |
|---|-------------|--------|---------------|
| 1 | AI chatbot/agent | **ABSENT** | grep `ai_service\|openrouter\|copilot\|chatbot\|GPT\|llm` = 0 in mzansi_* |
| 2 | Per-province vehicle markets | **PARTIAL** | `world_populator.lua:17` single DEALERSHIP; `market_config.lua:112` 3 lots; shop_config has full province matrix (template) |
| 3 | Gang group banking | **BROKEN/PARTIAL** | `gangs.lua:506,538` UPDATE `balance`; schema `treasury` (`gangs/database.lua:189`); balance never loaded |
| 4 | Entrepreneurship banking | **PARTIAL** | `business_ownership` CREATE only `core/database.lua:194–196`; no CRUD; loan tier exists `banking.lua:16–21`; enum 12 |
| 5a | Computer Engineering job | **ABSENT** | IDs 0–12 only; no ID 13; no CE activity |
| 5b | Mechatronics job | **ABSENT** | no ID 14; no mech skill |
| 6 | Investments/hedge (crypto/forex/options/stocks) | **PARTIAL** | fixed pools `market_config.lua:93,103` + asset_market invest/claim; no price engine; forex = NPC label `activity_system.lua:47` |
| 7 | Central/Reserve Bank | **PARTIAL** | marker `world_populator.lua:16`; teller `activity_system.lua:44–47`; **no policy mechanics**; `taxRate` config unused |
| 8 | Group accounts (non-gang) | **ABSENT** | grep group/joint account = 0 |

---

## 3. Structural Assets We Build On (already good)

- Activity engine (taxi/bus/farmer/miner/delivery/mechanic) — validated prior mandate
- Mutual-exclusion `closeOthers` (incl. intel contacts)
- `invHas/invAdd` export guards — **new cross-resource pattern**
- DX shop/bank UIs with onClientKey wheel
- Validators: `validate_all.lua.ps1` (20), `validate_meta_src.ps1` (92/0), `validate_xml_batch.ps1` (3)
- Char bridge: `mzansi_jobs/server/characters.lua` ↔ core exports

---

## 4. Known Residual Defects (out of current research edits; plan for implementation phase)

| ID | Defect | Severity |
|----|--------|----------|
| D1 | `mzansi_crime`, `mzansi_drugs`, `mzansi_illegalmarket` still call `Mzansi.Inventory.*` cross-VM | High (runtime nil) |
| D2 | Gang treasury SQL column mismatch | High (broken feature) |
| D3 | `taxRate` never charged | Medium (economy) |
| D4 | Single dealership only | Feature gap (mandate) |
| D5 | No AI surface | Feature gap |
| D6 | `business_ownership` dead | Feature gap |

D1–D2 should ride along in implementation plan as **stabilization tickets**.

---

## 5. Constraints Recap

- Full restart for core changes (protected=1)
- Lua 5.1 (no +=, no goto dependency)
- Meta src existence mandatory
- No cross-resource global tables (exports/events/elementData only)
- `bindKey` lowercase; no `onClientMouseWheel`; `playSoundFrontEnd` client-only

---

## 6. Angels

- **Regression Angel**: keep 20/92/3 validators green every phase
- **Schema Angel**: migrations idempotent; column truth single-source
