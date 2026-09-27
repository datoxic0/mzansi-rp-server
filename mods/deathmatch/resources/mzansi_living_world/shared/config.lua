-- ==============================================================
-- MZANSI LIVING WORLD — SHARED CONFIGURATION
-- Grounded in data/popcycle.dat, pedstats.dat, and weapon.dat
-- ==============================================================
MzansiLiving = MzansiLiving or {}
MzansiLiving.Config = {}

-- Virtual Streaming Bubble Parameters
MzansiLiving.Config.BUBBLE_RADIUS         = 120.0  -- Active simulation radius around player
MzansiLiving.Config.SPAWN_MIN_RADIUS      = 15.0   -- Minimum distance to spawn (visible nearby)
MzansiLiving.Config.SPAWN_MAX_RADIUS      = 75.0   -- Maximum distance to spawn ahead
MzansiLiving.Config.DESPAWN_RADIUS        = 130.0  -- Distance at which distant peds are recycled
MzansiLiving.Config.MAX_PEDS_PER_PLAYER   = 16     -- Target ped budget per active player
MzansiLiving.Config.MAX_SERVER_PEDS       = 120    -- Absolute global server ped cap
MzansiLiving.Config.BURST_INITIAL_PEDS    = 10     -- Initial burst peds on player spawn
MzansiLiving.Config.MAX_VEHICLES_PER_PLAYER = 6    -- Ambient driving traffic vehicles per player
MzansiLiving.Config.MAX_SERVER_VEHICLES   = 50     -- Absolute global traffic vehicle cap
MzansiLiving.Config.BURST_INITIAL_VEHICLES = 3     -- Initial burst vehicles on player spawn
MzansiLiving.Config.TICK_INTERVAL_SERVER  = 1500   -- Server bubble check interval (ms)
MzansiLiving.Config.TICK_INTERVAL_CLIENT  = 200    -- Client perception check interval (ms)

-- Acoustic Hearing Radii by GTA Weapon ID
MzansiLiving.Config.WeaponNoiseRadius = {
    [22] = 40.0,  -- 9mm Pistol (Colt 45)
    [23] = 10.0,  -- Silenced Pistol (Discrete)
    [24] = 55.0,  -- Desert Eagle
    [25] = 55.0,  -- Shotgun
    [26] = 50.0,  -- Sawn-off Shotgun
    [27] = 60.0,  -- Combat Shotgun
    [28] = 45.0,  -- Micro Uzi
    [29] = 50.0,  -- MP5 Submachine Gun
    [30] = 65.0,  -- AK-47 Assault Rifle
    [31] = 65.0,  -- M4 Assault Rifle
    [32] = 45.0,  -- Tec-9
    [33] = 70.0,  -- Country Rifle
    [34] = 85.0,  -- Sniper Rifle
    [16] = 100.0, -- Grenade Explosion
    [35] = 100.0, -- Rocket Launcher
    [36] = 100.0, -- Heatseeker
    [39] = 100.0, -- Satchel Charge
}

-- Visual Perception Settings
MzansiLiving.Config.Visual = {
    FOV_ANGLE     = 120.0, -- Horizontal field of view in degrees
    DAY_RANGE     = 35.0,  -- Clear daylight sight range (meters)
    NIGHT_RANGE   = 18.0,  -- Nighttime sight range (meters)
    AIM_RADAR     = 20.0,  -- Maximum distance peds detect weapon aimed at them
    COLLISION_SPD = 14.0,  -- Vehicle closing speed (m/s) that triggers evasive dive
}

-- Model Pools by Demographic Group (GTA SA Model IDs)
MzansiLiving.Config.ModelPools = {
    -- Commerce / Downtown: Business suits, workers, casual upscale
    commerce = {
        models = { 17, 19, 21, 29, 40, 59, 60, 98, 141, 147, 150, 186, 187, 216, 217, 227, 228, 240, 295 },
        archetypes = {
            [MzansiLiving.Enums.Archetype.CIVILIAN_NORMAL] = 70,
            [MzansiLiving.Enums.Archetype.CIVILIAN_WEAK]   = 20,
            [MzansiLiving.Enums.Archetype.CIVILIAN_TOUGH]  = 10
        }
    },
    -- Township / Gangland: Ganton, Idlewood, East LS
    township = {
        models = { 7, 14, 22, 28, 66, 67, 102, 103, 104, 105, 106, 107, 108, 109, 110, 142, 143, 180, 182, 183 },
        archetypes = {
            [MzansiLiving.Enums.Archetype.CIVILIAN_NORMAL] = 40,
            [MzansiLiving.Enums.Archetype.CIVILIAN_TOUGH]  = 30,
            [MzansiLiving.Enums.Archetype.GANG_MEMBER]     = 30
        }
    },
    -- Beachfront: Santa Maria beach, boardwalk
    beachfront = {
        models = { 18, 45, 97, 138, 139, 140, 154, 251 },
        archetypes = {
            [MzansiLiving.Enums.Archetype.CIVILIAN_NORMAL] = 80,
            [MzansiLiving.Enums.Archetype.CIVILIAN_WEAK]   = 20
        }
    },
    -- Industrial / Docks: Ocean Docks
    docks = {
        models = { 16, 27, 50, 70, 71, 95, 153, 260 },
        archetypes = {
            [MzansiLiving.Enums.Archetype.CIVILIAN_NORMAL] = 60,
            [MzansiLiving.Enums.Archetype.CIVILIAN_TOUGH]  = 40
        }
    },
    -- Durban / KZN Province (San Fierro area)
    durban = {
        models = { 17, 19, 21, 29, 40, 42, 59, 60, 98, 141, 147, 150, 186, 216, 217, 227, 240 },
        archetypes = {
            [MzansiLiving.Enums.Archetype.CIVILIAN_NORMAL] = 65,
            [MzansiLiving.Enums.Archetype.CIVILIAN_WEAK]   = 15,
            [MzansiLiving.Enums.Archetype.CIVILIAN_TOUGH]  = 20
        }
    },
    -- Johannesburg / GP Province (Las Venturas area)
    johannesburg = {
        models = { 17, 19, 21, 29, 40, 59, 60, 98, 141, 147, 150, 186, 187, 216, 217, 227, 228, 240, 295 },
        archetypes = {
            [MzansiLiving.Enums.Archetype.CIVILIAN_NORMAL] = 60,
            [MzansiLiving.Enums.Archetype.CIVILIAN_TOUGH]  = 25,
            [MzansiLiving.Enums.Archetype.CIVILIAN_WEAK]   = 15
        }
    }
}

-- GTA SA Walking Styles
MzansiLiving.Config.WalkingStyles = {
    118, -- Standard Male
    120, -- Fat Man
    121, -- Jogger
    122, -- Gang Swagger 1
    123, -- Gang Swagger 2
    128, -- Old Man Limp
    129, -- Civilian Male
    131, -- Sexy Woman
    132, -- Prostitute Sway
    133  -- Old Woman
}

-- Robbery Dynamics
MzansiLiving.Config.Robbery = {
    HOLDUP_TIME       = 5000, -- 5 seconds hold-up time
    MIN_CASH          = 600,  -- Minimum cash drop (Rands)
    MAX_CASH          = 2200, -- Maximum cash drop (Rands)
    COOLDOWN_PER_SHOP = 300   -- 5 minute cooldown before store can be robbed again (seconds)
}
