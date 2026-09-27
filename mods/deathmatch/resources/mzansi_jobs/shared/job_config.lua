Mzansi = Mzansi or {}
Mzansi.Jobs = Mzansi.Jobs or {}
Mzansi.Jobs.Config = {}

Mzansi.Jobs.Config.Locations = {
    [4] = {
        { name = "Trucking Depot", x = -532.5, y = -488.5, z = 25.5 },
        { name = "Cargo Terminal", x = -535.0, y = -500.0, z = 25.5 },
    },
    [5] = {
        { name = "Fishing Dock", x = 2345.5, y = -2210.5, z = 13.5 },
    },
    [6] = {
        { name = "Farm Hub", x = -366.5, y = 1188.5, z = 20.0 },
    },
    [7] = {
        { name = "Taxi Station", x = 1778.5, y = -1865.0, z = 13.5 },
    },
    [8] = {
        { name = "Bus Terminal", x = 1780.0, y = -1880.0, z = 13.5 },
    },
    [9] = {
        { name = "Mine Entrance", x = -580.0, y = 1860.0, z = 70.0 },
    },
    [11] = {
        { name = "Post Office", x = 580.0, y = -1250.0, z = 18.0 },
    },
    [3] = {
        { name = "LS Customs", x = 1041.5, y = -1026.5, z = 32.0 },
    },
    [13] = {
        { name = "Mzansi Digital HQ", x = 1481.5, y = -1745.5, z = 13.5 },
    },
    [14] = {
        { name = "Mzansi Automation Plant", x = 1505.8, y = -1664.2, z = 13.4 },
    },
}

Mzansi.Jobs.Config.PaydayInterval = 3600000

Mzansi.Jobs.Config.TruckerRoutes = {
    { name = "Airport Delivery", startX = -532.5, startY = -488.5, startZ = 25.5, endX = 1682.5, endY = -2267.0, endZ = 13.5, pay = 3500 },
    { name = "Downtown Delivery", startX = -532.5, startY = -488.5, startZ = 25.5, endX = 1500.0, endY = -1600.0, endZ = 14.0, pay = 2500 },
    { name = "Beach Delivery", startX = -532.5, startY = -488.5, startZ = 25.5, endX = 475.0, endY = -1850.0, endZ = 5.0, pay = 3000 },
}

Mzansi.Jobs.Config.FishTypes = {
    { name = "Sardine", minWeight = 0.5, maxWeight = 2.0, price = 50, chance = 0.4 },
    { name = "Mackerel", minWeight = 1.0, maxWeight = 4.0, price = 100, chance = 0.3 },
    { name = "Tuna", minWeight = 5.0, maxWeight = 20.0, price = 300, chance = 0.15 },
    { name = "Snoek", minWeight = 3.0, maxWeight = 15.0, price = 200, chance = 0.1 },
    { name = "Yellowtail", minWeight = 8.0, maxWeight = 30.0, price = 500, chance = 0.05 },
}

