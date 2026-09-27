-- ============================================================
-- MZANSI INTEL: CONFIG (God's Eye View inspired)
-- ============================================================

Mzansi = Mzansi or {}
Mzansi.Intel = Mzansi.Intel or {}

Mzansi.Intel.Config = {
    -- Detection / contacts
    contactRadius = 2500.0,        -- meters (mirrors GEV 2500m roster concept)
    refreshMs = 1500,
    maxContacts = 40,

    -- Aircraft classification (GTA SA plane model IDs)
    planeModels = {
        [511] = "Beagle", [512] = "Cropduster", [513] = "Stuntplane",
        [519] = "Shamal", [520] = "Hydra / F-35", [553] = "Nevada",
        [577] = "AT-400 / B737", [592] = "Andromada", [476] = "Rustler",
        [511] = "Beagle",
    },
    boatModels = {
        [430] = "Predator", [446] = "Squalo", [453] = "Speeder",
        [472] = "Coastguard", [473] = "Dinghy", [484] = "Kosatka Submarine",
        [493] = "Jetmax", [595] = "Tropic / Speed Yacht", [452] = "Submersible",
    },
    subModels = {
        [484] = "Kosatka Submarine", [452] = "Deep Sea Submersible",
    },
    heliModels = {
        [417] = "Leviathan", [425] = "Hunter", [447] = "Seasparrow",
        [469] = "Sparrow", [487] = "Maverick", [488] = "News Maverick",
        [497] = "Police Maverick", [548] = "Cargobob", [563] = "Raindance",
    },

    -- Access: admin_level >= this OR creator
    minAdminLevel = 1,

    -- HUD
    hudEnabledByDefault = false,
    showDetectionBoxes = true,
    showTrail = true,
}