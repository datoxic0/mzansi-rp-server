# Dossier 01: AI Chatbot & In-Game Agent
**Mode**: Zero-Temperature Deep Research
**Physical Targets**:
- `E:\Coding-and-Programming\Msinga-Campus-Server\windows\msinga-server\backend\ai_service.js`
- `...\backend\agentic_engine.js` (unwired in Msinga)
- `...\backend\server.js` (~L3810–4360 AI routes)
- `...\frontend\public\app.js` (AICopilotPage L4435–4582)
- `...\backend\local_ai_engine.js`
- `E:\Coding-and-Programming\Msinga-Campus-Server\.env.example`
- Gap target: Mzansi has **zero** AI code (grep `ai_service|openrouter|copilot|chatbot|GPT|llm` across all mzansi_* = 0 hits)

**Status**: Audited

---

## 1. Executive Summary

Msinga exposes a production AI façade (providers, rate limit, audit, settings mask) with a **non-streaming** copilot UI and an **unwired** tool-using agent engine. Mzansi has no AI. Port requires a **server-side bridge** because MTA clients cannot safely call arbitrary LLM APIs with keys.

---

## 2. Msinga AI Surface (verified)

### 2.1 `ai_service.js` (526 lines)

| Lines | Symbol | Role |
|------:|--------|------|
| 19–65 | `AI_PROVIDERS` | openrouter, openai, gemini, ollama, colibri |
| 67–90 | `getConfig(userSettings)` | env defaults + per-user override merge |
| 143–219 | `async complete(messages, options)` | main entry |
| 221–250 | `completeGemini` | **BUG**: uses `config.baseUrl` which `getConfig` never sets → `undefined/...` URL |
| 256–328 | `stream` | exists; **no HTTP route calls it** (grep zero) |
| 334–466 | `TASKS` | reviewCode, documentCode, optimizeCode, generateReadme, generateCommitMessage, explainCode, generateTests, chat |
| 476–486 | `checkUserRateLimit` | **20 req / 60s / userId**, in-memory |
| 494–506 | `auditLog` | RAM ring ~1000 |

**Env load** (`server.js:1`): dotenv from repo-root `.env`.
**`.env.example`**: `AI_PROVIDER`, `AI_API_KEY`, `AI_MODEL`, `AI_MAX_TOKENS`, `AI_TEMPERATURE`.
**Fallback chain**: no key / colibri / ollama → `local_ai_engine.generateSafe` → Ollama → GGUF runner → `runSentientReflex` (deterministic templates). Cloud fail → reflex.

### 2.2 Copilot UI
- `POST /ai/chat` body `{ message }` only — **no multi-turn history sent**.
- History is React `useState` — lost on reload.
- Settings: GET masks key (`••••••` + last 8); PUT ignores still-masked keys.
- Auth: Bearer JWT `requireAuth` on all AI routes; audit endpoint `requireRole('admin')`.

### 2.3 Agentic tools (`agentic_engine.js`, 516 lines) — **UNWIRED**
- No `require('./agentic_engine')` found under `windows\msinga-server`.
- TOOLS: `read_file`, `write_file`, `edit_file`, `list_files`, `search_files` (path-jailed to BACKEND_ROOT), `run_command` (admin/dictator, PowerShell, 30s), `query_database` (SELECT-only regex), `web_search`, `get_system_info`, project CRUD.
- Loop: MAX_ITERATIONS=8; conversation trim 50→30; logs to `agentic_conversations` (table exists `database.js:1004–1013`).

### 2.4 Agent HTTP (wired)
- `POST /api/ai/agents/orchestrate` (server.js:4113–4205): round-robin/sequential/hierarchical, maxRounds≤10.
- `POST /api/ai/agents/chat` (4208–4225): history string-joined client-supplied.
- CRUD on `ai_agents` (4228–4310).

### 2.5 Hive `agent_builder.js`
- Wired via `hive_system.js`; task executors return **stubs** — do not call `ai_service`. Do not treat as real agent brain.

---

## 3. MTA:SA Hard Constraints (architectural facts)

| Constraint | Implication |
|------------|-------------|
| API keys must never ship in client/meta.xml | Key lives server-side only (mtaserver.conf sidecar env or server Lua memory) |
| Client has no general-purpose HTTPS client for OpenAI-compatible APIs | **All LLM calls: MTA server `fetchRemote` OR Node/Python sidecar** |
| `fetchRemote` = single response | Non-streaming first (matches Msinga UI) |
| CEF UI | HTML/CSS/JS resource + `createBrowser` / `<gui-browser>` — vanilla mirrors AICopilotPage |
| No player-supplied cloud keys on shared server without care | Prefer single server key + rate limit; optional per-player key stored server-side encrypted-at-rest (Msinga stores plaintext — do not copy) |

---

## 4. Target Architecture (Mzansi)

```
[CEF chat UI resource mzansi_ai/client]
   triggerServerEvent("mzansi:ai:chat", …, sessionId, message)
        │
        v
[mzansi_ai/server]  rate-limit (20/min/account) → rebuild last N turns from DB
        │ fetchRemote POST
        v
[Optional sidecar :AI_PORT | direct OpenAI-compatible URL]
   complete() + provider façade + reflex fallback
        │
        triggerClientEvent("mzansi:ai:reply", …, content)
```

**Two modes** (phase the plan):
- **Mode A (lean)**: pure Lua `fetchRemote` to one provider (env key in sidecar conf file read by server Lua — not client).
- **Mode B (Msinga parity)**: Node sidecar reusing `ai_service.js` patterns (providers, rate limit, TASKS, agents CRUD).

**Game TASKS** (port presets, not code-review):
- `npc_dialog`, `lore_answer`, `bug_report_triage`, `job_coach`, `market_brief`, `mechatronics_tutor`, `ce_code_review`

**Agent tools (allowlist — NEVER port `run_command` to public RP)**:
- `read_snippet` — only whitelisted resource paths
- `query_game_db` — SELECT-only on `mzansi_*` allowlist
- `get_player_stats` — own character only
- `list_open_bugs` — CE job bug board only

**Persistence gap to fix vs Msinga**: table `mzansi_ai_messages(account_id, session_id, role, content, created_at)` + send last 8 turns in request.

---

## 5. Failure Modes

| Failure | Cause | Remediation |
|---------|-------|-------------|
| Key leak | Client-side key | Server-only key + mask on any GET |
| Rate abuse | No limit | 20/min/account + daily cap |
| Provider outage | Cloud fail | Reflex/template fallback (never hard-fail chat) |
| Gemini URL bug | Copy of Msinga `completeGemini` | Set `baseUrl` or skip Gemini until fixed |
| Prompt injection → tool abuse | Agent tools | Allowlist + no shell + path jail |
| History loss | Msinga UI pattern | Server-side session table |

---

## 6. Verification Spec (post-implementation)

```powershell
# syntax
luac -p <all mzansi_ai lua>
# meta src audit
# functional: /ai open UI, send message, get reply with AI down (reflex), rate-limit 21st request → reject
# grep client scripts for api keys → MUST be 0
```

---

## 7. Angels

- **RateLimit Angel**: 20/min/account enforcement + daily budget
- **Redaction Angel**: mask keys; never log full prompts with secrets
- **Fallback Angel**: reflex path when provider 5xx
- **ToolJail Angel**: path + SQL allowlist validation before any agent tool runs