-- ==============================================================
-- ACTIVITY ROUTES — full job loops (taxi, bus, farm, mine, mail, mechanic)
-- Each stop: { name, x, y, z, pay (per stop), requiresVehicle (bool) }
-- ==============================================================
Mzansi.Jobs.Config.Activities = {
    -- TAXI (7): pick up passenger → drop off
    [7] = {
        { name = "Rank Load-up",      x = 1778.5, y = -1865.0, z = 13.5, pay = 150, requiresVehicle = true },
        { name = "Pershore Pickup",   x = 1725.0, y = -1860.0, z = 13.5, pay = 250, requiresVehicle = true },
        { name = "Market Drop-off",   x = 1790.5, y = -1765.5, z = 13.5, pay = 350, requiresVehicle = true },
        { name = "Commerce Drop",     x = 1720.0, y = -1660.0, z = 13.5, pay = 300, requiresVehicle = true },
        { name = "Ganton Fare",       x = 2220.0, y = -1660.0, z = 13.5, pay = 450, requiresVehicle = true },
        { name = "Return to Rank",    x = 1778.5, y = -1865.0, z = 13.5, pay = 200, requiresVehicle = true },
    },
    -- BUS DRIVER (8): fixed public route
    [8] = {
        { name = "Terminal Board",    x = 1780.0, y = -1880.0, z = 13.5, pay = 200, requiresVehicle = true },
        { name = "Idlewood Stop",     x = 1940.0, y = -1740.0, z = 13.5, pay = 400, requiresVehicle = true },
        { name = "Ganton Stop",       x = 2220.0, y = -1690.0, z = 13.5, pay = 400, requiresVehicle = true },
        { name = "East Beach Stop",   x = 2440.0, y = -1640.0, z = 13.5, pay = 450, requiresVehicle = true },
        { name = "Willowfield Stop",  x = 2380.0, y = -1715.0, z = 13.5, pay = 400, requiresVehicle = true },
        { name = "Back to Terminal",  x = 1780.0, y = -1880.0, z = 13.5, pay = 350, requiresVehicle = true },
    },
    -- FARMER (6): harvest plots around farm hub
    [6] = {
        { name = "Irrigate Crops",    x = -366.5, y = 1188.5, z = 20.0, pay = 400, requiresVehicle = false },
        { name = "Harvest Wheat",     x = -380.0, y = 1210.0, z = 20.0, pay = 500, requiresVehicle = false },
        { name = "Feed Livestock",    x = -350.0, y = 1205.0, z = 20.0, pay = 450, requiresVehicle = false },
        { name = "Load Produce",      x = -340.0, y = 1175.0, z = 20.0, pay = 550, requiresVehicle = false },
        { name = "Sell at Market",    x = -366.5, y = 1160.0, z = 20.0, pay = 700, requiresVehicle = false },
    },
    -- MINER (9): extract ore nodes
    [9] = {
        { name = "Enter Mine",        x = -580.0, y = 1860.0, z = 70.0, pay = 250, requiresVehicle = false },
        { name = "Iron Vein",         x = -595.0, y = 1875.0, z = 68.0, pay = 600, requiresVehicle = false },
        { name = "Gold Vein",         x = -610.0, y = 1855.0, z = 66.0, pay = 900, requiresVehicle = false },
        { name = "Diamond Seam",      x = -625.0, y = 1880.0, z = 64.0, pay = 1400, requiresVehicle = false },
        { name = "Sell Ore at Surface", x = -580.0, y = 1860.0, z = 70.0, pay = 800, requiresVehicle = false },
    },
    -- DELIVERY / MAILMAN (11)
    [11] = {
        { name = "Collect Parcels",   x = 580.0,  y = -1250.0, z = 18.0, pay = 200, requiresVehicle = false },
        { name = "Vinewood Drop",     x = 610.0,  y = -1272.5, z = 19.5, pay = 400, requiresVehicle = false },
        { name = "Rodeo Drop",        x = 465.5,  y = -1550.5, z = 33.0, pay = 450, requiresVehicle = false },
        { name = "Market Drop",       x = 1790.5, y = -1765.5, z = 13.5, pay = 500, requiresVehicle = false },
        { name = "Ganton Drop",       x = 2244.5, y = -1665.5, z = 15.5, pay = 550, requiresVehicle = false },
        { name = "Return to Post",    x = 580.0,  y = -1250.0, z = 18.0, pay = 350, requiresVehicle = false },
    },
    -- MECHANIC (3): service callouts
    [3] = {
        { name = "Shop Intake",       x = 1041.5, y = -1026.5, z = 32.0, pay = 250, requiresVehicle = false },
        { name = "Roadside Call — Idlewood", x = 1950.0, y = -1450.0, z = 13.5, pay = 700, requiresVehicle = false },
        { name = "Roadside Call — Ganton",   x = 2244.5, y = -1665.5, z = 15.5, pay = 750, requiresVehicle = false },
        { name = "Downtown Call",     x = 1481.5, y = -1745.5, z = 13.5, pay = 800, requiresVehicle = false },
        { name = "Finish Job",        x = 1041.5, y = -1026.5, z = 32.0, pay = 500, requiresVehicle = false },
    },
    -- COMPUTER ENGINEER (13): ticket station → debug studio → deploy desk
    [13] = {
        { name = "Mzansi Digital Desk", x = 1481.5, y = -1745.5, z = 13.5, pay = 400, requiresVehicle = false },
        { name = "Debug Studio",        x = 1470.0, y = -1760.0, z = 13.5, pay = 750, requiresVehicle = false },
        { name = "Code Review Bay",     x = 1455.0, y = -1740.0, z = 13.5, pay = 850, requiresVehicle = false },
        { name = "Client Handoff",      x = 1481.5, y = -1745.5, z = 13.5, pay = 600, requiresVehicle = false },
        { name = "Ticket Closed",       x = 1481.5, y = -1745.5, z = 13.5, pay = 400, requiresVehicle = false },
    },
    -- MECHATRONICS TECH (14): workshop → machine floor → calibration
    [14] = {
        { name = "Automation Workbench", x = 1505.8, y = -1664.2, z = 13.4, pay = 350, requiresVehicle = false },
        { name = "Conveyor Logic Panel", x = 1520.0, y = -1655.0, z = 13.4, pay = 700, requiresVehicle = false },
        { name = "PLC Rack Station",     x = 1535.0, y = -1670.0, z = 13.4, pay = 850, requiresVehicle = false },
        { name = "Robot Arm Cell",       x = 1510.0, y = -1685.0, z = 13.4, pay = 950, requiresVehicle = false },
        { name = "Calibration Sign-off", x = 1505.8, y = -1664.2, z = 13.4, pay = 550, requiresVehicle = false },
    },
}

Mzansi.Jobs.Config.ActivityReach = 12.0
