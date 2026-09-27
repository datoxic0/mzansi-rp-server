Mzansi = Mzansi or {}
Mzansi.Shops = Mzansi.Shops or {}

-- ==============================================================
-- AMMUNATION STORES — Across all 8 SA provinces
-- ==============================================================
Mzansi.Shops.Ammunation = {
    { id = "ammo_ls_1",   name = "Ammu-Nation — Los Santos Central",  province = "Los Santos",   x = 1368.5,  y = -1279.5, z = 13.5 },
    { id = "ammo_ls_2",   name = "Ammu-Nation — Idlewood",            province = "Los Santos",   x = 1950.0,  y = -1450.0, z = 13.5 },
    { id = "ammo_ls_3",   name = "Ammu-Nation — Ganton",              province = "Los Santos",   x = 2244.5,  y = -1665.5, z = 15.5 },
    { id = "ammo_sf_1",   name = "Ammu-Nation — San Fierro",          province = "San Fierro",   x = -1675.5, y = 413.5,   z = 7.2  },
    { id = "ammo_sf_2",   name = "Ammu-Nation — Doherty",             province = "San Fierro",   x = -1448.5, y = -276.5,  z = 14.2 },
    { id = "ammo_lv_1",   name = "Ammu-Nation — Las Venturas",        province = "Las Venturas", x = 2131.5,  y = 943.5,   z = 10.8 },
    { id = "ammo_lv_2",   name = "Ammu-Nation — Redsands",            province = "Las Venturas", x = 1975.5,  y = 2162.5,  z = 11.7 },
    { id = "ammo_rc_1",   name = "Ammu-Nation — Montgomery",          province = "Red County",   x = 1450.5,  y = 2775.5,  z = 11.0 },
    { id = "ammo_tr_1",   name = "Ammu-Nation — Tierra Robada",       province = "Tierra Robada",x = -2225.5, y = 2325.5,  z = 7.5  },
    { id = "ammo_bc_1",   name = "Ammu-Nation — Bone County",         province = "Bone County",  x = 610.5,   y = 1760.5,  z = 12.5 },
    { id = "ammo_fc_1",   name = "Ammu-Nation — Flint County",        province = "Flint County", x = -216.5,  y = 965.5,   z = 19.5 },
    { id = "ammo_ws_1",   name = "Ammu-Nation — Whetstone",           province = "Whetstone",    x = -2160.5, y = -235.5,  z = 36.5 },
}

-- ==============================================================
-- CLOTHING SHOPS — Across all 8 SA provinces
-- ==============================================================
Mzansi.Shops.Clothing = {
    { id = "cloth_ls_1",  name = "Binco — LS Mall",           province = "Los Santos",   x = 2244.5,  y = -1665.5, z = 15.5 },
    { id = "cloth_ls_2",  name = "Pro-Laps — Market",         province = "Los Santos",   x = 1790.5,  y = -1765.5, z = 13.5 },
    { id = "cloth_ls_3",  name = "Didier Sachs — Rodeo",      province = "Los Santos",   x = 465.5,   y = -1550.5, z = 33.0 },
    { id = "cloth_ls_4",  name = "Suburban — Idlewood",       province = "Los Santos",   x = 1950.0,  y = -1450.0, z = 13.5 },
    { id = "cloth_sf_1",  name = "Binco — San Fierro",        province = "San Fierro",   x = -1675.5, y = 413.5,   z = 7.2  },
    { id = "cloth_sf_2",  name = "Pro-Laps — Doherty",        province = "San Fierro",   x = -1448.5, y = -276.5,  z = 14.2 },
    { id = "cloth_lv_1",  name = "Binco — Las Venturas",      province = "Las Venturas", x = 2131.5,  y = 943.5,   z = 10.8 },
    { id = "cloth_lv_2",  name = "Didier Sachs — Strip",      province = "Las Venturas", x = 2065.5,  y = 2225.5,  z = 11.0 },
    { id = "cloth_rc_1",  name = "Binco — Montgomery",        province = "Red County",   x = 1450.5,  y = 2775.5,  z = 11.0 },
    { id = "cloth_tr_1",  name = "Suburban — Tierra Robada",  province = "Tierra Robada",x = -2225.5, y = 2325.5,  z = 7.5  },
    { id = "cloth_bc_1",  name = "Binco — Bone County",       province = "Bone County",  x = 610.5,   y = 1760.5,  z = 12.5 },
    { id = "cloth_fc_1",  name = "Pro-Laps — Flint County",   province = "Flint County", x = -216.5,  y = 965.5,   z = 19.5 },
    { id = "cloth_ws_1",  name = "Binco — Whetstone",         province = "Whetstone",    x = -2160.5, y = -235.5,  z = 36.5 },
}

