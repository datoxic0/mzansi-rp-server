Mzansi = Mzansi or {}
Mzansi.Config = {}

Mzansi.Config.Server = {
    name = "Mzansi Roleplay",
    version = "1.0.0",
    maxPlayers = 128,
    defaultCash = 5000,
    defaultBank = 25000,
    startingLevel = 1,
    maxLevel = 100,
    xpPerLevel = 1000,
    payInterval = 3600000,
    vehicleDespawnTime = 60000,
    maxVehiclesPerPlayer = 4,
    maxHousesPerPlayer = 2,
    interestRate = 0.02,
    taxRate = 0.05,
}

Mzansi.Config.Database = {
    host = "localhost",
    port = 3306,
    username = "root",
    password = "",
    database = "mzansi_rp",
    poolSize = 10,
}

Mzansi.Config.Spawns = {
    { name = "LS Airport", x = 1682.5, y = -2267.0, z = 13.5, rot = 0, faction = nil },
    { name = "PDS HQ", x = 1547.5, y = -1675.5, z = 13.5, rot = 0, faction = Mzansi.Enums.Faction.SAPS },
    { name = "Hospital", x = 1176.8, y = -1323.0, z = 13.5, rot = 0, faction = Mzansi.Enums.Faction.EMS },
    { name = "DMV", x = -2026.8, y = -104.8, z = 35.0, rot = 0, faction = nil },
}

Mzansi.Config.Jobs = {
    [Mzansi.Enums.Job.UNEMPLOYED] = {
        name = "Unemployed",
        pay = 0,
        description = "Looking for work...",
    },
    [Mzansi.Enums.Job.POLICE] = {
        name = "SAPS Officer",
        pay = 8500,
        description = "South African Police Service",
        faction = Mzansi.Enums.Faction.SAPS,
    },
    [Mzansi.Enums.Job.EMS] = {
        name = "EMS Medic",
        pay = 7500,
        description = "Emergency Medical Services",
        faction = Mzansi.Enums.Faction.EMS,
    },
    [Mzansi.Enums.Job.MECHANIC] = {
        name = "Mechanic",
        pay = 5500,
        description = "Vehicle repair and maintenance",
        faction = nil,
    },
    [Mzansi.Enums.Job.TRUCKER] = {
        name = "Trucker",
        pay = 4200,
        description = "Long haul cargo delivery",
        faction = nil,
    },
    [Mzansi.Enums.Job.FISHERMAN] = {
        name = "Fisherman",
        pay = 3800,
        description = "Catch and sell fish",
        faction = nil,
    },
    [Mzansi.Enums.Job.FARMER] = {
        name = "Farmer",
        pay = 4500,
        description = "Cultivate crops and livestock",
        faction = nil,
    },
    [Mzansi.Enums.Job.TAXI] = {
        name = "Taxi Driver",
        pay = 3500,
        description = "Transport passengers",
        faction = nil,
    },
    [Mzansi.Enums.Job.BUS_DRIVER] = {
        name = "Bus Driver",
        pay = 4000,
        description = "Public transport routes",
        faction = nil,
    },
    [Mzansi.Enums.Job.MINER] = {
        name = "Miner",
        pay = 6000,
        description = "Extract minerals underground",
        faction = nil,
    },
    [Mzansi.Enums.Job.PILOT] = {
        name = "Pilot",
        pay = 9000,
        description = "Commercial aviation",
        faction = nil,
    },
    [Mzansi.Enums.Job.DELIVERY] = {
        name = "Delivery Driver",
        pay = 3200,
        description = "Package delivery service",
        faction = nil,
    },
    [Mzansi.Enums.Job.BUSINESS_OWNER] = {
        name = "Business Owner",
        pay = 0,
        description = "Own and operate businesses",
        faction = nil,
    },
}

Mzansi.Config.Factions = {
    [Mzansi.Enums.Faction.NONE] = {
        name = "Civilian",
        ranks = { "Civilian" },
    },
    [Mzansi.Enums.Faction.SAPS] = {
        name = "South African Police Service",
        ranks = {
            "Constable",
            "Lance Corporal",
            "Corporal",
            "Sergeant",
            "Staff Sergeant",
            "Warrant Officer",
            "Lieutenant",
            "Captain",
            "Major",
            "Colonel",
            "Brigadier",
            "Major General",
        },
        vehicles = { 596, 597, 598, 599, 601 },
    },
    [Mzansi.Enums.Faction.EMS] = {
        name = "Emergency Medical Services",
        ranks = {
            "Trainee Medic",
            "Paramedic",
            "Senior Paramedic",
            "Ambulance Officer",
            "Emergency Physician",
            "EMS Supervisor",
            "EMS Director",
        },
        vehicles = { 416, 427, 433 },
    },
    [Mzansi.Enums.Faction.SANDF] = {
        name = "South African National Defence Force",
        ranks = {
            "Private",
            "Lance Corporal",
            "Corporal",
            "Sergeant",
            "Staff Sergeant",
            "Warrant Officer",
            "Lieutenant",
            "Captain",
            "Major",
            "Colonel",
            "Brigadier",
            "Major General",
            "General",
        },
        vehicles = { 432, 433, 470, 528 },
    },
    [Mzansi.Enums.Faction.NEWS] = {
        name = "Cape Town News",
        ranks = {
            "Intern",
            "Reporter",
            "Senior Reporter",
            "Editor",
            "Senior Editor",
            "Chief Editor",
            "Director",
        },
        vehicles = { 488, 582 },
    },
}

