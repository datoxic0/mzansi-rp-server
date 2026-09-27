Mzansi = Mzansi or {}
Mzansi.Activity = {}
Mzansi.Activity._npcs = {}
Mzansi.Activity._vehicles = {}
Mzansi.Activity._activeMissions = {}
Mzansi.Activity._activeRobberies = {}
Mzansi.Activity._chaseActive = false
Mzansi.Activity._trafficVehicles = {}

-- ==============================================================
-- MASSIVE NPC ROSTER — 70+ South African Characters
-- ==============================================================
local NPC_LIST = {

    -- ==============================
    -- SAPS POLICE HEADQUARTERS (Pershing Square)
    -- ==============================
    { id = "saps_desk",      model = 280, x = 1554.5, y = -1675.5, z = 16.2,  rot = 90,  name = "Desk Sergeant Ndlovu",    role = "SAPS Duty & Information",    type = "police",       anim = "Copbrowse_nod",  block = "COP_AMBIENT" },
    { id = "saps_guard1",    model = 285, x = 1568.5, y = -1685.5, z = 6.0,   rot = 0,   name = "SWAT Officer van Zyl",    role = "Armory & Tactical Guard",    type = "police_guard", anim = "Cop_look",       block = "COP_AMBIENT" },
    { id = "saps_guard2",    model = 280, x = 1542.0, y = -1685.5, z = 6.0,   rot = 180, name = "Constable Lekota",        role = "SAPS Street Patrol",         type = "police",       anim = "Cop_Lean",       block = "COP_AMBIENT" },
    { id = "saps_captain",   model = 281, x = 1558.0, y = -1668.0, z = 16.2,  rot = 270, name = "Captain Dlamini",         role = "Station Commander",          type = "police_guard", anim = "Cop_Lean",       block = "COP_AMBIENT" },
    { id = "saps_patrol1",   model = 280, x = 1530.0, y = -1692.5, z = 6.0,   rot = 270, name = "Officer Mokoena",         role = "SAPS K9 Unit",               type = "police",       anim = "Cop_Lean",       block = "COP_AMBIENT" },
    { id = "saps_patrol2",   model = 285, x = 1525.0, y = -1700.0, z = 6.0,   rot = 90,  name = "Officer Joubert",         role = "SAPS Special Tasks",         type = "police_guard", anim = "Cop_look",       block = "COP_AMBIENT" },

    -- ==============================
    -- ALL SAINTS HOSPITAL (EMS)
    -- ==============================
    { id = "ems_doctor1",  model = 276, x = 1172.5, y = -1323.5, z = 14.5, rot = 270, name = "Dr. Mthembu",              role = "Chief Emergency Physician",  type = "doctor",    anim = "prtial_gngtlkA", block = "GANGS" },
    { id = "ems_nurse1",   model = 274, x = 1184.0, y = -1310.0, z = 13.5, rot = 180, name = "Sister Khumalo",           role = "Trauma Paramedic",           type = "ems_nurse", anim = "prtial_gngtlkA", block = "GANGS" },
    { id = "ems_nurse2",   model = 274, x = 1167.0, y = -1305.5, z = 13.5, rot = 0,   name = "Sister Naidoo",            role = "ICU Nurse",                  type = "ems_nurse", anim = "M_smk_in",       block = "SMOKING" },
    { id = "ems_doctor2",  model = 276, x = 1195.0, y = -1318.0, z = 14.5, rot = 90,  name = "Dr. Pieterse",             role = "Trauma Surgeon",             type = "doctor",    anim = "IDLE_stance",    block = "PED" },
    { id = "ems_paramedic",model = 274, x = 1190.0, y = -1330.0, z = 13.5, rot = 180, name = "Paramedic Baloyi",         role = "Emergency Response",         type = "ems_nurse", anim = "prtial_gngtlkE", block = "GANGS" },

    -- ==============================
    -- CITY HALL & JOB CENTER (Commerce)
    -- ==============================
    { id = "job_officer1", model = 17, x = 1481.5, y = -1748.5, z = 14.5, rot = 0,   name = "Advisor Dlamini",           role = "Department of Labour",       type = "jobs",   anim = "seat_idle",   block = "PED" },
    { id = "job_officer2", model = 35, x = 1476.0, y = -1742.0, z = 14.5, rot = 90,  name = "Clerk Sithole",             role = "Work Permit Officer",        type = "jobs",   anim = "dealer_idle", block = "DEALER" },
    { id = "receptionist", model = 9,  x = 1490.0, y = -1753.0, z = 14.5, rot = 270, name = "Receptionist Moyo",         role = "Government Services",        type = "jobs",   anim = "seat_idle",   block = "PED" },

    -- ==============================
    -- CENTRAL BANK (Downtown LS)
    -- ==============================
    { id = "bank_guard1",  model = 163, x = 1458.0, y = -1025.0, z = 23.8, rot = 180, name = "Officer Botha",            role = "G4S Armed Vault Security",   type = "bank_guard", anim = "Cop_look",       block = "COP_AMBIENT" },
    { id = "bank_guard2",  model = 163, x = 1465.0, y = -1035.0, z = 23.8, rot = 270, name = "Officer Smit",             role = "G4S Entrance Security",      type = "bank_guard", anim = "Cop_Lean",       block = "COP_AMBIENT" },
    { id = "bank_teller1", model = 9,   x = 1468.5, y = -1018.0, z = 23.8, rot = 90,  name = "Teller Kgomotso",          role = "Standard Bank Cashier",      type = "jobs",       anim = "seat_idle",      block = "PED" },
    { id = "bank_teller2", model = 35,  x = 1462.0, y = -1018.0, z = 23.8, rot = 90,  name = "Teller Precious",          role = "Forex & Transfers",          type = "jobs",       anim = "dealer_idle",    block = "DEALER" },

    -- ==============================
    -- 24/7 SUPERMARKETS
    -- ==============================
    { id = "store_clerk_1", model = 17, x = 1587.5, y = -1676.5, z = 13.5, rot = 180, name = "Sipho (Store Clerk)",      role = "24/7 Supermarket Cashier",   type = "clerk", storeId = 1, anim = "dealer_idle",  block = "DEALER" },
    { id = "store_clerk_2", model = 17, x = 1352.0, y = -1758.0, z = 13.5, rot = 180, name = "Thabo (Store Clerk)",      role = "Idlewood 24/7 Cashier",      type = "clerk", storeId = 2, anim = "dealer_idle",  block = "DEALER" },
    { id = "store_clerk_3", model = 9,  x = 2086.0, y = -1899.0, z = 13.5, rot = 270, name = "Grace (Store Clerk)",      role = "Willowfield 24/7 Cashier",   type = "clerk", storeId = 3, anim = "seat_idle",    block = "PED" },
    { id = "store_clerk_4", model = 35, x = 1929.0, y = -1772.0, z = 13.5, rot = 90,  name = "Moses (Store Clerk)",      role = "Idlewood Gas Station Clerk", type = "clerk", storeId = 4, anim = "dealer_idle",  block = "DEALER" },

    -- ==============================
    -- AMMU-NATION (Weapons)
    -- ==============================
    { id = "gun_dealer1",   model = 179, x = 1368.5, y = -1280.0, z = 13.5, rot = 90,  name = "Johan (Arms Dealer)",     role = "Licensed Firearms Merchant", type = "arms", anim = "dealer_idle",  block = "DEALER" },
    { id = "gun_dealer2",   model = 179, x = 1362.0, y = -1285.0, z = 13.5, rot = 270, name = "Piet (Gunsmith)",         role = "Weapon Maintenance",         type = "arms", anim = "IDLE_stance",  block = "PED" },

    -- ==============================
    -- SOUTH SIDE KINGS GANG (Ganton / Grove Street)
    -- ==============================
    { id = "ssk_homie_1", model = 105, x = 2495.0, y = -1670.0, z = 13.5, rot = 60,  name = "SSK OG Smoke",          role = "South Side Kings OG",        type = "gang_ssk", anim = "M_smk_in",        block = "SMOKING" },
    { id = "ssk_homie_2", model = 106, x = 2496.2, y = -1668.5, z = 13.5, rot = 240, name = "SSK Ryder",             role = "South Side Kings Enforcer",  type = "gang_ssk", anim = "hndshkfa",        block = "GANGS" },
    { id = "ssk_homie_3", model = 107, x = 2488.0, y = -1665.0, z = 13.5, rot = 180, name = "SSK K-Dog",             role = "South Side Kings Soldier",   type = "gang_ssk", anim = "prtial_gngtlkA",  block = "GANGS" },
    { id = "ssk_homie_4", model = 105, x = 2510.0, y = -1660.0, z = 13.5, rot = 90,  name = "SSK Tiny",              role = "South Side Kings Lookout",   type = "gang_ssk", anim = "prtial_gngtlkE",  block = "GANGS" },
    { id = "ssk_homie_5", model = 107, x = 2520.0, y = -1645.0, z = 13.5, rot = 0,   name = "SSK T-Bone",            role = "South Side Kings Muscle",    type = "gang_ssk", anim = "M_smk_in",        block = "SMOKING" },
    { id = "ssk_homie_6", model = 106, x = 2480.0, y = -1655.0, z = 13.5, rot = 270, name = "SSK Peanut",            role = "South Side Kings Corner",    type = "gang_ssk", anim = "prtial_gngtlkA",  block = "GANGS" },

    -- ==============================
    -- DURBAN / KWAZULU-NATAL (Zulu Warriors Gang - Garcia Hostels & Harbour)
    -- ==============================
    { id = "zw_homie_1", model = 102, x = -2160.5, y = -235.5, z = 36.5, rot = 270, name = "Brother Mandla",         role = "Zulu Warriors Shot Caller",  type = "gang_zw", anim = "prtial_gngtlkE", block = "GANGS" },
    { id = "zw_homie_2", model = 103, x = -2158.0, y = -236.0, z = 36.5, rot = 90,  name = "Brother Bheki",          role = "Zulu Warriors Amabutho",     type = "gang_zw", anim = "prtial_gngtlkA", block = "GANGS" },
    { id = "zw_homie_3", model = 102, x = -2165.0, y = -242.0, z = 36.5, rot = 0,   name = "Brother Siphamandla",    role = "Zulu Warriors Enforcer",     type = "gang_zw", anim = "M_smk_in",        block = "SMOKING" },
    { id = "zw_homie_4", model = 103, x = -2150.0, y = -230.0, z = 36.5, rot = 180, name = "Brother Nhlanhla",       role = "Zulu Warriors Patrol",       type = "gang_zw", anim = "hndshkfa",        block = "GANGS" },
    { id = "zw_port_1",  model = 102, x = -1600.0, y = 150.0,  z = 10.5, rot = 90,  name = "Nduna Khumalo",          role = "Durban Port Contraband Boss",type = "gang_zw", anim = "dealer_idle",     block = "DEALER" },

    -- ==============================
    -- CRAZY DRAGONS GANG (Cape Town - Market / Chinatown)
    -- ==============================
    { id = "cd_homie_1", model = 121, x = 1920.5, y = -1760.5, z = 13.5, rot = 0,   name = "Triad Sentry Wei",       role = "Crazy Dragons Syndicate",    type = "gang_cd", anim = "mrnM_loop",       block = "GRAVEYARD" },
    { id = "cd_homie_2", model = 122, x = 1915.0, y = -1768.0, z = 13.5, rot = 180, name = "Dragon Li",              role = "Crazy Dragons Enforcer",     type = "gang_cd", anim = "prtial_gngtlkA",  block = "GANGS" },
    { id = "cd_homie_3", model = 123, x = 1930.0, y = -1755.0, z = 13.5, rot = 90,  name = "Dragon Chen",            role = "Crazy Dragons Hitman",       type = "gang_cd", anim = "dealer_idle",     block = "DEALER" },

    -- ==============================
    -- CAPE TOWN 28s NUMBERS GANG (Cape Town - Idlewood)
    -- ==============================
    { id = "28s_homie_1", model = 180, x = 1950.0, y = -1450.0, z = 13.5, rot = 180, name = "28s General Chesa",     role = "Cape Town Numbers Gang",     type = "gang_28s", anim = "dealer_idle",     block = "DEALER" },
    { id = "28s_homie_2", model = 181, x = 1945.0, y = -1458.0, z = 13.5, rot = 90,  name = "28s Sergeant Boer",     role = "28s Street Sergeant",        type = "gang_28s", anim = "M_smk_in",        block = "SMOKING" },
    { id = "28s_homie_3", model = 180, x = 1960.0, y = -1445.0, z = 13.5, rot = 0,   name = "28s Skollie Nats",      role = "28s Road Lookout",           type = "gang_28s", anim = "prtial_gngtlkE",  block = "GANGS" },

    -- ==============================
    -- BOERE MAFIA GANG (Jozi / Gauteng - Redsands East, Las Venturas)
    -- ==============================
    { id = "bm_homie_1", model = 158, x = 2270.5, y = 1430.5, z = 11.5, rot = 180, name = "Oubaas Van Der Merwe",  role = "Boere Mafia Patriarch",      type = "gang_bm",  anim = "M_smk_in",        block = "SMOKING" },
    { id = "bm_homie_2", model = 73,  x = 2275.0, y = 1435.0, z = 11.5, rot = 90,  name = "Commando Piet",          role = "Highveld Arms Master",       type = "gang_bm",  anim = "prtial_gngtlkA",  block = "GANGS" },
    { id = "bm_cit_1",   model = 164, x = 2550.0, y = 700.0,  z = 11.0, rot = 0,   name = "Madala Jackson",         role = "CIT Syndicate Operative",    type = "gang_bm",  anim = "dealer_idle",     block = "DEALER" },

    -- ==============================
    -- NYAU DUST CARTEL (Jozi / Gauteng - Old Venturas Strip, Las Venturas)
    -- ==============================
    { id = "ndc_homie_1", model = 113, x = 2480.5, y = 2110.5, z = 11.0, rot = 270, name = "El Patron Banda",       role = "Nyau Cartel Baron",          type = "gang_ndc", anim = "dealer_idle",     block = "DEALER" },
    { id = "ndc_homie_2", model = 114, x = 2485.0, y = 2115.0, z = 11.0, rot = 0,   name = "Cartel Pusher Moses",    role = "Jozi Meth & Cat Supplier",   type = "gang_ndc", anim = "prtial_gngtlkE",  block = "GANGS" },

    -- ==============================
    -- PROVINCIAL DRUG DEALERS
    -- ==============================
    { id = "dealer_idlewood", model = 105, x = 1970.0,  y = -1780.0, z = 13.5, rot = 270, name = "Scarra (Cape Town Dealer)", role = "Cape Flats Substances",     type = "drug_dealer", anim = "dealer_idle", block = "DEALER" },
    { id = "dealer_ganton",   model = 106, x = 2265.0,  y = -1640.0, z = 13.5, rot = 180, name = "K-Mac (Ganton Corner)",     role = "Ganton Drug Corner",          type = "drug_dealer", anim = "M_smk_in",    block = "SMOKING" },
    { id = "dealer_durban",   model = 103, x = -2720.0, y = -320.0,  z = 7.5,  rot = 270, name = "Sipho (Durban Beach)",      role = "KZN Coastal Dagga Dealer",    type = "drug_dealer", anim = "dealer_idle", block = "DEALER" },
    { id = "dealer_jozi",     model = 106, x = 2028.0,  y = 1008.0,  z = 10.8, rot = 90,  name = "Bra Vusi (Egoli Pusher)",   role = "Jozi Highveld Gold/Cat Merchant",type = "drug_dealer", anim = "dealer_idle", block = "DEALER" },

    -- ==============================
    -- PIER & BEACHFRONT (Santa Maria)
    -- ==============================
    { id = "pier_fisherman1", model = 95,  x = 385.0,  y = -2088.0, z = 7.8, rot = 90,  name = "Oom Piet",               role = "Deep Sea Angler",            type = "fisherman",   anim = "gnstkrch",    block = "SWAT" },
    { id = "pier_fisherman2", model = 96,  x = 372.0,  y = -2091.0, z = 7.8, rot = 270, name = "Uncle Moses",             role = "Pier Regular",               type = "fisherman",   anim = "seat_idle",   block = "PED" },
    { id = "beach_tourist1",  model = 9,   x = 360.0,  y = -2095.0, z = 3.0, rot = 180, name = "Tourist Sarah",           role = "Beachgoer",                  type = "civilian",    anim = "M_smk_in",    block = "SMOKING" },
    { id = "beach_tourist2",  model = 35,  x = 340.0,  y = -2110.0, z = 3.0, rot = 0,   name = "Surfer Dave",             role = "Beach Surfer",               type = "civilian",    anim = "seat_idle",   block = "PED" },
    { id = "beach_lifeguard", model = 131, x = 400.0,  y = -2085.0, z = 3.5, rot = 270, name = "Lifeguard Ramon",         role = "Beach Safety Patrol",        type = "civilian",    anim = "IDLE_stance",  block = "PED" },

    -- ==============================
    -- AIRPORT AREA (Los Santos International)
    -- ==============================
    { id = "airport_guard1",  model = 163, x = 1680.0, y = -2258.0, z = 14.0, rot = 180, name = "Security Officer Dube",  role = "LSIA Security",              type = "police_guard", anim = "Cop_look",     block = "COP_AMBIENT" },
    { id = "airport_worker1", model = 95,  x = 1695.0, y = -2265.0, z = 14.0, rot = 0,   name = "Groundcrew Themba",      role = "Aircraft Ground Handler",    type = "civilian",     anim = "seat_idle",    block = "PED" },
    { id = "airport_pilot",   model = 72,  x = 1705.0, y = -2248.0, z = 14.0, rot = 90,  name = "Captain Ferreira",       role = "Commercial Airline Pilot",   type = "civilian",     anim = "IDLE_stance",  block = "PED" },

    -- ==============================
    -- OCEAN DOCKS / INDUSTRIAL
    -- ==============================
    { id = "trucker1",   model = 95,  x = -535.0, y = -485.0, z = 25.5, rot = 0,   name = "Driver Joubert",          role = "Long Haul Trucker",          type = "trucker", anim = "seat_idle",     block = "PED" },
    { id = "trucker2",   model = 96,  x = -545.0, y = -490.0, z = 25.5, rot = 180, name = "Driver Baloyi",           role = "Cargo Logistics",            type = "trucker", anim = "dealer_idle",   block = "DEALER" },
    { id = "dock_guard", model = 163, x = -520.0, y = -495.0, z = 25.5, rot = 90,  name = "Guard Pretorius",         role = "Ocean Docks Security",       type = "police_guard", anim = "Cop_look",    block = "COP_AMBIENT" },

    -- ==============================
    -- VINEWOOD (Affluent Civilians)
    -- ==============================
    { id = "vinewood_celeb1", model = 72,  x = 616.0,  y = -1272.5, z = 19.5, rot = 270, name = "Celebrity Cassidy",    role = "Vinewood A-Lister",          type = "civilian", anim = "M_smk_in",    block = "SMOKING" },
    { id = "vinewood_celeb2", model = 9,   x = 625.0,  y = -1280.0, z = 19.5, rot = 90,  name = "Starlet Candice",      role = "Film Actress",               type = "civilian", anim = "seat_idle",   block = "PED" },
    { id = "vinewood_paparazzi", model = 35, x = 608.5, y = -1268.0, z = 19.5, rot = 180, name = "Paparazzi Carl",      role = "Tabloid Photographer",       type = "civilian", anim = "dealer_idle", block = "DEALER" },

    -- ==============================
    -- MARKET DISTRICT (General Street Life)
    -- ==============================
    { id = "street_vendor1", model = 17,  x = 1612.0, y = -1510.0, z = 13.5, rot = 180, name = "Sis Nomsa (Vendor)",   role = "Township Fruit Vendor",      type = "civilian", anim = "dealer_idle",    block = "DEALER" },
    { id = "street_vendor2", model = 35,  x = 1625.0, y = -1505.0, z = 13.5, rot = 90,  name = "Bra Mike (Griller)",   role = "Braai Meat Street Vendor",   type = "civilian", anim = "M_smk_in",       block = "SMOKING" },
    { id = "mechanic1",      model = 95,  x = 1505.0, y = -1665.0, z = 13.5, rot = 270, name = "Mechanic Sipho",       role = "Auto Repair Workshop",       type = "mechanic", anim = "IDLE_stance",    block = "PED" },
    { id = "mechanic2",      model = 96,  x = 1510.0, y = -1672.0, z = 13.5, rot = 90,  name = "Apprentice Tshepo",    role = "Auto Repair Assistant",      type = "mechanic", anim = "dealer_idle",    block = "DEALER" },
    { id = "taxi_dispatch",  model = 17,  x = 1778.0, y = -1860.0, z = 13.5, rot = 180, name = "Dispatcher Gugu",      role = "Taxi Rank Dispatcher",       type = "trucker",  anim = "seat_idle",      block = "PED" },

    -- ==============================
    -- AUTO DEALERSHIP (Sunshine Autos)
    -- ==============================
    { id = "dealer_sales1",  model = 72,  x = 2128.0, y = -1148.0, z = 24.0, rot = 270, name = "Salesman Wayne",       role = "Car Sales Consultant",       type = "jobs",    anim = "dealer_idle",   block = "DEALER" },
    { id = "dealer_sales2",  model = 9,   x = 2135.0, y = -1145.0, z = 24.0, rot = 90,  name = "Finance Manager Gail", role = "Auto Finance & Insurance",   type = "jobs",    anim = "seat_idle",     block = "PED" },
}

