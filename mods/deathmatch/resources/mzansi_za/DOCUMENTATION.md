# Mzansi-ZA Roleplay Environment Documentation

## Overview
Mzansi-ZA is a South African roleplay environment starter resource built for a MTA-style GTA SA server. It provides a modular base for player persistence, banking, MDT, job/faction systems, and UI shells.

## Resource Structure
- `meta.xml` – resource entry point and script registration
- `shared/` – shared constants, enums, config, and utilities
- `server/` – server-side runtime systems
- `client/` – client-side UI, CEF, HUD, and asset bootstrap
- `ui/` – browser UI files for bank, MDT, and registration
- `db/` – persistence schema for SQL storage

## Core Systems
### 1. Shared Layer
Files in `shared/` provide common configuration and constants:
- `class.lua` – minimal class helper
- `enums.lua` – roleplay enums for jobs, factions, spawn points, and UI types
- `util.lua` – shared helper functions
- `config.lua` – server defaults and localization settings

### 2. Server Layer
The server side includes the following modules:
- `db.lua` – SQLite connection + player persistence hooks
- `player.lua` – character lookup, save, and authentication flow
- `events.lua` – login/disconnect and startup events
- `spawn.lua` – spawn location handling
- `commands.lua` – `/bank`, `/mdt`, `/register`, and `/spawn` commands
- `bank.lua` – deposit/withdraw banking logic
- `mdt.lua` – MDT lookup skeleton
- `registration.lua` – character creation flow
- `jobs.lua` – job assignment logic
- `faction.lua` – faction assignment logic
- `assets.lua` – placeholder vehicle/building asset lists
- `main.lua` – exported resource functions and startup glue

### 3. Client Layer
The client runtime includes:
- `main.lua` – UI event handlers and resource startup
- `cef.lua` – browser shell creation and UI navigation
- `assets.lua` – asset bootstrap placeholders
- `hud.lua` – basic character HUD renderer
- `ui_bridge.lua` – event bridging between browser and server

### 4. UI Screens
The `ui/` folder contains browser HTML/CSS/JS screens:
- `index.html` – main UI shell
- `bank.html` – banking interface
- `mdt.html` – MDT interface
- `register.html` – character registration interface
- `app.js` / `style.css` – shared UI styling and screen selection

## Database Schema
The database schema lives in `db/schema.sql` and contains the `mzansi_players` table.

Required columns:
- `id`
- `serial`
- `account_name`
- `first_name`
- `last_name`
- `money`
- `bank`
- `job`
- `faction`
- `x`
- `y`
- `z`
- `rotation`
- `created_at`

## ACL Notes
The resource is registered alongside the default server ACL structure in `mods/deathmatch/acl.xml` to keep permissions aligned with the existing admin model.

## Current Status
This documentation reflects a complete starter implementation for:
- resource structure
- player persistence
- roleplay command/event hooks
- banking and MDT skeletons
- job/faction support
- CEF-based UI layer

## Recommended Next Steps
To take this from a solid starter package into a production roleplay environment, the next layer should include:
1. Real South African vehicle and object streaming
2. Full character creation UI connected to server events
3. Persistent job/faction logic with enforcement rules
4. Business, property, police, and EMS gameplay systems
5. More advanced CEF UI screens and dynamic data loading
