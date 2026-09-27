# Dossier 09: Reference Projects (ASCAD, GTA Assets, vGPU, Lua Workshop, Msinga)
**Mode**: Zero-Temperature Deep Research
**Boundary audit**: all paths EXISTS (see 00 §4)

**Status**: Audited

---

## 1. ASCAD — mechatronics + software suite

**Path**: `E:\Coding-and-Programming\ASCAD`

| Asset | Use for mandate |
|-------|-----------------|
| Learning Case Study (3 subjects) | Mechatronics job curriculum outline (Dossier 07) |
| Digital Logic Lab | Stage 1–3 puzzle inspiration (re-implement) |
| Analog Schematic Editor | Stage 4–5 |
| VoltLogicPRO | Stage 6 PLC ladder patterns |
| Robot Workspace | Stage 8 arm paths |
| **License VEO-SA-NC-1.0** | Commercial/royalty constraints — **do not embed source** |

Pedagogy OK. Source files out of scope without legal sign-off.

---

## 2. GTA assets — `G:\Games\Gamez Materials\GTA - RockStar`

| Item | Finding |
|------|---------|
| `San Andreas\Vehicles\*.zip` (17) | Content = **SP installers (.exe/.mmrc)** not ready `.dff/.txd` for MTA |
| `.asi`/`.cleo` mods | **Single-player injection — incompatible with MTA:SA** |
| Usable path | Extract models only if zip contains raw dff/txd; then package as MTA resource with model IDs in free range |

**Plan implication**: Vehicle shops (Dossier 02) Phase 1 = stock models. Custom models = separate extract/convert/verify pipeline (not free).

---

## 3. Virtual GPU Project — `G:\Coding-and-Programming\Virtual GPU Project`

| File | Relevance |
|------|-----------|
| `host_system.py`, `vGPU_Project.py` | Systems-engineering flavor for CE advanced tickets |
| `1testshader.shader` | Optional advanced CE "shader logic" theory ticket |

Not executable in MTA client as-is. Use as **lore/tutorial content**, not runtime.

---

## 4. Lua Workshop (user-referenced)

No path supplied in this message. **Unverified** — do not invent location. When implementation reaches CE snippet editor / model pipeline, re-confirm path with user or search under E:/G: with user consent.

Prior session corpus mentioned Lua tooling generally; `luac.exe` at `C:\Program Files (x86)\Lua\5.1\luac.exe` is the local syntax gate.

---

## 5. Msinga Campus Server — primary AI + ops pattern

**Path**: `E:\Coding-and-Programming\Msinga-Campus-Server`

Already dissected in Dossier 01 (`ai_service.js`, agentic engine, copilot UI, rate limit, audit). Secondary reuse:

- EWMA monitor / diagnostics patterns → optional ops Angel later
- Dual-auth patterns → **not required** (game has its own account system)
- Research folder `Msinga-Campus-Server\research\` → architectural caution (ports, redirect loops) — N/A to MTA

---

## 6. Consolidated do-nots

1. Do not copy ASCAD source (license).
2. Do not install GTA SP mods into MTA.
3. Do not ship API keys in client files.
4. Do not reference unverified "Lua Workshop" path in implementation until confirmed.
