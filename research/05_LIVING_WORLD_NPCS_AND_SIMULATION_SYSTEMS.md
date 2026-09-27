# Dossier 05: Living World, NPCs & Simulation Systems
**Project**: Mzansi-ZA Roleplay Environment  
**Audit Standard**: Environmental Simulation & Living World Analysis  
**Physical Source Files**:  
- `server/mods/deathmatch/resources/mzansi_core/server/world_populator.lua` (470 lines)  
- `server/mods/deathmatch/resources/mzansi_core/server/activity_system.lua` (843 lines)  
- `server/mods/deathmatch/resources/mzansi_core/client/activity_client.lua` (161 lines)  

---

## 1. Executive Summary & Existing Foundations

The server already contains a remarkably rich narrative foundation in `world_populator.lua` and `activity_system.lua`. Rather than generic GTA characters, the world is populated by **over 70 uniquely named, culturally localized South African NPCs**, **13 interactive world markers**, **85 ambient street vehicles**, and **5 dynamic server Angel loops**.

However, the world currently feels static because **100% of the NPCs are frozen in place**, street vehicles are unoccupied, and ambient traffic lacks autonomous drivers.

---

## 2. Exhaustive Audit of Existing World Systems

### 2.1 The 70+ South African NPC Roster

```mermaid
graph TD
    subgraph CIVIC [Civic & Services]
        SAPS[SAPS HQ: Desk Sergeant Ndlovu, SWAT Officer van Zyl, Constable Lekota]
        EMS[Hospital: Dr. Mthembu, Sister Khumalo, Sister Naidoo, Dr. Pieterse]
        BANK[Standard Bank: G4S Vault Guard Botha, Guard Smit, Cashier Kgomotso]
        LABOUR[City Hall: Advisor Dlamini, Clerk Sithole, Receptionist Moyo]
    end

    subgraph COMMERCE [Commerce & Trades]
        STORE[24/7 Stores: Sipho, Thabo, Grace, Moses]
        ARMS[Ammu-Nation: Johan, Piet]
        STREET[Street Vendors: Sis Nomsa (Fruit), Bra Mike (Braai Meat Griller)]
        PIER[Santa Maria Pier: Oom Piet, Uncle Moses]
        MECH[Auto Repair: Mechanic Sipho, Apprentice Tshepo]
    end

    subgraph UNDERWORLD [Gangs & Underworld]
        SSK[South Side Kings: OG Smoke, Ryder, K-Dog, Tiny, T-Bone, Peanut]
        ZW[Zulu Warriors: Brother Mandla, Brother Bheki, Brother Siphamandla]
        CD[Crazy Dragons: Triad Sentry Wei, Dragon Li, Dragon Chen]
        TWENTY_EIGHT[Cape Town 28s: General Chesa, Sergeant Boer, Skollie Nats]
        DEALERS[Street Corners: Scarra, K-Mac, Lotto, Speedy]
    end
```

### 2.2 Interactive 3D World Markers & Radar Blips
Thirteen interactive 3D cylinders are positioned at iconic locations:
1. **Airport Starter Rental** (`1675.0, -2250.0, 13.5`) — Instant vehicle rental for new arrivals.
2. **SAPS Duty Station** (`1547.5, -1675.5, 13.5`) — Pershing Square police sign-on.
3. **EMS Hospital Duty** (`1176.8, -1323.0, 13.5`) — All Saints medical sign-on.
4. **City Hall & Careers** (`1481.5, -1745.5, 13.5`) — Job center and work permits.
5. **Standard Bank Central** (`1460.0, -1025.0, 23.5`) — Banking and foreign exchange.
6. **Fishing Pier** (`385.0, -2088.0, 7.8`) — Santa Maria deep-sea fishing.
7. **Auto Repair Ramp** (`1505.8, -1664.2, 13.4`) — Vehicle servicing and engine repairs.
8. **Commerce Taxi Rank** (`1778.0, -1860.0, 13.5`) — Public transport hub.
9. **Auto Dealership** (`2131.5, -1150.5, 24.0`) — Vehicle acquisition.
10. **Ammu-Nation Firearms** (`1368.5, -1279.5, 13.5`) — Arms dealer.
11. **Ocean Docks Depot** (`-532.5, -488.5, 25.5`) — Heavy cargo logistics.
12. **Santa Maria Beach** (`360.0, -2090.0, 3.0`) — Water recreation and jetskis.
13. **Four Dragons Casino** (`2031.0, -1894.0, 13.5`) — Gambling entertainment.

### 2.3 Client-Side 3D HUD Indicators (`activity_client.lua`)
`activity_client.lua` provides visual immersion:
- **Floating 3D Nameplates**: Color-coded by NPC role (Blue for Police, Red for EMS, Orange for Gangs, Purple for Dealers).
- **Line-of-Sight Culling**: Uses `isLineOfSightClear()` so nameplates are not rendered through walls.
- **Distance Scaling**: Dynamically scales text size from 30 meters down to close proximity.
- **Context Interaction**: Displays `[E] Talk to [Name]` when within 3.5 meters.
- **Gang Turf Alerts**: Top-screen warning banners when crossing into SSK, Zulu Warriors, or 28s turf.

---

## 3. What is Missing to Make the World Truly Come Alive

While the static placement of 70 NPCs and 85 vehicles creates the illusion of an active city, the simulation currently suffers from six critical gaps:

### Gap 1: Stationary "Mannequin" Syndrome
Every ped has `setElementFrozen(ped, true)` enabled. They cannot turn, walk, run, or react to gunshots, ambient weather, or vehicle collisions. When a shootout occurs, NPCs continue playing their looped idle animation (`seat_idle`, `dealer_idle`, `M_smk_in`).

### Gap 2: Driverless "Ghost Car" Dynamic Traffic
The dynamic traffic spawner in `activity_system.lua:329` spawns vehicles with `createVehicle()`, but **does not spawn or warp an NPC ped into the driver's seat**. Vehicles appear as stationary empty cars scattered across intersections rather than living, moving traffic.

### Gap 3: Missing Minibus Taxi Transit Loops
Minibus taxis (Toyota Quantums) are the circulatory system of South African cities. In the current server:
- Taxis exist as empty parked vehicles.
- No NPC passengers queue at taxi ranks or hail taxis on street corners.
- Taxi drivers have no route checkpoints or passenger pick-up missions.

### Gap 4: Absence of Audio Atmosphere & Street Soundscape
The world is completely silent aside from default GTA SA ambient vehicle audio:
- No Amapiano / Kwaito music playing from township spaza shops or passing cars.
- No South African voice greetings when pressing `[E]` (e.g., "Sawubona!", "Heita daar!", "Sharp fana!", "Howzit bru!").
- No ambient taxi rank queue marshals calling routes ("Noord! Bree! Soweto!").

### Gap 5: Static Spaza Shops & Street Economics
Street vendors (Bra Mike, Sis Nomsa) are stationary peds with text notifications. Players cannot actually buy boerewors rolls, cold drinks, or airtime vouchers from them.

### Gap 6: Autonomous Police Patrols
SAPS vehicles remain parked in the police station courtyard. No AI police cruisers actively patrol high-crime corridors (Ganton, Idlewood, Ocean Docks) or respond autonomously with sirens to dynamic emergency calls.