Mzansi.Config.Vehicles = {
    fuelEnabled = true,
    lockEnabled = true,
    engineDamage = true,
    maxFuel = 100,
    fuelConsumptionRate = 0.05,
    repairCostPerPercent = 50,
    insuranceBaseCost = 2000,
    speedLimit = 200,
}

Mzansi.Config.Housing = {
    maxFurniture = 50,
    rentMultiplier = 0.1,
    propertyTaxRate = 0.01,
    maxStorage = 100,
}

Mzansi.Config.Phone = {
    callCostPerMinute = 50,
    smsCost = 25,
    dataCostPerMB = 10,
    signalRadius = 200,
}

Mzansi.Config.Police = {
    arrestRange = 5,
    handcuffRange = 3,
    ticketMin = 500,
    ticketMax = 5000,
    jailMinutePerStar = 5,
    maxBail = 50000,
}

Mzansi.Config.EMS = {
    healRange = 5,
    reviveTime = 10000,
    healCost = 500,
    reviveCost = 2500,
}

Mzansi.Config.Weapons = {
    [22] = { name = "9mm Pistol", price = 2500, license = true },
    [23] = { name = "Silenced 9mm", price = 3500, license = true },
    [24] = { name = "Desert Eagle", price = 5000, license = true },
    [25] = { name = "Shotgun", price = 4000, license = true },
    [28] = { name = "Micro SMG", price = 6000, license = true },
    [29] = { name = "MP5", price = 7500, license = true },
    [30] = { name = "AK-47", price = 10000, license = true },
    [31] = { name = "M4", price = 12000, license = true },
    [33] = { name = "Country Rifle", price = 8000, license = true },
    [34] = { name = "Sniper Rifle", price = 15000, license = true },
}

Mzansi.Config.Businesses = {
    { id = 1, name = "24/7 - LS Airport", type = "convenience", x = 1585.5, y = -1678.5, z = 13.5 },
    { id = 2, name = "Binco - LS Mall", type = "clothing", x = 2244.5, y = -1665.5, z = 15.5 },
    { id = 3, name = "Ammu-Nation - LS", type = "ammunation", x = 1368.5, y = -1279.5, z = 13.5 },
    { id = 4, name = "LS Customs", type = "modshop", x = 1041.5, y = -1026.5, z = 32.0 },
    { id = 5, name = "Pay N Spray - LS", type = "paynspray", x = 1025.5, y = -1023.5, z = 32.0 },
    { id = 6, name = "Gas Station - LS", type = "gas", x = 1944.5, y = -1772.5, z = 13.5 },
    { id = 7, name = "Supermarket - Ganton", type = "convenience", x = 1352.5, y = -1759.5, z = 13.5 },
    { id = 8, name = "Cluckin' Bell - LS", type = "restaurant", x = 928.5, y = -1353.5, z = 13.5 },
    { id = 9, name = "Burger Shot - LS", type = "restaurant", x = 1199.5, y = -918.5, z = 43.5 },
    { id = 10, name = "Pizza Stack - LS", type = "restaurant", x = 2105.5, y = -1806.5, z = 13.5 },
}

Mzansi.Config.Zones = {
    { name = "Los Santos", minX = -2994.0, maxX = 2994.0, minY = -2994.0, maxY = 880.0 },
    { name = "Bone County", minX = -1461.0, maxX = 556.0, minY = 880.0, maxY = 2500.0 },
    { name = "Tierra Robada", minX = -1461.0, maxX = -461.0, minY = 880.0, maxY = 2000.0 },
    { name = "Red County", minX = 556.0, maxX = 2994.0, minY = 880.0, maxY = 2500.0 },
    { name = "Flint County", minX = -461.0, maxX = 556.0, minY = -820.0, maxY = 880.0 },
    { name = "Whetstone", minX = -461.0, maxX = 556.0, minY = -2994.0, maxY = -820.0 },
    { name = "Las Venturas", minX = -1461.0, maxX = 2994.0, minY = 2000.0, maxY = 2994.0 },
    { name = "San Fierro", minX = -2994.0, maxX = -461.0, minY = -2994.0, maxY = 880.0 },
}
