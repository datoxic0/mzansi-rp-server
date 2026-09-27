-- ==============================================================
-- MZANSI LIVING WORLD — AIRPORT TRAFFIC ENGINE
-- Spawns parked and cycling aircraft at all 3 South African airports
-- Airports: CTIA (Cape Town / LS), King Shaka (Durban / SF), OR Tambo (Jozi / LV)
-- ==============================================================
MzansiLiving = MzansiLiving or {}
MzansiLiving.Airports = {}

-- Plane model IDs available in GTA:SA
local AIRCRAFT_MODELS = {
    { id = 577, name = "AT-400",    size = "heavy"  },
    { id = 519, name = "Shamal",    size = "medium" },
    { id = 553, name = "Nevada",    size = "medium" },
    { id = 592, name = "Andromada", size = "heavy"  },
    { id = 593, name = "Dodo",      size = "small"  },
}

-- Airport definitions: apron parking bays and runway departure markers
local AIRPORTS = {
    -- ==========================================
    -- CTIA — Cape Town International Airport (LS / Western Cape)
    -- ==========================================
    CTIA = {
        name = "Cape Town International Airport (CTIA)",
        province = "wc",
        bays = {
            -- LS Airport main apron (open tarmac, no walls)
            { x = 1900.0,  y = -2450.0, z = 13.5, rot = 0,   model = 577, name = "Bay 1 - AT-400"    },
            { x = 1950.0,  y = -2455.0, z = 13.5, rot = 0,   model = 519, name = "Bay 2 - Shamal"    },
            { x = 2000.0,  y = -2450.0, z = 13.5, rot = 0,   model = 553, name = "Bay 3 - Nevada"    },
            { x = 1900.0,  y = -2420.0, z = 13.5, rot = 180, model = 519, name = "Bay 4 - Shamal"    },
            { x = 1950.0,  y = -2420.0, z = 13.5, rot = 180, model = 593, name = "Bay 5 - Dodo"      },
        },
        taxiOut = { x = 1950.0, y = -2500.0, z = 13.5, rot = 0 },
        runway  = { x = 1950.0, y = -2880.0, z = 13.5 },
    },

    -- ==========================================
    -- KING SHAKA — Durban International (SF Easter Bay / KZN)
    -- Hangars and aprons from native SFSe.ipl
    -- ==========================================
    KING_SHAKA = {
        name = "King Shaka International Airport",
        province = "kzn",
        bays = {
            -- Real Easter Bay Airport open hangars and tarmac aprons
            { x = -1272.08, y = -660.33, z = 14.1, rot = 0,   model = 519, name = "Hangar 1 - Shamal"    },
            { x = -1334.48, y = -660.33, z = 14.1, rot = 0,   model = 553, name = "Hangar 2 - Nevada"    },
            { x = -1396.88, y = -660.33, z = 14.1, rot = 0,   model = 593, name = "Hangar 3 - Dodo"      },
            { x = -1438.41, y = -529.63, z = 14.1, rot = 135, model = 577, name = "Main Hangar - AT-400" },
            { x = -1217.14, y = -67.17,  z = 14.1, rot = 90,  model = 519, name = "North Hangar - Shamal" },
        },
        taxiOut = { x = -1350.0, y = -450.0, z = 14.1, rot = 0 },
        runway  = { x = -1340.0, y = 400.0,  z = 14.1 },
    },

    -- ==========================================
    -- OR TAMBO — Johannesburg Int. Airport (LV Juank Air / Gauteng)
    -- Real Hangars and aprons from native vegasS.ipl
    -- ==========================================
    OR_TAMBO = {
        name = "OR Tambo International Airport",
        province = "gp",
        bays = {
            -- Real Juank Air open hangars and wide tarmac apron bays
            { x = 1609.34, y = 1671.70, z = 10.8, rot = 180, model = 577, name = "Hangar 1 - AT-400"    },
            { x = 1677.30, y = 1671.70, z = 10.8, rot = 180, model = 592, name = "Hangar 2 - Andromada" },
            { x = 1530.00, y = 1600.00, z = 10.8, rot = 180, model = 553, name = "Apron Bay 1 - Nevada" },
            { x = 1470.00, y = 1600.00, z = 10.8, rot = 180, model = 519, name = "Apron Bay 2 - Shamal" },
            { x = 1410.00, y = 1600.00, z = 10.8, rot = 180, model = 593, name = "Apron Bay 3 - Dodo"   },
        },
        taxiOut = { x = 1470.0, y = 1500.0, z = 10.8, rot = 180 },
        runway  = { x = 1350.0, y = 1300.0, z = 10.8 },
    },
}

-- Track all parked aircraft and active taxi timers
local _parkedAircraft = {}  -- [bayId] = vehicle element
local _taxiTimers     = {}