-- ==============================================================
-- MASSIVE VEHICLE FLEET — 85+ Ambient Street Vehicles
-- ==============================================================
local VEHICLE_FLEET = {
    -- ============================
    -- GROVE STREET / GANTON LOWRIDERS
    -- ============================
    { model = 480, x = 2490.0, y = -1675.0, z = 13.5, rot = 90,  plate = "SSK-01", col1 = 0,   col2 = 100 }, -- Savanna
    { model = 536, x = 2498.0, y = -1660.0, z = 13.5, rot = 180, plate = "SSK-02", col1 = 0,   col2 = 150 }, -- Blade
    { model = 492, x = 2480.0, y = -1655.0, z = 13.5, rot = 270, plate = "SSK-03", col1 = 30,  col2 = 30  }, -- Greenwood
    { model = 412, x = 2505.0, y = -1650.0, z = 13.5, rot = 0,   plate = "SSK-04", col1 = 10,  col2 = 10  }, -- Voodoo
    { model = 474, x = 2515.0, y = -1645.0, z = 13.5, rot = 0,   plate = "SSK-05", col1 = 5,   col2 = 150 }, -- Hermes

    -- ============================
    -- DURBAN / KWAZULU-NATAL (Zulu Warriors Fleet - Garcia Hostels)
    -- ============================
    { model = 402, x = -2150.0, y = -230.0, z = 36.5, rot = 90,  plate = "ZW-01",  col1 = 0,   col2 = 200 }, -- Buffalo (Green)
    { model = 575, x = -2155.0, y = -240.0, z = 36.5, rot = 90,  plate = "ZW-02",  col1 = 50,  col2 = 180 }, -- Broadway
    { model = 412, x = -2145.0, y = -225.0, z = 36.5, rot = 180, plate = "ZW-03",  col1 = 0,   col2 = 200 }, -- Voodoo
    { model = 536, x = -2165.0, y = -245.0, z = 36.5, rot = 0,   plate = "ZW-04",  col1 = 0,   col2 = 80  }, -- Blade
    { model = 474, x = -2170.0, y = -235.0, z = 36.5, rot = 270, plate = "ZW-05",  col1 = 200, col2 = 10  }, -- Hermes

    -- ============================
    -- JOZI / GAUTENG (Boere Mafia Heavy Fleet - Redsands East)
    -- ============================
    { model = 579, x = 2275.0,  y = 1435.0, z = 11.5, rot = 180, plate = "BM-01",  col1 = 200, col2 = 150 }, -- Huntley SUV (Ochre)
    { model = 470, x = 2280.0,  y = 1440.0, z = 11.5, rot = 90,  plate = "BM-02",  col1 = 80,  col2 = 80  }, -- Patriot Heavy
    { model = 567, x = 2265.0,  y = 1425.0, z = 11.5, rot = 270, plate = "BM-03",  col1 = 150, col2 = 100 }, -- Remington Custom

    -- ============================
    -- JOZI / GAUTENG (Nyau Dust Cartel Exotic Fleet - Old Venturas Strip)
    -- ============================
    { model = 415, x = 2485.0,  y = 2115.0, z = 11.0, rot = 270, plate = "NDC-01", col1 = 150, col2 = 0   }, -- Cheetah (Purple)
    { model = 560, x = 2490.0,  y = 2120.0, z = 11.0, rot = 180, plate = "NDC-02", col1 = 180, col2 = 50  }, -- Sultan
    { model = 411, x = 2475.0,  y = 2105.0, z = 11.0, rot = 0,   plate = "NDC-03", col1 = 100, col2 = 0   }, -- Infernus

    -- ============================
    -- IDLEWOOD / MARKET (28s & Crazy Dragons Turf)
    -- ============================
    { model = 500, x = 1942.0, y = -1778.0, z = 13.5, rot = 180, plate = "CD-01",  col1 = 255, col2 = 0   }, -- Mesa (Red)
    { model = 491, x = 1928.0, y = -1760.0, z = 13.5, rot = 90,  plate = "CD-02",  col1 = 50,  col2 = 50  }, -- Rancher
    { model = 403, x = 1960.0, y = -1453.0, z = 13.5, rot = 0,   plate = "28S-01", col1 = 10,  col2 = 10  }, -- Linerunner
    { model = 579, x = 1975.0, y = -1440.0, z = 13.5, rot = 270, plate = "28S-02", col1 = 80,  col2 = 0   }, -- Huntley SUV
    { model = 560, x = 1962.0, y = -1468.0, z = 13.5, rot = 90,  plate = "28S-03", col1 = 0,   col2 = 0   }, -- Sultan

    -- ============================
    -- OCEAN DOCKS TRUCKING FLEET
    -- ============================
    { model = 403, x = -532.5, y = -488.5, z = 25.5, rot = 0,   plate = "HAUL-01", col1 = 200, col2 = 150 }, -- Linerunner
    { model = 515, x = -520.0, y = -488.5, z = 25.5, rot = 0,   plate = "HAUL-02", col1 = 180, col2 = 20  }, -- Roadtrain
    { model = 455, x = -508.0, y = -488.5, z = 25.5, rot = 0,   plate = "HAUL-03", col1 = 100, col2 = 100 }, -- Flatbed
    { model = 514, x = -545.0, y = -495.0, z = 25.5, rot = 180, plate = "HAUL-04", col1 = 150, col2 = 100 }, -- Tanker
    { model = 584, x = -558.0, y = -492.0, z = 25.5, rot = 90,  plate = "HAUL-05", col1 = 255, col2 = 200 }, -- Dozer

    -- ============================
    -- TAXI & PUBLIC TRANSPORT RANK (Commerce)
    -- ============================
    { model = 420, x = 1778.5, y = -1865.0, z = 13.5, rot = 0,   plate = "TAXI-01", col1 = 255, col2 = 255 }, -- Taxi
    { model = 438, x = 1785.0, y = -1865.0, z = 13.5, rot = 0,   plate = "TAXI-02", col1 = 255, col2 = 255 }, -- Cabbie
    { model = 420, x = 1792.0, y = -1865.0, z = 13.5, rot = 0,   plate = "TAXI-03", col1 = 255, col2 = 255 }, -- Taxi
    { model = 431, x = 1800.0, y = -1865.0, z = 13.5, rot = 0,   plate = "BUS-01",  col1 = 255, col2 = 200 }, -- Bus
    { model = 437, x = 1810.0, y = -1865.0, z = 13.5, rot = 0,   plate = "BUS-02",  col1 = 255, col2 = 200 }, -- Coach

    -- ============================
    -- AUTO DEALERSHIP SHOWROOM (Sunshine Autos)
    -- ============================
    { model = 411, x = 2125.0, y = -1150.0, z = 24.0, rot = 270, plate = "MZ-VIP1", col1 = 200, col2 = 170 }, -- Infernus
    { model = 451, x = 2125.0, y = -1155.0, z = 24.0, rot = 270, plate = "MZ-VIP2", col1 = 255, col2 = 0   }, -- Turismo
    { model = 541, x = 2138.0, y = -1150.0, z = 24.0, rot = 90,  plate = "MZ-VIP3", col1 = 0,   col2 = 120 }, -- Bullet
    { model = 429, x = 2138.0, y = -1158.0, z = 24.0, rot = 270, plate = "MZ-VIP4", col1 = 0,   col2 = 0   }, -- Banshee
    { model = 502, x = 2150.0, y = -1150.0, z = 24.0, rot = 90,  plate = "MZ-VIP5", col1 = 210, col2 = 0   }, -- Alpha (super)
    { model = 506, x = 2150.0, y = -1158.0, z = 24.0, rot = 270, plate = "MZ-VIP6", col1 = 0,   col2 = 180 }, -- Super GT
    { model = 494, x = 2162.0, y = -1150.0, z = 24.0, rot = 90,  plate = "MZ-SUV1", col1 = 10,  col2 = 10  }, -- Bobcat Truck
    { model = 579, x = 2162.0, y = -1158.0, z = 24.0, rot = 270, plate = "MZ-SUV2", col1 = 50,  col2 = 50  }, -- Huntley SUV

    -- ============================
    -- CENTRAL BANK STAFF VEHICLES
    -- ============================
    { model = 445, x = 1450.0, y = -1015.0, z = 23.8, rot = 180, plate = "BNK-01", col1 = 10,  col2 = 20  }, -- Admiral
    { model = 428, x = 1445.0, y = -1025.0, z = 23.8, rot = 270, plate = "SEC-01", col1 = 50,  col2 = 50  }, -- Securicar

    -- ============================
    -- SANTA MARIA BEACH / PIER
    -- ============================
    { model = 473, x = 370.0,  y = -2090.0, z = 1.0, rot = 0,   plate = "BOAT-01", col1 = 0,   col2 = 200 }, -- Dinghy
    { model = 493, x = 360.0,  y = -2090.0, z = 1.0, rot = 0,   plate = "BOAT-02", col1 = 255, col2 = 100 }, -- Jetmax
    { model = 481, x = 380.0,  y = -2095.0, z = 1.0, rot = 0,   plate = "BOAT-03", col1 = 100, col2 = 200 }, -- Speeder
    { model = 428, x = 330.0,  y = -2080.0, z = 3.0, rot = 90,  plate = "BEACH-01",col1 = 150, col2 = 200 }, -- beach car

    -- ============================
    -- DOWNTOWN / COMMERCE DISTRICT STREET TRAFFIC
    -- ============================
    { model = 562, x = 1512.0, y = -1661.4, z = 13.6, rot = 270, plate = "JHB-01",  col1 = 200, col2 = 20  }, -- Elegy
    { model = 496, x = 1501.0, y = -1670.9, z = 13.6, rot = 90,  plate = "JHB-02",  col1 = 50,  col2 = 50  }, -- Blista Compact
    { model = 415, x = 1492.0, y = -1660.5, z = 13.6, rot = 180, plate = "JHB-03",  col1 = 10,  col2 = 10  }, -- Cheetah
    { model = 402, x = 1705.0, y = -1490.0, z = 13.6, rot = 180, plate = "CPT-01",  col1 = 180, col2 = 20  }, -- Buffalo
    { model = 579, x = 1700.0, y = -1480.0, z = 13.6, rot = 270, plate = "CPT-02",  col1 = 10,  col2 = 10  }, -- Huntley SUV
    { model = 589, x = 1715.0, y = -1472.0, z = 13.6, rot = 0,   plate = "CPT-03",  col1 = 100, col2 = 100 }, -- Club
    { model = 445, x = 1430.0, y = -1730.0, z = 13.6, rot = 90,  plate = "COM-01",  col1 = 80,  col2 = 80  }, -- Admiral
    { model = 516, x = 1415.0, y = -1720.0, z = 13.6, rot = 270, plate = "COM-02",  col1 = 30,  col2 = 30  }, -- Nebula
    { model = 527, x = 1400.0, y = -1710.0, z = 13.6, rot = 180, plate = "COM-03",  col1 = 255, col2 = 128 }, -- Cadrona
    { model = 540, x = 1620.0, y = -1590.0, z = 13.6, rot = 0,   plate = "COM-04",  col1 = 120, col2 = 200 }, -- Vincent
    { model = 421, x = 1635.0, y = -1580.0, z = 13.6, rot = 90,  plate = "COM-05",  col1 = 200, col2 = 150 }, -- Washington
    { model = 418, x = 1650.0, y = -1575.0, z = 13.6, rot = 270, plate = "COM-06",  col1 = 50,  col2 = 100 }, -- Moonbeam

    -- ============================
    -- AIRPORT & AVIATION FLEET
    -- ============================
    { model = 411, x = 1740.0, y = -2166.0, z = 13.5, rot = 90,  plate = "AIR-01",    col1 = 255, col2 = 255 }, -- Infernus
    { model = 487, x = 1720.0, y = -2130.0, z = 13.5, rot = 90,  plate = "AIR-HELI1", col1 = 200, col2 = 180 }, -- Maverick Helicopter
    { model = 417, x = 1763.0, y = -2160.0, z = 13.5, rot = 0,   plate = "HEAVY-AIR", col1 = 100, col2 = 120 }, -- Leviathan Cargo Heli
    { model = 418, x = 1665.0, y = -2260.0, z = 13.5, rot = 180, plate = "AIR-VAN",   col1 = 255, col2 = 255 }, -- Airport Shuttle Van
    { model = 419, x = 1665.0, y = -2270.0, z = 13.5, rot = 180, plate = "AIR-03",    col1 = 200, col2 = 200 }, -- Airport Bakkie
 
    -- ============================
    -- VINEWOOD / NORTH LS LUXURY
    -- ============================
    { model = 429, x = 610.0,  y = -1275.0, z = 19.5, rot = 180, plate = "VWD-01", col1 = 0,   col2 = 0   }, -- Banshee
    { model = 541, x = 620.0,  y = -1280.0, z = 19.5, rot = 0,   plate = "VWD-02", col1 = 128, col2 = 0   }, -- Bullet
    { model = 445, x = 630.0,  y = -1270.0, z = 19.5, rot = 90,  plate = "VWD-03", col1 = 10,  col2 = 10  }, -- Admiral
    { model = 536, x = 600.0,  y = -1290.0, z = 19.5, rot = 270, plate = "VWD-04", col1 = 150, col2 = 0   }, -- Blade
 
    -- ============================
    -- GENERAL INNER-CITY PARKED TRAFFIC
    -- ============================
    { model = 491, x = 1845.0, y = -1640.0, z = 13.5, rot = 90,  plate = "STR-01", col1 = 90,  col2 = 90  }, -- Rancher
    { model = 400, x = 1865.0, y = -1630.0, z = 13.5, rot = 270, plate = "STR-02", col1 = 50,  col2 = 50  }, -- Landstalker
    { model = 436, x = 1880.0, y = -1620.0, z = 13.5, rot = 180, plate = "STR-03", col1 = 200, col2 = 100 }, -- Previon
    { model = 405, x = 1755.0, y = -1725.0, z = 13.5, rot = 0,   plate = "STR-04", col1 = 70,  col2 = 100 }, -- Sentinel
    { model = 409, x = 1768.0, y = -1730.0, z = 13.5, rot = 90,  plate = "STR-05", col1 = 30,  col2 = 30  }, -- Stretch Limo
    { model = 466, x = 1780.0, y = -1740.0, z = 13.5, rot = 180, plate = "STR-06", col1 = 10,  col2 = 150 }, -- Glendale
    { model = 549, x = 1610.0, y = -1840.0, z = 13.5, rot = 270, plate = "STR-07", col1 = 255, col2 = 128 }, -- Tampa
    { model = 540, x = 1622.0, y = -1840.0, z = 13.5, rot = 90,  plate = "STR-08", col1 = 150, col2 = 50  }, -- Vincent
    { model = 516, x = 1634.0, y = -1840.0, z = 13.5, rot = 0,   plate = "STR-09", col1 = 80,  col2 = 80  }, -- Nebula
    { model = 527, x = 2195.0, y = -1670.0, z = 13.5, rot = 90,  plate = "STR-10", col1 = 100, col2 = 200 }, -- Cadrona
    { model = 421, x = 2210.0, y = -1670.0, z = 13.5, rot = 270, plate = "STR-11", col1 = 200, col2 = 80  }, -- Washington
    { model = 418, x = 2225.0, y = -1670.0, z = 13.5, rot = 180, plate = "STR-12", col1 = 30,  col2 = 100 }, -- Moonbeam
    { model = 401, x = 2240.0, y = -1670.0, z = 13.5, rot = 0,   plate = "STR-13", col1 = 220, col2 = 50  }, -- Bravura
    { model = 404, x = 1300.0, y = -1100.0, z = 23.8, rot = 180, plate = "STR-14", col1 = 10,  col2 = 200 }, -- Perennial
    { model = 458, x = 1310.0, y = -1090.0, z = 23.8, rot = 90,  plate = "STR-15", col1 = 250, col2 = 0   }, -- Solair
}

