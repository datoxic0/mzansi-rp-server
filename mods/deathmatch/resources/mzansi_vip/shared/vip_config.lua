--[[
    Mzansi Roleplay - Ngamla (GQonqa) VIP & Monetization System
    Shared Configuration
]]

Mzansi = Mzansi or {}
Mzansi.VIP = {}

Mzansi.VIP.Config = {
    -- Slang & Cultural Nomenclature
    statusName = "Ngamla",
    cheatWord = "gqonqa",
    commandName = "gqonqa",
    tagPrefix = "[NGAMLA]",
    tagColorHex = "#FFD700", -- South African Gold

    -- Server Owner / Developer Serials for Sovereign Cheat & Creator Authorization
    ownerSerials = {
        ["5626CC6016B4B1E245C55BAF40161FF4"] = true, -- Server Owner
    },

    -- Master Passphrase fallback for creator verification
    masterPassphrase = "SovereignNgamla2026",

    -- VIP Tiers & Multipliers
    tiers = {
        [1] = {
            name = "Ngamla Bronze",
            color = { 205, 127, 50 },
            salaryMultiplier = 1.20,
            dailyGrant = 5000,
            vehicles = { 560, 579 }, -- Sultan, Huntley
            freeFlights = false,
            tollExempt = true
        },
        [2] = {
            name = "Ngamla Gold",
            color = { 255, 215, 0 },
            salaryMultiplier = 1.50,
            dailyGrant = 12000,
            vehicles = { 560, 579, 415, 487 }, -- Sultan, Huntley, Cheetah, Maverick Heli
            freeFlights = true,
            tollExempt = true
        },
        [3] = {
            name = "Ngamla Executive / Creator",
            color = { 255, 223, 0 },
            salaryMultiplier = 2.00,
            dailyGrant = 30000,
            vehicles = { 411, 579, 487, 560, 409, 415, 522 }, -- Infernus, Huntley VIP, Maverick, Sultan, Limo, Cheetah, NRG-500
            freeFlights = true,
            tollExempt = true,
            godmodeAllowed = true
        }
    },

    -- Quick Teleport Locations for Developer Mode
    teleports = {
        ["ct"] = { name = "Cape Town (LS) Civic Centre", x = 1481.0, y = -1768.0, z = 18.7, dim = 0 },
        ["dbn"] = { name = "Durban (SF) Golden Mile", x = -1985.0, y = 160.0, z = 27.6, dim = 0 },
        ["jhb"] = { name = "Johannesburg (LV) Gold Reef", x = 2028.0, y = 1008.0, z = 10.8, dim = 0 },
        ["vc"] = { name = "Vice City Coastal Expansion", x = -200.0, y = -1200.0, z = 10.0, dim = 10 },
        ["lc"] = { name = "Liberty City Freight Expansion", x = 1000.0, y = -500.0, z = 10.0, dim = 20 },
        ["island"] = { name = "Custom Offshore Island", x = 2904.0, y = -792.0, z = 11.0, dim = 0 },
        ["robben"] = { name = "Robben Island Outpost", x = 200.0, y = -3000.0, z = 5.0, dim = 30 }
    }
}