-- ============================================================
-- SPAWN ALL AIRPORT AIRCRAFT
-- ============================================================
local function spawnAircraft(airport, bayIndex, bay)
    -- Don't double-spawn
    local bayId = airport.name .. "_" .. bayIndex
    if _parkedAircraft[bayId] and isElement(_parkedAircraft[bayId]) then
        return
    end

    local veh = createVehicle(bay.model, bay.x, bay.y, bay.z, 0, 0, bay.rot)
    if not veh then
        outputDebugString("[Airport] Failed to spawn " .. bay.name .. " at " .. airport.name, 2)
        return
    end

    -- Unlocked so players can enter and fly
    setVehicleLocked(veh, false)
    setVehicleDoorState(veh, 0, 2) -- Close doors
    setVehicleFuelTankExplodable(veh, false)
    setVehicleEngineState(veh, true)
    setElementData(veh, "mzansi:airport:parked", true)
    setElementData(veh, "mzansi:airport:bayId", bayId)
    setElementData(veh, "mzansi:airport:name", bay.name)
    setElementData(veh, "mzansi:airport:driveable", true)

    -- Random livery color variation
    local colors = {
        { 7, 0 },   -- White / black
        { 1, 7 },   -- Blue / white
        { 5, 7 },   -- Green / white
        { 8, 0 },   -- Light blue / black
    }
    local c = colors[math.random(1, #colors)]
    setVehicleColor(veh, c[1], c[2], 0, 0)

    _parkedAircraft[bayId] = veh
    outputDebugString("[Airport] Spawned " .. bay.name .. " at " .. airport.name)
end

-- ============================================================
-- TAXI CYCLE: Randomly pick a bay, "depart" (warp off map),
-- wait, then re-spawn a new random aircraft.
-- ============================================================
local function runTaxiCycle(airport)
    if not airport.bays or #airport.bays == 0 then return end

    -- Pick a random filled bay
    local bayIndex = math.random(1, #airport.bays)
    local bay      = airport.bays[bayIndex]
    local bayId    = airport.name .. "_" .. bayIndex
    local veh      = _parkedAircraft[bayId]

    if not veh or not isElement(veh) then return end

    outputDebugString("[Airport] " .. airport.name .. ": " .. bay.name .. " is taxiing out...")

    -- Phase 1: Unlock and move to taxiway
    setVehicleLocked(veh, false)
    local taxiOut = airport.taxiOut
    setElementPosition(veh, taxiOut.x, taxiOut.y, taxiOut.z)
    setElementRotation(veh, 0, 0, taxiOut.rot)

    -- Phase 2: After 8 seconds, warp to "end of runway" and despawn (departure)
    setTimer(function()
        if isElement(veh) then
            local rwy = airport.runway
            setElementPosition(veh, rwy.x, rwy.y, rwy.z + 15)
            setTimer(function()
                if isElement(veh) then
                    destroyElement(veh)
                    _parkedAircraft[bayId] = nil
                end
            end, 3500, 1)
        end
    end, 8000, 1)

    -- Phase 3: After 30-60 seconds, spawn a new aircraft in that bay
    local respawnDelay = math.random(30000, 60000)
    setTimer(function()
        spawnAircraft(airport, bayIndex, bay)
    end, respawnDelay, 1)
end

-- ============================================================
-- INIT: Called on resource start
-- ============================================================
function MzansiLiving.Airports.init()
    outputDebugString("[Airport] Initializing airport aircraft at all 3 airports...")

    for _, airport in pairs(AIRPORTS) do
        for i, bay in ipairs(airport.bays) do
            spawnAircraft(airport, i, bay)
        end
    end

    outputDebugString("[Airport] All airport aircraft spawned. " ..
        "Taxi cycle starting in 3 minutes...")

    -- Start the taxi departure cycle after 3 minutes (allows world to settle)
    setTimer(function()
        for _, airport in pairs(AIRPORTS) do
            -- Each airport gets its own independent cycle
            local function scheduleCycle()
                runTaxiCycle(airport)
                -- Schedule next departure: 4-8 minutes from now
                setTimer(scheduleCycle, math.random(240000, 480000), 1)
            end
            -- Stagger initial departures so they don't all fire at once
            setTimer(scheduleCycle, math.random(1000, 15000), 1)
        end
    end, 180000, 1)
end

-- ============================================================
-- CLEANUP: Remove all aircraft on resource stop
-- ============================================================
addEventHandler("onResourceStop", resourceRoot, function()
    for bayId, veh in pairs(_parkedAircraft) do
        if isElement(veh) then
            destroyElement(veh)
        end
        _parkedAircraft[bayId] = nil
    end
    outputDebugString("[Airport] All airport aircraft removed.")
end)

-- ============================================================
-- AUTO-START
-- ============================================================
addEventHandler("onResourceStart", resourceRoot, function()
    -- Wait 5 seconds after resource start to avoid race with other init functions
    setTimer(MzansiLiving.Airports.init, 5000, 1)
end)
