-- Mzansi-ZA Player Management
-- Server-side player authentication, character selection, and spawn handling

local PlayerManager = class.new()
PlayerManager.__index = PlayerManager

function PlayerManager:constructor()
    self.players = {} -- playerElement -> playerData
    self.accounts = {} -- accountName -> accountData
    self.pendingLogins = {} -- playerElement -> {account, password, timestamp}
    self.spawnPoints = Enums.SpawnLocations
end

function PlayerManager:init()
    -- Register events
    addEvent(Enums.Events.SERVER_LOGIN, true)
    addEventHandler(Enums.Events.SERVER_LOGIN, root, function(...) self:onLoginRequest(source, ...) end)
    
    addEvent(Enums.Events.SERVER_REGISTER, true)
    addEventHandler(Enums.Events.SERVER_REGISTER, root, function(...) self:onRegisterRequest(source, ...) end)
    
    addEvent(Enums.Events.SERVER_SPAWN_REQUEST, true)
    addEventHandler(Enums.Events.SERVER_SPAWN_REQUEST, root, function(...) self:onSpawnRequest(source, ...) end)
    
    addEventHandler("onPlayerJoin", root, function() self:onPlayerJoin(source) end)
    addEventHandler("onPlayerQuit", root, function(...) self:onPlayerQuit(source, ...) end)
    addEventHandler("onPlayerLogin", root, function(...) self:onPlayerLogin(source, ...) end)
    addEventHandler("onPlayerLogout", root, function(...) self:onPlayerLogout(source, ...) end)
    
    Utils.logInfo("PlayerManager initialized")
end

-- Player Join - Initialize session
function PlayerManager:onPlayerJoin(player)
    Utils.debugPrint("Player joined:", getPlayerName(player))
    
    -- Set initial element data
    setElementData(player, Enums.ElementData.IS_LOGGED_IN, false)
    setElementData(player, Enums.ElementData.ACCOUNT_ID, nil)
    setElementData(player, Enums.ElementData.CHARACTER_ID, nil)
    setElementData(player, Enums.ElementData.CASH, 0)
    setElementData(player, Enums.ElementData.BANK, 0)
    setElementData(player, Enums.ElementData.FACTION, Enums.Factions.CIVILIAN)
    setElementData(player, Enums.ElementData.FACTION_RANK, 1)
    
    -- Initialize player session data
    self.players[player] = {
        account = nil,
        character = nil,
        isSpawned = false,
        joinTime = getTickCount(),
        afkTime = 0,
        lastPosition = {x = 0, y = 0, z = 0}
    }
    
    -- Fade camera for login screen
    fadeCamera(player, false, 0, 0, 0, 0)
    setCameraTarget(player, player)
    
    -- Trigger client to show login UI
    triggerClientEvent(player, Enums.Events.CLIENT_LOGIN, resourceRoot)
end

-- Player Quit - Save data and cleanup
function PlayerManager:onPlayerQuit(player, reason)
    local session = self.players[player]
    if session then
        -- Save character data if logged in
        if session.character then
            self:saveCharacterData(player, session.character)
            Utils.logInfo("Saved character data for " .. getPlayerName(player))
        end
        
        -- Log playtime
        local playtime = getTickCount() - session.joinTime
        Utils.logInfo(string.format("%s disconnected after %s (reason: %s)", 
            getPlayerName(player), Utils.formatTime(playtime), reason or "unknown"))
        
        self.players[player] = nil
    end
end

-- Player Login (MTA account system)
function PlayerManager:onPlayerLogin(player, account, autoLogin)
    if not account or isGuestAccount(account) then return end
    
    Utils.logInfo(getPlayerName(player) .. " logged into account: " .. getAccountName(account))
    
    -- Load account data
    local accountData = {
        id = getAccountData(account, "account_id") or 0,
        name = getAccountName(account),
        adminLevel = getAccountData(account, "admin_level") or 0,
        donatorLevel = getAccountData(account, "donator_level") or 0
    }
    
    local session = self.players[player]
    if session then
        session.account = accountData
        session.accountElement = account
    end
    
    setElementData(player, Enums.ElementData.ACCOUNT_ID, accountData.id)
    setElementData(player, Enums.ElementData.ACCOUNT_NAME, accountData.name)
    setElementData(player, Enums.ElementData.ADMIN_LEVEL, accountData.adminLevel)
    
    -- Update last login
    Database:execute("UPDATE accounts SET last_login = CURRENT_TIMESTAMP WHERE id = ?", {accountData.id})
    
    -- Trigger character selection
    self:loadCharactersForAccount(player, accountData.id)
