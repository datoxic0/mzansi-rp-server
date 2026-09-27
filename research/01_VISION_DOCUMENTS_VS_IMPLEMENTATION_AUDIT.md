# Dossier 01: Vision Documents vs. Implementation Audit
**Project**: Mzansi-ZA Roleplay Environment  
**Audit Standard**: Zero-Temperature Empirical Codebase Verification  
**Location**: `e:\Games Library\GTA SA MP - Copy\server`  

---

## 1. Executive Summary

A comprehensive, side-by-side audit was performed comparing the **5 foundational strategic vision documents** located in the `server` root directory against the **16 active resources** (`server/mods/deathmatch/resources/mzansi_*`) and the core configuration (`mtaserver.conf`).

The vision documents establish an ambitious architectural standard: a high-fidelity South African MMO roleplay simulation featuring custom regional vehicles (Toyota Quantum taxis, SAPS VW Polo/BMW cruisers), township architecture, low-latency deterministic networking via NAPAfrica/Teraco peering, modern CEF (HTML5/CSS3) interfaces, secure BCrypt authentication, and non-blocking asynchronous data persistence.

However, the empirical audit reveals a substantial disconnect between strategic doctrine and code reality. Key vision commitments remain either partially scaffolded, orphaned, or fundamentally unimplemented.

---

## 2. Document-by-Document Parity Audit

### Document 1: `MTA-SA-Mzansi-ZA.md`
*(Strategic Implementation Plan: Mzansi-ZA Roleplay Environment)*

| Vision Commitment / Directive | Status in Codebase | Physical Evidence & Reality Gap |
| :--- | :--- | :--- |
| **NAPAfrica / Teraco Peering & Port Topology** (UDP 22003, TCP 22005, UDP 22126 ASE) | **Partially Aligned** | `mtaserver.conf` has ports 22003, 22005, and ASE enabled (`<ase>1</ase>`). However, local testing runs on `127.0.0.1` and `httpdownloadurl` is blank (`""`), meaning external CDN offloading is not configured. |
| **Asset Pipeline (.COL $\rightarrow$ .TXD $\rightarrow$ .DFF)** | **NOT IMPLEMENTED** | Zero custom South African vehicle or building models exist in `resources/`. No `.dff`, `.txd`, or `.col` files exist in any of the 16 `mzansi_*` resources. |
| **Dynamic Model Allocation (`engineRequestModel`)** | **NOT IMPLEMENTED** | `engineRequestModel` is never called anywhere in the codebase. All vehicles and skins use vanilla GTA San Andreas model IDs (e.g. 426, 596, 420, 105). |
| **Asynchronous Database (`dbQuery` callbacks, `dbPoll(0)`)** | **VIOLATED** | `server/database.lua` line 262 and line 271 use **`dbPoll(dbQuery(...), -1)`**, forcing a 100% synchronous, thread-blocking query execution that stalls the main server tick loop! |
| **Question Mark Parameterization** | **Compliant** | All database queries correctly use `?` placeholders without vulnerable string concatenation. |
| **Latent Events (`triggerLatentClientEvent`)** | **NOT IMPLEMENTED** | Standard `triggerClientEvent` is used everywhere. Zero calls to `triggerLatentClientEvent` exist in any resource. Heavy payloads like full inventories are sent via standard events. |
| **Event Hardening (`source == client`)** | **Partially Compliant** | Some handlers in `core` check `client or source`, but several resource handlers accept client parameters without authoritative server-side ownership or balance verification. |

---

### Document 2: `The Mzansi-ZA Technical Compendium.md`
*(Architecting a High-Performance MTA:SA Roleplay Ecosystem)*

| Vision Commitment / Directive | Status in Codebase | Physical Evidence & Reality Gap |
| :--- | :--- | :--- |
| **Object-Oriented Architecture (`class(TBL)`)** | **Implemented** | `mzansi_core/shared/class.lua` defines the metatable-based `class()` constructor. However, other resources rarely use it, relying instead on flat procedural tables. |
| **Resource Isolation & Scoping (`resourceRoot`)** | **Partially Violated** | Many handlers bind to `root` instead of `resourceRoot`, permitting event propagation bubbling across the entire element tree. |
| **CEF Interface Integration (HTML5/CSS3)** | **Orphaned / Fragmented** | HTML files exist (`login.html`, `register.html`, `phone.html`, `inventory.html`, `hud.html`), but: <br>1. `login.html` and `register.html` are NOT declared in `mzansi_core/meta.xml`. <br>2. `inventory.html` is NOT declared in `mzansi_inventory/meta.xml`. <br>3. `mdt.html` does NOT exist on disk, causing 404s when `/mdt` is run. <br>4. The client uses fallback DX rendering (`client/login.lua`, `client/dashboard.lua`, `client/phone_client.lua`). |
| **BCrypt Password Hashing (`passwordHash`)** | **VIOLATED & BROKEN** | `server/accounts.lua` lines 26 & 79 call `hash("sha256", password .. username)`. `hash` is NOT an MTA built-in function, causing fatal nil errors on registration/login! The mandated BCrypt algorithm is completely absent. |
| **Payday System Synchronized to Midnight** | **Partially Implemented** | `mzansi_jobs/server/jobs.lua` has a pay interval timer, but it uses a simple recurring interval (`payInterval = 3600000`) rather than calculating `msToMidnight` via `getRealTime()`. |

