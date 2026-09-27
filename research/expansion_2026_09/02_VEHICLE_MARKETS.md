# Dossier 02: Vehicle Markets — All Provinces
**Mode**: Zero-Temperature Deep Research
**Physical Targets**:
- `mzansi_core/server/world_populator.lua:17` — single `DEALERSHIP` marker
- `mzansi_core/server/asset_market.lua:6–14` — buyVehicle/sellVehicle events
- `mzansi_core/shared/market_config.lua:112` — 3 lots only (car/boat/plane)
- `mzansi_core/shared/shop_config.lua` — province-spread pattern (ammunation/clothing) — **template**
- `mzansi_vehicles/shared/vehicle_config.lua:5–29` — fuel/mod shops LS/SF/LV
- `mzansi_core/client/dashboard.lua:627` — one GPS point
- GTA asset zips: `G:\Games\Gamez Materials\GTA - RockStar\San Andreas\Vehicles\*.zip` (17) — **SP installers only**

**Status**: Audited

---

## 1. Gap Statement

| Fact | Evidence |
|------|----------|
| Exactly one dealership marker | `world_populator.lua:17` |
| Market lots = 3 generic lots | `market_config.lua:112` |
| Province shop infrastructure EXISTS for weapons/clothing | `shop_config.lua` Ammunation + Clothing across 8 provinces |
| No per-province vehicle dealerships | grep DEALERSHIP = 1 location |
| Vehicle .dff packs in GTA folder are **.exe/.mmrc SP installers** | archive listing — NOT MTA resources |

**Status: PARTIAL → target COMPLETE.**

---

## 2. Design (reuse proven pattern)

### 2.1 Location table (mirror shop_config)

New `shared/vehicle_shop_config.lua` in mzansi_core:
- Provinces: LS, SF, LV, (custom maps if present: liberty/vice from mzansi_maps — verify dims at build time)
- Each province: 1–3 dealership coords + blip id + showroom spawn slots
- Categories per branch: economy / luxury / sport / utility / bikes / boats (ports) / planes (airports)

### 2.2 Runtime

- `world_populator`: loop `VehicleShops` → markers `vehicle_shop` + blips
- Marker hit → `mzansi:vehicleshop:open` → server distance check → `mzansi:vehicleshop:setCatalog` → client DX UI (clone shop_ui pattern; **onClientKey wheel, not onClientMouseWheel**)
- Buy: reuse `asset_market` / vehicles exports (`createPlayerVehicle`, cash gate, `maxVehiclesPerPlayer=4`)
- Mutual exclusion: fire `mzansi:bank:close` + `mzansi:shop:closeUI` + dashboard closes on open (set from prior session)

### 2.3 Fleet data

- Phase 1: **stock SA vehicle IDs** (guaranteed MTA-compatible)
- Phase 2: custom models only if raw `.dff/.txd` extracted and packaged as MTA resource — **current GTA zip contents are installers; do not plan on them without extraction pipeline**

### 2.4 Commands / keys

- `/vehicleshop`, GPS entry per province, optional E-interact at marker

---

## 3. Failure Modes

| Mode | Remediation |
|------|-------------|
| Catalog empty | Server-side catalog always non-empty; client fallback message |
| Duplicate spawn collisions | Spawn slot pool + occupied check |
| Money race (double-click) | Server-side atomic removeCash then spawn; idempotent buy token |
| protected core restart | Full server restart after meta additions |

---

## 4. Verification

- luac -p all new/changed lua
- meta.xml src audit = 0 missing
- In-game: marker present each province; buy 1 car; cannot exceed maxVehicles; UI closes bank/phone

## 5. Angels

- **Catalog Integrity Angel**: validate model IDs against MTA valid range before spawn
- **Economy Angel**: cash subtract precedes spawn; rollback on spawn fail
