-- Mzansi-ZA Shared Enums and Constants
-- Single source of truth for all magic numbers and strings

local Enums = {}

-- Player spawn locations (Johannesburg City Hall area)
Enums.SpawnLocations = {
    JOHANNESBURG_CITY_HALL = { x = 1520.0, y = -1520.0, z = 13.5, rot = 0.0, interior = 0, dimension = 0 },
    SAPS_HEADQUARTERS = { x = 1550.0, y = -1650.0, z = 14.0, rot = 90.0, interior = 0, dimension = 0 },
    TAXI_RANK = { x = 2150.0, y = -1850.0, z = 13.5, rot = 180.0, interior = 0, dimension = 0 },
    TOWNSHIP_SPAWN = { x = -2450.0, y = 550.0, z = 30.0, rot = 270.0, interior = 0, dimension = 0 }
}

-- South African Vehicle Models (using dynamic allocation via engineRequestModel)
Enums.SAVehicleModels = {
    -- Taxis & Public Transport
    TOYOTA_QUANTUM = { name = "Toyota Quantum", baseModel = 482, category = "taxi" },
    TOYOTA_HIACE = { name = "Toyota Hiace", baseModel = 482, category = "taxi" },
    MAZDA_BONGO = { name = "Mazda Bongo", baseModel = 482, category = "taxi" },
    
    -- SAPS Vehicles
    SAPS_POLO = { name = "VW Polo SAPS", baseModel = 546, category = "police", lights = true },
    SAPS_BMW = { name = "BMW 3-Series SAPS", baseModel = 420, category = "police", lights = true },
    SAPS_RANGER = { name = "Ford Ranger SAPS", baseModel = 490, category = "police", lights = true },
    SAPS_HELI = { name = "SAPS Helicopter", baseModel = 497, category = "police_air" },
    
    -- Metro Police
    METRO_VW = { name = "VW Polo Metro", baseModel = 546, category = "police", lights = true },
    METRO_BMW = { name = "BMW Metro", baseModel = 420, category = "police", lights = true },
    
    -- EMS
    EMS_AMBULANCE = { name = "EMS Ambulance", baseModel = 416, category = "ems", lights = true },
    
    -- Civilian Vehicles (common SA cars)
    VW_GOLF = { name = "VW Golf", baseModel = 422, category = "civilian" },
    TOYOTA_COROLLA = { name = "Toyota Corolla", baseModel = 445, category = "civilian" },
    HYUNDAI_I20 = { name = "Hyundai i20", baseModel = 445, category = "civilian" },
    FORD_FIGO = { name = "Ford Figo", baseModel = 445, category = "civilian" },
    NISSAN_NP200 = { name = "Nissan NP200", baseModel = 525, category = "civilian" },
    TOYOTA_HILUX = { name = "Toyota Hilux", baseModel = 525, category = "civilian" },
    FORD_RANGER = { name = "Ford Ranger", baseModel = 490, category = "civilian" },
    ISUZU_KB = { name = "Isuzu KB", baseModel = 490, category = "civilian" },
    
    -- Minibus Taxis (the iconic Quantum)
    QUANTUM_TAXI = { name = "Toyota Quantum Taxi", baseModel = 482, category = "taxi", livery = "taxi" },
    QUANTUM_PRIVATE = { name = "Toyota Quantum Private", baseModel = 482, category = "taxi", livery = "private" }
}

-- Faction/Job Types
Enums.Factions = {
    NONE = 0,
    CIVILIAN = 1,
    SAPS = 2,              -- South African Police Service
    METRO_POLICE = 3,      -- Johannesburg Metro Police
    EMS = 4,               -- Emergency Medical Services
    TAXI_ASSOCIATION = 5,  -- Taxi industry
    SECURITY = 6,          -- Private security
    GOVERNMENT = 7,        -- Government officials
    MECHANIC = 8,          -- Vehicle mechanics
    TRUCKER = 9,           -- Logistics/trucking
    LAWYER = 10            -- Legal profession
}

