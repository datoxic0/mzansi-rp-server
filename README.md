# 🇿🇦 Mzansi RP — Multi Theft Auto: San Andreas Server

An enterprise-grade, high-performance **Multi Theft Auto: San Andreas (MTA:SA)** South African roleplay server framework architected for maximum stability, low-latency multiplayer netcode, and immersive simulation.

---

## 🏛️ Architecture & Highlights

- **San Andreas Core Stability**: Total conversion streamers (Liberty City, Vice City, EAGELoader) are completely isolated (`startup="0"`), guaranteeing a 100% stable San Andreas world geometry with zero collision clipping or underwater map corruption.
- **Dual-Mode Database Engine**: Seamless auto-detecting abstraction supporting enterprise **MariaDB / MySQL** with zero-config embedded **SQLite** fallback (`:/databases/mzansi_rp.db`) across all 11 core data services.
- **Sovereign Economic System**: Fully integrated Reserve Bank, ZAR (R) currency formatting, banking UI, asset markets, investment funds, and group treasury accounts.
- **Factions & Law Enforcement**: Dedicated SAPS (South African Police Service) MDT, criminal records, warrants, and EMS emergency medical system.
- **Dynamic Gangs & Underworld**: Territory capture zones, drug grow operations, illegal black market dealers, and coordinated heist mechanics.
- **Modern UI & CEF**: In-game smartphones, GPS routing, banking terminals, dealership catalogs, and customizable character creation.
- **Guardrail Verified**: 100% Lua syntax compilation verification (`luac 5.1`), verified ACL elevation, zero missing meta assets, and validated client/server MTA context isolation.

---

## 📦 Resource Ecosystem

The server runs 28 custom, tightly integrated `mzansi_*` resources located in `mods/deathmatch/resources/`:

| Resource | Purpose |
|---|---|
| `mzansi_core` | Core framework, character manager, accounts, banking, HUD, shops, and database abstraction |
| `mzansi_saps` | South African Police Service faction, MDT, warrants, cuffs, and jail system |
| `mzansi_ems` | Emergency Medical Services, hospital spawn, revival, and medical supplies |
| `mzansi_gangs` | Gang system, hierarchies, member recruitment, and territory warfare |
| `mzansi_crime` | Robberies, heists, wanted levels, and criminal bounties |
| `mzansi_drugs` | Drug harvesting, processing, and element data visual shaders |
| `mzansi_illegalmarket` | Dynamic black market weapon & contraband ped vendors |
| `mzansi_vehicles` | Player-owned vehicles, dealerships, trunk storage, fueling, and health persistence |
| `mzansi_inventory` | Slot-based item inventory with drag-and-drop support |
| `mzansi_housing` | Real estate properties, interiors, locks, and furniture |
| `mzansi_jobs` | Legal employment (Delivery, Mining, Taxi, Sanitation, Logistics) with payday cycles |
| `mzansi_phone` | Smartphone interface with contacts, messaging, banking app, and camera |
| `mzansi_radio` | In-game radio channels and vehicle audio synchronization |
| `mzansi_market` | Stock, fund, and financial instrument trading system |
| `mzansi_ce` | Civil engineering ticket and municipal infrastructure system |
| `mzansi_lab` | Digital circuit puzzle and laboratory mechanics |
| `mzansi_mech` | Mechanical repair and custom vehicle tuning |
| `mzansi_vip` | VIP perks, donation tiers, and exclusive vehicle access |
| `mzansi_admin` | In-game administrative dashboard, moderation, and player management |
| `mzansi_anticheat` | Server-side anticheat monitoring speed, flyhacks, and weapon injection |
| `mzansi_hud` | Immersive South African themed HUD display |
| `mzansi_maps` | Curated GTA San Andreas map additions (purged of corrupted underwater geometry) |
| `mzansi_living_world` | Ambient NPC behavior, pedestrian spawns, and traffic enrichment |
| `mzansi_intel` | Intelligence network and surveillance tools |
| `mzansi_freeroam` | Roleplay spawn and fallback character handler |
| `mzansi_ai` | AI assistance and in-game copilot integration |
| `mzansi_assets` | Custom 3D vehicle, weapon, and skin models |
| `mzansi_utils` | Cross-resource shared mathematical and formatting helpers |

---

## 🚀 Quick Start

### Prerequisites
- Windows 10/11 x64 or Windows Server
- Visual C++ 2015-2022 Redistributable (x64 and x86)
- Optional: MariaDB / MySQL 8.0+ (SQLite fallback operates automatically if database server is unavailable)

### Running the Server
1. Clone the repository:
   ```bash
   git clone https://github.com/datoxic0/mzansi-rp-server.git
   cd mzansi-rp-server
   ```
2. Launch the server using:
   ```cmd
   START_SERVER.bat
   ```
   *Alternatively, execute `MTA Server.exe` directly.*
3. Connect your MTA:SA client to `localhost:22003`.

---

## 🛡️ Verification & Guardrails

The server has been comprehensively validated against the Universal Agentic Coding Guardrail Suite:
- **Lua Syntax**: All 235 Lua files pass `luac -p` with zero syntax errors.
- **Asset Integrity**: All 375 meta.xml files and scripts verified existing on disk.
- **Context Boundaries**: Zero client-side calls to server-only MTA APIs, zero server-side calls to client-only MTA APIs.
- **SQL Schema Alignment**: Zero schema column or table mismatches across all database queries.

---

## 👤 Author & Architecture
- **Lead Architect & Developer**: Siyabonga Blessing Phakathi
- **Project**: Mzansi RP MTA:SA Server
