# Dossier 09b: Msinga Lua Workshop & Game Server Hosting
**Mode**: Zero-Temperature Deep Research
**Physical Targets** (all verified EXISTS):
- `E:\Coding-and-Programming\Msinga-Campus-Server\windows\msinga-server\backend\server.js`
- `...\backend\database.js:643–671` (`game_servers` table)
- `...\backend\library_service.js:602` (exe discovery helper)
- `...\backend\app_host.js:1189,1366,1380` (game exe detection)
**Status**: Audited — boundary gap "Lua Workshop path" CLOSED (found in server.js)

---

## 1. Location Map (server.js)

| Feature | Lines | Notes |
|---------|------:|-------|
| Swagger tag `Games` | 444–450 | |
| Swagger tag `Lua` `/api/lua/run` | 452–458 | |
| Game stdin console | 1980–1993 | POST `/api/games/:id/input` |
| **LUA WORKSHOP banner** | **1996** | Comment: "server-side Lua toolchain for MTA:SA / SA-MP / etc." |
| Lua binary resolve | 1999–2019 | PATH scan `lua*`, `luac*` |
| GET `/api/lua/info` | 2021–2036 | toolchain detect |
| POST `/api/lua/run` | 2038–2068 | temp file + `spawnSync`, 10s timeout |
| POST `/api/lua/compile` | 2070–2115 | `luac -p` or bytecode base64 |
| POST `/api/lua/lint` | 2117–2189 | luac + bracket/string-aware lint |
| GET `/api/lua/files` | 2191–2210 | tree under `{install_path}/resources/msinga-workshop` |
| GET `/api/lua/files/read` | 2212–2223 | path jail |
| PUT `/api/lua/files/write` | 2225–2239 | admin/mod/dictator + audit |
| POST `/api/lua/files/create` | 2241–2259 | file or dir |
| DELETE `/api/lua/files/delete` | 2261–2273 | recursive rm + jail |
| GET `/api/lua/snippets` | 2275–2279 | `ai_code_snippets` language=lua |
| GAME SERVER HOSTING banner | 2281–2286 | `gameProcesses` Map |
| `detectGameDefaults` | 2289–2303 | mta-sa, sa-mp, cs, mc signatures |
| GET `/api/games/types` | 2305–2318 | 7 game types incl. MTA:SA 22003/22005 |
| GET `/api/games/known-servers` | 2320–2350 | scans `Games Library` / `Games` on all drives |
| GET `/api/games` CRUD | 2352–2451 | list/get/post/put/delete |
| POST start/stop/logs/detect | 2453–2599 | spawn + MTA `mods/deathmatch/logs/server.log` tail |

**Auth**: Lua write/run/compile/lint = `requireRole('admin','moderator','dictator')`; file read/list = any auth.

---

## 2. Lua Workshop — What It Actually Does

### 2.1 Toolchain
- Resolves `lua`/`luac` from PATH (not hardcoded to `C:\Program Files (x86)\Lua`).
- **run**: write snippet → interpreter → stdout/stderr/exit/duration; temp file deleted.
- **compile**: `luac -p` syntax or full bytecode → base64.
- **lint**: luac errors mapped to line + custom scan (unbalanced `{ } ( ) [ ]` with string/comment awareness, `undefined` warn, redundant nil, leftover `print()`).

### 2.2 File tree (Workshop IDE files)
- **Root jail**: `{game.install_path}/resources/msinga-workshop` — dedicated resource name, not arbitrary MTA resources (safer).
- Lists only `*.lua` and `*.meta`.
- Path traversal: `path.resolve` + `startsWith(baseDir)` on read/write/create/delete.
- Write requires elevated role + `logAudit('LUA_FILE_WRITE')`.

### 2.3 Snippets
- DB table `ai_code_snippets` filtered `language='lua'`.

### 2.4 Bugs / gaps found (Msinga-side, for awareness)
| Issue | Line | Severity |
|-------|-----:|----------|
| `stdio: ['ignore','pipe','pipe']` but stdin console expects `proc.stdin.write` | 2481 vs 1988 | **HIGH** — game input API will throw / no-op |
| `compile` bytecode path shadows `args` const (`const args` redeclared inside if) | 2085–2086 | Medium (works but ugly / eslint) |
| `findLuaBinary` uses `X_OK` on Windows — often fails without exec bit semantics | 2010 | Medium — may miss `lua.exe` on some PATH setups |
| Workshop path fixed to `msinga-workshop` only — cannot edit live `mzansi_*` tree via this API | 2197 | By design (isolation) |
| No `lua.exe` at PATH but luac exists at known path | local machine | Use dual resolution: PATH + known install dirs |