Enums.FactionNames = {
    [Enums.Factions.NONE] = "Civilian",
    [Enums.Factions.SAPS] = "South African Police Service",
    [Enums.Factions.METRO_POLICE] = "Johannesburg Metro Police",
    [Enums.Factions.EMS] = "Emergency Medical Services",
    [Enums.Factions.TAXI_ASSOCIATION] = "Taxi Association",
    [Enums.Factions.SECURITY] = "Private Security",
    [Enums.Factions.GOVERNMENT] = "Government",
    [Enums.Factions.MECHANIC] = "Mechanic",
    [Enums.Factions.TRUCKER] = "Trucker",
    [Enums.Factions.LAWYER] = "Lawyer"
}

Enums.FactionRanks = {
    SAPS = {
        [1] = "Constable",
        [2] = "Sergeant",
        [3] = "Warrant Officer",
        [4] = "Lieutenant",
        [5] = "Captain",
        [6] = "Major",
        [7] = "Lieutenant Colonel",
        [8] = "Colonel",
        [9] = "Brigadier",
        [10] = "Major General",
        [11] = "Lieutenant General",
        [12] = "General",
        [13] = "Commissioner"
    },
    METRO_POLICE = {
        [1] = "Metro Constable",
        [2] = "Metro Sergeant",
        [3] = "Metro Inspector",
        [4] = "Metro Chief Inspector",
        [5] = "Metro Superintendent",
        [6] = "Metro Chief Superintendent",
        [7] = "Metro Director",
        [8] = "Metro Chief Director",
        [9] = "Metro Commissioner"
    },
    EMS = {
        [1] = "Student Paramedic",
        [2] = "Paramedic",
        [3] = "Senior Paramedic",
        [4] = "Shift Supervisor",
        [5] = "Station Commander",
        [6] = "District Manager",
        [7] = "Provincial Head"
    },
    TAXI_ASSOCIATION = {
        [1] = "Driver",
        [2] = "Senior Driver",
        [3] = "Queue Marshal",
        [4] = "Route Manager",
        [5] = "Association Secretary",
        [6] = "Association Chairperson"
    }
}

-- Economy
Enums.Economy = {
    STARTING_CASH = 5000,
    STARTING_BANK = 10000,
    PAYDAY_INTERVAL_MS = 3600000, -- 1 hour
    PAYDAY_BASE = 2000,
    PAYDAY_FACTION_BONUS = {
        [Enums.Factions.SAPS] = 3500,
        [Enums.Factions.METRO_POLICE] = 3000,
        [Enums.Factions.EMS] = 2500,
        [Enums.Factions.TAXI_ASSOCIATION] = 1500,
        [Enums.Factions.MECHANIC] = 2000,
        [Enums.Factions.TRUCKER] = 3000
    },
    BANK_INTEREST_RATE = 0.02, -- 2% per payday
    MAX_CASH_CARRY = 500000,
    VEHICLE_PURCHASE_TAX = 0.15,
    PROPERTY_TAX_RATE = 0.01
}

-- Vehicle prices (in ZAR)
Enums.VehiclePrices = {
    [Enums.SAVehicleModels.TOYOTA_QUANTUM] = 350000,
    [Enums.SAVehicleModels.SAPS_POLO] = 450000,
    [Enums.SAVehicleModels.SAPS_BMW] = 850000,
    [Enums.SAVehicleModels.SAPS_RANGER] = 650000,
    [Enums.SAVehicleModels.VW_GOLF] = 280000,
    [Enums.SAVehicleModels.TOYOTA_COROLLA] = 320000,
    [Enums.SAVehicleModels.HYUNDAI_I20] = 250000,
    [Enums.SAVehicleModels.FORD_FIGO] = 220000,
    [Enums.SAVehicleModels.NISSAN_NP200] = 280000,
    [Enums.SAVehicleModels.TOYOTA_HILUX] = 450000,
    [Enums.SAVehicleModels.FORD_RANGER] = 520000,
    [Enums.SAVehicleModels.ISUZU_KB] = 480000
}

