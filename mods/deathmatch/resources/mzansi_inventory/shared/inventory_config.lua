Mzansi = Mzansi or {}
Mzansi.Inventory = Mzansi.Inventory or {}
Mzansi.Inventory.Config = {}

Mzansi.Inventory.Config.MaxSlots = 20
Mzansi.Inventory.Config.MaxWeight = 50

Mzansi.Inventory.Config.Shops = {
    { name = "24/7", type = "convenience", items = { "bread", "water", "cola", "bandage", "phone" } },
    { name = "Ammu-Nation", type = "weapon", items = { "weapon_license" } },
    { name = "Hardware Store", type = "tool", items = { "repair_kit", "fishing_rod", "lockpick", "spray", "pc_toolkit", "mech_toolkit" } },
    { name = "Medical Center", type = "medical", items = { "bandage", "medkit" } },
}

Mzansi.Inventory.Config.ItemPrices = {
    ["bread"] = 50,
    ["water"] = 30,
    ["cola"] = 40,
    ["bandage"] = 200,
    ["medkit"] = 1000,
    ["lockpick"] = 5000,
    ["repair_kit"] = 2500,
    ["fishing_rod"] = 1500,
    ["radio"] = 800,
    ["spray"] = 300,
    ["pc_toolkit"] = 3500,
    ["mech_toolkit"] = 4500,
    ["logic_module"] = 1200,
    ["plc_basic"] = 3800,
    ["servo_kit"] = 5200,
}