---

## 3. Game Server Hosting — What It Actually Does

| Piece | Behavior |
|-------|----------|
| Registry | SQLite `game_servers` (id, name, game_type, install_path, executable, ports, rcon, status, pid…) |
| Discovery | Scans `C:\Program Files*`, `{drive}:\Games Library`, `{drive}:\Games` one level deep for known exes |
| MTA:SA signature | `MTA Server.exe`, port 22003, query 22005 |
| Start | `spawn(cmd, {shell:true})` with env `SERVER_PORT`/`QUERY_PORT`/`MAX_PLAYERS`; cwd = install_path |
| Log tail | **MTA-specific**: tails `{install}/mods/deathmatch/logs/server.log` every 2s from EOF-at-start |
| Live buffer | stdout/stderr + file lines → ring 200; SSE listeners every 20s ping |
| Stop | SIGTERM then SIGKILL after 5s; updates DB status |
| Console in | POST `/api/games/:id/input` → stdin (broken while stdio ignore — see bug) |
| Status | pid, uptime, port, queryPort |

**This is how Mzansi MTA server can be operated from Msinga panel** — register install_path `E:\Games Library\GTA SA MP - Copy\server`, executable `MTA_Server64.exe` (detection looks for `MTA Server.exe` — **must set executable field manually** or extend sigs).

---

## 4. Implications for Mzansi Mandate

### 4.1 CE Job (P6) — reuse Msinga Lua Workshop remotely OR mirror in-game
Two integration modes:

| Mode | How | When |
|------|-----|------|
| **A. Bridge** (recommended first) | Mzansi CE admin UI calls Msinga `/api/lua/*` with server-side JWT (sidecar) | Msinga already runs; no reimplementation |
| **B. In-game mirror** | New `mzansi_workshop` resource: CEF editor + server `luac -p` via `fetchRemote` to sidecar **or** local luac if MTA allows (it doesn't — no process spawn in pure Lua) | Offline Msinga |

**Truth**: MTA server Lua **cannot** spawn `luac` itself. CE sandbox must either:
1. Pattern-lint in pure Lua (like Msinga lint braces), or
2. HTTP to Msinga Lua Workshop / tiny sidecar.

**Recommendation**: Pattern lint in-game + optional HTTP bridge for real `luac`.

### 4.2 Game Hosting (ops)
- Register Mzansi server in Msinga `game_servers`.
- Extend `detectGameDefaults` to recognize `MTA_Server64.exe` (Msinga currently only `MTA Server.exe`).
- Fix stdin stdio before relying on remote `input` API.
- Workshop resource root `msinga-workshop` ≠ `mods/deathmatch/resources` — **separate sandbox**; do not point workshop at live tree without path-jail redesign.

### 4.3 Online gaps filled (user: "get online what we don't have")
| Need | Source acquired |
|------|-----------------|
| In-game Lua editor patterns | MTA community `luaeditor` v4 (CodeMirror, meta auto-reg, ACL, backups, 1MB cap) — **pattern only**, not vendored |
| MTA resource security | mtasa-resources coding guidelines (error level 2, camelCase, no OOP, range-for) |
| Remote panel ops | Local Msinga implementation (primary) — no external panel needed |

---

## 5. Target Mzansi Architecture (workshop + host)

```
[Player CE client]  CEF editor (CodeMirror-like minimal)
        │ triggerServerEvent mzansi:ce:lint
        v
[mzansi_ce server]  pure-Lua lint (Msinga algorithm port) 
        │ optional fetchRemote
        v
[Msinga :3443 /api/lua/lint|compile]  requireAuth + role
        │
        v
luac / lua on PATH
```

Ops path:
```
Msinga Admin → /api/games (register E:\...\server + MTA_Server64.exe)
            → start/stop + tail mods/deathmatch/logs/server.log
            → /api/lua/files on msinga-workshop sandbox
```

---

## 6. Verification (post-integration)

1. Msinga `GET /api/lua/info` → interpreter/luac non-null on this PC.
2. `POST /api/lua/lint` with known-bad code → line number.
3. Mzansi CE lint mirrors same result for fixture.
4. Register game server → start → logs show MTA boot lines (when Msinga is running).
5. **Before stdin use**: fix Msinga start stdio to `['pipe','pipe','pipe']` (Msinga edit — only if user asks to patch Msinga).

## 7. Angels

- **PathJail Angel**: workshop file ops never escape `msinga-workshop`
- **Toolchain Angel**: dual PATH + known-dir lua/luac resolution
- **Host Log Angel**: MTA server.log tail only (no full-disk read)
- **Sandbox Split Angel**: CE player code never writes live `mzansi_*` tree
