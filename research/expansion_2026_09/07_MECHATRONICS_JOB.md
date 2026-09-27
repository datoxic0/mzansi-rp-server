# Dossier 07: Mechatronics Job
**Mode**: Zero-Temperature Deep Research
**Physical Targets** (verified):
- `E:\Coding-and-Programming\ASCAD\` — suite: Digital Logic Lab, Analog Schematic Editor, VoltLogicPRO (PLC), Robot Workspace; license **VEO-SA-NC-1.0** (royalty 12% if commercial)
- `ASCAD\Mechatronics Three Subjects Learning Case Study\` — curriculum source
- Mzansi job framework (same as Dossier 06): next ID **14**, Activities pattern
- Joint CE synergies

**Status**: Audited (curriculum mapped; no code)

---

## 1. Concept

**Mechatronics** = legal job: logic gates → electrical/electronics circuits → PLC ladder → robotics machinery. Pay from assembly/repair/calibration tickets and producing sellable machines into the economy (linked to group accounts / shops).

**License constraint**: ASCAD is a learning-study reference — re-implement *pedagogy* (topics, progressions, exercises) in MTA DX/CEF UI; **do not copy ASCAD source files into the resource** without license review.

---

## 2. Job Identity

| Field | Value |
|-------|-------|
| ID | **14** |
| Name | `MECHATRONIC_TECH` |
| Employer | "Mzansi Automation" (fictional) |
| Skills | add `Mechatronics` skill 0–4 (skills file currently lacks it — extend shared config) |
| Tools | `mech_toolkit` item via inventory export |

---

## 3. Curriculum → Game Loops

| Stage | Real concept | In-game task | Payout |
|------:|--------------|--------------|--------|
| 1 | Boolean gates (AND/OR/XOR/NOT/NAND) | Gate-grid puzzle: wire inputs/outputs, server evaluates truth table | Small |
| 2 | Combinational (mux, decoder, adder) | Build truth table from scenario (security keypad) | Small+ |
| 3 | Sequential (latch, counter, FSM) | Sequence controller for conveyor NPC | Medium |
| 4 | Analog electronics (Ohm, divider, RC) | Read meter → pick component values within tolerance | Medium |
| 5 | Circuits board | Solder-sim: place components, continuity check (DX click order) | Medium+ |
| 6 | PLC / ladder (VoltLogicPRO-inspired) | Ladder rung editor (simplified): start/stop, interlock, timer, counter | High |
| 7 | Actuators & sensors | Calibrate proximity/encoder at machine marker (timing minigame) | High |
| 8 | Robotics arm path | Waypoint sequence programming (order matters) + safety interlock | High |
| 9 | Integration | Joint CE ticket: "write PLC logic for our dispenser" (06) | High |
| 10 | Maintenance shift | Real activity stops at machines across map (fan job style) | Salary |

**Puzzle engine**: all evaluation **server-side** (client only paints). Persist per-char stage in character skill XP or `mzansi_mech_progress`.

---

## 4. Assets & Locations

- Workshop hub: reuse campus/industrial district markers; plant equipment at mine/factory-style positions from map config (avoid colliding with miner activities in `job_config.lua` Activities[9]).
- Machines: existing world props + arrow blips (JobsBlips pattern L65–75).

---

## 5. Productization (economy link)

- Completed Stage 5+ can "craft" sellable items: `logic_module`, `plc_basic`, `servo_kit` (inventory add) → sell to businesses / gang group account / vehicle shops (spare parts flavor).
- Fees + material sinks keep inflation in check (ties Dossier 04/05).

---

## 6. Failure Modes

| Mode | Remediation |
|------|------------|
| Client-side puzzle cheat | server evaluates every submission |
| ASCAD IP contamination | original implementations only; no file copy |
| Puzzle state loss on quit | persist progress row; resume prompt |
| Marker overlap with other jobs | unique id space; distance validation like ActivityReach |

---

## 7. Verification

- Stage1 truth table: known vectors pass/fail
- Craft → inventory hasItem count increases; sell path pays group account
- luac -p; meta 0 missing; ENTER/close wiring

## 8. Angels

- **Evaluator Angel**: deterministic puzzle scoring
- **Safety Angel**: robotics interlock failure = no payout (must solve safety first)
- **IP Angel**: no third-party source blobs