-- Database table names
Enums.DatabaseTables = {
    ACCOUNTS = "accounts",
    CHARACTERS = "characters",
    VEHICLES = "vehicles",
    PROPERTIES = "properties",
    FACTIONS = "factions",
    FACTION_MEMBERS = "faction_members",
    INVENTORY = "inventory",
    LOGS = "logs",
    BANS = "bans",
    SETTINGS = "settings"
}

-- Element data keys (shared between client/server)
Enums.ElementData = {
    ACCOUNT_ID = "account:id",
    ACCOUNT_NAME = "account:name",
    CHARACTER_ID = "character:id",
    CHARACTER_NAME = "character:name",
    CHARACTER_SKIN = "character:skin",
    CASH = "player:cash",
    BANK = "player:bank",
    FACTION = "player:faction",
    FACTION_RANK = "player:faction_rank",
    IS_LOGGED_IN = "player:logged_in",
    SPAWN_POSITION = "player:spawn_pos",
    ADMIN_LEVEL = "player:admin_level",
    AFK_TIME = "player:afk_time",
    INVENTORY = "player:inventory",
    VEHICLE_KEYS = "player:vehicle_keys",
    PHONE_NUMBER = "player:phone_number",
    WANTED_LEVEL = "player:wanted_level",
    IS_CUFFED = "player:cuffed",
    IS_INJURED = "player:injured"
}

-- Event names (prevent typos)
Enums.Events = {
    -- Server -> Client
    CLIENT_SPAWN = "mzansi:onClientSpawn",
    CLIENT_LOGIN = "mzansi:onClientLogin",
    CLIENT_LOGOUT = "mzansi:onClientLogout",
    CLIENT_CASH_UPDATE = "mzansi:onClientCashUpdate",
    CLIENT_BANK_UPDATE = "mzansi:onClientBankUpdate",
    CLIENT_FACTION_UPDATE = "mzansi:onClientFactionUpdate",
    CLIENT_VEHICLE_SPAWN = "mzansi:onClientVehicleSpawn",
    CLIENT_SHOW_CEF = "mzansi:showCEF",
    CLIENT_HIDE_CEF = "mzansi:hideCEF",
    CLIENT_NOTIFICATION = "mzansi:showNotification",
    CLIENT_CHAT_MESSAGE = "mzansi:chatMessage",
    CLIENT_ASSETS_LOADED = "mzansi:assetsLoaded",
    CLIENT_PAYDAY = "mzansi:payday",
    CLIENT_WANTED_UPDATE = "mzansi:wantedLevelUpdate",
    
    -- Client -> Server
    SERVER_LOGIN = "mzansi:serverLogin",
    SERVER_REGISTER = "mzansi:serverRegister",
    SERVER_SPAWN_REQUEST = "mzansi:serverSpawnRequest",
    SERVER_GIVE_CASH = "mzansi:serverGiveCash",
    SERVER_TAKE_CASH = "mzansi:serverTakeCash",
    SERVER_BANK_DEPOSIT = "mzansi:serverBankDeposit",
    SERVER_BANK_WITHDRAW = "mzansi:serverBankWithdraw",
    SERVER_BANK_TRANSFER = "mzansi:serverBankTransfer",
    SERVER_FACTION_JOIN = "mzansi:serverFactionJoin",
    SERVER_FACTION_LEAVE = "mzansi:serverFactionLeave",
    SERVER_VEHICLE_BUY = "mzansi:serverVehicleBuy",
    SERVER_VEHICLE_SELL = "mzansi:serverVehicleSell",
    SERVER_VEHICLE_SPAWN = "mzansi:serverVehicleSpawn",
    SERVER_VEHICLE_DESPAWN = "mzansi:serverVehicleDespawn",
    SERVER_CHAT_MESSAGE = "mzansi:serverChatMessage",
    SERVER_COMMAND = "mzansi:serverCommand",
    SERVER_ASSET_REQUEST = "mzansi:serverAssetRequest",
    SERVER_CEF_CALLBACK = "mzansi:serverCEFCallback",
    
    -- Shared (both directions)
    SYNC_PLAYER_DATA = "mzansi:syncPlayerData",
    SYNC_VEHICLE_DATA = "mzansi:syncVehicleData",
    SYNC_FACTION_DATA = "mzansi:syncFactionData"
}

