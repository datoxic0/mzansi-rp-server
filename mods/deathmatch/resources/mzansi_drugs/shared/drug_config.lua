Mzansi = Mzansi or {}
Mzansi.Drugs = Mzansi.Drugs or {}
Mzansi.Drugs.Config = {}

Mzansi.Drugs.Config.GrowthTime = 300000
Mzansi.Drugs.Config.HarvestCooldown = 120000
Mzansi.Drugs.Config.TrafficCooldown = 600000

Mzansi.Drugs.Config.Drugs = {
    {
        id = "weed",
        name = "Cannabis (Dagga)",
        growTime = 300000,
        harvestAmount = { min = 1, max = 3 },
        sellPrice = 800,
        usePrice = 0,
        effects = { health = 10, armor = 0, speed = 0.8, duration = 30000 },
        addiction = 0.1,
        description = "South African dagga. Grows in the countryside.",
    },
    {
        id = "cocaine",
        name = "Cocaine (Tik)",
        growTime = 600000,
        harvestAmount = { min = 1, max = 2 },
        sellPrice = 2500,
        usePrice = 0,
        effects = { health = -5, armor = 0, speed = 1.5, duration = 20000 },
        addiction = 0.3,
        description = "Crystal meth. Highly addictive.",
    },
    {
        id = "heroin",
        name = "Heroin (Nyaope)",
        growTime = 900000,
        harvestAmount = { min = 1, max = 1 },
        sellPrice = 5000,
        usePrice = 0,
        effects = { health = -10, armor = 0, speed = 0.5, duration = 45000 },
        addiction = 0.5,
        description = "Nyaope mix. Dangerous and addictive.",
    },
    {
        id = "ecstasy",
        name = "Ecstasy (Buttons)",
        growTime = 450000,
        harvestAmount = { min = 2, max = 4 },
        sellPrice = 1200,
        usePrice = 0,
        effects = { health = 5, armor = 10, speed = 1.2, duration = 25000 },
        addiction = 0.2,
        description = "Party drugs. Popular in clubs.",
    },
    {
        id = "meth",
        name = "Methamphetamine (Whoonga)",
        growTime = 750000,
        harvestAmount = { min = 1, max = 2 },
        sellPrice = 3500,
        usePrice = 0,
        effects = { health = -15, armor = 0, speed = 1.8, duration = 15000 },
        addiction = 0.4,
        description = "Whoonga. Devastating to communities.",
    },
}

Mzansi.Drugs.Config.GrowLocations = {
    { id = 1, name = "Flint County Farm", x = -366.5, y = 1188.5, z = 20.0, radius = 50, slots = 10 },
    { id = 2, name = "Backwood Fields", x = -500.5, y = 1200.5, z = 25.0, radius = 40, slots = 8 },
    { id = 3, name = "Abandoned Warehouse", x = 1200.5, y = -2000.5, z = 13.5, radius = 30, slots = 15 },
    { id = 4, name = "Countryside Barn", x = 200.5, y = 800.5, z = 30.0, radius = 35, slots = 12 },
    { id = 5, name = "Desert hideout", x = 500.5, y = 1500.5, z = 20.0, radius = 45, slots = 10 },
}

Mzansi.Drugs.Config.TrafficRoutes = {
    {
        id = 1,
        name = "LS Distribution",
        start = { x = 1200.5, y = -2000.5, z = 13.5 },
        dropoffs = {
            { name = "Ganton Drop", x = 2244.5, y = -1665.5, z = 15.5, pay = 5000 },
            { name = "Idlewood Drop", x = 1970.5, y = -1800.5, z = 13.5, pay = 4500 },
            { name = "East LS Drop", x = 2500.5, y = -1700.5, z = 13.5, pay = 5500 },
        },
    },
    {
        id = 2,
        name = "County Connection",
        start = { x = -500.5, y = 1200.5, z = 25.0 },
        dropoffs = {
            { name = "Paleto Bay", x = -100.5, y = -230.5, z = 12.5, pay = 8000 },
            { name = "Blueberry", x = 250.5, y = 60.5, z = 12.5, pay = 7000 },
        },
    },
    {
        id = 3,
        name = "International Smuggle",
        start = { x = 2400.5, y = -2200.5, z = 13.5 },
        dropoffs = {
            { name = "Airport Drop", x = 1682.5, y = -2267.0, z = 13.5, pay = 15000 },
            { name = "Dock Drop", x = 2400.5, y = -2400.5, z = 13.5, pay = 12000 },
        },
    },
}

Mzansi.Drugs.Config.Processing = {
    {
        id = 1,
        name = "Weed Processing",
        input = { drug = "weed", amount = 3 },
        output = { drug = "weed_package", amount = 1 },
        time = 60000,
        location = { x = 1200.5, y = -2000.5, z = 13.5 },
    },
    {
        id = 2,
        name = "Meth Lab",
        input = { drug = "meth", amount = 2 },
        output = { drug = "meth_package", amount = 1 },
        time = 90000,
        location = { x = 500.5, y = 1500.5, z = 20.0 },
    },
    {
        id = 3,
        name = "Cocaine Press",
        input = { drug = "cocaine", amount = 2 },
        output = { drug = "cocaine_package", amount = 1 },
        time = 75000,
        location = { x = -500.5, y = 1200.5, z = 25.0 },
    },
}

Mzansi.Drugs.Config.Effects = {
    weed = {
        name = "Dagga High",
        screenBlur = 5,
        healthRegen = 2,
        speedMod = 0.9,
        duration = 30000,
        message = "You feel relaxed...",
    },
    cocaine = {
        name = "Tik Rush",
        screenBlur = 0,
        healthRegen = -1,
        speedMod = 1.4,
        duration = 20000,
        message = "You feel energized!",
    },
    heroin = {
        name = "Nyaope Nod",
        screenBlur = 10,
        healthRegen = -3,
        speedMod = 0.6,
        duration = 45000,
        message = "You feel drowsy...",
    },
    ecstasy = {
        name = "Buttons Buzz",
        screenBlur = 3,
        healthRegen = 1,
        speedMod = 1.2,
        duration = 25000,
        message = "You feel euphoric!",
    },
    meth = {
        name = "Whoonga Rush",
        screenBlur = 0,
        healthRegen = -5,
        speedMod = 1.6,
        duration = 15000,
        message = "You feel invincible!",
    },
}
