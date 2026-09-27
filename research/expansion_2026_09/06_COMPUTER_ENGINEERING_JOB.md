# Dossier 06: Computer Engineering Job
**Mode**: Zero-Temperature Deep Research
**Physical Targets**:
- Job framework: `mzansi_core/shared/job_config.lua` (IDs 0–12), `mzansi_jobs/server/jobs.lua` (activity engine), `mzansi_jobs/shared/job_config.lua` (Activities 6–11), `mzansi_jobs/client/jobs_client.lua` (stops, ENTER)
- Enums: `mzansi_core/shared/enums.lua:5` `BUSINESS_OWNER=12`
- Prior mandate pattern: taxi/bus/farmer/miner/delivery/mechanic activity loops (validated)
- Virtual GPU Project: `G:\Coding-and-Programming\Virtual GPU Project\` (`host_system.py`, `vGPU_Project.py`, `1testshader.shader`)
- Lua Workshop (referenced by user — see Dossier 09)
- Existing bug inventory (session history): cross-VM `Mzansi.Inventory` calls, Lua 5.3 `+=`, server `playSoundFrontEnd`, `onClientMouseWheel`, unwired closeOthers — all FIXED in prior mandate; remaining known broken: `mzansi_crime`, `mzansi_drugs`, `mzansi_illegalmarket` still call `Mzansi.Inventory.*`

**Status**: Audited (design only)

---

## 1. Concept

**Computer Engineering** = a legal job whose work is *actually* engineering for this server: write Lua snippets, create/inspect assets, triage and fix real bug tickets. Pay comes from completing real tickets, not from walking between waypoints pretending to type.

---

## 2. Job Identity

| Field | Value |
|-------|-------|
| ID | **13** (next after BUSINESS_OWNER=12) |
| Name | `COMPUTER_ENGINEER` |
| Employer | `mzansi_core` / "Mzansi Digital" (fictional campus IT firm) |
| Unlock | application via existing `/job apply` + new entry in job_config |
| Skills | `mzansi_jobs/shared/job_config.lua` Skills already has Computer Engineering 0–4 — wire it |
| Payday | salary + ticket completion bonuses |

---

## 3. Work Types (three pillars — user mandate)

### Pillar A — Real scripting tickets
- Server generates tickets from a **curated bug/feature board** (new table `mzansi_ce_tickets`).
- Phase 1 (game loop): pick ticket → NPC workstation marker (campus/central bank office) → timer + checklist of "run debug / patch / verify" actions with tool props → payout.
- Phase 2 (meta): ticket types like "fix cross-resource Inventory call in resource X" — **the three broken resources are living curriculum content** (fix them in a later implementation mandate with user approval; CE job references them as closed educational tickets once fixed).
- Phase 3 (optional): **sandboxed snippet editor** — CEF textarea, server validates against a **pure-Lua expression whitelist** (no `io`, `os`, `require`, `debug`), runs in sandbox, scores correctness. Never load arbitrary player code into real resource VMs.

### Pillar B — Real asset creation
- Work orders: "produce texture variant / dff metadata note" style tasks that teach pipeline; payout when player completes multi-step workflow (collect reference → workshop timer → deliver to mailbox NPC).
- MTA cannot hot-load arbitrary `.dff` from players safely. **Reality constraint**: asset creation tickets are *simulated production pipeline* + admin-reviewed real submissions out-of-band if ever enabled.
- Virtual GPU / shader material (Dossier 09): theory snippets for advanced CE tickets (optional flavor).

### Pillar C — Real bug-fixing for game/server
- Ticket board seeded from **actual codebase smells** (grep-derived), severity-coded.
- Completion = verify steps the player performs in-game (restart resource at debug studio? not possible mid-session for protected core) → **player completes a diagnostic checklist minigame** (find the bad line in a *fictional* snippet that mirrors a real bug pattern).
- Server scores checklist; wrong answers cost durability/toolwear.

**Truth note**: Real production patches remain an **out-of-game developer** activity (this session's code). The job must never expose live file write to players.

---

## 4. Integration Points

| Need | Reuse |
|------|-------|
| Apply/quit/work loop | `jobs.lua` activity engine |
| Stops/markers | `job_config.lua` Activities[] pattern (id 13) |
| Inventory rewards | `exports.mzansi_inventory:addItem` (pc_toolkit, etc.) |
| UI | DX prompt via `jobs_client.lua` + optional CEF editor resource `mzansi_ce` |
| Group/employer pay | business account (Dossier 03) "Mzansi Digital" |
| AI assist (01) | `/ai` task `ce_code_review` for tutor hints |

---

## 5. Progression

1. Intern: checklist tickets (Easy)
2. Technician: multi-step debug journeys
3. Engineer: sandbox snippet solve (medium fixtures)
4. Systems: coord with mechatronics joint tickets (07)
5. Lead: manage ticket board (view only) + review bonus

XP from `addXP`; skill bar Computer Engineering already in skills config.

---

## 6. Failure Modes

| Mode | Remediation |
|------|------------|
| Player Lua escapes sandbox | allowlist AST/regex + forbid identifiers; run in stripped env with instruction budget |
| Cheating timer skips | server-side duration + action proofs |
| Ticket dupe farm | one completion per ticket_id per char; daily cap |
| Revealing real vuln text | tickets use sanitized excerpt, never live secrets |

---

## 7. Verification (post-build)

- `/job apply` id 13 listed; work loop starts/stops; payout once per ticket
- luac -p; meta src 0 missing; mutual-exclusion closeOthers
- Sandbox: attempt `os.execute` → rejected

## 8. Angels

- **Sandbox Angel**: code execution jail
- **Ticket Ledger Angel**: single-credit enforcement
- **Progression Angel**: XP/skill gates
