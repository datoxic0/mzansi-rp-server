Mzansi = Mzansi or {}
Mzansi.Gangs = Mzansi.Gangs or {}
Mzansi.Gangs.Config = {}

Mzansi.Gangs.Config.MaxGangMembers = 30
Mzansi.Gangs.Config.MaxGangs = 10
Mzansi.Gangs.Config.GangCreationCost = 100000
Mzansi.Gangs.Config.TerritoryClaimCost = 25000
Mzansi.Gangs.Config.TerritoryIncome = 5000
Mzansi.Gangs.Config.WarCooldown = 3600000
Mzansi.Gangs.Config.SprayCooldown = 300000

-- ==============================================================
-- SOUTH AFRICAN PROVINCIAL GANG SYNDICATES
-- Distributed across Cape Town (LS), Durban (SF), and Jozi (LV)
-- ==============================================================
Mzansi.Gangs.Config.Gangs = {
    -- ---------------------------------------------------------
    -- WESTERN CAPE / CAPE TOWN (LOS SANTOS)
    -- ---------------------------------------------------------
    [1] = {
        id = 1,
        name = "Crazy Dragons",
        tag = "CD",
        province = "Western Cape (Cape Town)",
        color = { r = 255, g = 0, b = 0 },
        leader = nil,
        description = "Chinese triad syndicate running port smuggling and contraband in Cape Town.",
        spawn = { x = 1920.5, y = -1760.5, z = 13.5 },
        ranks = {
            { name = "Associate", level = 0 },
            { name = "Soldier", level = 1 },
            { name = "Enforcer", level = 2 },
            { name = "Lieutenant", level = 3 },
            { name = "Captain", level = 4 },
            { name = "Underboss", level = 5 },
            { name = "Boss", level = 6 },
        },
    },
    [2] = {
        id = 2,
        name = "South Side Kings",
        tag = "SSK",
        province = "Western Cape (Cape Town)",
        color = { r = 0, g = 100, b = 255 },
        leader = nil,
        description = "Dominant street lowrider crew controlling Ganton and local Cape Flats corners.",
        spawn = { x = 2244.5, y = -1665.5, z = 15.5 },
        ranks = {
            { name = "Peewee", level = 0 },
            { name = "Gangsta", level = 1 },
            { name = "OG", level = 2 },
            { name = "Shot Caller", level = 3 },
            { name = "Big Dog", level = 4 },
            { name = "Vice Boss", level = 5 },
            { name = "Boss", level = 6 },
        },
    },
    [6] = {
        id = 6,
        name = "Numbers Gang (28s)",
        tag = "NG",
        province = "Western Cape (Cape Town)",
        color = { r = 255, g = 100, b = 0 },
        leader = nil,
        description = "Feared prison-born 28s criminal society with iron rule over Cape Flats.",
        spawn = { x = 1950.0, y = -1450.0, z = 13.5 },
        ranks = {
            { name = "26", level = 0 },
            { name = "27", level = 1 },
            { name = "28", level = 2 },
            { name = "Big Five", level = 3 },
            { name = "Generaal", level = 4 },
            { name = "Oorlogsraad", level = 5 },
            { name = "Oppermann", level = 6 },
        },
    },

    -- ---------------------------------------------------------
    -- KWAZULU-NATAL / DURBAN (SAN FIERRO)
    -- ---------------------------------------------------------
    [3] = {
        id = 3,
        name = "Zulu Warriors",
        tag = "ZW",
        province = "KwaZulu-Natal (Durban)",
        color = { r = 0, g = 200, b = 0 },
        leader = nil,
        description = "KwaZulu-Natal warrior fraternity controlling Durban Harbour, hostels, and coastal transit.",
        spawn = { x = -2160.5, y = -235.5, z = 36.5 },
        ranks = {
            { name = "Izandla", level = 0 },
            { name = "Umbutho", level = 1 },
            { name = "Induna", level = 2 },
            { name = "iSipatha", level = 3 },
            { name = "iNkosi Encane", level = 4 },
            { name = "iNkosi Enkulu", level = 5 },
            { name = "Inkosi", level = 6 },
        },
    },

    -- ---------------------------------------------------------
    -- GAUTENG / JOHANNESBURG (LAS VENTURAS)
    -- ---------------------------------------------------------
    [4] = {
        id = 4,
        name = "Boere Mafia",
        tag = "BM",
        province = "Gauteng (Johannesburg)",
        color = { r = 200, g = 150, b = 0 },
        leader = nil,
        description = "Highveld Afrikaner syndicate running heavy arms dealing, CIT armoured heists, and mining belts.",
        spawn = { x = 2270.5, y = 1430.5, z = 11.5 },
        ranks = {
            { name = "Man", level = 0 },
            { name = "Rider", level = 1 },
            { name = "Veld Commando", level = 2 },
            { name = "Area Boss", level = 3 },
            { name = "General", level = 4 },
            { name = "Oubaas", level = 5 },
            { name = "Patriarch", level = 6 },
        },
    },
    [5] = {
        id = 5,
        name = "Nyau Dust Cartel",
        tag = "NDC",
        province = "Gauteng (Johannesburg)",
        color = { r = 150, g = 0, b = 200 },
        leader = nil,
        description = "High-stakes Gauteng cartel operating crystal meth superlabs and casino gold laundering.",
        spawn = { x = 2480.5, y = 2110.5, z = 11.0 },
        ranks = {
            { name = "Runner", level = 0 },
            { name = "Pusher", level = 1 },
            { name = "Distributor", level = 2 },
            { name = "Supplier", level = 3 },
            { name = "Lieutenant", level = 4 },
            { name = "Consigliere", level = 5 },
            { name = "El Patron", level = 6 },
        },
    },
}

