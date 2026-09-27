Mzansi = Mzansi or {}
Mzansi.Crime = Mzansi.Crime or {}
Mzansi.Crime.Config = {}

Mzansi.Crime.Config.RobberyCooldown = 600000
Mzansi.Crime.Config.HeistCooldown = 3600000
Mzansi.Crime.Config.WantedDecayTime = 300000

Mzansi.Crime.Config.Robberies = {
    {
        id = 1,
        name = "24/7 Robbery",
        description = "Rob a convenience store for quick cash.",
        x = 1585.5, y = -1678.5, z = 13.5,
        radius = 10,
        minPlayers = 1,
        reward = { min = 2000, max = 8000 },
        wantedLevel = 2,
        requiredItems = { "mask" },
        duration = 30000,
        npcs = {
            { model = 17, x = 1587.5, y = -1676.5, z = 13.5, rot = 180 },
        },
    },
    {
        id = 2,
        name = "Bank ATM Robbery",
        description = "Break into an ATM for cash.",
        x = 1390.5, y = -1580.5, z = 13.5,
        radius = 5,
        minPlayers = 1,
        reward = { min = 1000, max = 5000 },
        wantedLevel = 1,
        requiredItems = { "lockpick" },
        duration = 20000,
        npcs = {},
    },
    {
        id = 3,
        name = "Gas Station Robbery",
        description = "Rob a gas station.",
        x = 1944.5, y = -1772.5, z = 13.5,
        radius = 10,
        minPlayers = 1,
        reward = { min = 3000, max = 10000 },
        wantedLevel = 2,
        requiredItems = { "mask" },
        duration = 35000,
        npcs = {
            { model = 17, x = 1946.5, y = -1770.5, z = 13.5, rot = 180 },
        },
    },
    {
        id = 4,
        name = "Jewelry Store",
        description = "Rob the jewelry store for valuable gems.",
        x = 1025.5, y = -1023.5, z = 32.0,
        radius = 15,
        minPlayers = 2,
        reward = { min = 15000, max = 40000 },
        wantedLevel = 3,
        requiredItems = { "mask", "weapon_25" },
        duration = 60000,
        npcs = {
            { model = 17, x = 1027.5, y = -1021.5, z = 32.0, rot = 180 },
            { model = 17, x = 1023.5, y = -1025.5, z = 32.0, rot = 0 },
        },
    },
    {
        id = 5,
        name = "Paleto Bay Bank",
        description = "Rob the Paleto Bay bank vault.",
        x = -100.5, y = -230.5, z = 12.5,
        radius = 20,
        minPlayers = 3,
        reward = { min = 50000, max = 150000 },
        wantedLevel = 4,
        requiredItems = { "mask", "weapon_30", "drill" },
        duration = 120000,
        npcs = {
            { model = 280, x = -98.5, y = -228.5, z = 12.5, rot = 180 },
            { model = 280, x = -102.5, y = -232.5, z = 12.5, rot = 0 },
        },
    },
    {
        id = 6,
        name = "LS Bank Vault",
        description = "The big one. Rob the Los Santos bank.",
        x = 1470.5, y = -1010.5, z = 27.5,
        radius = 25,
        minPlayers = 4,
        reward = { min = 200000, max = 500000 },
        wantedLevel = 4,
        requiredItems = { "mask", "weapon_31", "drill", "c4" },
        duration = 180000,
        npcs = {
            { model = 280, x = 1472.5, y = -1008.5, z = 27.5, rot = 180 },
            { model = 280, x = 1468.5, y = -1012.5, z = 27.5, rot = 0 },
            { model = 281, x = 1474.5, y = -1012.5, z = 27.5, rot = 90 },
        },
    },
}