end

function PlayerManager:onPlayerLogout(player, account)
    local session = self.players[player]
    if session and session.character then
        self:saveCharacterData(player, session.character)
        session.character = nil
    end
    
    setElementData(player, Enums.ElementData.IS_LOGGED_IN, false)
    setElementData(player, Enums.ElementData.CHARACTER_ID, nil)
    setElementData(player, Enums.ElementData.CASH, 0)
    setElementData(player, Enums.ElementData.BANK, 0)
    setElementData(player, Enums.ElementData.FACTION, Enums.Factions.CIVILIAN)
    
    -- Respawn at login screen
    fadeCamera(player, false, 0, 0, 0, 0)
    triggerClientEvent(player, Enums.Events.CLIENT_LOGOUT, resourceRoot)
end

-- Login Request from Client
function PlayerManager:onLoginRequest(player, username, password)
    -- Security: Validate client
    if not client or client ~= player then
        Utils.logWarning("Login spoof attempt from " .. getPlayerName(player))
        return
    end
    
    -- Rate limiting
    local now = getTickCount()
    if self.pendingLogins[player] and now - self.pendingLogins[player].timestamp < 5000 then
        triggerClientEvent(player, Enums.Events.CLIENT_NOTIFICATION, resourceRoot, 
            "Please wait before trying again", Enums.NotificationType.ERROR)
        return
    end
    
    self.pendingLogins[player] = {timestamp = now}
    
    -- Sanitize input
    username = Utils.sanitizeInput(username, 32)
    password = Utils.sanitizeInput(password, 64)
    
    if #username < 3 or #password < 4 then
        triggerClientEvent(player, Enums.Events.CLIENT_NOTIFICATION, resourceRoot, 
            "Invalid username or password", Enums.NotificationType.ERROR)
        return
    end
    
    -- Check if account exists
    Database:query("SELECT * FROM accounts WHERE username = ?", {username}, function(result)
        if not isElement(player) then return end
        
        if result and #result > 0 then
            local account = result[1]
            
            -- Verify password (bcrypt)
            if passwordVerify(password, account.password_hash) then
                -- Check ban status
                if account.is_banned == 1 then
                    triggerClientEvent(player, Enums.Events.CLIENT_NOTIFICATION, resourceRoot, 
                        "Account banned: " .. (account.ban_reason or "No reason given"), Enums.NotificationType.ERROR)
                    return
                end
                
                -- Check serial if enabled
                local playerSerial = getPlayerSerial(player)
                if account.serial and account.serial ~= "" and account.serial ~= playerSerial then
                    triggerClientEvent(player, Enums.Events.CLIENT_NOTIFICATION, resourceRoot, 
                        "Account serial mismatch. Contact admin.", Enums.NotificationType.ERROR)
                    return
                end
                
                -- Log in to MTA account system
                local mtaAccount = getAccount(username, password)
                if mtaAccount then
                    logIn(player, mtaAccount, password)
                else
                    -- Create MTA account if doesn't exist
                    mtaAccount = addAccount(username, password)
                    if mtaAccount then
                        setAccountData(mtaAccount, "account_id", account.id)
                        setAccountData(mtaAccount, "admin_level", account.admin_level)
                        setAccountData(mtaAccount, "donator_level", account.donator_level)
                        logIn(player, mtaAccount, password)
                    end
                end
            else
                triggerClientEvent(player, Enums.Events.CLIENT_NOTIFICATION, resourceRoot, 
                    "Invalid password", Enums.NotificationType.ERROR)
                -- Log failed attempt
                Database:execute("INSERT INTO logs (type, actor_id, action, details, ip) VALUES (?, ?, ?, ?, ?)", 
                    {"security", account.id, "failed_login", "Invalid password", getPlayerIP(player)})
            end
        else
            triggerClientEvent(player, Enums.Events.CLIENT_NOTIFICATION, resourceRoot, 
                "Account not found", Enums.NotificationType.ERROR)
        end
    end)
