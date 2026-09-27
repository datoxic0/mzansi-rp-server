Mzansi = Mzansi or {}
Mzansi.VehicleShops = Mzansi.VehicleShops or {}

-- ==============================================================
-- PROVINCE VEHICLE DEALERSHIPS — mirrors shop_config province matrix
-- ==============================================================
Mzansi.VehicleShops.Locations = {
    { id = "vshop_ls_1", name = "Mzansi Auto — LS Downtown", province = "Los Santos", x = 2131.5, y = -1150.5, z = 24.0 },
    { id = "vshop_ls_2", name = "Ganton Motors", province = "Los Santos", x = 2244.5, y = -1665.5, z = 15.5 },
    { id = "vshop_ls_3", name = "Idlewood Autos", province = "Los Santos", x = 1950.0, y = -1450.0, z = 13.5 },
    { id = "vshop_sf_1", name = "San Fierro Auto Plaza", province = "San Fierro", x = -1675.5, y = 413.5, z = 7.2 },
    { id = "vshop_sf_2", name = "Doherty Motors", province = "San Fierro", x = -1448.5, y = -276.5, z = 14.2 },
    { id = "vshop_lv_1", name = "Las Venturas Motors", province = "Las Venturas", x = 2131.5, y = 943.5, z = 10.8 },
    { id = "vshop_lv_2", name = "Redsands Auto", province = "Las Venturas", x = 1975.5, y = 2162.5, z = 11.7 },
    { id = "vshop_rc_1", name = "Montgomery Vehicles", province = "Red County", x = 1450.5, y = 2775.5, z = 11.0 },
    { id = "vshop_tr_1", name = "Tierra Robada Autos", province = "Tierra Robada", x = -2225.5, y = 2325.5, z = 7.5 },
    { id = "vshop_bc_1", name = "Bone County Motors", province = "Bone County", x = 610.5, y = 1760.5, z = 12.5 },
    { id = "vshop_fc_1", name = "Flint County Auto", province = "Flint County", x = -216.5, y = 965.5, z = 19.5 },
    { id = "vshop_ws_1", name = "Whetstone Vehicles", province = "Whetstone", x = -2160.5, y = -235.5, z = 36.5 },
}

-- Spawn slots near each shop (3 slots) — offsets are small world deltas
Mzansi.VehicleShops.SpawnOffsets = {
    { dx = 8, dy = 0, rot = 0 },
    { dx = 8, dy = 6, rot = 0 },
    { dx = 8, dy = -6, rot = 0 },
}
