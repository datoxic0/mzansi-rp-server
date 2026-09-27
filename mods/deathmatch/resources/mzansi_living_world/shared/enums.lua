-- ==============================================================
-- MZANSI LIVING WORLD — SHARED ENUMS
-- Rockstar Games Event-Task Architecture for MTA:SA
-- ==============================================================
MzansiLiving = MzansiLiving or {}
MzansiLiving.Enums = {}

-- AI Behavioral States (mirrors CTaskComplex macro states)
MzansiLiving.Enums.State = {
    IDLE                = 0, -- Standing, idling, breathing
    WANDER              = 1, -- Navigating the node graph
    SCENARIO            = 2, -- Performing stationary contextual task (smoking, bench, phone)
    CHATTING            = 3, -- Paired conversation with another ped
    PANIC_FLEE          = 4, -- Sprinting away from threat along node graph
    COWER               = 5, -- Dropping to knees with hands over head
    COMBAT_RETALIATE    = 6, -- Drawing weapon, seeking cover, returning fire
    WITNESS_CALL_POLICE = 7  -- Outside fire arc, whipping out phone to dial 911
}

-- 41 Engine Events (derived from data/Decision/PedEvent.txt)
MzansiLiving.Enums.Event = {
    DAMAGE                  = 9,
    DEAD_PED                = 11,
    POTENTIAL_RUN_OVER      = 12,
    POTENTIAL_WALK_INTO_PED = 13,
    SHOT_FIRED              = 15,
    GUN_AIMED_AT            = 31,
    SHOT_FIRED_WHIZZED_BY   = 49,
    SEEN_PANICKED_PED       = 65,
    SEEN_COP                = 72,
    VEHICLE_ON_FIRE         = 79
}

-- Ped Demographic Archetypes (derived from data/pedstats.dat)
MzansiLiving.Enums.Archetype = {
    CIVILIAN_NORMAL = 1, -- Average citizen: panics or flees from gunfire
    CIVILIAN_WEAK   = 2, -- Cowers, cries, easily terrified
    CIVILIAN_TOUGH  = 3, -- Fights back if cornered, yells insults
    GANG_MEMBER     = 4, -- Carries concealed handgun, returns fire, protects turf
    COP             = 5, -- SAPS officer: pursues shooters, lethal force
    SHOPKEEPER      = 6, -- Stationed behind counters, raises hands in robberies, drops cash
    PARAMEDIC       = 7  -- EMS medic: tends to injured peds
}

-- Zone Classifications (derived from data/popcycle.dat)
MzansiLiving.Enums.Zone = {
    COMMERCE   = "commerce",   -- Downtown business, banking, City Hall
    TOWNSHIP   = "township",   -- Ganton, Idlewood, East Los Santos
    DOCKS      = "docks",      -- Ocean Docks industrial area
    BEACHFRONT = "beachfront", -- Santa Maria beach and pier
    SUBURBAN   = "suburban",   -- Vinewood hills and residential
    DURBAN     = "durban",     -- San Fierro area (Durban/KZN province)
    JOHANNESBURG = "johannesburg" -- Las Venturas area (Johannesburg/GP province)
}