end

-- Register Request from Client
function PlayerManager:onRegisterRequest(player, username, password, email)
    -- Security: Validate client
    if not client or client ~= player then
        Utils.logWarning("Register spoof attempt from " .. getPlayerName(player))
        return
    end
    
    -- Sanitize input
    username = Utils.sanitizeInput(username, 32)
    password = Utils.sanitizeInput(password, 64)
    email = Utils.sanitizeInput(email or "", 128)
    
    -- Validation
    if #username < 3 then
        triggerClientEvent(player, Enums.Events.CLIENT_NOTIFICATION, resourceRoot, 
            "Username must be at least 3 characters", Enums.NotificationType.ERROR)
        return
    end
    
    if #password < 6 then
        triggerClientEvent(player, Enums.Events.CLIENT_NOTIFICATION, resourceRoot, 
            "Password must be at least 6 characters", Enums.NotificationType.ERROR)
        return
    end
    
    if email ~= "" and not Utils.isValidEmail(email) then
        triggerClientEvent(player, Enums.Events.CLIENT_NOTIFICATION, resourceRoot, 
            "Invalid email format", Enums.NotificationType.ERROR)
        return
    end
    
    -- Check if username exists
    Database:query("SELECT id FROM accounts WHERE username = ?", {username}, function(result)
        if not isElement(player) then return end
        
        if result and #result > 0 then
            triggerClientEvent(player, Enums.Events.CLIENT_NOTIFICATION, resourceRoot, 
                "Username already taken", Enums.NotificationType.ERROR)
            return
        end
        
        -- Hash password with bcrypt
        local passwordHash = passwordHash(password, "bcrypt", {})
        
        -- Insert account
        Database:execute("INSERT INTO accounts (username, password_hash, email, serial, ip) VALUES (?, ?, ?, ?, ?)", 
            {username, passwordHash, email, getPlayerSerial(player), getPlayerIP(player)}, function(success, lastId)
            if not isElement(player) then return end
            
            if success then
                Utils.logInfo("New account registered: " .. username .. " (ID: " .. lastId .. ")")
                triggerClientEvent(player, Enums.Events.CLIENT_NOTIFICATION, resourceRoot, 
                    "Account created successfully! Please login.", Enums.NotificationType.SUCCESS)
                
                -- Log registration
                Database:execute("INSERT INTO logs (type, actor_id, action, details, ip) VALUES (?, ?, ?, ?, ?)", 
                    {"account", lastId, "register", "New account registered", getPlayerIP(player)})
            else
                triggerClientEvent(player, Enums.Events.CLIENT_NOTIFICATION, resourceRoot, 
                    "Registration failed. Try again.", Enums.NotificationType.ERROR)
            end
        end)
    end)
end

-- Load characters for account
function PlayerManager:loadCharactersForAccount(player, accountId)
    Database:query("SELECT * FROM characters WHERE account_id = ? ORDER BY last_seen DESC", {accountId}, function(result)
        if not isElement(player) then return end
        
        local characters = result or {}
        
        -- Send character list to client
        triggerClientEvent(player, "mzansi:characterList", resourceRoot, characters)
    end)
end

-- Character Selection/Spawn Request
function PlayerManager:onSpawnRequest(player, characterId, spawnLocation)
    -- Security: Validate client
    if not client or client ~= player then
        Utils.logWarning("Spawn spoof attempt from " .. getPlayerName(player))
        return
    end
    
    local session = self.players[player]
    if not session or not session.account then
        triggerClientEvent(player, Enums.Events.CLIENT_NOTIFICATION, resourceRoot, 
            "Not logged in", Enums.NotificationType.ERROR)
        return
    end
    
    -- Load character data
    Database:query("SELECT * FROM characters WHERE id = ? AND account_id = ?", {characterId, session.account.id}, function(result)
        if not isElement(player) then return end
        
        if result and #result > 0 then
            local character = result[1]
            self:spawnCharacter(player, character, spawnLocation)
        else
            triggerClientEvent(player, Enums.Events.CLIENT_NOTIFICATION, resourceRoot, 
                "Character not found", Enums.NotificationType.ERROR)
        end
    end)