-- CEF Interface Types
Enums.CEFInterfaces = {
    BANKING = "banking",
    MDT = "mdt",
    INVENTORY = "inventory",
    PHONE = "phone",
    VEHICLE_SHOP = "vehicle_shop",
    PROPERTY_MENU = "property_menu",
    FACTION_MENU = "faction_menu",
    ADMIN_PANEL = "admin_panel"
}

-- Notification types
Enums.NotificationType = {
    INFO = "info",
    SUCCESS = "success",
    WARNING = "warning",
    ERROR = "error",
    SYSTEM = "system"
}

-- Weapon licenses (SA context)
Enums.WeaponLicenses = {
    NONE = 0,
    COMPETENCY = 1,      -- Basic competency certificate
    SELF_DEFENSE = 2,    -- Self defense permit
    SECURITY = 3,        -- Security officer license
    POLICE = 4,          -- Police service
    DEDICATED_HUNTER = 5 -- Dedicated hunter
}

-- Vehicle spawn limits per faction
Enums.FactionVehicleLimits = {
    [Enums.Factions.SAPS] = 5,
    [Enums.Factions.METRO_POLICE] = 3,
    [Enums.Factions.EMS] = 2,
    [Enums.Factions.TAXI_ASSOCIATION] = 10,
    [Enums.Factions.SECURITY] = 2,
    [Enums.Factions.GOVERNMENT] = 2
}

-- Animation dictionaries for SA context
Enums.Animations = {
    SAPS_ARREST = { dict = "COP_AMBIENT", anim = "Coplook_loop" },
    SAPS_TAZER = { dict = "COP_AMBIENT", anim = "Coplook_think" },
    HANDS_UP = { dict = "PED", anim = "HANDSUP" },
    SIT = { dict = "PED", anim = "SEAT_DOWN" },
    LEAN = { dict = "PED", anim = "LEAN_LOOP" },
    TAXI_HAIL = { dict = "PED", anim = "HAIL_TAXI" },
    PHONE_CALL = { dict = "PED", anim = "PHONE_IN" },
    PHONE_TALK = { dict = "PED", anim = "PHONE_TALK" },
    PHONE_OUT = { dict = "PED", anim = "PHONE_OUT" }
}

-- Weather types for SA climate
Enums.SAWeather = {
    SUNNY = 0,
    EXTRA_SUNNY = 1,
    CLOUDY = 2,
    RAINY = 3,
    FOGGY = 4,
    OVERCAST = 5,
    THUNDERSTORM = 6,
    CLEAR = 7,
    BLITZ = 8,
    SANDSTORM = 9 -- For Northern Cape/Karoo
}

-- Interior IDs for SA locations
Enums.Interiors = {
    SAPS_HQ = 1,
    METRO_HQ = 2,
    HOSPITAL = 3,
    BANK = 4,
    COURT = 5,
    TAXI_RANK = 6,
    MALL = 7,
    APARTMENT_LOW = 8,
    APARTMENT_MID = 9,
    APARTMENT_HIGH = 10,
    HOUSE_TOWNSHIP = 11,
    HOUSE_SUBURBAN = 12,
    HOUSE_LUXURY = 13,
    FACTORY = 14,
    WAREHOUSE = 15,
    GARAGE = 16
}

-- Chat colors (RGB)
Enums.ChatColors = {
    WHITE = {255, 255, 255},
    RED = {255, 0, 0},
    GREEN = {0, 255, 0},
    BLUE = {0, 150, 255},
    YELLOW = {255, 255, 0},
    ORANGE = {255, 165, 0},
    PURPLE = {180, 0, 255},
    PINK = {255, 100, 200},
    GREY = {180, 180, 180},
    GOLD = {255, 215, 0},
    SAPS_BLUE = {0, 51, 153},
    METRO_BLUE = {0, 102, 204},
    EMS_GREEN = {0, 153, 51},
    TAXI_YELLOW = {255, 204, 0}
}

-- Export enums globally
_G.Enums = Enums

return Enums