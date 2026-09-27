# Dossier 11: Failure Modes & Cross-Cutting Invariants
**Mode**: Zero-Temperature auditor pass
**Status**: Audited

---

## 1. System-Level Failure Modes

| # | Failure | Root cause | Detection | Remediation (implementation) |
|---|---------|------------|-----------|------------------------------|
| F1 | Protected-core hot-edit miss | `protected="1"` on core | docs + restart checklist | Full server restart after core meta/script edits |
| F2 | Cross-VM nil (`Mzansi.*` other resource) | Lua VM isolation | residual D1 grep | exports + nil guards (pattern from jobs invHas) |
| F3 | Schema drift (balance vs treasury) | parallel migrations | SQL error on use | single `runMigrations` + column assertions |
| F4 | Lua 5.3 syntax (`+=`) in 5.1 | copy-paste | luac -p gate | keep validator suite |
| F5 | Meta src missing | rename without meta | validate_meta_src | CI-style run before restart |
| F6 | UI stack bleed | overlapping DX/CEF | user reports | closeOthers on every opener |
| F7 | Input API wrong (`onClientMouseWheel`) | MTA nonexistence | client silent fail | onClientKey mouse_wheel_* |
| F8 | Server-only sound on client API | runtime error | log | playSoundFrontEnd only client |
| F9 | Money dupe / race | double-click handlers | audit gaps | server-authoritative atomic ops + idempotency tokens |
| F10 | AI key leak / prompt abuse | bad port | grep client keys | server-only key, rate limit, tool jail (01) |
| F11 | Market inflation | faucet loops | money supply snapshots | reserve sinks (05), fees, caps |
| F12 | Strategy runaway | overfit bot port | risk logs | circuit breakers (04/08) |
| F13 | Player code execution | CE sandbox escape | hostile test | allowlist + instruction budget (06) |
| F14 | License contamination | ASCAD/GTA copy | file audit | re-implement; no source embed (09) |
| F15 | Roadmap overwrite of prior research | same folder numbers | directory listing | **this cycle isolated in `expansion_2026_09\`** |
| F16 | Unverified path (Lua Workshop) | no user path | — | confirm before use (09) |
| F17 | E: disk pressure | ~1.0 GB free | free space | prefer small files; consider G: for bulky assets |

---

## 2. Non-Negotiable Invariants (all implementation phases)

1. **Validators green**: LUA 20/20, META 92/0 missing (or updated counts), XML OK.
2. **No production edits until user approves** `implementation_plan.md`.
3. **Angel terminology** in all docs/code comments (never "daemon").
4. **Zero real-money / exchange keys** in game resources.
5. **Server-authoritative economy** (cash, market, AI rate limits).
6. **closeOthers** wired on every new full-screen UI.
7. **Protected core** ⇒ coordinated full restart; partial reload only for non-protected satellites.
8. **License-clean**: original implementations for pedagogy derived from ASCAD topics only.

---

## 3. Stop Conditions (escalate to human)

- More than 2 skills conflict on a directive
- Any need to read secret `.env` files
- Ambiguous commercial licensing decision (ASCAD royalty)
- Uncertain binary model conversion needing paid tools
- Verification confidence < 80% after validators + targeted tests

---

## 4. Book of Lessons (this research cycle)

- Prior research in `server\research\` numbered 00–09/11 → new cycle must not clobber → used subfolder.
- Parallel explore agents produced grounded file:line evidence — retained in dossiers 01–10.
- GTA "assets" ≠ MTA assets without extraction — prevented a false dependency.