-- ==============================================================
-- DYNAMIC ROAD-NETWORK TRAFFIC SYSTEM
-- Vehicles spawn and travel strictly along verified asphalt road lanes
-- ==============================================================
local TRAFFIC_MODELS = { 400, 401, 404, 405, 421, 436, 491, 516, 527, 540, 549, 589, 579, 560 }
local MAX_DYNAMIC_TRAFFIC = 16

function Mzansi.Activity.spawnDynamicTraffic()
    -- Clear old ones that are too far from all players (> 200m)
    for i = #Mzansi.Activity._trafficVehicles, 1, -1 do
        local tData = Mzansi.Activity._trafficVehicles[i]
        local veh = tData.vehicle
        if not isElement(veh) then
            if isElement(tData.driver) then destroyElement(tData.driver) end
            table.remove(Mzansi.Activity._trafficVehicles, i)
        else
            local vx, vy, vz = getElementPosition(veh)
            local tooFar = true
            for _, player in ipairs(getElementsByType("player")) do
                local px, py, pz = getElementPosition(player)
                if getDistanceBetweenPoints3D(px, py, pz, vx, vy, vz) < 220 then
                    tooFar = false
                    break
                end
            end
            if tooFar then
                if isElement(tData.driver) then destroyElement(tData.driver) end
                destroyElement(veh)
                table.remove(Mzansi.Activity._trafficVehicles, i)
            end
        end
    end

    -- Angel: Ambient Traffic Spawner
    -- Spawn dynamic traffic populated with NPC drivers strictly on surveyed road network
    if #getElementsByType("player") == 0 then return end
    if #Mzansi.Activity._trafficVehicles >= MAX_DYNAMIC_TRAFFIC then return end

    if not Mzansi.Roads or not Mzansi.Roads.getRandomSpawnNode then return end
    local spawnNode, circuit, nodeIdx = Mzansi.Roads.getRandomSpawnNode()
    if not spawnNode then return end

    local model = TRAFFIC_MODELS[math.random(1, #TRAFFIC_MODELS)]
    local col1 = math.random(0, 255)
    local col2 = math.random(0, 255)

    local veh = createVehicle(model, spawnNode.x, spawnNode.y, spawnNode.z, 0, 0, spawnNode.heading, "TRAF" .. math.random(1000, 9999))
    if veh then
        setVehicleColor(veh, col1, col2, 0, 0)
        setElementData(veh, "mzansi:fuel", math.random(60, 100))
        setElementData(veh, "mzansi:isAmbient", true)

        -- Spawn autonomous NPC civilian driver
        local driverSkin = math.random(9, 280)
        local driver = createPed(driverSkin, spawnNode.x, spawnNode.y, spawnNode.z + 1)
        if driver then
            warpPedIntoVehicle(driver, veh, 0)
            setVehicleEngineState(veh, true)
            local rad = math.rad(spawnNode.heading)
            setElementVelocity(veh, -math.sin(rad) * spawnNode.speed, math.cos(rad) * spawnNode.speed, 0)
            setElementData(driver, "mzansi:isTrafficDriver", true)
            setElementData(veh, "mzansi:ambientDriver", driver)
            addEventHandler("onPedDamage", driver, function() cancelEvent() end)
        end

        table.insert(Mzansi.Activity._trafficVehicles, {
            vehicle = veh,
            driver = driver,
            circuit = circuit,
            targetNode = (nodeIdx % #circuit.nodes) + 1
        })
    end
end

-- Progress ambient traffic along circuit waypoints
function Mzansi.Activity.updateTrafficRoutes()
    for i = #Mzansi.Activity._trafficVehicles, 1, -1 do
        local tData = Mzansi.Activity._trafficVehicles[i]
        local veh = tData.vehicle
        local driver = tData.driver

        if not isElement(veh) or not isElement(driver) or getVehicleOccupant(veh, 0) ~= driver then
            if isElement(veh) then destroyElement(veh) end
            if isElement(driver) then destroyElement(driver) end
            table.remove(Mzansi.Activity._trafficVehicles, i)
        else
            local target = tData.circuit.nodes[tData.targetNode]
            if target then
                local vx, vy, vz = getElementPosition(veh)
                local dist = getDistanceBetweenPoints3D(vx, vy, vz, target.x, target.y, target.z)
                if dist < 10 then
                    tData.targetNode = (tData.targetNode % #tData.circuit.nodes) + 1
                    target = tData.circuit.nodes[tData.targetNode]
                end

                local angle = (360 - math.deg(math.atan2(target.x - vx, target.y - vy))) % 360
                setElementRotation(veh, 0, 0, angle)
                local rad = math.rad(angle)
                setElementVelocity(veh, -math.sin(rad) * target.speed, math.cos(rad) * target.speed, 0)
                setVehicleEngineState(veh, true)
            end
        end
    end
end

-- ==============================================================
-- INIT — Start the entire living world
-- ==============================================================
function Mzansi.Activity.init()
    outputDebugString("[Mzansi-Activity] Spawning MASSIVE Living World — NPCs, Vehicles, Gangs, Traffic...")

    -- 1. Spawn all persistent roleplay NPCs (Unfrozen with authentic natural animations)
    for _, npcData in ipairs(NPC_LIST) do
        local ped = createPed(npcData.model, npcData.x, npcData.y, npcData.z, npcData.rot)
        if ped then
            setElementData(ped, "mzansi:isNPC", true)
            setElementData(ped, "mzansi:npcName", npcData.name)
            setElementData(ped, "mzansi:npcRole", npcData.role)
            setElementData(ped, "mzansi:npcType", npcData.type)
            if npcData.storeId then setElementData(ped, "mzansi:storeId", npcData.storeId) end

            if npcData.block and npcData.anim then
                setPedAnimation(ped, npcData.block, npcData.anim, -1, true, false, false, false)
            end

            -- Protect vital NPCs from being killed
            addEventHandler("onPedDamage", ped, function() cancelEvent() end)
            Mzansi.Activity._npcs[npcData.id] = ped
        end
    end

    -- 2. Spawn the static street fleet
    for _, vData in ipairs(VEHICLE_FLEET) do
        local veh = createVehicle(vData.model, vData.x, vData.y, vData.z, 0, 0, vData.rot, vData.plate)
        if veh then
            setElementData(veh, "mzansi:fuel", 100)
            setElementData(veh, "mzansi:locked", false)
            setVehicleColor(veh, vData.col1 or 0, vData.col2 or 0, 0, 0)
            Mzansi.Activity._vehicles[#Mzansi.Activity._vehicles + 1] = veh
        end
    end

    -- 3. Emergency mission dispatch every 3 minutes
    --    First fire delayed to 3 min so players spawn safely before any armed NPCs appear.
    setTimer(Mzansi.Activity.generateEmergencyMission, 180000, 0)
    setTimer(Mzansi.Activity.generateEmergencyMission, 180000, 1)

    -- 4. Dynamic ambient traffic spawner every 30 seconds
    setTimer(Mzansi.Activity.spawnDynamicTraffic, 30000, 0)
    setTimer(Mzansi.Activity.spawnDynamicTraffic, 8000, 1)

    -- 5. Dynamic traffic waypoint progress Angel loop every 1.5 seconds
    setTimer(Mzansi.Activity.updateTrafficRoutes, 1500, 0)

    -- 6. Random gang activity & drive-bys every 5 minutes
    --    First fire delayed to 5 min — no gangwar during player spawn window.
    setTimer(Mzansi.Activity.generateGangEvent, 300000, 0)
    setTimer(Mzansi.Activity.generateGangEvent, 300000, 1)

    -- 7. Random civilian events every 4 minutes
    setTimer(Mzansi.Activity.generateCivilianEvent, 240000, 0)
    setTimer(Mzansi.Activity.generateCivilianEvent, 240000, 1)

    outputDebugString("[Mzansi-Activity] ✓ " .. #NPC_LIST .. " NPCs | " .. #VEHICLE_FLEET .. " Street Vehicles | Dynamic Road Traffic ACTIVE!")
end

-- ==============================================================
-- EMERGENCY MISSION GENERATOR (SAPS 911 & EMS Calls)
-- ==============================================================
function Mzansi.Activity.generateEmergencyMission()
    Mzansi.Activity.cleanupOldMissions()

    local missionTypes = { "robbery", "ems_rescue", "armored_heist", "drug_bust", "hostage" }
    local chosen = missionTypes[math.random(1, #missionTypes)]

    if chosen == "robbery" then
        local locations = {
            -- NOTE: Willowfield (1585, -1678) removed — it overlaps the SAPS spawn zone
            --       and caused mission robbers to kill freshly-spawned players.
            { name = "Idlewood Gas Station Mini-Mart",     x = 1944.5, y = -1772.5, z = 13.5 },
            { name = "Commerce Corner Mart",               x = 1352.0, y = -1758.0, z = 13.5 },
            { name = "Ganton Liquor Store",                x = 2250.0, y = -1640.0, z = 13.5 },
            { name = "East LS Convenience Store",          x = 2385.0, y = -1650.0, z = 13.5 },
            { name = "Vinewood Petrol Stop",               x = 1025.0, y = -920.0,  z = 42.5 },
        }
        local loc = locations[math.random(1, #locations)]

        outputChatBox("[SAPS 911 DISPATCH] 10-31 Armed Robbery at " .. loc.name .. " • Hostiles on scene!", root, 255, 75, 75)
        outputChatBox("[Reward] R 15,000 + 500 XP upon neutralizing suspects • Follow RED blip!", root, 50, 220, 100)

        local blip   = createBlip(loc.x, loc.y, loc.z, 20, 3, 255, 0, 0, 255, 0, 9999)
        local marker = createMarker(loc.x, loc.y, loc.z - 1.0, "checkpoint", 4.0, 255, 0, 0, 180)
        local robber1 = createPed(29, loc.x + 1.5, loc.y + 1.0, loc.z, 180)
        local robber2 = createPed(30, loc.x - 1.5, loc.y - 1.0, loc.z, 0)
        giveWeapon(robber1, 28, 500, true)
        giveWeapon(robber2, 25, 100, true)

        local function onRobberDeath(killer)
            if isElement(robber1) and isPedDead(robber1) and isElement(robber2) and isPedDead(robber2) then
                if isElement(killer) and getElementType(killer) == "player" then
                    Mzansi.Characters.addCash(killer, 15000)
                    Mzansi.Characters.addXP(killer, 500)
                    Mzansi.Util.sendNotification(killer, "Mission Complete! Received R 15,000 + 500 XP!", "success")
                end
                outputChatBox("[SAPS DISPATCH] 10-99: Robbery neutralized at " .. loc.name .. "!", root, 50, 255, 50)
                Mzansi.Activity.cleanupOldMissions()
            end
        end
        addEventHandler("onPedWasted", robber1, function(ammo, killer) onRobberDeath(killer) end)
        addEventHandler("onPedWasted", robber2, function(ammo, killer) onRobberDeath(killer) end)

        table.insert(Mzansi.Activity._activeMissions, { type = "robbery", blip = blip, marker = marker, peds = { robber1, robber2 } })

    elseif chosen == "ems_rescue" then
        local locations = {
            { name = "Idlewood Street Crossing",  x = 1960.0, y = -1750.0, z = 13.5 },
            { name = "Ganton Train Tracks",        x = 2300.0, y = -1650.0, z = 14.0 },
            { name = "Commerce Plaza",             x = 1450.0, y = -1700.0, z = 13.5 },
            { name = "Ocean Docks Warehouse",      x = -520.0, y = -490.0,  z = 25.5 },
        }
        local loc = locations[math.random(1, #locations)]

        outputChatBox("[EMS 911 DISPATCH] Priority 1: Medical Emergency at " .. loc.name .. "!", root, 50, 180, 255)
        outputChatBox("[Reward] R 8,500 + 350 XP for treating victim • Follow GREEN blip!", root, 50, 220, 100)

        local blip   = createBlip(loc.x, loc.y, loc.z, 22, 3, 50, 220, 100, 255, 0, 9999)
        local marker = createMarker(loc.x, loc.y, loc.z - 1.0, "cylinder", 3.0, 50, 220, 100, 180)
        local victim = createPed(14, loc.x, loc.y, loc.z, 90)
        setElementFrozen(victim, true)
        setPedAnimation(victim, "CRACK", "crckidle2", -1, true, false, false, false)

        addEventHandler("onMarkerHit", marker, function(hitEl, matching)
            if matching and getElementType(hitEl) == "player" and not isPedInVehicle(hitEl) then
                Mzansi.Characters.addCash(hitEl, 8500)
                Mzansi.Characters.addXP(hitEl, 350)
                Mzansi.Util.sendNotification(hitEl, "Patient stabilized! Received R 8,500 + 350 XP!", "success")
                outputChatBox("[EMS DISPATCH] Code 4: Patient rescued by " .. getPlayerName(hitEl) .. "!", root, 50, 255, 50)
                Mzansi.Activity.cleanupOldMissions()
            end
        end)

        table.insert(Mzansi.Activity._activeMissions, { type = "ems_rescue", blip = blip, marker = marker, peds = { victim } })

    elseif chosen == "drug_bust" then
        local locations = {
            { name = "Idlewood Alley Drug Lab",    x = 1975.0, y = -1800.0, z = 13.5 },
            { name = "Ganton Crack House",         x = 2270.0, y = -1660.0, z = 13.5 },
            { name = "East LS Stash House",        x = 2350.0, y = -1690.0, z = 13.5 },
        }
        local loc = locations[math.random(1, #locations)]

        outputChatBox("[SAPS NARCOTICS] Drug Bust near " .. loc.name .. " — Suspected lab in operation!", root, 200, 80, 255)
        outputChatBox("[Reward] R 20,000 + 700 XP | Eliminate dealers & secure the drugs!", root, 50, 220, 100)

        local blip   = createBlip(loc.x, loc.y, loc.z, 20, 3, 200, 50, 255, 255, 0, 9999)
        local marker = createMarker(loc.x, loc.y, loc.z - 1.0, "checkpoint", 5.0, 200, 50, 255, 150)

        local peds = {}
        for i = 1, 3 do
            local dealer = createPed(180, loc.x + math.random(-3, 3), loc.y + math.random(-3, 3), loc.z, math.random(0, 360))
            if dealer then
                giveWeapon(dealer, 31, 300, true)  -- M4
                table.insert(peds, dealer)
            end
        end

        local killed = 0
        local function onDealerKill(killer)
            killed = killed + 1
            if killed >= #peds then
                if isElement(killer) and getElementType(killer) == "player" then
                    Mzansi.Characters.addCash(killer, 20000)
                    Mzansi.Characters.addXP(killer, 700)
                    Mzansi.Util.sendNotification(killer, "Drug bust successful! R 20,000 + 700 XP seized!", "success")
                end
                outputChatBox("[SAPS NARCOTICS] Lab neutralized at " .. loc.name .. "! Area secured.", root, 200, 50, 255)
                Mzansi.Activity.cleanupOldMissions()
            end
        end
        for _, p in ipairs(peds) do
            addEventHandler("onPedWasted", p, function(ammo, killer) onDealerKill(killer) end)
        end

        table.insert(Mzansi.Activity._activeMissions, { type = "drug_bust", blip = blip, marker = marker, peds = peds })

    elseif chosen == "hostage" then
        local loc = { name = "Central Bank Lobby", x = 1462.0, y = -1020.0, z = 23.8 }

        outputChatBox("[SAPS SWAT] Active Hostage Situation — Bank robbery at " .. loc.name .. "!", root, 255, 190, 40)
        outputChatBox("[Reward] R 30,000 + 1,000 XP | Eliminate all threats & save hostages!", root, 50, 220, 100)

        local blip   = createBlip(loc.x, loc.y, loc.z, 20, 3, 255, 200, 0, 255, 0, 9999)
        local marker = createMarker(loc.x, loc.y, loc.z - 1.0, "checkpoint", 4.0, 255, 200, 0, 180)
        local peds   = {}

        for i = 1, 4 do
            local gunman = createPed(285, loc.x + math.random(-4, 4), loc.y + math.random(-4, 4), loc.z, math.random(0, 360))
            if gunman then
                giveWeapon(gunman, 29, 500, true)  -- MP5
                giveWeapon(gunman, 24, 200, true)  -- Deagle
                table.insert(peds, gunman)
            end
        end

        local killed = 0
        local function onGunmanKill(killer)
            killed = killed + 1
            if killed >= #peds then
                if isElement(killer) and getElementType(killer) == "player" then
                    Mzansi.Characters.addCash(killer, 30000)
                    Mzansi.Characters.addXP(killer, 1000)
                    Mzansi.Util.sendNotification(killer, "SWAT Mission Complete! R 30,000 + 1,000 XP! All hostages freed!", "success")
                end
                outputChatBox("[SAPS SWAT] All suspects neutralized at " .. loc.name .. ". Hostages safe.", root, 50, 255, 50)
                Mzansi.Activity.cleanupOldMissions()
            end
        end
        for _, p in ipairs(peds) do
            addEventHandler("onPedWasted", p, function(ammo, killer) onGunmanKill(killer) end)
        end

        table.insert(Mzansi.Activity._activeMissions, { type = "hostage", blip = blip, marker = marker, peds = peds })
    end
end

-- ==============================================================
-- GANG EVENTS (Drive-bys, Territory Wars)
-- ==============================================================
local GANG_FIGHT_ZONES = {
    -- Western Cape (Cape Town)
    { name = "Crazy Dragons vs Cape Flats 28s (Market District)", x = 1935.0,  y = -1608.0, z = 13.5 },
    { name = "SSK vs Cape Flats 28s (Idlewood Border)",           x = 2050.0,  y = -1722.0, z = 13.5 },
    -- KwaZulu-Natal (Durban)
    { name = "Zulu Warriors vs Port Smugglers (Durban Harbour)",  x = -1605.0, y = 155.0,   z = 10.5 },
    { name = "Zulu Warriors Hostel Turf War (Garcia Hostels)",    x = -2150.0, y = -240.0,  z = 36.5 },
    { name = "Golden Mile Beachfront Turf Clash (Ocean Flats)",   x = -2715.0, y = -325.0,  z = 7.5  },
    -- Gauteng (Johannesburg)
    { name = "Boere Mafia vs Nyau Dust Cartel (Redsands Crossing)", x = 2280.0, y = 1440.0, z = 11.5 },
    { name = "CIT Armoured Heist Clash (Egoli Gold Reef Strip)",    x = 2040.0, y = 1020.0, z = 10.8 },
    { name = "East Rand Mining Syndicate Feud (Rockshore Mines)",   x = 2545.0, y = 710.0,  z = 11.0 },
}

function Mzansi.Activity.generateGangEvent()
    if #getElementsByType("player") == 0 then return end

    local zone = GANG_FIGHT_ZONES[math.random(1, #GANG_FIGHT_ZONES)]

    outputChatBox("[GANG INTEL] Skirmish breaking out near " .. zone.name .. " — Stay clear or get involved!", root, 255, 160, 40)

    local gangA = {}
    local gangB = {}

    for i = 1, 3 do
        local g1 = createPed(math.random(100, 110), zone.x + math.random(-5, 0), zone.y + math.random(-3, 3), zone.z, 90)
        local g2 = createPed(math.random(180, 182), zone.x + math.random(1,  6), zone.y + math.random(-3, 3), zone.z, 270)
        if g1 then giveWeapon(g1, 28, 300, true) setElementData(g1, "mzansi:isNPC", false) table.insert(gangA, g1) end
        if g2 then giveWeapon(g2, 31, 200, true) setElementData(g2, "mzansi:isNPC", false) table.insert(gangB, g2) end
    end

    -- Angel: Skirmish Combat Director
    -- Orient combat targets between skirmishing factions
    for _, a in ipairs(gangA) do
        local b = gangB[math.random(1, #gangB)]
        if isElement(a) and isElement(b) then
            local ax, ay, az = getElementPosition(a)
            local tx, ty, tz = getElementPosition(b)
            local angle = (360 - math.deg(math.atan2(tx - ax, ty - ay))) % 360
            setPedRotation(a, angle)
            setPedAnimation(a, "RIFLE", "RIFLE_fire", -1, true, false, false, false)
        end
    end
    for _, b in ipairs(gangB) do
        local a = gangA[math.random(1, #gangA)]
        if isElement(a) and isElement(b) then
            local bx, by, bz = getElementPosition(b)
            local tx, ty, tz = getElementPosition(a)
            local angle = (360 - math.deg(math.atan2(tx - bx, ty - by))) % 360
            setPedRotation(b, angle)
            setPedAnimation(b, "COLT45", "colt45_fire", -1, true, false, false, false)
        end
    end

    -- Clean up gang fight after 90 seconds
    setTimer(function()
        for _, p in ipairs(gangA) do if isElement(p) then destroyElement(p) end end
        for _, p in ipairs(gangB) do if isElement(p) then destroyElement(p) end end
    end, 90000, 1)
end

-- ==============================================================
-- CIVILIAN EVENTS (Car Accidents, Street Performers, etc.)
-- ==============================================================
local CIVILIAN_EVENT_SPOTS = {
    { name = "Commerce Avenue",  x = 1490.0, y = -1720.0, z = 13.5 },
    { name = "Idlewood Corner",  x = 1970.0, y = -1740.0, z = 13.5 },
    { name = "Market Boulevard", x = 1600.0, y = -1590.0, z = 13.5 },
}

function Mzansi.Activity.generateCivilianEvent()
    if #getElementsByType("player") == 0 then return end

    local spot   = CIVILIAN_EVENT_SPOTS[math.random(1, #CIVILIAN_EVENT_SPOTS)]
    local events = { "accident", "street_performer", "mugging" }
    local chosen = events[math.random(1, #events)]

    if chosen == "accident" then
        outputChatBox("[LSFD] Vehicle accident reported at " .. spot.name .. ". EMS on the way.", root, 255, 200, 50)
        local victim = createPed(14, spot.x, spot.y, spot.z, 90)
        if victim then
            setElementFrozen(victim, true)
            setPedAnimation(victim, "CRACK", "crckidle2", -1, true, false, false, false)
            setTimer(function() if isElement(victim) then destroyElement(victim) end end, 60000, 1)
        end
    elseif chosen == "street_performer" then
        outputChatBox("[LS STREET LIFE] Street performer spotted at " .. spot.name .. "! Come check it out!", root, 100, 200, 255)
        local performer = createPed(math.random(8, 40), spot.x, spot.y, spot.z, 180)
        if performer then
            setPedAnimation(performer, "DANCING", "dnce_M_b", -1, true, false, false, false)
            setTimer(function() if isElement(performer) then destroyElement(performer) end end, 120000, 1)
        end
    elseif chosen == "mugging" then
        outputChatBox("[CRIME ALERT] Mugger spotted near " .. spot.name .. "! Citizens at risk!", root, 255, 100, 50)
        local mugger = createPed(29, spot.x + 2, spot.y, spot.z, 270)
        if mugger then
            giveWeapon(mugger, 5, 1, true) -- Knife
            setTimer(function() if isElement(mugger) then destroyElement(mugger) end end, 90000, 1)
        end
    end
end

-- ==============================================================
-- MISSION CLEANUP
-- ==============================================================
function Mzansi.Activity.cleanupOldMissions()
    for i = #Mzansi.Activity._activeMissions, 1, -1 do
        local m = Mzansi.Activity._activeMissions[i]
        if isElement(m.blip)   then destroyElement(m.blip) end
        if isElement(m.marker) then destroyElement(m.marker) end
        if m.peds then
            for _, p in ipairs(m.peds) do
                if isElement(p) then destroyElement(p) end
            end
        end
        table.remove(Mzansi.Activity._activeMissions, i)
    end
end

-- Legacy compat
function Mzansi.Activity.cleanupMission()
    Mzansi.Activity.cleanupOldMissions()
end

-- ==============================================================
-- STORE ROBBERY (/rob / /robstore)
-- ==============================================================
function Mzansi.Activity.startStoreRobbery(player)
    local char = Mzansi.Characters.getCharacter(player)
    if not char then return end

    local px, py, pz = getElementPosition(player)
    local targetClerk, targetClerkId = nil, nil

    for id, npc in pairs(Mzansi.Activity._npcs) do
        if isElement(npc) and getElementData(npc, "mzansi:npcType") == "clerk" then
            local nx, ny, nz = getElementPosition(npc)
            if getDistanceBetweenPoints3D(px, py, pz, nx, ny, nz) < 8.0 then
                targetClerk = npc
                targetClerkId = id
                break
            end
        end
    end

    if not targetClerk then
        Mzansi.Util.sendNotification(player, "You must be inside a 24/7 store near the cashier to initiate a robbery!", "error")
        return
    end

    if Mzansi.Activity._activeRobberies[targetClerkId] then
        Mzansi.Util.sendNotification(player, "This store was recently robbed! The register is empty.", "warning")
        return
    end

    Mzansi.Activity._activeRobberies[targetClerkId] = true
    setPedAnimation(targetClerk, "SHOP", "SHP_Rob_HandsUp", -1, false, false, false, true)

    outputChatBox("═══════════════════════════════════════════════════════", root, 255, 50, 50)
    outputChatBox("[POLICE ALARM] 10-31: Silent panic alarm triggered at 24/7 Supermarket!", root, 255, 50, 50)
    outputChatBox("[Suspect] Armed robbery in progress! All available SAPS officers respond!", root, 240, 240, 240)
    outputChatBox("═══════════════════════════════════════════════════════", root, 255, 50, 50)

    Mzansi.Util.sendNotification(player, "Robbery in progress! Hold your position for 20 seconds while bagging the cash!", "warning")
    setPlayerWantedLevel(player, 2)

    setTimer(function()
        if isElement(player) and isElement(targetClerk) then
            local loot = math.random(10000, 25000)
            Mzansi.Characters.addCash(player, loot)
            Mzansi.Characters.addXP(player, 400)
            Mzansi.Util.sendNotification(player, "Robbery Success! You bagged " .. Mzansi.Util.formatMoney(loot) .. "! Escape the police!", "success")
            setPedAnimation(targetClerk, "DEALER", "dealer_idle", -1, true, false, false, false)
        end
    end, 20000, 1)

    setTimer(function()
        Mzansi.Activity._activeRobberies[targetClerkId] = nil
    end, 300000, 1)
end

-- ==============================================================
-- HOP-IN VEHICLE JOB TRIGGER (Trucking & Taxi)
-- ==============================================================
addEventHandler("onPlayerVehicleEnter", root, function(vehicle, seat, jacked)
    if seat ~= 0 then return end
    local model = getElementModel(vehicle)
    if model == 403 or model == 515 or model == 455 or model == 514 then
        local char = Mzansi.Characters.getCharacter(source)
        if char then
            Mzansi.Characters.setJob(source, Mzansi.Enums.Job.TRUCKER)
            Mzansi.Util.sendNotification(source, "Trucking Route Activated! Type /route to start delivering cargo across SA!", "info")
        end
    elseif model == 420 or model == 438 then
        local char = Mzansi.Characters.getCharacter(source)
        if char then
            Mzansi.Characters.setJob(source, Mzansi.Enums.Job.TAXI)
            Mzansi.Util.sendNotification(source, "Taxi Transit Activated! Fare meter running. Type /fare for passenger calls.", "info")
        end
    end
end)

-- ==============================================================
-- NPC INTERACTION (Press E)
-- ==============================================================
addEvent("mzansi:activity:interactNPC", true)
addEventHandler("mzansi:activity:interactNPC", root, function(npcType)
    local player = client or source
    local char = Mzansi.Characters.getCharacter(player)
    if not char then return end

    if npcType == "police" or npcType == "police_guard" then
        Mzansi.World.togglePoliceDuty(player)
    elseif npcType == "doctor" or npcType == "ems_nurse" then
        setElementHealth(player, 100)
        setPedArmor(player, 50)
        Mzansi.Util.sendNotification(player, "Dr. Mthembu treated your injuries. HP: 100 | Armor: 50!", "success")
    elseif npcType == "jobs" then
        triggerClientEvent(player, "mzansi:dashboard:openJobs", player)
    elseif npcType == "clerk" then
        Mzansi.Util.sendNotification(player, "Store Clerk: Welcome to 24/7! Need something? (Type /rob to hold up the register!)", "info")
    elseif npcType == "arms" then
        giveWeapon(player, 22, 50, true)
        Mzansi.Util.sendNotification(player, "Johan: One 9mm pistol with ammo. Stay safe out there, bru!", "info")
    elseif npcType == "gang_ssk" then
        Mzansi.Util.sendNotification(player, "SSK OG: Ganton is South Side Kings territory. Cape Town lowriders run this block.", "info")
    elseif npcType == "gang_zw" then
        Mzansi.Util.sendNotification(player, "Brother Mandla: Sawubona! Zulu Warriors command Durban, the port, and Garcia Hostels. Respect KwaZulu!", "info")
    elseif npcType == "gang_cd" then
        Mzansi.Util.sendNotification(player, "Triad Sentry: Crazy Dragons run the Cape Town docks and market corridors. Step lightly.", "info")
    elseif npcType == "gang_28s" then
        Mzansi.Util.sendNotification(player, "General Chesa: Cape Flats 28s Numbers operate here. Don't play with the numbers.", "info")
    elseif npcType == "gang_bm" then
        Mzansi.Util.sendNotification(player, "Oubaas Van Der Merwe: This is Boere Mafia territory in Jozi. No monkey business on the Highveld, boet.", "info")
    elseif npcType == "gang_ndc" then
        Mzansi.Util.sendNotification(player, "El Patron Banda: Nyau Dust Cartel controls the Jozi fast-life and casino trade. Step correct.", "info")
    elseif npcType == "drug_dealer" then
        Mzansi.Util.sendNotification(player, "Dealer: Psst... you looking for something? Check /inventory or /buy.", "warning")
    elseif npcType == "fisherman" then
        Mzansi.Util.sendNotification(player, "Oom Piet: Lekker weather for fishing hey! Type /fish to start catching kingfish!", "info")
    elseif npcType == "trucker" then
        Mzansi.Util.sendNotification(player, "Driver: Hop in one of the trucks and type /route to start a cargo haul. Good money!", "info")
    elseif npcType == "mechanic" then
        local veh = getPedOccupiedVehicle(player)
        if veh then
            fixVehicle(veh)
            Mzansi.Util.sendNotification(player, "Mechanic Sipho: Fixed your vehicle! That'll be on the house, boss.", "success")
        else
            Mzansi.Util.sendNotification(player, "Mechanic Sipho: Drive your vehicle here and I'll fix her up!", "info")
        end
    elseif npcType == "bank_guard" then
        Mzansi.Util.sendNotification(player, "G4S Guard: This is Standard Bank premises. Security protocols are active at all times.", "info")
    elseif npcType == "civilian" then
        local responses = {
            "Howzit! Beautiful day in Los Santos, né?",
            "Watch yourself around Ganton, things are hectic over there.",
            "Did you hear about the robbery on Commerce? Eish...",
            "The cops have been cracking down on the gangs lately.",
            "You should visit the beach sometime, it's lekker this time of year!",
        }
        Mzansi.Util.sendNotification(player, "Civilian: " .. responses[math.random(1, #responses)], "info")
    end
end)

-- ==============================================================
-- COMMANDS
-- ==============================================================
addCommandHandler("rob", function(player) Mzansi.Activity.startStoreRobbery(player) end)
addCommandHandler("robstore", function(player) Mzansi.Activity.startStoreRobbery(player) end)
addCommandHandler("mission", function(player)
    Mzansi.Activity.generateEmergencyMission()
    Mzansi.Util.sendNotification(player, "New 911 Emergency Mission dispatched!", "info")
end)
-- /dispatch is owned by mzansi_saps (backup requests). The previous handler
-- here was a duplicate of /mission and double-fired with the SAPS command.
addCommandHandler("gangevent", function(player)
    Mzansi.Activity.generateGangEvent()
    Mzansi.Util.sendNotification(player, "Gang territorial event triggered!", "info")
end)
addCommandHandler("spawntraffic", function(player)
    Mzansi.Activity.spawnDynamicTraffic()
    Mzansi.Util.sendNotification(player, "Ambient traffic spawned!", "info")
end)

addEvent("mzansi:activity:requestMission", true)
addEventHandler("mzansi:activity:requestMission", root, function()
    local player = client or source
    Mzansi.Activity.generateEmergencyMission()
    if isElement(player) then
        Mzansi.Util.sendNotification(player, "New 911 Emergency Mission dispatched!", "info")
    end
end)

addEventHandler("onResourceStart", resourceRoot, function()
    Mzansi.Activity.init()
end)