Mzansi.Crime.Config.Heists = {
    {
        id = 1,
        name = "Humane Labs Raid",
        description = "Steal experimental weapons from Humane Labs.",
        requiredItems = { "hacking_device", "weapon_31" },
        minPlayers = 4,
        reward = { min = 300000, max = 600000 },
        wantedLevel = 4,
        phases = {
            { name = "Infiltrate", duration = 60000, objective = "Kill all guards" },
            { name = "Hack Security", duration = 90000, objective = "Complete hacking minigame" },
            { name = "Steal Weapons", duration = 120000, objective = "Collect weapons from vault" },
            { name = "Escape", duration = 60000, objective = "Escape to drop point" },
        },
    },
    {
        id = 2,
        name = "Casino Heist",
        description = "Rob the Caligula's Palace casino.",
        requiredItems = { "hacking_device", "thermal_charge", "weapon_25" },
        minPlayers = 3,
        reward = { min = 250000, max = 500000 },
        wantedLevel = 4,
        phases = {
            { name = "Scout", duration = 60000, objective = "Find entry points" },
            { name = "Disguise", duration = 30000, objective = "Put on disguises" },
            { name = "Vault", duration = 120000, objective = "Open vault and collect cash" },
            { name = "Escape", duration = 90000, objective = "Escape to drop point" },
        },
    },
    {
        id = 3,
        name = "Prison Break",
        description = "Break a prisoner out of Bolingbroke Penitentiary.",
        requiredItems = { "prison_keycard", "weapon_22" },
        minPlayers = 3,
        reward = { min = 150000, max = 300000 },
        wantedLevel = 4,
        phases = {
            { name = "Distract Guards", duration = 60000, objective = "Create a distraction" },
            { name = "Disable Cameras", duration = 45000, objective = "Hack camera system" },
            { name = "Free Prisoner", duration = 60000, objective = "Reach and free the prisoner" },
            { name = "Escape", duration = 120000, objective = "Escape the prison" },
        },
    },
}

Mzansi.Crime.Config.IllegalJobs = {
    {
        id = 1,
        name = "Car Theft",
        description = "Steal vehicles and deliver to chop shop.",
        x = 2477.5, y = -1950.5, z = 13.5,
        reward = { min = 5000, max = 15000 },
        wantedLevel = 1,
        vehicleModels = { 402, 411, 451, 522, 560 },
    },
    {
        id = 2,
        name = "Drug Run",
        description = "Deliver drugs across the city.",
        x = 1200.5, y = -2000.5, z = 13.5,
        reward = { min = 8000, max = 25000 },
        wantedLevel = 2,
        requiredItems = { "weed_package", "cocaine_package" },
    },
    {
        id = 3,
        name = "Smuggling",
        description = "Smuggle contraband through the docks.",
        x = 2400.5, y = -2200.5, z = 13.5,
        reward = { min = 10000, max = 35000 },
        wantedLevel = 2,
        requiredItems = { "smuggle_package" },
    },
    {
        id = 4,
        name = "Illegal Street Race",
        description = "Win underground street races for cash.",
        x = 1700.5, y = -1800.5, z = 13.5,
        reward = { min = 10000, max = 50000 },
        wantedLevel = 1,
        requiredItems = {},
    },
    {
        id = 5,
        name = "Kidnapping",
        description = "Kidnap a target and collect ransom.",
        x = 1500.5, y = -1200.5, z = 13.5,
        reward = { min = 50000, max = 100000 },
        wantedLevel = 3,
        requiredItems = { "rope" },
    },
}

Mzansi.Crime.Config.BlackMarket = {
    {
        id = 1,
        name = "Weapon Dealer",
        location = { x = 2320.5, y = -2150.5, z = 13.5 },
        items = {
            { name = "Silenced Pistol", price = 15000, weaponId = 23 },
            { name = "Shotgun", price = 25000, weaponId = 25 },
            { name = "AK-47", price = 50000, weaponId = 30 },
            { name = "Sniper Rifle", price = 75000, weaponId = 34 },
        },
    },
    {
        id = 2,
        name = "Counterfeit Documents",
        location = { x = 1100.5, y = -1500.5, z = 13.5 },
        items = {
            { name = "Fake ID", price = 5000 },
            { name = "Fake License", price = 8000 },
            { name = "Fake Passport", price = 15000 },
        },
    },
    {
        id = 3,
        name = "Stolen Electronics",
        location = { x = 1800.5, y = -1900.5, z = 13.5 },
        items = {
            { name = "Stolen Phone", price = 2000 },
            { name = "Stolen Laptop", price = 5000 },
            { name = "Stolen TV", price = 8000 },
        },
    },
}
