--[[
    Mzansi Cutscene Scenes (Client)
    Builders for flight depart/arrive, portal transit, spawn intro, hospital wake.
    Server triggers mzansi:cutscene:play with { kind, phase, token, advancePhase, data }
]]

Mzansi = Mzansi or {}
Mzansi.CutsceneScenes = Mzansi.CutsceneScenes or {}

local Scenes = Mzansi.CutsceneScenes

local function aptPos(apt)
    if not apt then return 0, 0, 15 end
    return apt.x or 0, apt.y or 0, (apt.z or 15)
end

local function offsetPos(x, y, z, dx, dy, dz)
    return x + (dx or 0), y + (dy or 0), z + (dz or 0)
end

-- ── Flight ───────────────────────────────────────────────────

local function buildFlightDepart(data)
    local from = data.from or {}
    local to = data.to or {}
    local fx, fy, fz = aptPos(from)
    local label = data.isSpace and "SPACEPORT LAUNCH"
        or (data.isUnderwater and "DEEP-SEA SUBMERSIBLE BAY"
        or "ACSA DEPARTURES")
    local sub = data.isSpace and ("Ascent → " .. (to.name or "Orbit"))
        or (data.isUnderwater and ("Dive → " .. (to.name or "Abyssal Zone"))
        or ("Boarding " .. (to.name or "destination") .. "  ·  " .. (to.city or "")))
    local planeModel = data.isUnderwater and 484 or 577

    -- Ground track relative to terminal (runway-ish heading east)
    local gnd = { fx + 120, fy - 40, fz + 1.5 }
    local lift = { fx + 260, fy + 40, fz + 55 }
    local climb = { fx + 520, fy + 160, fz + 220 }

    return {
        kind = "flight",
        phase = "depart",
        token = data.token,
        advancePhase = "depart_done",
        skippable = true,
        letterbox = true,
        title = "Mzansi ACSA  ·  Departure",
        scenes = {
            {
                duration = 3200,
                caption = label,
                sub = sub,
                cam = { fx - 70, fy - 90, fz + 28, fx, fy, fz + 4 },
            },
            {
                duration = 3600,
                caption = from.name or "Origin Terminal",
                sub = data.isSpace and "Main engine ignition…"
                    or (data.isUnderwater and "Pressure check…"
                    or "Cabin crew, seats for departure"),
                move = {
                    from = { gnd[1] - 50, gnd[2] - 60, gnd[3] + 12, gnd[1], gnd[2], gnd[3] + 3 },
                    to   = { gnd[1] + 30, gnd[2] - 40, gnd[3] + 8, gnd[1] + 20, gnd[2], gnd[3] + 3 },
                },
                plane = {
                    model = planeModel,
                    scale = 0.9,
                    pitchFrom = 0,
                    pitchTo = 0,
                    from = { gnd[1], gnd[2], gnd[3], 45 },
                    to   = { gnd[1] + 40, gnd[2] + 10, gnd[3], 45 },
                },
            },
            {
                duration = 4000,
                caption = data.isSpace and "MAX-Q  · 脱离 gravity well"
                    or (data.isUnderwater and "Negative buoyancy  ·  descending"
                    or "Rotate  ·  positive rate"),
                sub = data.isSpace and "Orbital insertion burn"
                    or (data.isUnderwater and "Hadal corridor engaged"
                    or "Gear up  ·  en route " .. (to.city or to.name or "")),
                move = {
                    from = { gnd[1] - 30, gnd[2] - 70, gnd[3] + 20, lift[1], lift[2], lift[3] },
                    to   = { climb[1] - 80, climb[2] - 90, climb[3] + 30, climb[1], climb[2], climb[3] },
                },
                plane = {
                    model = planeModel,
                    scale = 0.9,
                    pitchFrom = data.isUnderwater and -20 or 18,
                    pitchTo = data.isUnderwater and -35 or 28,
                    from = { gnd[1] + 40, gnd[2] + 10, gnd[3], 45 },
                    to   = { climb[1], climb[2], climb[3], 45 },
                },
                fadeOut = true,
            },
            {
                duration = 1600,
                caption = "IN TRANSIT",
                sub = (from.city or from.name or "?") .. "  →  " .. (to.city or to.name or "?"),
                cam = { climb[1], climb[2], climb[3] + 5, climb[1] + 100, climb[2] + 100, climb[3] },
                black = true,
            },
        },
    }
end

