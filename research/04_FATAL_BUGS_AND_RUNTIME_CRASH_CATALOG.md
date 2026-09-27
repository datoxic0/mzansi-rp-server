# Dossier 04: Fatal Bugs & Runtime Crash Catalog
**Project**: Mzansi-ZA Roleplay Environment  
**Analysis Standard**: Zero-Temperature Empirical Diagnostic Dissection  
**Primary Evidence**: `server/mods/deathmatch/logs/server.log` & Static Call Graph Audit  

---

## 1. Executive Summary

Empirical inspection of `server.log` and static AST analysis across all 108 Lua source files revealed **10 fatal runtime crash vectors**. These bugs are not theoretical edge cases—they are active, breaking defects that cause immediate server console spam, client UI freezes, nil arithmetic crashes, or silent transaction failures during standard gameplay loops.

---

## 2. Fatal Bug Inventory & Diagnostic Analysis

### Bug 1: Missing Global `getElementSpeed` (Server Log Spam & HUD Crash)
- **Severity**: **CRITICAL / BLOCKING**
- **Location**:
  - `mzansi_anticheat/server/anticheat.lua:14`
  - `mzansi_core/client/hud.lua:62, 91`
  - `mzansi_hud/client/hud_client.lua:22`
  - `mzansi_vehicles/client/vehicles_client.lua:20`
- **Empirical Evidence from `server.log`**:
  ```log
  [2026-09-15 05:54:10] ERROR: mzansi_anticheat\server\anticheat.lua:14: attempt to call global 'getElementSpeed' (a nil value)
  [2026-09-15 05:54:16] ERROR: mzansi_anticheat\server\anticheat.lua:14: attempt to call global 'getElementSpeed' (a nil value) [DUP x5]
  ```
- **Root Cause**: `getElementSpeed` is NOT an MTA:SA built-in function; it is a community utility function that was called in 5 places but never defined anywhere in the codebase.
- **Remedy**: Implement a global helper in `shared/util.lua`:
  ```lua
  function getElementSpeed(element, unit)
      if not isElement(element) then return 0 end
      local vx, vy, vz = getElementVelocity(element)
      if not vx then return 0 end
      local speed = math.sqrt(vx * vx + vy * vy + vz * vz)
      if unit == "kmh" or unit == 1 or unit == "km/h" then
          return speed * 180
      else
          return speed * 111.84681456
      end
  end
  ```

---

### Bug 2: Server-Side Execution of Client-Only `setPedTarget`
- **Severity**: **CRITICAL**
- **Location**: `mzansi_core/server/activity_system.lua:597-598`
- **Empirical Evidence from `server.log`**:
  ```log
  [2026-09-15 05:55:34] ERROR: mzansi_core\server\activity_system.lua:597: attempt to call global 'setPedTarget' (a nil value)
  ```
- **Root Cause**: In MTA:SA, `setPedTarget` is a **client-only** function. Calling it from server-side script `activity_system.lua` during the gang skirmish timer immediately terminates the skirmish loop with a fatal nil call.
- **Remedy**: On the server, use `setPedAimTarget` combined with `setPedControlState(ped, "fire", true)` or trigger a synchronized client event to instruct clients to handle local targeting.

---

### Bug 3: Lua Multi-Return Truncation in `Mzansi.Util.distance`
- **Severity**: **CRITICAL / PERSISTENT**
- **Location**: 12 critical files across SAPS, EMS, Gangs, Housing, and Crime:
  - `mzansi_saps/client/saps_client.lua:116-119` (`getClosestPlayer`)
  - `mzansi_ems/client/ems_client.lua:50` (`getClosestPlayer`)
  - `mzansi_gangs/client/gangs_client.lua:204, 213, 230` (`claim`, `attack`)
  - `mzansi_gangs/server/gangs.lua:419, 424` (`checkTerritoryCapture`)
  - `mzansi_housing/server/housing.lua:122-125, 153-156` (`enterProperty`, `toggleLock`)
  - `mzansi_housing/client/housing_client.lua:57, 66`
  - `mzansi_crime/server/crime.lua:56, 75, 155, 174`
- **Code Defect**:
  ```lua
  -- Example: saps_client.lua lines 116-119
  local dist = Mzansi.Util.distance(
      getElementPosition(localPlayer),
      getElementPosition(player)
  )
  ```
- **Root Cause**: In Lua syntax rules, when a multi-return function (`getElementPosition` returns `x, y, z`) is passed as an argument that is **NOT the final argument** in a call list, **it is truncated to only its first return value (`x`)**!
  Therefore, the call evaluates to:
  `Mzansi.Util.distance(x1, x2, y2, z2)` (only 4 arguments instead of 6!).
  Inside `Mzansi.Util.distance(x1, y1, z1, x2, y2, z2)`, arguments `y2` and `z2` are `nil`. The subtraction `dz = z2 - z1` throws:
  `attempt to perform arithmetic on a nil value`.
- **Systemic Impact**:
  - Police officers cannot cuff, arrest, ticket, or frisk players.
  - EMS medics cannot heal or revive players.
  - Players cannot enter or lock houses.
  - Gangs cannot claim or attack territories.
- **Remedy**: Replace all instances with MTA's native C++ function `getDistanceBetweenPoints3D`:
  ```lua
  local x1, y1, z1 = getElementPosition(localPlayer)
  local x2, y2, z2 = getElementPosition(player)
  local dist = getDistanceBetweenPoints3D(x1, y1, z1, x2, y2, z2)
  ```