end

-- Spawn character in world
function PlayerManager:spawnCharacter(player, character, spawnLocation)
    local session = self.players[player]
    
    -- Determine spawn position
    local spawn = spawnLocation and self.spawnPoints[spawnLocation] or self.spawnPoints.JOHANNESBURG_CITY_HALL
    if character.pos_x and character.pos_x ~= 0 then
        spawn = {x = character.pos_x, y = character.pos_y, z = character.pos_z, rot = character.pos_rot, 
                 interior = character.interior, dimension = character.dimension}
    end
    
    -- Spawn player
    spawnPlayer(player, spawn.x, spawn.y, spawn.z, spawn.rot, character.skin, spawn.interior, spawn.dimension)
    fadeCamera(player, true)
    setCameraTarget(player, player)
    
    -- Set element data
    setElementData(player, Enums.ElementData.IS_LOGGED_IN, true)
    setElementData(player, Enums.ElementData.CHARACTER_ID, character.id)
    setElementData(player, Enums.ElementData.CHARACTER_NAME, character.name)
    setElementData(player, Enums.ElementData.CASH, character.cash)
    setElementData(player, Enums.ElementData.BANK, character.bank)
    setElementData(player, Enums.ElementData.FACTION, character.faction)
    setElementData(player, Enums.ElementData.FACTION_RANK, character.faction_rank)
    setElementData(player, Enums.ElementData.PHONE_NUMBER, character.phone_number)
    setElementData(player, Enums.ElementData.WANTED_LEVEL, character.wanted_level)
    
    -- Update session
    session.character = character
    session.isSpawned = true
    session.lastPosition = {x = spawn.x, y = spawn.y, z = spawn.z}
    
    -- Update character online status
    Database:execute("UPDATE characters SET is_online = 1, last_seen = CURRENT_TIMESTAMP WHERE id = ?", {character.id})
    
    -- Trigger client spawn event
    triggerClientEvent(player, Enums.Events.CLIENT_SPAWN, resourceRoot, character, spawn)
    
    -- Load player's vehicles
    self:loadPlayerVehicles(player, character.id)
    
    -- Trigger payday timer if needed
    self:checkPayday(player, character)
    
    Utils.logInfo(string.format("%s spawned as %s (ID: %d) at %.1f, %.1f, %.1f", 
        getPlayerName(player), character.name, character.id, spawn.x, spawn.y, spawn.z))
end

-- Save character data
function PlayerManager:saveCharacterData(player, character)
    if not character or not character.id then return end
    
    local x, y, z = getElementPosition(player)
    local _, _, rot = getElementRotation(player)
    local interior = getElementInterior(player)
    local dimension = getElementDimension(player)
    local cash = getElementData(player, Enums.ElementData.CASH) or character.cash
    local bank = getElementData(player, Enums.ElementData.BANK) or character.bank
    local faction = getElementData(player, Enums.ElementData.FACTION) or character.faction
    local factionRank = getElementData(player, Enums.ElementData.FACTION_RANK) or character.faction_rank
    local wantedLevel = getElementData(player, Enums.ElementData.WANTED_LEVEL) or character.wanted_level
    
    Database:execute([[
        UPDATE characters SET 
            cash = ?, bank = ?, faction = ?, faction_rank = ?,
            pos_x = ?, pos_y = ?, pos_z = ?, pos_rot = ?,
            interior = ?, dimension = ?, wanted_level = ?,
            last_seen = CURRENT_TIMESTAMP
        WHERE id = ?
    ]], {cash, bank, faction, factionRank, x, y, z, rot, interior, dimension, wantedLevel, character.id})
end

