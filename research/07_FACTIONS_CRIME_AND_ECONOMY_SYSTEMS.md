# Dossier 07: Factions, Crime & Economy Systems
**Project**: Mzansi-ZA Roleplay Environment  
**Audit Standard**: Gameplay Loop & Faction Mechanics Dissection  
**Subsystems Audited**:  
- `mzansi_saps` (Police) | `mzansi_ems` (Medical) | `mzansi_gangs` (Territories & Underworld)  
- `mzansi_crime` (Heists & Robberies) | `mzansi_drugs` (Cultivation) | `mzansi_illegalmarket` (Fencing)  
- `mzansi_jobs` (Careers) | `mzansi_housing` (Real Estate)  

---

## 1. Faction Systems Audit

### 1.1 South African Police Service (SAPS)
`mzansi_saps` provides an authentic SAPS roleplay structure:
- **Rank Hierarchy**: Constable (1), Sergeant (2), Captain (3), Colonel (4), Brigadier (5), General (6).
- **Vehicular Fleet**: Marked cruisers (model 596), Enforcer SWAT van (model 601), Police Maverick helicopter (model 497), Police HPV-1000 motorcycle (model 523).
- **Core Mechanics**:
  - `/cuff [target]` — Restricts player movement and sprint controls.
  - `/arrest [target] [time]` — Jails suspects with server-enforced countdown.
  - `/ticket [target] [amount] [reason]` — Issues financial citations deductable from character balance.
  - `/frisk [target]` — Authoritatively inspects target inventory and reports contraband to officer chat.
  - `/dispatch [msg]` — Broadcasts Code 3 911 dispatch calls with coordinates.
- **Identified Blockers**:
  - `getClosestPlayer()` crashes due to Lua multi-return truncation in `Mzansi.Util.distance`.
  - `/mdt` attempts to load non-existent `ui/mdt.html`.
  - Arrested players are not warped into physical jail cells or police holding rooms.
  - Missing police tactical gear: Spikestrips, radar speed gun, and taser.

---

### 1.2 Emergency Medical Services (EMS)
`mzansi_ems` anchors public health and emergency response:
- **Base of Operations**: All Saints General Hospital (Pershing/Market corridor).
- **Vehicular Fleet**: Ambulances (model 416) with medical equipment.
- **Core Mechanics**:
  - `/heal [target]` — Restores health to 100% and charges medical fee.
  - `/revive [target]` — Revives fallen/downed players on scene.
  - `/loadambulance [target]` — Transports critically injured patients to the hospital trauma bay.
  - Downed markers on radar: When a citizen takes fatal damage, an emergency cross blip appears on the radar for online medics.
- **Identified Blockers**:
  - `getClosestPlayer()` crashes due to the same distance truncation bug.
  - No stretcher object model is attached to the player during ambulance loading.

---

### 1.3 The 4-Gang Territory Warfare Engine
`mzansi_gangs/server/gangs.lua` is a remarkably detailed 698-line system modeling South Africa's most prominent street factions:
1. **South Side Kings (SSK)** — Ganton / Grove Street (Blue / #1E90FF).
2. **Zulu Warriors (ZW)** — East Los Santos (Green / #00C800).
3. **Crazy Dragons (CD)** — Market / Chinatown (Red / #FF3232).
4. **Cape Town 28s Numbers Gang** — Idlewood (Gold / #FFC800).

- **Implemented Mechanics**:
  - `/gang create [id] [name] [tag]` — Creates registered gang with custom colors and treasury.
  - `/gang invite [player]` / `/gang accept` — Player recruitment and rank promotions.
  - `/gang deposit [amt]` / `/gang withdraw [amt]` — Shared gang bank account.
  - `/gang tag` (`sprayTag`) — Players can spray paint their gang's insignia on walls in rival territory.
  - `/gang claim` & `/gang attack` — Dynamic turf conquest with a capture timer and defensive alert notifications.
  - `/gang backup` — Sends instant SOS coordinates to all online gang members with radar markers.
- **Identified Blockers**:
  - Distance checks in `checkTerritoryCapture` crash due to `Mzansi.Util.distance`.
  - Territories are not visually marked on the radar map (needs `createRadarArea` with gang colors).

---

## 2. Crime, Drugs & Black Market Systems

### 2.1 Illicit Substance Cultivation (`mzansi_drugs`)
- **Implemented Mechanics**:
  - Planting seeds at designated drug plots (`mzansi_drug_plots` table).
  - Growth simulation over time with water/fertilizer stages.
  - Harvesting into inventory items: Dagga (Weed), Nyaope, Mandrax, Meth.
  - Drug Consumption Effects:
    - Weed: Visual camera drunk filter + health regeneration.
    - Speed/Meth: Movement speed boost + armor boost.
  - Trafficking Runs (`startTrafficRun`): Timed delivery runs across city checkpoints with cash rewards.
- **Gaps**:
  - Plants are purely simulated in the database; no physical 3D plant objects (e.g., weed plant models) are created in the game world at the plot coordinates.

### 2.2 Robberies & Heists (`mzansi_crime` & `activity_system`)
- **Implemented Mechanics**:
  - **Store Robberies**: `/rob` and `/robstore` in 24/7 supermarkets. Peds hold hands up in fear (`SHP_Rob_HandsUp`), 911 alarms sound, wanted level 2 is applied, and player must hold position for 20 seconds to loot R 10,000 - R 25,000.
  - **Armored Bank Heist**: Central Bank vault break-in with multi-phase alarms, police response, and large cash payouts.
  - **Vehicle Chop Shop & Fencing**: Stolen cars can be broken down at Ocean Docks for black market cash.
  - **Mask System**: `/mask` conceals character identity from police logs and floating nameplates.

---

## 3. Economy & Career Systems (`mzansi_jobs`)

The server economy is anchored to the South African Rand (ZAR - R):
- **Starting Cash**: R 5,000 cash, R 25,000 bank.
- **Careers Defined in `shared/config.lua` & `dashboard.lua`**:
  1. **Trucker** (Ocean Docks) — Hauling heavy cargo across provincial routes (R 4,200/load).
  2. **Taxi Driver** (Commerce Rank) — Public transit fares (R 3,500/hr + passenger fares).
  3. **Bus Driver** (Transit Terminal) — Scheduled transit loops (R 3,800/route).
  4. **Mechanic** (JHB Auto Repair) — Vehicle repair, paint jobs, refuel (R 5,500/service).
  5. **Fisherman** (Santa Maria Pier) — Deep-sea and pier angling (R 3,200/catch).
  6. **Delivery Courier** (City Hall) — Package and food deliveries (R 3,000/drop).
  7. **Miner** (Hunter Quarry) — Ore excavation and mineral transport (R 4,800/haul).
  8. **Farmer** (Flint County) — Agricultural crop harvesting (R 3,600/crop).

- **Gaps in Economy**:
  - Several jobs (Miner, Farmer, Courier) are listed in the F1 Dashboard but lack dedicated route scripts in `mzansi_jobs/server/jobs.lua`.
  - The taxi job has no NPC passenger hailing system, making it non-viable when player concurrency is low.
