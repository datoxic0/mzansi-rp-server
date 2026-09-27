Mzansi = Mzansi or {}
Mzansi.IllegalMarket = Mzansi.IllegalMarket or {}
Mzansi.IllegalMarket.Config = {}

Mzansi.IllegalMarket.Config.Locations = {
    {
        id = 1,
        name = "Underground Arms Dealer",
        description = "Military-grade weapons for the right price.",
        x = 2320.5, y = -2150.5, z = 13.5,
        radius = 10,
        items = {
            { name = "9mm Pistol", price = 8000, weaponId = 22, ammo = 50 },
            { name = "Silenced 9mm", price = 12000, weaponId = 23, ammo = 50 },
            { name = "Desert Eagle", price = 18000, weaponId = 24, ammo = 30 },
            { name = "Shotgun", price = 15000, weaponId = 25, ammo = 30 },
            { name = "Micro SMG", price = 22000, weaponId = 28, ammo = 100 },
            { name = "MP5", price = 28000, weaponId = 29, ammo = 100 },
            { name = "AK-47", price = 45000, weaponId = 30, ammo = 150 },
            { name = "M4", price = 55000, weaponId = 31, ammo = 150 },
            { name = "Country Rifle", price = 35000, weaponId = 33, ammo = 30 },
            { name = "Sniper Rifle", price = 70000, weaponId = 34, ammo = 20 },
        },
    },
    {
        id = 2,
        name = "Counterfeit Documents",
        description = "New identity, new life.",
        x = 1100.5, y = -1500.5, z = 13.5,
        radius = 8,
        items = {
            { name = "Fake ID Card", price = 5000 },
            { name = "Fake Driver License", price = 8000 },
            { name = "Fake Weapon License", price = 12000 },
            { name = "Fake Passport", price = 20000 },
        },
    },
    {
        id = 3,
        name = "Stolen Electronics Fence",
        description = "Quick cash for hot goods.",
        x = 1800.5, y = -1900.5, z = 13.5,
        radius = 8,
        items = {
            { name = "Stolen Phone", price = 1500, sellPrice = 800 },
            { name = "Stolen Laptop", price = 4000, sellPrice = 2000 },
            { name = "Stolen TV", price = 6000, sellPrice = 3000 },
            { name = "Stolen Jewelry", price = 8000, sellPrice = 4000 },
            { name = "Stolen Car Parts", price = 3000, sellPrice = 1500 },
        },
    },
    {
        id = 4,
        name = "Drug Dealer",
        description = "Pure product, no cut.",
        x = 1500.5, y = -1800.5, z = 13.5,
        radius = 8,
        items = {
            { name = "Weed Seed", price = 500 },
            { name = "Cocaine Seed", price = 1500 },
            { name = "Meth Seed", price = 2500 },
            { name = "Heroin Seed", price = 3500 },
            { name = "Ecstasy Seed", price = 800 },
        },
    },
    {
        id = 5,
        name = "Explosives Dealer",
        description = "Boom.",
        x = 2400.5, y = -2000.5, z = 13.5,
        radius = 8,
        items = {
            { name = "Smoke Grenade", price = 3000, weaponId = 17 },
            { name = "Tear Gas", price = 2500, weaponId = 17 },
            { name = "Molotov", price = 5000, weaponId = 18 },
            { name = "C4 Charge", price = 25000 },
        },
    },
    {
        id = 6,
        name = "Vehicle Chop Shop",
        description = "Turn hot rides into cold cash.",
        x = 2477.5, y = -1950.5, z = 13.5,
        radius = 15,
        items = {},
    },
}

Mzansi.IllegalMarket.Config.FenceItems = {
    { name = "Stolen Phone", basePrice = 800 },
    { name = "Stolen Laptop", basePrice = 2000 },
    { name = "Stolen TV", basePrice = 3000 },
    { name = "Stolen Jewelry", basePrice = 4000 },
    { name = "Gold Ore", basePrice = 5000 },
    { name = "Diamond", basePrice = 15000 },
    { name = "Electronics", basePrice = 2500 },
}

Mzansi.IllegalMarket.Config.ChopShop = {
    vehicleRewards = {
        { model = 402, name = "Buffalo", scrap = 5000 },
        { model = 411, name = "Infernus", scrap = 15000 },
        { model = 451, name = "Turismo", scrap = 20000 },
        { model = 522, name = "NRG-500", scrap = 12000 },
        { model = 560, name = "Sultan", scrap = 8000 },
        { model = 562, name = "Elegy", scrap = 7000 },
    },
    chopTime = 30000,
}
