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
    -- ==========================================
    -- KING SHAKA — Durban International (SF Easter Bay / KZN)
    -- Placed directly outside on the open tarmac apron facing the runway
    -- ==========================================
    KING_SHAKA = {
        name = "King Shaka International Airport",
        province = "kzn",
        bays = {
            -- Outside on the open runway apron tarmac — fully visible to players
            { x = -1340.0, y = -260.0, z = 14.1, rot = 135, model = 577, name = "Runway Apron 1 - AT-400"     },
            { x = -1365.0, y = -235.0, z = 14.1, rot = 135, model = 519, name = "Runway Apron 2 - Shamal"     },
            { x = -1390.0, y = -210.0, z = 14.1, rot = 135, model = 553, name = "Runway Apron 3 - Nevada"     },
            { x = -1415.0, y = -185.0, z = 14.1, rot = 135, model = 593, name = "Runway Apron 4 - Dodo"       },
            { x = -1440.0, y = -160.0, z = 14.1, rot = 135, model = 476, name = "Runway Apron 5 - Rustler"    },
            { x = -1315.0, y = -240.0, z = 14.1, rot = 135, model = 487, name = "Apron Helipad - Maverick"    },
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
    -- Don't double-spawn if vehicle still valid and not blown up
    local bayId = airport.name .. "_" .. bayIndex
    if _parkedAircraft[bayId] and isElement(_parkedAircraft[bayId]) and getElementHealth(_parkedAircraft[bayId]) > 0 then
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
    setElementData(veh, "mzansi:fuel", 100)
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

    -- Handle vehicle destruction/respawn
    addEventHandler("onVehicleExplode", veh, function()
        setTimer(function()
            if isElement(veh) then destroyElement(veh) end
            _parkedAircraft[bayId] = nil
            spawnAircraft(airport, bayIndex, bay)
        end, 45000, 1)
    end)

    _parkedAircraft[bayId] = veh
    outputDebugString("[Airport] Spawned " .. bay.name .. " outside on runway apron at " .. airport.name)
end

-- ============================================================
-- AIRPORT PATROL & RESPAWN MONITOR (replaces despawning taxi cycle)
-- Keeps aircraft available for players to fly; respawns missing/destroyed
-- ============================================================
local function checkAirportBays()
    for _, airport in pairs(AIRPORTS) do
        for i, bay in ipairs(airport.bays) do
            local bayId = airport.name .. "_" .. i
            local veh = _parkedAircraft[bayId]
            if not veh or not isElement(veh) or getElementHealth(veh) <= 0 then
                spawnAircraft(airport, i, bay)
            end
        end
    end
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

    outputDebugString("[Airport] All airport aircraft spawned outside near runway.")

    -- Monitor bays every 60 seconds to ensure aircraft remain available
    setTimer(checkAirportBays, 60000, 0)
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
