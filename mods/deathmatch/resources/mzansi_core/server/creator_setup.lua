-- ============================================================
-- MZANSI CREATOR MASTER ACCOUNT SETUP
-- Creates the default sovereign creator account with full access
-- Run once on first server start, then can be removed
-- ============================================================

Mzansi = Mzansi or {}
Mzansi.CreatorSetup = {}

local CREATOR_USERNAME = "Creator"
local CREATOR_PASSWORD = "MzansiCreator2026!Sovereign"
local CREATOR_EMAIL = "creator@mzansi.local"

function Mzansi.CreatorSetup.createCreatorAccount()
    if not Mzansi.Database._pool then
        outputDebugString("[CreatorSetup] Database not connected, waiting...", 2)
        setTimer(Mzansi.CreatorSetup.createCreatorAccount, 5000, 1)
        return
    end

    -- Check if creator account already exists
    local existing = Mzansi.Database.getAccount(CREATOR_USERNAME)
    if existing then
        -- Ensure it has max admin level and creator flag
        Mzansi.Database.update(
            "UPDATE mzansi_accounts SET admin_level = 10, banned = 0 WHERE username = ?",
            CREATOR_USERNAME
        )
        outputDebugString("[CreatorSetup] Creator account exists, updated to admin level 10 (Sovereign)")
        Mzansi.CreatorSetup.createCreatorCharacter(existing.id)
        return
    end

    -- Hash password using bcrypt (cost 10)
    local hash
    if passwordHash then
        hash = passwordHash(CREATOR_PASSWORD, "bcrypt", { cost = 10 })
    elseif sha256 then
        hash = sha256(CREATOR_PASSWORD .. CREATOR_USERNAME)
    else
        hash = md5(CREATOR_PASSWORD .. CREATOR_USERNAME)
    end

    -- Create the creator account with admin_level = 10 (Sovereign Creator)
    local accountId = Mzansi.Database.insert(
        "INSERT INTO mzansi_accounts (username, password_hash, email, serial, admin_level, banned) VALUES (?, ?, ?, ?, 10, 0)",
        CREATOR_USERNAME, hash, CREATOR_EMAIL, ""
    )

    if accountId then
        outputDebugString("[CreatorSetup] ==========================================")
        outputDebugString("[CreatorSetup] SOVEREIGN CREATOR ACCOUNT CREATED")
        outputDebugString("[CreatorSetup] Username: " .. CREATOR_USERNAME)
        outputDebugString("[CreatorSetup] Password: " .. CREATOR_PASSWORD)
        outputDebugString("[CreatorSetup] Admin Level: 10 (SOVEREIGN CREATOR)")
        outputDebugString("[CreatorSetup] Can create/manage other admins")
        outputDebugString("[CreatorSetup] Has full access to all systems")
        outputDebugString("[CreatorSetup] ==========================================")

        -- Create creator character
        Mzansi.CreatorSetup.createCreatorCharacter(accountId)
    else
        outputDebugString("[CreatorSetup] ERROR: Failed to create creator account!", 1)
    end
end

function Mzansi.CreatorSetup.createCreatorCharacter(accountId)
    -- Check if character already exists
    local existingChar = Mzansi.Database.query(
        "SELECT * FROM mzansi_characters WHERE account_id = ? LIMIT 1",
        accountId
    )

    if existingChar and #existingChar > 0 then
        -- Update existing character to be god-tier
        Mzansi.Database.update(
            "UPDATE mzansi_characters SET cash = 999999999, bank = 999999999, level = 100, job = 0, faction = 0 WHERE account_id = ?",
            accountId
        )
        outputDebugString("[CreatorSetup] Creator character updated to god-tier stats")
        return
    end

    -- Create the creator character with max stats
    local charId = Mzansi.Database.insert(
        "INSERT INTO mzansi_characters (account_id, first_name, last_name, age, gender, cash, bank, level, job, faction, spawn_x, spawn_y, spawn_z, spawn_rot, health, armor) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
        accountId,
        "Sovereign",
        "Creator",
        99,
        0,
        999999999,  -- cash
        999999999,  -- bank
        100,        -- level
        0,          -- job (unemployed but can do anything)
        0,          -- faction (civilian but sovereign)
        1682.5,     -- spawn_x (LS Airport)
        -2267.0,    -- spawn_y
        13.5,       -- spawn_z
        0,          -- spawn_rot
        100,        -- health
        100         -- armor
    )

    if charId then
        outputDebugString("[CreatorSetup] Creator character created with ID: " .. charId)
        outputDebugString("[CreatorSetup] Character has max cash, bank, level 100")
    end

    -- Give creator all licenses
    Mzansi.Database.update(
        "UPDATE mzansi_characters SET driver_license = 1, weapon_license = 1, fish_license = 1 WHERE id = ?",
        charId
    )

    -- Add starter inventory items for creator
    local creatorItems = {
        { "creator_tool", 1, "Admin creator tool - spawns anything" },
        { "admin_godmode", 1, "God mode toggle" },
        { "admin_noclip", 1, "No-clip mode" },
        { "vehicle_spawner", 1, "Spawn any vehicle" },
        { "teleport_gun", 1, "Teleport anywhere" },
        { "weather_controller", 1, "Control weather/time" },
    }

    for _, item in ipairs(creatorItems) do
        Mzansi.Database.insert(
            "INSERT INTO mzansi_inventory (owner_id, item_name, item_type, quantity, metadata) VALUES (?, ?, 0, ?, ?)",
            charId, item[1], item[2], item[3]
        )
    end
end

-- Auto-run on resource start (with delay to ensure DB is ready)
addEventHandler("onResourceStart", resourceRoot, function()
    setTimer(Mzansi.CreatorSetup.createCreatorAccount, 3000, 1)
end)

-- Command to manually trigger (admin only)
addCommandHandler("createcreator", function(player)
    if not isElement(player) then return end
    if not exports.mzansi_admin and not getElementData(player, "mzansi:creator") then
        outputChatBox("Only the server console can run this.", player, 255, 80, 80)
        return
    end
    Mzansi.CreatorSetup.createCreatorAccount()
    outputChatBox("Creator account setup triggered. Check server console.", player, 100, 255, 100)
end)