---

### Bug 4: Non-Existent `hash("sha256", ...)` in Account Authentication
- **Severity**: **FATAL / BLOCKING AUTH**
- **Location**: `mzansi_core/server/accounts.lua:26, 79`
- **Code Defect**:
  ```lua
  local passwordHash = hash("sha256", password .. username)
  ```
- **Root Cause**: MTA:SA does not have a global function named `hash()`. Hashing in MTA is achieved via `passwordHash()`, `sha256()`, or `md5()`. Calling `hash()` causes an immediate nil error, completely blocking account registration and login!
- **Remedy**: Upgrade directly to the BCrypt standard mandated by the Technical Compendium:
  ```lua
  -- On Registration:
  local passwordHash = passwordHash(password, "bcrypt", { cost = 10 })

  -- On Login:
  passwordVerify(password, account.password_hash, function(isValid)
      if isValid then
          -- Complete authentication
      end
  end)
  ```

---

### Bug 5: Client-Side Direct Money Mutation
- **Severity**: **HIGH / SECURITY & CRASH**
- **Location**: `mzansi_vehicles/client/vehicles_client.lua:67-68`
- **Code Defect**:
  ```lua
  if not Mzansi.Characters.removeCash(cost) then
      if not Mzansi.Characters.removeBank(cost) then
  ```
- **Root Cause**: `Mzansi.Characters` is a server-side table in `mzansi_core`. It does not exist in the client Lua state. Calling it on the client crashes with `attempt to index field 'Characters' (a nil value)`. Furthermore, client-side money alteration violates server authority.
- **Remedy**: Send a server event `triggerServerEvent("mzansi:vehicles:refuel", localPlayer)` and perform all balance checks authoritatively on the server.

---

### Bug 6: Non-Existent `triggerBrowserEvent` in Inventory
- **Severity**: **HIGH / CEF UI FAILURE**
- **Location**: `mzansi_inventory/client/inventory_client.lua:61`
- **Code Defect**:
  ```lua
  triggerBrowserEvent(Mzansi.Inventory._browser, "inventory:loaded", items)
  ```
- **Root Cause**: MTA:SA has no function called `triggerBrowserEvent`. Communication from Lua to JavaScript in MTA:SA CEF must be performed via `executeBrowserJavascript(browser, jsString)`.
- **Remedy**:
  ```lua
  executeBrowserJavascript(Mzansi.Inventory._browser, string.format("loadInventory(%s);", toJSON(items)))
  ```

---

### Bug 7: Housing Teleportation into Ocean Void
- **Severity**: **CRITICAL / GAMEPLAY BREAKING**
- **Location**: `mzansi_housing/server/housing.lua:166, 180`
- **Code Defect**:
  ```lua
  -- Line 166 (enterProperty):
  setElementPosition(source, 0, 0, 0)

  -- Line 180 (exitProperty):
  local prop = Mzansi.Housing._properties[1]
  setElementPosition(source, prop.x, prop.y, prop.z + 3)
  ```
- **Root Cause**: When a player enters any property, they are teleported to coordinate `(0, 0, 0)` in the ocean. When they exit *any* house on the map, line 180 always teleports them to Property 1 (Ganton House)!
- **Remedy**: Configure authentic GTA SA interior coordinates for each house type (e.g. CJ House, Small Burglary House) and store the player's entry property ID in element data so they exit back to the exact house exterior they entered from.

---

### Bug 8: `dxDrawCircle` Parameter Inversion in HUD
- **Severity**: **MEDIUM / RENDERING CORRUPTION**
- **Location**: `mzansi_hud/client/hud_client.lua:20`
- **Code Defect**:
  ```lua
  dxDrawCircle(cx, cy, radius, tocolor(0, 0, 0, 180), tocolor(200, 170, 50, 100), true)
  ```
- **Root Cause**: MTA's `dxDrawCircle` syntax expects `(posX, posY, radius, startAngle, stopAngle, theColor...)`. Passing `tocolor(...)` as the 4th argument passes a 32-bit color integer (~4278190260) where a float angle (0-360) is expected.
- **Remedy**:
  ```lua
  dxDrawCircle(cx, cy, radius, 0, 360, tocolor(0, 0, 0, 180), tocolor(200, 170, 50, 100), 32)
  ```

---

### Bug 9: Thread-Freezing Synchronous `dbPoll(-1)`
- **Severity**: **CRITICAL / TICK RATE DEGRADATION**
- **Location**: `mzansi_core/server/database.lua:262, 271`
- **Root Cause**: Infinite blocking timeout `-1` halts the C++ game loop while awaiting MySQL responses.
- **Remedy**: Convert queries to non-blocking asynchronous callbacks or non-blocking polling (`timeout = 0`).

---

### Bug 10: Missing `ui/mdt.html` Browser Target
- **Severity**: **MEDIUM / 404 BROWSER ERROR**
- **Location**: `mzansi_saps/client/saps_client.lua:28`
- **Root Cause**: Command `/mdt` invokes `loadBrowserURL("http://mta/local/ui/mdt.html")`, but `ui/mdt.html` does not exist on disk.
- **Remedy**: Create a high-tech SAPS MDT interface or cleanly render an in-game DX tactical terminal.
