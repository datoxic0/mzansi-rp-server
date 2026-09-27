-- ==============================================================
-- MZANSI LIVING WORLD — MILITARY FLEET & HELICOPTER SPANNER
-- Spawns military tanks, trucks, jets, and helicopters across San Andreas
-- Bases: Area 69 (Bone County), Easter Basin Naval Base (SF), Hospital/Police/Airport Helipads
-- ==============================================================

MzansiLiving = MzansiLiving or {}
MzansiLiving.Military = {}

local _militaryVehicles = {} -- id -> vehicle element

local MILITARY_AND_HELIS = {
    -- ==========================================================
    -- AREA 69 — BONE COUNTY MILITARY BASE (SANDF DESERT COMMAND)
    -- ==========================================================
    { id = "a69_rhino_1",   model = 432, name = "SANDF Rhino Tank Alpha",       x = 215.0,  y = 1875.0, z = 13.1, rot = 0,   col = { 70, 75, 60 } },
    { id = "a69_rhino_2",   model = 432, name = "SANDF Rhino Tank Bravo",       x = 228.0,  y = 1875.0, z = 13.1, rot = 0,   col = { 70, 75, 60 } },
    { id = "a69_patriot_1", model = 470, name = "SANDF Patriot Humvee 1",       x = 277.0,  y = 1960.0, z = 17.6, rot = 270, col = { 70, 75, 60 } },
    { id = "a69_patriot_2", model = 470, name = "SANDF Patriot Humvee 2",       x = 277.0,  y = 1970.0, z = 17.6, rot = 270, col = { 70, 75, 60 } },
    { id = "a69_barracks_1",model = 433, name = "SANDF Heavy Barracks Truck 1", x = 277.0,  y = 1980.0, z = 17.6, rot = 270, col = { 70, 75, 60 } },
    { id = "a69_barracks_2",model = 433, name = "SANDF Heavy Barracks Truck 2", x = 277.0,  y = 1992.0, z = 17.6, rot = 270, col = { 70, 75, 60 } },
    { id = "a69_hydra_1",   model = 520, name = "SANDF Hydra Supersonic Jet 1", x = 325.0,  y = 2020.0, z = 17.6, rot = 180, col = { 80, 85, 90 } },
    { id = "a69_hydra_2",   model = 520, name = "SANDF Hydra Supersonic Jet 2", x = 350.0,  y = 2020.0, z = 17.6, rot = 180, col = { 80, 85, 90 } },
    { id = "a69_hunter_1",  model = 425, name = "SANDF Hunter Attack Gunship",  x = 380.0,  y = 2020.0, z = 17.6, rot = 180, col = { 60, 65, 55 } },
    { id = "a69_cargo_1",   model = 548, name = "SANDF Cargobob Heavy Lift",    x = 405.0,  y = 2020.0, z = 17.6, rot = 180, col = { 70, 75, 65 } },

    -- ==========================================================
    -- EASTER BASIN NAVAL BASE & AIRCRAFT CARRIER (SAN FIERRO)
    -- ==========================================================
    { id = "naval_hydra_1",   model = 520, name = "Carrier Deck Hydra Jet 1",   x = -1420.0, y = 1490.0, z = 11.5, rot = 90,  col = { 85, 90, 95 } },
    { id = "naval_hydra_2",   model = 520, name = "Carrier Deck Hydra Jet 2",   x = -1380.0, y = 1490.0, z = 11.5, rot = 90,  col = { 85, 90, 95 } },
    { id = "naval_sparrow_1", model = 447, name = "Carrier Seasparrow Heli",   x = -1400.0, y = 1530.0, z = 11.5, rot = 180, col = { 75, 80, 85 } },
    { id = "naval_patriot_1", model = 470, name = "Naval Shore Patrol Patriot", x = -1535.0, y = 1350.0, z = 7.2,  rot = 90,  col = { 70, 75, 60 } },
    { id = "naval_barrack_1", model = 433, name = "Naval Supply Barracks",     x = -1545.0, y = 1350.0, z = 7.2,  rot = 90,  col = { 70, 75, 60 } },

    -- ==========================================================
    -- PUBLIC & CIVIC HELIPADS ACROSS SAN ANDREAS
    -- ==========================================================
    -- Cape Town (LS Airport) Helipads
    { id = "ls_heli_1", model = 487, name = "CTIA Airport Maverick Heli",    x = 1545.0,  y = -2285.0, z = 13.5, rot = 0,   col = { 255, 255, 255 } },
    { id = "ls_heli_2", model = 563, name = "CTIA Raindance Search & Rescue",x = 1565.0,  y = -2285.0, z = 13.5, rot = 0,   col = { 200, 50, 50 } },

    -- King Shaka (SF Airport) Helipad
    { id = "sf_heli_1", model = 487, name = "KSIA Executive Maverick",       x = -1280.0, y = -250.0,  z = 14.1, rot = 135, col = { 30, 90, 180 } },

    -- OR Tambo (LV Airport) Helipad
    { id = "lv_heli_1", model = 487, name = "ORTIA Executive Maverick",      x = 1580.0,  y = 1580.0,  z = 10.8, rot = 180, col = { 218, 165, 32 } },

    -- SAPS Central Police Roof Helipad (Los Santos)
    { id = "saps_heli_1", model = 497, name = "SAPS Air Wing Police Maverick", x = 1555.0, y = -1675.0, z = 28.5, rot = 90, col = { 0, 0, 100 } },

    -- EMS All Saints Hospital Roof Helipad (Los Santos)
    { id = "ems_heli_1",  model = 563, name = "EMS Air Ambulance Raindance",  x = 1180.0, y = -1325.0, z = 35.5, rot = 0,  col = { 220, 20, 60 } },

    -- Free State (Bayside Marina & Government Bluff Helipad)
    { id = "fs_heli_1",   model = 487, name = "Free State Government Maverick", x = -2260.0, y = 2320.0, z = 7.5, rot = 90, col = { 255, 215, 0 } },
}