local function buildFlightArrive(data)
    local from = data.from or {}
    local to = data.to or {}
    local tx, ty, tz = aptPos(to)
    local rx, ry, rz = tx, ty, tz
    if data.arrival then
        rx, ry, rz = data.arrival.x or tx, data.arrival.y or ty, data.arrival.z or tz
    end

    local label = data.isSpace and "ORBITAL ARRIVAL"
        or (data.isUnderwater and "SURFACE / BAY ARRIVAL"
        or "ACSA ARRIVALS")
    local sub = data.isSpace and ("Welcome to " .. (to.name or "orbit"))
        or (data.isUnderwater and ("Docking at " .. (to.name or "station"))
        or ("Welcome to " .. (to.city or to.name or "destination")))
    local planeModel = data.isUnderwater and 484 or 577

    local approach = { tx - 280, ty - 160, tz + 120 }
    local gate = { tx + 40, ty - 30, tz + 8 }

    return {
        kind = "flight",
        phase = "arrive",
        token = data.token,
        advancePhase = "arrive_done",
        skippable = true,
        letterbox = true,
        title = "Mzansi ACSA  ·  Arrival",
        scenes = {
            {
                duration = 800,
                caption = "",
                sub = "",
                cam = { approach[1], approach[2], approach[3], tx, ty, tz },
                fadeIn = 400,
                black = true,
            },
            {
                duration = 3400,
                caption = label,
                sub = sub,
                move = {
                    from = { approach[1], approach[2], approach[3], tx, ty, tz + 5 },
                    to   = { gate[1] - 60, gate[2] - 40, gate[3] + 18, tx, ty, tz + 3 },
                },
                plane = {
                    model = planeModel,
                    scale = 0.9,
                    pitchFrom = data.isUnderwater and -15 or 8,
                    pitchTo = 0,
                    from = { approach[1], approach[2], approach[3], 45 },
                    to   = { gate[1], gate[2], gate[3], 45 },
                },
            },
            {
                duration = 2800,
                caption = to.name or "Terminal",
                sub = (to.city or "") .. "  ·  Gate open",
                move = {
                    from = { gate[1], gate[2] - 20, gate[3] + 10, rx, ry, rz + 2 },
                    to   = { rx - 6, ry - 8, rz + 3.5, rx, ry, rz + 1 },
                },
            },
        },
    }
end

-- ── Portal ───────────────────────────────────────────────────

local function buildPortalDepart(data)
    local p = data.pos or {}
    local x, y, z = p.x or 0, p.y or 0, p.z or 10
    local dest = data.destination or "Unknown Territory"
    local label = data.label or "DIMENSIONAL TRANSIT"

    return {
        kind = "portal",
        phase = "depart",
        token = data.token,
        advancePhase = "depart_done",
        skippable = true,
        letterbox = true,
        title = "Mzansi Portals",
        scenes = {
            {
                duration = 2800,
                caption = label,
                sub = "→ " .. dest,
                move = {
                    from = { x + 18, y - 22, z + 10, x, y, z + 1 },
                    to   = { x + 6, y - 8, z + 4, x, y, z + 1 },
                },
            },
            {
                duration = 2000,
                caption = "RIFT STABILISING",
                sub = dest,
                cam = { x + 4, y - 6, z + 3, x, y, z + 1 },
                fadeOut = true,
            },
        },
    }
end

local function buildPortalArrive(data)
    local p = data.pos or {}
    local x, y, z = p.x or 0, p.y or 0, p.z or 10
    local dest = data.destination or "Unknown Territory"
    local rot = p.rot or 0

    return {
        kind = "portal",
        phase = "arrive",
        token = data.token,
        advancePhase = "arrive_done",
        skippable = true,
        letterbox = true,
        title = "Mzansi Portals",
        scenes = {
            {
                duration = 700,
                caption = "",
                sub = "",
                cam = { x, y, z + 6, x, y, z },
                fadeIn = 350,
                black = true,
            },
            {
                duration = 2600,
                caption = "TRANSIT COMPLETE",
                sub = dest,
                move = {
                    from = { x - 10, y + 12, z + 7, x, y, z + 1 },
                    to   = { x + math.cos(math.rad(rot)) * -4, y + math.sin(math.rad(rot)) * -4, z + 2.2, x, y, z + 1 },
                },
            },
        },
    }
end

-- ── Spawn intro (client-only) ────────────────────────────────

