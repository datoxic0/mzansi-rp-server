Mzansi = Mzansi or {}
Mzansi.Market = Mzansi.Market or {}

Mzansi.Market.VehicleKinds = {
    car = "Car",
    boat = "Boat",
    plane = "Aircraft",
}

Mzansi.Market.Vehicles = {
    car = {
        { model = 401, name = "Bravura", price = 8500, class = "Economy" },
        { model = 410, name = "Manana", price = 7500, class = "Economy" },
        { model = 436, name = "Previon", price = 9000, class = "Economy" },
        { model = 439, name = "Stallion", price = 12000, class = "Economy" },
        { model = 458, name = "Solair", price = 14000, class = "Sedan" },
        { model = 466, name = "Glendale", price = 15000, class = "Sedan" },
        { model = 492, name = "Greenwood", price = 18000, class = "Sedan" },
        { model = 507, name = "Elegant", price = 22000, class = "Sedan" },
        { model = 516, name = "Nebula", price = 16000, class = "Sedan" },
        { model = 529, name = "Willard", price = 17000, class = "Sedan" },
        { model = 400, name = "Landstalker", price = 35000, class = "SUV" },
        { model = 479, name = "Regina", price = 20000, class = "Wagon" },
        { model = 491, name = "Virgo", price = 21000, class = "Muscle" },
        { model = 545, name = "Hustler", price = 26000, class = "Classic" },
        { model = 554, name = "Yosemite", price = 24000, class = "Pickup" },
        { model = 579, name = "Huntley", price = 55000, class = "Luxury SUV" },
        { model = 402, name = "Buffalo", price = 48000, class = "Sport" },
        { model = 475, name = "Sabre", price = 32000, class = "Muscle" },
        { model = 533, name = "Feltzer", price = 62000, class = "Sport" },
        { model = 555, name = "Windsor", price = 45000, class = "Coupe" },
        { model = 560, name = "Sultan", price = 70000, class = "Sport" },
        { model = 562, name = "Elegy", price = 75000, class = "Sport" },
        { model = 587, name = "Euros", price = 68000, class = "Sport" },
        { model = 603, name = "Phoenix", price = 58000, class = "Muscle" },
        { model = 411, name = "Infernus", price = 250000, class = "Super" },
        { model = 415, name = "Cheetah", price = 240000, class = "Super" },
        { model = 429, name = "Banshee", price = 180000, class = "Super" },
        { model = 451, name = "Turismo", price = 260000, class = "Super" },
        { model = 541, name = "Bullet", price = 275000, class = "Super" },
        { model = 565, name = "Flash", price = 52000, class = "Sport" },
    },
    boat = {
        { model = 473, name = "Dinghy", price = 18000, class = "Utility" },
        { model = 493, name = "Jetmax", price = 95000, class = "Speedboat" },
        { model = 452, name = "Speeder", price = 72000, class = "Speedboat" },
        { model = 446, name = "Squalo", price = 88000, class = "Speedboat" },
        { model = 454, name = "Tropic", price = 140000, class = "Yacht" },
        { model = 484, name = "Marquis", price = 160000, class = "Yacht" },
        { model = 430, name = "Predator", price = 65000, class = "Patrol" },
        { model = 472, name = "Coastguard", price = 110000, class = "Patrol" },
        { model = 453, name = "Reefer", price = 55000, class = "Fishing" },
        { model = 595, name = "Launch", price = 22000, class = "Utility" },
    },
    plane = {
        { model = 593, name = "Dodo", price = 180000, class = "Light" },
        { model = 511, name = "Beagle", price = 320000, class = "Private" },
        { model = 513, name = "Stuntplane", price = 210000, class = "Sport" },
        { model = 476, name = "Rustler", price = 275000, class = "Warbird" },
        { model = 460, name = "Skimmer", price = 195000, class = "Seaplane" },
        { model = 519, name = "Shamal", price = 650000, class = "Business Jet" },
        { model = 553, name = "Nevada", price = 480000, class = "Cargo" },
        { model = 577, name = "AT-400", price = 950000, class = "Airliner" },
        { model = 592, name = "Andromada", price = 900000, class = "Cargo" },
        { model = 512, name = "Cropduster", price = 140000, class = "Agri" },
    },
}

Mzansi.Market.Investments = {
    {
        key = "fixed_deposit",
        name = "Fixed Deposit",
        desc = "Locked bank savings. Stable, low yield.",
        min = 10000,
        max = 5000000,
        rate = 0.004,
        cycleMs = 300000,
        risk = "Low",
    },
    {
        key = "property_fund",
        name = "Property Fund",
        desc = "Pooled commercial property portfolio.",
        min = 50000,
        max = 10000000,
        rate = 0.008,
        cycleMs = 600000,
        risk = "Medium",
    },
    {
        key = "jse_equity",
        name = "JSE Equity Index",
        desc = "Johannesburg Stock Exchange broad index.",
        min = 25000,
        max = 10000000,
        rate = 0.012,
        cycleMs = 900000,
        risk = "High",
    },
    {
        key = "mining_bond",
        name = "Mining Bond",
        desc = "Gauteng deep-level mining corporate bonds.",
        min = 75000,
        max = 8000000,
        rate = 0.010,
        cycleMs = 720000,
        risk = "Medium-High",
    },
}

Mzansi.Market.Lots = {
    car = {
        x = 2131.5, y = -1145.0, z = 24.0,
        name = "Mzansi Auto Dealership",
        spawn = {
            { x = 2138.0, y = -1142.0, z = 24.0, rot = 90 },
            { x = 2138.0, y = -1148.0, z = 24.0, rot = 90 },
            { x = 2138.0, y = -1154.0, z = 24.0, rot = 90 },
            { x = 2144.0, y = -1142.0, z = 24.0, rot = 90 },
            { x = 2144.0, y = -1148.0, z = 24.0, rot = 90 },
        },
    },
    boat = {
        x = 2770.0, y = -2450.0, z = 13.5,
        name = "Cape Town Marina",
        spawn = {
            { x = 2754.0, y = -2485.0, z = 1.0, rot = 180 },
            { x = 2760.0, y = -2485.0, z = 1.0, rot = 180 },
            { x = 2766.0, y = -2485.0, z = 1.0, rot = 180 },
            { x = 2772.0, y = -2485.0, z = 1.0, rot = 180 },
        },
    },
    plane = {
        x = 1682.5, y = -2267.0, z = 13.5,
        name = "CTIA Aircraft Sales",
        spawn = {
            { x = 1670.0, y = -2245.0, z = 14.0, rot = 0 },
            { x = 1690.0, y = -2245.0, z = 14.0, rot = 0 },
            { x = 1710.0, y = -2245.0, z = 14.0, rot = 0 },
            { x = 1670.0, y = -2285.0, z = 14.0, rot = 180 },
        },
    },
}

function Mzansi.Market.findVehicle(kind, model)
    local list = Mzansi.Market.Vehicles[kind]
    if not list then return nil end
    for _, entry in ipairs(list) do
        if entry.model == model then
            return entry
        end
    end
    return nil
end

function Mzansi.Market.findInvestment(key)
    for _, entry in ipairs(Mzansi.Market.Investments) do
        if entry.key == key then
            return entry
        end
    end
    return nil
end