---

### Document 3: `The Developer’s Dual Reality.md`
*(A Walkthrough of Server-Side vs. Client-Side Scripting)*

| Vision Commitment / Directive | Status in Codebase | Physical Evidence & Reality Gap |
| :--- | :--- | :--- |
| **Server-Authoritative Economy (No client-side money changes)** | **VIOLATED in `mzansi_vehicles`** | `mzansi_vehicles/client/vehicles_client.lua` lines 67-68 attempts to call `Mzansi.Characters.removeCash(cost)` and `Mzansi.Characters.removeBank(cost)` directly from the **CLIENT**, which violates server authority and throws nil errors! |
| **Deterministic RPCs & Bridges** | **Architecturally Bloated** | Instead of a clean export bridge, 12 out of 16 resources physically duplicate the 555-line `server/database.lua` and 314-line `shared/util.lua`. |
| **Camera Matrix Manipulation** | **Implemented** | `mzansi_core/client/login.lua` lines 95-125 features an impressive smooth circular cinematic camera fly-over around Pershing Square / Los Santos during the authentication phase. |

---

### Document 4: `MTA San Andreas Server Setup.md`
*(Technical Architecture, Network Engineering, and Custom Asset Infrastructure)*

| Vision Commitment / Directive | Status in Codebase | Physical Evidence & Reality Gap |
| :--- | :--- | :--- |
| **`bandwidth_reduction` = `none`** | **VIOLATED** | In `server/mods/deathmatch/mtaserver.conf` line 134, `bandwidth_reduction` is set to **`medium`**, which culls packets and causes desynchronization for custom vehicles and mapped objects. |
| **`player_sync_interval` = `50`** | **VIOLATED** | In `mtaserver.conf` line 140, `player_sync_interval` is set to **`100`** (the 10Hz default), failing to provide the 20Hz combat polling rate mandated by the setup document. |
| **Disable Default `play` Gamemode** | **Compliant** | In `mtaserver.conf` line 349, `<resource src="play" startup="0" protected="0" />` is properly disabled. |
| **Disable Default `spawnmanager`** | **Compliant** | In `mtaserver.conf` line 342, `<resource src="spawnmanager" startup="0" protected="0" />` is properly disabled. |
| **Hardened Access Control List (`acl.xml`)** | **NOT CONFIGURED** | `mods/deathmatch/acl.xml` does NOT list any of the `mzansi_*` resources in the `RPC` group or `Admin` group, potentially restricting database operations or privileged MTA commands. |

---

### Document 5: `GTA Multiverse Mod Analysis.md`
*(Autonomous Reverse Engineering & Multi-Game Convergence)*

| Vision Commitment / Directive | Status in Codebase | Physical Evidence & Reality Gap |
| :--- | :--- | :--- |
| **Multi-Engine Spatial Portals (Liberty City / Vice City / SA)** | **Strategic Concept / Future Phase** | The current server instance is a pure MTA:SA 1.6 server. No librw C++ plugins, multiverse portals, or external memory hooks are active in the local server binary (`MTA Server.exe`). |
| **FLA (Fastman92 Limit Adjuster) Tuning** | **Client-Side Requirement** | Server relies on standard MTA:SA element limits. Custom dynamic models and matrix expansion will require client-side package deployment once custom assets are introduced. |

---

## 3. Summary of Vision vs Reality Disconnect

1. **Visual & Cultural Void**: While the vision documents describe Toyota Quantum minibus taxis, SAPS VW Polos, spaza shops, and regional signage, the active server has **zero custom models and an empty map file**.
2. **Interface Disconnection**: Beautiful HTML/CSS mockups exist for Login, Register, Phone, and Inventory, but they are disconnected from the MTA engine or bypassed in favor of raw DX rendering.
3. **Severe Network & Engine Tuning Gaps**: Critical server parameters (`bandwidth_reduction`, `player_sync_interval`) in `mtaserver.conf` remain at legacy defaults rather than the high-performance values mandated by the technical compendium.
4. **Synchronous Blocking I/O Anti-Pattern**: The database layer claims to be asynchronous, but physically executes blocking `dbPoll(-1)` queries that hitch server tick rates.