local function buildSpawnIntro(data)
    local x, y, z = data.x or 0, data.y or 0, data.z or 10
    local name = data.name or "Citizen"

    return {
        kind = "spawn",
        phase = "intro",
        skippable = true,
        letterbox = true,
        title = "Mzansi Roleplay",
        freeze = true,
        scenes = {
            {
                duration = 3000,
                caption = "MZANSI RP",
                sub = "Welcome back, " .. name,
                move = {
                    from = { x + 40, y - 50, z + 35, x, y, z },
                    to   = { x + 14, y - 18, z + 12, x, y, z + 1 },
                },
                fadeIn = 600,
            },
            {
                duration = 2800,
                caption = getZoneName(x, y, z) or "San Andreas",
                sub = "Press F2 for the dashboard  ·  F3 flight board",
                move = {
                    from = { x + 14, y - 18, z + 12, x, y, z + 1 },
                    to   = { x + 4, y - 5, z + 2.8, x, y, z + 1 },
                },
            },
        },
        onDone = function()
            if isElement(localPlayer) then
                setCameraTarget(localPlayer)
                fadeCamera(true, 0.6)
                setElementFrozen(localPlayer, false)
                if triggerServerEvent then
                    triggerServerEvent("mzansi:characters:unfreeze", localPlayer)
                end
            end
        end,
    }
end

-- ── Hospital wake ────────────────────────────────────────────

local function buildHospitalWake(data)
    local x = data.x or 1176.8
    local y = data.y or -1323.0
    local z = data.z or 13.5
    return {
        kind = "hospital",
        phase = "wake",
        skippable = true,
        letterbox = true,
        title = "All Saints General Hospital",
        freeze = true,
        scenes = {
            {
                duration = 2800,
                caption = "ALL SAINTS GENERAL",
                sub = "You are receiving care…",
                move = {
                    from = { x + 8, y - 10, z + 6, x, y, z + 1 },
                    to   = { x + 3, y - 4, z + 2.5, x, y, z + 1 },
                },
                fadeIn = 800,
            },
            {
                duration = 2400,
                caption = "STABLE",
                sub = "Discharge when ready",
                cam = { x + 2.5, y - 3.5, z + 2.2, x, y, z + 1 },
            },
        },
        onDone = function()
            if isElement(localPlayer) then
                setCameraTarget(localPlayer)
                fadeCamera(true, 0.5)
                setElementFrozen(localPlayer, false)
                setElementHealth(localPlayer, math.max(50, getElementHealth(localPlayer)))
                if triggerServerEvent then
                    triggerServerEvent("mzansi:characters:unfreeze", localPlayer)
                end
            end
        end,
    }
end

-- ── EMS revive (short) ───────────────────────────────────────

local function buildRevive(data)
    local x, y, z = getElementPosition(localPlayer)
    return {
        kind = "revive",
        phase = "revive",
        skippable = true,
        letterbox = true,
        title = "Emergency Medical Services",
        freeze = true,
        scenes = {
            {
                duration = 3200,
                caption = "EMS REVIVAL",
                sub = data.medic and ("Medic: " .. data.medic) or "Vital signs returning…",
                move = {
                    from = { x + 5, y - 6, z + 4, x, y, z + 1 },
                    to   = { x + 2, y - 2.5, z + 2, x, y, z + 1 },
                },
                fadeIn = 500,
            },
        },
        onDone = function()
            if isElement(localPlayer) then
                setCameraTarget(localPlayer)
                fadeCamera(true, 0.4)
                setElementFrozen(localPlayer, false)
            end
        end,
    }
end

-- ── Dispatch ─────────────────────────────────────────────────

function Scenes.build(payload)
    if type(payload) ~= "table" then return nil end
    local kind = payload.kind
    local data = payload.data or payload
    data.token = data.token or payload.token

    if kind == "flight" then
        if payload.phase == "arrive" or data.phase == "arrive" then
            return buildFlightArrive(data)
        end
        return buildFlightDepart(data)
    elseif kind == "portal" then
        if payload.phase == "arrive" or data.phase == "arrive" then
            return buildPortalArrive(data)
        end
        return buildPortalDepart(data)
    elseif kind == "spawn" then
        return buildSpawnIntro(data)
    elseif kind == "hospital" then
        return buildHospitalWake(data)
    elseif kind == "revive" then
        return buildRevive(data)
    end
    return nil
end

addEvent("mzansi:cutscene:scene", true)
addEventHandler("mzansi:cutscene:scene", root, function(payload)
    local def = Scenes.build(payload)
    if def then
        Mzansi.Cutscene.play(def)
    end
end)

-- Server payloads use mzansi:cutscene:scene (preferred) or play with kind/phase
addEventHandler("mzansi:cutscene:play", root, function(def)
    if type(def) == "table" and def.kind and def.phase and type(def.scenes) ~= "table" then
        local built = Scenes.build(def)
        if built then
            Mzansi.Cutscene.play(built)
        end
    end
end)

outputDebugString("[Mzansi-Core] Cutscene scenes loaded.")