-- ==============================================================
-- TERRITORIES — TRI-PROVINCIAL CONTESTED ZONES
-- ==============================================================
Mzansi.Gangs.Config.Territories = {
    -- ---------------------------------------------------------
    -- PROVINCE 1: CAPE TOWN / WESTERN CAPE (LOS SANTOS)
    -- ---------------------------------------------------------
    { id = 1,  name = "Ganton / Mitchells Plain",     x = 2240.5,  y = -1750.5, z = 13.5, radius = 150, gangId = 2,   province = "Western Cape" },
    { id = 2,  name = "Idlewood Cape Flats",          x = 1970.5,  y = -1800.5, z = 13.5, radius = 150, gangId = 6,   province = "Western Cape" },
    { id = 3,  name = "Market & Chinatown Strip",     x = 1920.5,  y = -1760.5, z = 13.5, radius = 150, gangId = 1,   province = "Western Cape" },
    { id = 4,  name = "Ocean Docks Wharfs",           x = 2400.5,  y = -2200.5, z = 13.5, radius = 160, gangId = nil, province = "Western Cape" },
    { id = 5,  name = "El Corona / Athlone",          x = 1780.5,  y = -2150.5, z = 13.5, radius = 150, gangId = nil, province = "Western Cape" },

    -- ---------------------------------------------------------
    -- PROVINCE 2: DURBAN / KWAZULU-NATAL (SAN FIERRO)
    -- ---------------------------------------------------------
    { id = 6,  name = "Durban Golden Mile (SF)",      x = -2720.0, y = -320.0,  z = 7.5,  radius = 160, gangId = 3,   province = "KwaZulu-Natal" },
    { id = 7,  name = "Durban Harbour Easter Basin",  x = -1600.0, y = 150.0,   z = 10.5, radius = 175, gangId = 3,   province = "KwaZulu-Natal" },
    { id = 8,  name = "KwaMashu Garcia Hostels",      x = -2160.0, y = -240.0,  z = 36.5, radius = 150, gangId = 3,   province = "KwaZulu-Natal" },
    { id = 9,  name = "Warwick Taxi Junction (SF)",   x = -2050.0, y = 150.0,   z = 28.5, radius = 150, gangId = nil, province = "KwaZulu-Natal" },
    { id = 10, name = "Point Road Smuggling Strip",   x = -2680.0, y = 1350.0,  z = 7.0,  radius = 160, gangId = nil, province = "KwaZulu-Natal" },

    -- ---------------------------------------------------------
    -- PROVINCE 3: JOHANNESBURG (JOZI) / GAUTENG (LAS VENTURAS)
    -- ---------------------------------------------------------
    { id = 11, name = "Egoli Gold Reef Strip (LV)",   x = 2028.0,  y = 1008.0,  z = 10.8, radius = 160, gangId = nil, province = "Gauteng" },
    { id = 12, name = "Hillbrow Redsands East (LV)",  x = 2270.0,  y = 1430.0,  z = 11.5, radius = 150, gangId = 4,   province = "Gauteng" },
    { id = 13, name = "Old Venturas Braamfontein Strip",x= 2480.0, y = 2110.0,  z = 11.0, radius = 150, gangId = 5,   province = "Gauteng" },
    { id = 14, name = "Rockshore East Rand Mines",    x = 2550.0,  y = 700.0,   z = 11.0, radius = 175, gangId = 4,   province = "Gauteng" },
    { id = 15, name = "Come-A-Lot Casino District",   x = 2160.0,  y = 1680.0,  z = 11.0, radius = 150, gangId = 5,   province = "Gauteng" },
}

-- ==============================================================
-- GANG VEHICLE SPAWNS — PROVINCIAL HEADQUARTERS
-- ==============================================================
Mzansi.Gangs.Config.VehicleSpawns = {
    -- Cape Town (Crazy Dragons - Mesa / Sultan)
    [1] = { model = 560, x = 1925.5,  y = -1755.5, z = 13.5, rot = 0   },
    -- Cape Town (SSK - Blade)
    [2] = { model = 536, x = 2250.5,  y = -1660.5, z = 15.5, rot = 90  },
    -- Durban / KZN (Zulu Warriors - Buffalo)
    [3] = { model = 402, x = -2150.0, y = -230.0,  z = 36.5, rot = 90  },
    -- Jozi / Gauteng (Boere Mafia - Huntley SUV)
    [4] = { model = 579, x = 2275.0,  y = 1435.0,  z = 11.5, rot = 180 },
    -- Jozi / Gauteng (Nyau Dust Cartel - Cheetah)
    [5] = { model = 415, x = 2485.0,  y = 2115.0,  z = 11.0, rot = 270 },
    -- Cape Town (Numbers Gang 28s - Greenwood)
    [6] = { model = 492, x = 1955.0,  y = -1455.0, z = 13.5, rot = 0   },
}