-- Load player vehicles
function PlayerManager:loadPlayerVehicles(player, characterId)
    Database:query("SELECT * FROM vehicles WHERE character_id = ? AND is_impounded = 0", {characterId}, function(result)
        if not isElement(player) then return end
        
        local vehicles = result or {}
        triggerClientEvent(player, "mzansi:vehicleList", resourceRoot, vehicles)
    end)
end

-- Check payday
function PlayerManager:checkPayday(player, character)
    local playtime = character.playtime or 0
    -- Payday logic handled by separate timer
end

-- Create new character
function PlayerManager:createCharacter(player, name, skin, spawnLocation)
    if not client or client ~= player then return end
    
    local session = self.players[player]
    if not session or not session.account then return end
    
    -- Validate name
    name = Utils.sanitizeInput(name, 24)
    if #name < 3 then
        triggerClientEvent(player, Enums.Events.CLIENT_NOTIFICATION, resourceRoot, 
            "Name too short", Enums.NotificationType.ERROR)
        return
    end
    
    -- Check name availability
    Database:query("SELECT id FROM characters WHERE name = ?", {name}, function(result)
        if not isElement(player) then return end
        
        if result and #result > 0 then
            triggerClientEvent(player, Enums.Events.CLIENT_NOTIFICATION, resourceRoot, 
                "Name already taken", Enums.NotificationType.ERROR)
            return
        end
        
        -- Validate skin
        skin = tonumber(skin) or 0
        if skin < 0 or skin > 312 then skin = 0 end
        
        -- Get spawn
        local spawn = self.spawnPoints[spawnLocation] or self.spawnPoints.JOHANNESBURG_CITY_HALL
        
        -- Generate phone number
        local phoneNumber = Utils.randomPhoneNumber()
        
        -- Create character
        Database:execute([[
            INSERT INTO characters (account_id, name, skin, cash, bank, faction, faction_rank,
                pos_x, pos_y, pos_z, pos_rot, interior, dimension, phone_number)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ]], {session.account.id, name, skin, Enums.Economy.STARTING_CASH, Enums.Economy.STARTING_BANK,
            Enums.Factions.CIVILIAN, 1, spawn.x, spawn.y, spawn.z, spawn.rot, spawn.interior, spawn.dimension, phoneNumber},
            function(success, lastId)
                if not isElement(player) then return end
                
                if success then
                    Utils.logInfo("Character created: " .. name .. " (ID: " .. lastId .. ") for account " .. session.account.name)
                    triggerClientEvent(player, Enums.Events.CLIENT_NOTIFICATION, resourceRoot, 
                        "Character created!", Enums.NotificationType.SUCCESS)
                    
                    -- Reload character list
                    self:loadCharactersForAccount(player, session.account.id)
                else
                    triggerClientEvent(player, Enums.Events.CLIENT_NOTIFICATION, resourceRoot, 
                        "Failed to create character", Enums.NotificationType.ERROR)
                end
            end)
    end)
end

-- Delete character
function PlayerManager:deleteCharacter(player, characterId)
    if not client or client ~= player then return end
    
    local session = self.players[player]
    if not session or not session.account then return end
    
    Database:execute("DELETE FROM characters WHERE id = ? AND account_id = ?", {characterId, session.account.id}, function(success)
        if not isElement(player) then return end
        
        if success then
            triggerClientEvent(player, Enums.Events.CLIENT_NOTIFICATION, resourceRoot, 
                "Character deleted", Enums.NotificationType.SUCCESS)
            self:loadCharactersForAccount(player, session.account.id)
        else
            triggerClientEvent(player, Enums.Events.CLIENT_NOTIFICATION, resourceRoot, 
                "Failed to delete character", Enums.NotificationType.ERROR)
        end
    end)
end

-- Get player session data
function PlayerManager:getSession(player)
    return self.players[player]
end

function PlayerManager:getCharacter(player)
    local session = self.players[player]
    return session and session.character or nil
end

function PlayerManager:getAccount(player)
    local session = self.players[player]
    return session and session.account or nil
end

-- Check if player is logged in and spawned
function PlayerManager:isPlayerSpawned(player)
    local session = self.players[player]
    return session and session.isSpawned == true
end

-- Global instance
_G.PlayerManager = PlayerManager:new()

return PlayerManager