-- ==============================================================
-- CLOTHING CATALOG — Skins + outfit colors
-- ==============================================================
Mzansi.Shops.ClothingCatalog = {
    -- Male skins (GTA SA ped model IDs)
    male = {
        { id = 0,   name = "Default Male",        price = 0 },
        { id = 1,   name = "Civilian Male",       price = 500 },
        { id = 2,   name = "Worker Male",         price = 750 },
        { id = 7,   name = "Business Male",       price = 1500 },
        { id = 14,  name = "Beach Male",          price = 600 },
        { id = 15,  name = "Mechanic",            price = 1200 },
        { id = 20,  name = "Farmer",              price = 900 },
        { id = 21,  name = "Security Guard",      price = 1800 },
        { id = 22,  name = "Construction",        price = 1000 },
        { id = 26,  name = "Executive",           price = 2500 },
        { id = 47,  name = "DJ",                  price = 1400 },
        { id = 58,  name = "Gang Member",         price = 800 },
        { id = 59,  name = "Street Male",         price = 650 },
        { id = 60,  name = "Pilot",               price = 3000 },
        { id = 72,  name = "Sniper",              price = 2200 },
        { id = 98,  name = "Chef",                price = 1300 },
        { id = 101, name = "Firefighter",         price = 1600 },
        { id = 102, name = "Police Cadet",        price = 2000 },
        { id = 105, name = "SAPS Officer",        price = 2800 },
        { id = 106, name = "SAPS Detective",      price = 3200 },
        { id = 112, name = "EMS Paramedic",       price = 2400 },
        { id = 115, name = "EMS Doctor",          price = 3500 },
        { id = 220, name = "Biker",               price = 1100 },
        { id = 250, name = "Military",            price = 4000 },
        { id = 292, name = "SWAT",                price = 4500 },
        { id = 293, name = "TRIAD",               price = 1500 },
        { id = 294, name = "Yakuza",              price = 1700 },
        { id = 297, name = "Triad Boss",          price = 2600 },
        { id = 299, name = "SAPS Sergeant",       price = 3800 },
    },
    -- Female skins
    female = {
        { id = 9,   name = "Default Female",      price = 0 },
        { id = 10,  name = "Civilian Female",     price = 500 },
        { id = 11,  name = "Office Female",       price = 1200 },
        { id = 12,  name = "Shopkeeper",          price = 1000 },
        { id = 13,  name = "Beach Female",        price = 600 },
        { id = 40,  name = "Executive Female",    price = 2500 },
        { id = 41,  name = "Sex Worker",          price = 800 },
        { id = 53,  name = "Prostitute",          price = 700 },
        { id = 54,  name = "Business Female",     price = 1800 },
        { id = 55,  name = "Female Staff",        price = 1100 },
        { id = 56,  name = "Waitress",            price = 900 },
        { id = 76,  name = "Farmer Female",       price = 950 },
        { id = 93,  name = "Medic Female",        price = 2400 },
        { id = 103, name = "Police Female",       price = 2800 },
        { id = 104, name = "SAPS Female",         price = 3000 },
        { id = 110, name = "Businesswoman",       price = 2200 },
        { id = 111, name = "Tourist",             price = 750 },
        { id = 148, name = "Gang Female",         price = 850 },
        { id = 157, name = "Skinny Female",       price = 650 },
        { id = 192, name = "Office Worker",       price = 1300 },
        { id = 195, name = "Old Female",          price = 550 },
        { id = 196, name = "Pro-Laps Model",      price = 1600 },
        { id = 233, name = "Business Suit",       price = 3500 },
        { id = 276, name = "EMS Female",          price = 2600 },
        { id = 298, name = "Police Sergeant F",   price = 3800 },
    },
}

-- ==============================================================
-- WEAPON AMMO PRICES (per magazine)
-- ==============================================================
Mzansi.Shops.AmmoPrices = {
    [22] = 50,   -- 9mm
    [23] = 75,   -- Silenced 9mm
    [24] = 100,  -- Desert Eagle
    [25] = 80,   -- Shotgun
    [26] = 90,   -- Sawn-off
    [27] = 100,  -- Combat Shotgun
    [28] = 60,   -- Micro SMG
    [29] = 70,   -- MP5
    [30] = 120,  -- AK-47
    [31] = 140,  -- M4
    [32] = 60,   -- Tec-9
    [33] = 100,  -- Country Rifle
    [34] = 200,  -- Sniper Rifle
    [35] = 500,  -- Rocket Launcher
    [36] = 300,  -- Heat Rocket
    [37] = 250,  -- Flamethrower
    [38] = 400,  -- Minigun
    [39] = 600,  -- Satchel Charge
    [40] = 150,  -- Detonator
    [41] = 30,   -- Spraycan
    [42] = 40,   -- Fire Extinguisher
    [43] = 60,   -- Camera
    [46] = 100,  -- Parachute
}

function Mzansi.Shops.getAmmunationById(id)
    for _, loc in ipairs(Mzansi.Shops.Ammunation) do
        if loc.id == id then return loc end
    end
    return nil
end

function Mzansi.Shops.getClothingById(id)
    for _, loc in ipairs(Mzansi.Shops.Clothing) do
        if loc.id == id then return loc end
    end
    return nil
end