local function spawnMilitaryVehicle(cfg)
    if _militaryVehicles[cfg.id] and isElement(_militaryVehicles[cfg.id]) and getElementHealth(_militaryVehicles[cfg.id]) > 0 then
        return
    end

    local veh = createVehicle(cfg.model, cfg.x, cfg.y, cfg.z, 0, 0, cfg.rot)
    if not veh then
        outputDebugString("[Military] Failed to spawn " .. cfg.name, 2)
        return
    end

    setVehicleLocked(veh, false)
    setVehicleDoorState(veh, 0, 2)
    setVehicleEngineState(veh, true)
    setElementData(veh, "mzansi:fuel", 100)
    setElementData(veh, "mzansi:military:id", cfg.id)
    setElementData(veh, "mzansi:military:name", cfg.name)

    if cfg.col then
        setVehicleColor(veh, cfg.col[1], cfg.col[2], cfg.col[3], cfg.col[1], cfg.col[2], cfg.col[3])
    end

    addEventHandler("onVehicleExplode", veh, function()
        setTimer(function()
            if isElement(veh) then destroyElement(veh) end
            _militaryVehicles[cfg.id] = nil
            spawnMilitaryVehicle(cfg)
        end, 45000, 1)
    end)

    _militaryVehicles[cfg.id] = veh
end

function MzansiLiving.Military.init()
    outputDebugString("[Mzansi-LivingWorld] Deploying military vehicles and helicopters across bases and helipads...")
    for _, cfg in ipairs(MILITARY_AND_HELIS) do
        spawnMilitaryVehicle(cfg)
    end
    outputDebugString("[Mzansi-LivingWorld] ✓ " .. #MILITARY_AND_HELIS .. " military & helicopter assets online.")

    -- Monitor every 60s to ensure permanent availability
    setTimer(function()
        for _, cfg in ipairs(MILITARY_AND_HELIS) do
            local veh = _militaryVehicles[cfg.id]
            if not veh or not isElement(veh) or getElementHealth(veh) <= 0 then
                spawnMilitaryVehicle(cfg)
            end
        end
    end, 60000, 0)
end

addEventHandler("onResourceStop", resourceRoot, function()
    for id, veh in pairs(_militaryVehicles) do
        if isElement(veh) then destroyElement(veh) end
        _militaryVehicles[id] = nil
    end
end)

addEventHandler("onResourceStart", resourceRoot, function()
    setTimer(MzansiLiving.Military.init, 3000, 1)
end)
