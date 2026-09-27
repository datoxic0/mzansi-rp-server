Mzansi = Mzansi or {}
Mzansi.Housing = Mzansi.Housing or {}
Mzansi.Housing.Config = {}

Mzansi.Housing.Config.Properties = {
    -- ==========================================================
    -- LOS SANTOS & SURROUNDING PROPERTIES (IDs 1-11)
    -- ==========================================================
    {
        id = 1, name = "Ganton House", type = 0,
        x = 2244.5, y = -1665.5, z = 15.5, price = 50000, rentPrice = 2000,
        interior = 2, interiorX = 223.7, interiorY = 1287.1, interiorZ = 1082.1, dimension = 1,
        garageX = 2248.5, garageY = -1660.0, garageZ = 15.5, garageRot = 0
    },
    {
        id = 2, name = "Idlewood House", type = 0,
        x = 1932.5, y = -1765.5, z = 13.5, price = 45000, rentPrice = 1800,
        interior = 2, interiorX = 223.7, interiorY = 1287.1, interiorZ = 1082.1, dimension = 2,
        garageX = 1938.0, garageY = -1765.0, garageZ = 13.5, garageRot = 90
    },
    {
        id = 3, name = "Vinewood Apartment", type = 0,
        x = 1025.5, y = -1023.5, z = 32.0, price = 120000, rentPrice = 5000,
        interior = 3, interiorX = 235.3, interiorY = 1186.7, interiorZ = 1080.2, dimension = 3,
        garageX = 1020.0, garageY = -1015.0, garageZ = 32.0, garageRot = 180
    },
    {
        id = 4, name = "Rodeo House", type = 0,
        x = 345.5, y = -1190.5, z = 76.5, price = 200000, rentPrice = 8000,
        interior = 7, interiorX = 225.8, interiorY = 1021.4, interiorZ = 1084.0, dimension = 4,
        garageX = 340.0, garageY = -1180.0, garageZ = 76.5, garageRot = 180
    },
    {
        id = 5, name = "Mulholland Mansion", type = 0,
        x = 135.5, y = -1455.5, z = 45.5, price = 500000, rentPrice = 20000,
        interior = 5, interiorX = 1265.8, interiorY = -778.0, interiorZ = 1091.9, dimension = 5,
        garageX = 145.0, garageY = -1450.0, garageZ = 45.5, garageRot = 270
    },
    {
        id = 6, name = "Palomino House", type = 0,
        x = 2230.5, y = 1285.5, z = 45.5, price = 35000, rentPrice = 1500,
        interior = 2, interiorX = 223.7, interiorY = 1287.1, interiorZ = 1082.1, dimension = 6,
        garageX = 2235.0, garageY = 1290.0, garageZ = 45.5, garageRot = 0
    },
    {
        id = 7, name = "Willowfield House", type = 0,
        x = 2390.5, y = -1705.5, z = 13.5, price = 40000, rentPrice = 1600,
        interior = 2, interiorX = 223.7, interiorY = 1287.1, interiorZ = 1082.1, dimension = 7,
        garageX = 2395.0, garageY = -1700.0, garageZ = 13.5, garageRot = 90
    },
    {
        id = 8, name = "Verona Beach House", type = 0,
        x = 855.5, y = -1805.5, z = 13.5, price = 75000, rentPrice = 3000,
        interior = 3, interiorX = 235.3, interiorY = 1186.7, interiorZ = 1080.2, dimension = 8,
        garageX = 850.0, garageY = -1800.0, garageZ = 13.5, garageRot = 180
    },
    {
        id = 9, name = "Santa Maria House", type = 0,
        x = 755.5, y = -1705.5, z = 13.5, price = 65000, rentPrice = 2600,
        interior = 7, interiorX = 225.8, interiorY = 1021.4, interiorZ = 1084.0, dimension = 9,
        garageX = 750.0, garageY = -1700.0, garageZ = 13.5, garageRot = 180
    },
    {
        id = 10, name = "Downtown Business", type = 1,
        x = 1500.5, y = -1600.5, z = 14.5, price = 300000, rentPrice = 12000,
        interior = 14, interiorX = 2317.8, interiorY = -1026.8, interiorZ = 1050.2, dimension = 10,
        garageX = 1505.0, garageY = -1590.0, garageZ = 14.5, garageRot = 0
    },
    {
        id = 11, name = "LS Airport Garage", type = 2,
        x = 1682.5, y = -2290.5, z = 13.5, price = 80000, rentPrice = 3200,
        interior = 0, interiorX = 1682.5, interiorY = -2290.5, interiorZ = 13.5, dimension = 11,
        garageX = 1682.5, garageY = -2285.0, garageZ = 13.5, garageRot = 0
    },

    -- ==========================================================
    -- FREE STATE — GOVERNMENT & ADMIN SANCTUARY ESTATES (BAYSIDE)
    -- Reserved for Government & Admins (IDs 101-110)
    -- ==========================================================
    {
        id = 101, name = "Sovereign Presidential Palace (Free State #1)", type = 0, zone = "Free State",
        x = -2310.0, y = 2360.0, z = 10.5, price = 1500000, rentPrice = 50000,
        interior = 5, interiorX = 1265.8, interiorY = -778.0, interiorZ = 1091.9, dimension = 101,
        garageX = -2320.0, garageY = 2350.0, garageZ = 10.5, garageRot = 270,
        adminRank = 5 -- Head of State / Sovereign Admin
    },
    {
        id = 102, name = "High Minister Executive Manor (Free State #2)", type = 0, zone = "Free State",
        x = -2335.0, y = 2425.0, z = 16.0, price = 1200000, rentPrice = 40000,
        interior = 15, interiorX = 295.9, interiorY = 1472.3, interiorZ = 1080.2, dimension = 102,
        garageX = -2345.0, garageY = 2420.0, garageZ = 16.0, garageRot = 270,
        adminRank = 4 -- Senior Admin
    },
    {
        id = 103, name = "Hilltop Executive Admin Residence (Free State #3)", type = 0, zone = "Free State",
        x = -2295.0, y = 2415.0, z = 15.0, price = 950000, rentPrice = 30000,
        interior = 3, interiorX = 235.3, interiorY = 1186.7, interiorZ = 1080.2, dimension = 103,
        garageX = -2285.0, garageY = 2415.0, garageZ = 15.0, garageRot = 90,
        adminRank = 3 -- Admin
    },
    {
        id = 104, name = "Free State Ocean View Villa (Free State #4)", type = 0, zone = "Free State",
        x = -2240.0, y = 2420.0, z = 10.0, price = 850000, rentPrice = 25000,
        interior = 7, interiorX = 225.8, interiorY = 1021.4, interiorZ = 1084.0, dimension = 104,
        garageX = -2230.0, garageY = 2420.0, garageZ = 10.0, garageRot = 90,
        adminRank = 2 -- Junior Admin
    },
    {
        id = 105, name = "Government Quarter Estate (Free State #5)", type = 0, zone = "Free State",
        x = -2260.0, y = 2355.0, z = 8.0, price = 750000, rentPrice = 22000,
        interior = 10, interiorX = 2262.8, interiorY = -1137.7, interiorZ = 1050.6, dimension = 105,
        garageX = -2250.0, garageY = 2355.0, garageZ = 8.0, garageRot = 90,
        adminRank = 1 -- Trial Admin / Moderator
    },
    {
        id = 106, name = "Cabinet Secretary Villa (Free State #6)", type = 0, zone = "Free State",
        x = -2210.0, y = 2360.0, z = 7.5, price = 700000, rentPrice = 20000,
        interior = 12, interiorX = 2324.4, interiorY = -1145.5, interiorZ = 1050.7, dimension = 106,
        garageX = -2200.0, garageY = 2360.0, garageZ = 7.5, garageRot = 90,
        adminRank = 1
    },
    {
        id = 107, name = "Judicial High Court Compound (Free State #7)", type = 0, zone = "Free State",
        x = -2250.0, y = 2300.0, z = 7.5, price = 800000, rentPrice = 24000,
        interior = 14, interiorX = 2317.8, interiorY = -1026.8, interiorZ = 1050.2, dimension = 107,
        garageX = -2240.0, garageY = 2300.0, garageZ = 7.5, garageRot = 0,
        adminRank = 1
    },
    {
        id = 108, name = "Diplomatic Corp Residence (Free State #8)", type = 0, zone = "Free State",
        x = -2215.0, y = 2275.0, z = 7.5, price = 650000, rentPrice = 18000,
        interior = 9, interiorX = 318.6, interiorY = 1114.9, interiorZ = 1083.8, dimension = 108,
        garageX = -2205.0, garageY = 2275.0, garageZ = 7.5, garageRot = 0,
        adminRank = 1
    },
    {
        id = 109, name = "Marina Waterfront Admin Villa (Free State #9)", type = 0, zone = "Free State",
        x = -2185.0, y = 2400.0, z = 5.5, price = 750000, rentPrice = 22000,
        interior = 7, interiorX = 225.8, interiorY = 1021.4, interiorZ = 1084.0, dimension = 109,
        garageX = -2175.0, garageY = 2400.0, garageZ = 5.5, garageRot = 180,
        adminRank = 1
    },
    {
        id = 110, name = "Harbor Master Admin Estate (Free State #10)", type = 0, zone = "Free State",
        x = -2175.0, y = 2315.0, z = 6.0, price = 600000, rentPrice = 16000,
        interior = 2, interiorX = 223.7, interiorY = 1287.1, interiorZ = 1082.1, dimension = 110,
        garageX = -2165.0, garageY = 2315.0, garageZ = 6.0, garageRot = 180,
        adminRank = 1
    },
}

Mzansi.Housing.Config.DepositAmount = 5000
Mzansi.Housing.Config.MaxFurniture = 50
Mzansi.Housing.Config.RentInterval = 86400000

Mzansi.Housing.Config.Furniture = {
    { id = 1, name = "Sofa", price = 5000 },
    { id = 2, name = "Bed", price = 8000 },
    { id = 3, name = "Table", price = 3000 },
    { id = 4, name = "Chair", price = 1500 },
    { id = 5, name = "TV", price = 12000 },
    { id = 6, name = "Fridge", price = 10000 },
    { id = 7, name = "Wardrobe", price = 7000 },
    { id = 8, name = "Lamp", price = 2000 },
}
