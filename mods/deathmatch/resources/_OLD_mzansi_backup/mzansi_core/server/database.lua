-- Mzansi-ZA Database Layer
-- Asynchronous database operations with SQLite/MySQL support

local Database = class.new()
Database.__index = Database

function Database:constructor()
    self.connection = nil
    self.dbType = "sqlite"
    self.queryQueue = {}
    self.isConnected = false
    self.config = {}
end

function Database:connect(config)
    self.config = config or {}
    self.dbType = self.config.db_type or "sqlite"
    
    local connectionString
    if self.dbType == "mysql" then
        local host = self.config.db_host or "localhost"
        local port = self.config.db_port or 3306
        local name = self.config.db_name or "mzansi_za"
        local user = self.config.db_user or "root"
        local pass = self.config.db_pass or ""
        connectionString = string.format("mysql://%s:%s@%s:%d/%s", user, pass, host, port, name)
    else
        connectionString = "sqlite://mzansi_za.db"
    end
    
    self.connection = dbConnect(connectionString)
    
    if not self.connection then
        Utils.logError("Failed to connect to database: " .. connectionString)
        return false
    end
    
    self.isConnected = true
    Utils.logInfo("Database connected: " .. self.dbType)
    
    -- Initialize schema
    self:initializeSchema()
    
    return true
end

function Database:initializeSchema()
    local schemaQueries = {
        -- Accounts table
        [[CREATE TABLE IF NOT EXISTS accounts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE NOT NULL,
            password_hash TEXT NOT NULL,
            email TEXT,
            serial TEXT,
            ip TEXT,
            admin_level INTEGER DEFAULT 0,
            donator_level INTEGER DEFAULT 0,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            last_login DATETIME,
            is_banned INTEGER DEFAULT 0,
            ban_reason TEXT
        )]],
        
        -- Characters table
        [[CREATE TABLE IF NOT EXISTS characters (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            account_id INTEGER NOT NULL,
            name TEXT UNIQUE NOT NULL,
            skin INTEGER DEFAULT 0,
            cash INTEGER DEFAULT 5000,
            bank INTEGER DEFAULT 10000,
            faction INTEGER DEFAULT 1,
            faction_rank INTEGER DEFAULT 1,
            pos_x REAL DEFAULT 1520.0,
            pos_y REAL DEFAULT -1520.0,
            pos_z REAL DEFAULT 13.5,
            pos_rot REAL DEFAULT 0.0,
            interior INTEGER DEFAULT 0,
            dimension INTEGER DEFAULT 0,
            phone_number TEXT,
            wanted_level INTEGER DEFAULT 0,
            playtime INTEGER DEFAULT 0,
            last_seen DATETIME DEFAULT CURRENT_TIMESTAMP,
            is_online INTEGER DEFAULT 0,
            FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE
        )]],
        
        -- Vehicles table
        [[CREATE TABLE IF NOT EXISTS vehicles (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            character_id INTEGER NOT NULL,
            model INTEGER NOT NULL,
            plate TEXT UNIQUE NOT NULL,
            color1 INTEGER DEFAULT 0,
            color2 INTEGER DEFAULT 0,
            paintjob INTEGER DEFAULT 3,
            upgrades TEXT DEFAULT '[]',
            pos_x REAL DEFAULT 0,
            pos_y REAL DEFAULT 0,
            pos_z REAL DEFAULT 0,
            pos_rot REAL DEFAULT 0,
            interior INTEGER DEFAULT 0,
            dimension INTEGER DEFAULT 0,
            health REAL DEFAULT 1000,
            fuel REAL DEFAULT 100,
            mileage REAL DEFAULT 0,
            is_locked INTEGER DEFAULT 1,
            is_impounded INTEGER DEFAULT 0,
            purchase_price INTEGER DEFAULT 0,
            purchase_date DATETIME DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (character_id) REFERENCES characters(id) ON DELETE CASCADE
        )]],
        
        -- Properties table
        [[CREATE TABLE IF NOT EXISTS properties (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            character_id INTEGER,
            name TEXT NOT NULL,
            type TEXT NOT NULL, -- house, apartment, business, garage
            interior_id INTEGER NOT NULL,
            entrance_x REAL NOT NULL,
            entrance_y REAL NOT NULL,
            entrance_z REAL NOT NULL,
            entrance_rot REAL DEFAULT 0,
            price INTEGER NOT NULL,
            rent INTEGER DEFAULT 0,
            is_for_sale INTEGER DEFAULT 0,
            is_for_rent INTEGER DEFAULT 0,
            locked INTEGER DEFAULT 1,
            FOREIGN KEY (character_id) REFERENCES characters(id) ON DELETE SET NULL
        )]],
        
        -- Factions table
        [[CREATE TABLE IF NOT EXISTS factions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT UNIQUE NOT NULL,
            type INTEGER NOT NULL, -- matches Enums.Factions
            leader_id INTEGER,
            bank INTEGER DEFAULT 0,
            motd TEXT DEFAULT '',
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (leader_id) REFERENCES characters(id) ON DELETE SET NULL
        )]],
        
        -- Faction members
        [[CREATE TABLE IF NOT EXISTS faction_members (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            faction_id INTEGER NOT NULL,
            character_id INTEGER NOT NULL,
            rank INTEGER DEFAULT 1,
            joined_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (faction_id) REFERENCES factions(id) ON DELETE CASCADE,
            FOREIGN KEY (character_id) REFERENCES characters(id) ON DELETE CASCADE,
            UNIQUE(faction_id, character_id)
        )]],
        
        -- Inventory table
        [[CREATE TABLE IF NOT EXISTS inventory (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            character_id INTEGER NOT NULL,
            item_id TEXT NOT NULL,
            item_name TEXT NOT NULL,
            quantity INTEGER DEFAULT 1,
            metadata TEXT DEFAULT '{}',
            slot INTEGER DEFAULT 0,
            FOREIGN KEY (character_id) REFERENCES characters(id) ON DELETE CASCADE
        )]],
        
        -- Logs table
        [[CREATE TABLE IF NOT EXISTS logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT NOT NULL, -- admin, chat, transaction, faction, vehicle, property
            actor_id INTEGER,
            target_id INTEGER,
            action TEXT NOT NULL,
            details TEXT,
            ip TEXT,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )]],
        
        -- Bans table
        [[CREATE TABLE IF NOT EXISTS bans (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            serial TEXT,
            ip TEXT,
            account_id INTEGER,
            reason TEXT NOT NULL,
            banned_by INTEGER,
            banned_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            expires_at DATETIME,
            is_permanent INTEGER DEFAULT 0,
            FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE SET NULL,
            FOREIGN KEY (banned_by) REFERENCES accounts(id) ON DELETE SET NULL
        )]],
        
        -- Settings table
        [[CREATE TABLE IF NOT EXISTS settings (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL,
            description TEXT
        )]],
        
        -- Indexes for performance
        "CREATE INDEX IF NOT EXISTS idx_characters_account ON characters(account_id)",
        "CREATE INDEX IF NOT EXISTS idx_characters_name ON characters(name)",
        "CREATE INDEX IF NOT EXISTS idx_vehicles_character ON vehicles(character_id)",
        "CREATE INDEX IF NOT EXISTS idx_vehicles_plate ON vehicles(plate)",
        "CREATE INDEX IF NOT EXISTS idx_properties_character ON properties(character_id)",
        "CREATE INDEX IF NOT EXISTS idx_faction_members_faction ON faction_members(faction_id)",
        "CREATE INDEX IF NOT EXISTS idx_faction_members_character ON faction_members(character_id)",
        "CREATE INDEX IF NOT EXISTS idx_inventory_character ON inventory(character_id)",
        "CREATE INDEX IF NOT EXISTS idx_logs_type ON logs(type)",
        "CREATE INDEX IF NOT EXISTS idx_logs_actor ON logs(actor_id)",
        "CREATE INDEX IF NOT EXISTS idx_bans_serial ON bans(serial)",
        "CREATE INDEX IF NOT EXISTS idx_bans_ip ON bans(ip)"
    }
    
    for _, query in ipairs(schemaQueries) do
        self:exec(query)
    end
    
    -- Insert default factions if they don't exist
    self:initializeDefaultFactions()
    
    Utils.logInfo("Database schema initialized")
end

function Database:initializeDefaultFactions()
    local factions = {
        { name = "South African Police Service", type = Enums.Factions.SAPS, bank = 1000000, motd = "Serve and Protect" },
        { name = "Johannesburg Metro Police Department", type = Enums.Factions.METRO_POLICE, bank = 500000, motd = "Keeping Jozi Safe" },
        { name = "Emergency Medical Services", type = Enums.Factions.EMS, bank = 300000, motd = "Saving Lives" },
        { name = "Taxi Association", type = Enums.Factions.TAXI_ASSOCIATION, bank = 200000, motd = "Moving South Africa" }
    }
    
    for _, faction in ipairs(factions) do
        self:query(
            "INSERT OR IGNORE INTO factions (name, type, bank, motd) VALUES (?, ?, ?, ?)",
            { faction.name, faction.type, faction.bank, faction.motd }
        )
    end
end

-- Asynchronous query with callback
function Database:query(sql, params, callback)
    if not self.isConnected then
        Utils.logError("Database not connected")
        if callback then callback(nil, "Database not connected") end
        return
    end
    
    local function dbCallback(qh)
        local result, numRows, lastInsertId = dbPoll(qh, 0)
        if callback then
            callback(result, nil, numRows, lastInsertId)
        end
    end
    
    if params then
        dbQuery(dbCallback, {sql, params}, self.connection)
    else
        dbQuery(dbCallback, {sql}, self.connection)
    end
end

-- Synchronous exec (for schema/init only)
function Database:exec(sql, params)
    if not self.isConnected then return false end
    
    if params then
        return dbExec(self.connection, sql, unpack(params))
    else
        return dbExec(self.connection, sql)
    end
end

-- Prepared statement helpers
function Database:select(sql, params, callback)
    self:query(sql, params, callback)
end

function Database:insert(sql, params, callback)
    self:query(sql, params, function(result, err, numRows, lastInsertId)
        if callback then callback(lastInsertId, err) end
    end)
end

function Database:update(sql, params, callback)
    self:query(sql, params, function(result, err, numRows)
        if callback then callback(numRows, err) end
    end)
end

function Database:delete(sql, params, callback)
    self:query(sql, params, function(result, err, numRows)
        if callback then callback(numRows, err) end
    end)
end

-- Transaction support
function Database:transaction(callback)
    if not self.isConnected then
        if callback then callback(false, "Database not connected") end
        return
    end
    
    local success = dbExec(self.connection, "BEGIN TRANSACTION")
    if not success then
        if callback then callback(false, "Failed to start transaction") end
        return
    end
    
    local function commit()
        dbExec(self.connection, "COMMIT")
        if callback then callback(true) end
    end
    
    local function rollback(err)
        dbExec(self.connection, "ROLLBACK")
        if callback then callback(false, err) end
    end
    
    -- Return transaction object
    return {
        query = function(self, sql, params, cb)
            self:query(sql, params, function(result, err, ...)
                if err then
                    rollback(err)
                else
                    if cb then cb(result, err, ...) end
                end
            end)
        end,
        commit = commit,
        rollback = rollback
    }
end

-- Account methods
function Database:createAccount(username, passwordHash, email, serial, ip, callback)
    local sql = [[
        INSERT INTO accounts (username, password_hash, email, serial, ip, created_at)
        VALUES (?, ?, ?, ?, ?, datetime('now'))
    ]]
    self:insert(sql, {username, passwordHash, email, serial, ip}, callback)
end

function Database:getAccountByUsername(username, callback)
    self:select("SELECT * FROM accounts WHERE username = ?", {username}, function(result, err)
        if callback then callback(result and result[1] or nil, err) end
    end)
end

function Database:getAccountBySerial(serial, callback)
    self:select("SELECT * FROM accounts WHERE serial = ?", {serial}, function(result, err)
        if callback then callback(result and result[1] or nil, err) end
    end
)

function Database:updateLastLogin(accountId, callback)
    self:update("UPDATE accounts SET last_login = datetime('now') WHERE id = ?", {accountId}, callback)
end

function Database:setAdminLevel(accountId, level, callback)
    self:update("UPDATE accounts SET admin_level = ? WHERE id = ?", {level, accountId}, callback)
end

-- Character methods
function Database:createCharacter(accountId, name, skin, callback)
    local sql = [[
        INSERT INTO characters (account_id, name, skin, cash, bank, faction, faction_rank, 
                               pos_x, pos_y, pos_z, pos_rot, phone_number)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ]]
    local params = {accountId, name, skin or 0, Enums.Economy.STARTING_CASH, Enums.Economy.STARTING_BANK,
                    Enums.Factions.CIVILIAN, 1, 
                    Enums.SpawnLocations.JOHANNESBURG_CITY_HALL.x,
                    Enums.SpawnLocations.JOHANNESBURG_CITY_HALL.y,
                    Enums.SpawnLocations.JOHANNESBURG_CITY_HALL.z,
                    Enums.SpawnLocations.JOHANNESBURG_CITY_HALL.rot,
                    Utils.randomPhoneNumber()}
    self:insert(sql, params, callback)
end

function Database:getCharactersByAccount(accountId, callback)
    self:select("SELECT * FROM characters WHERE account_id = ? AND is_online = 0", {accountId}, callback)
end

function Database:getCharacterById(characterId, callback)
    self:select("SELECT * FROM characters WHERE id = ?", {characterId}, function(result, err)
        if callback then callback(result and result[1] or nil, err) end
    end)
end

function Database:getCharacterByName(name, callback)
    self:select("SELECT * FROM characters WHERE name = ?", {name}, function(result, err)
        if callback then callback(result and result[1] or nil, err) end
    end)
end

function Database:updateCharacter(characterId, data, callback)
    local setParts = {}
    local params = {}
    
    for key, value in pairs(data) do
        table.insert(setParts, key .. " = ?")
        table.insert(params, value)
    end
    
    if #setParts == 0 then
        if callback then callback(0) end
        return
    end
    
    table.insert(params, characterId)
    local sql = "UPDATE characters SET " .. table.concat(setParts, ", ") .. " WHERE id = ?"
    self:update(sql, params, callback)
end

function Database:setCharacterOnline(characterId, online, callback)
    self:update("UPDATE characters SET is_online = ?, last_seen = datetime('now') WHERE id = ?", 
                {online and 1 or 0, characterId}, callback)
end

function Database:addPlaytime(characterId, minutes, callback)
    self:update("UPDATE characters SET playtime = playtime + ? WHERE id = ?", {minutes, characterId}, callback)
end

-- Vehicle methods
function Database:createVehicle(characterId, model, plate, color1, color2, price, callback)
    local sql = [[
        INSERT INTO vehicles (character_id, model, plate, color1, color2, purchase_price, 
                             pos_x, pos_y, pos_z, pos_rot)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ]]
    -- Default spawn at character position or city hall
    local spawn = Enums.SpawnLocations.JOHANNESBURG_CITY_HALL
    local params = {characterId, model, plate, color1 or 0, color2 or 0, price or 0,
                    spawn.x, spawn.y, spawn.z, spawn.rot}
    self:insert(sql, params, callback)
end

function Database:getVehiclesByCharacter(characterId, callback)
    self:select("SELECT * FROM vehicles WHERE character_id = ? AND is_impounded = 0", {characterId}, callback)
end

function Database:getVehicleById(vehicleId, callback)
    self:select("SELECT * FROM vehicles WHERE id = ?", {vehicleId}, function(result, err)
        if callback then callback(result and result[1] or nil, err) end
    end)
end

function Database:getVehicleByPlate(plate, callback)
    self:select("SELECT * FROM vehicles WHERE plate = ?", {plate}, function(result, err)
        if callback then callback(result and result[1] or nil, err) end
    end)
end

function Database:updateVehicle(vehicleId, data, callback)
    local setParts = {}
    local params = {}
    
    for key, value in pairs(data) do
        table.insert(setParts, key .. " = ?")
        table.insert(params, value)
    end
    
    if #setParts == 0 then
        if callback then callback(0) end
        return
    end
    
    table.insert(params, vehicleId)
    local sql = "UPDATE vehicles SET " .. table.concat(setParts, ", ") .. " WHERE id = ?"
    self:update(sql, params, callback)
end

-- Faction methods
function Database:getFactionById(factionId, callback)
    self:select("SELECT * FROM factions WHERE id = ?", {factionId}, function(result, err)
        if callback then callback(result and result[1] or nil, err) end
    end)
end

function Database:getFactionByType(factionType, callback)
    self:select("SELECT * FROM factions WHERE type = ?", {factionType}, function(result, err)
        if callback then callback(result and result[1] or nil, err) end
    end)
end

function Database:getAllFactions(callback)
    self:select("SELECT * FROM factions", nil, callback)
end

function Database:getFactionMembers(factionId, callback)
    local sql = [[
        SELECT fm.*, c.name as character_name, c.skin
        FROM faction_members fm
        JOIN characters c ON fm.character_id = c.id
        WHERE fm.faction_id = ?
        ORDER BY fm.rank DESC
    ]]
    self:select(sql, {factionId}, callback)
end

function Database:addFactionMember(factionId, characterId, rank, callback)
    self:insert("INSERT INTO faction_members (faction_id, character_id, rank) VALUES (?, ?, ?)",
                {factionId, characterId, rank or 1}, callback)
end

function Database:removeFactionMember(factionId, characterId, callback)
    self:delete("DELETE FROM faction_members WHERE faction_id = ? AND character_id = ?",
                {factionId, characterId}, callback)
end

function Database:updateFactionMemberRank(factionId, characterId, rank, callback)
    self:update("UPDATE faction_members SET rank = ? WHERE faction_id = ? AND character_id = ?",
                {rank, factionId, characterId}, callback)
end

function Database:updateFactionBank(factionId, amount, callback)
    self:update("UPDATE factions SET bank = bank + ? WHERE id = ?", {amount, factionId}, callback)
end

function Database:setFactionLeader(factionId, characterId, callback)
    self:update("UPDATE factions SET leader_id = ? WHERE id = ?", {characterId, factionId}, callback)
end

-- Property methods
function Database:getPropertiesByCharacter(characterId, callback)
    self:select("SELECT * FROM properties WHERE character_id = ?", {characterId}, callback)
end

function Database:getPropertyById(propertyId, callback)
    self:select("SELECT * FROM properties WHERE id = ?", {propertyId}, function(result, err)
        if callback then callback(result and result[1] or nil, err) end
    end)
end

function Database:getPropertiesForSale(callback)
    self:select("SELECT * FROM properties WHERE is_for_sale = 1 OR is_for_rent = 1", nil, callback)
end

function Database:createProperty(data, callback)
    local keys = {}
    local values = {}
    local placeholders = {}
    
    for k, v in pairs(data) do
        table.insert(keys, k)
        table.insert(values, v)
        table.insert(placeholders, "?")
    end
    
    local sql = "INSERT INTO properties (" .. table.concat(keys, ", ") .. ") VALUES (" .. table.concat(placeholders, ", ") .. ")"
    self:insert(sql, values, callback)
end

function Database:updateProperty(propertyId, data, callback)
    local setParts = {}
    local params = {}
    
    for key, value in pairs(data) do
        table.insert(setParts, key .. " = ?")
        table.insert(params, value)
    end
    
    table.insert(params, propertyId)
    local sql = "UPDATE properties SET " .. table.concat(setParts, ", ") .. " WHERE id = ?"
    self:update(sql, params, callback)
end

-- Inventory methods
function Database:getInventory(characterId, callback)
    self:select("SELECT * FROM inventory WHERE character_id = ? ORDER BY slot", {characterId}, callback)
end

function Database:addInventoryItem(characterId, itemId, itemName, quantity, metadata, slot, callback)
    -- Check if item exists and is stackable
    local sql = "SELECT * FROM inventory WHERE character_id = ? AND item_id = ? AND slot = ?"
    self:select(sql, {characterId, itemId, slot or 0}, function(result, err)
        if result and #result > 0 then
            -- Update quantity
            local newQty = result[1].quantity + (quantity or 1)
            self:update("UPDATE inventory SET quantity = ? WHERE id = ?", {newQty, result[1].id}, callback)
        else
            -- Insert new
            sql = "INSERT INTO inventory (character_id, item_id, item_name, quantity, metadata, slot) VALUES (?, ?, ?, ?, ?, ?)"
            self:insert(sql, {characterId, itemId, itemName, quantity or 1, metadata or "{}", slot or 0}, callback)
        end
    end)
end

function Database:removeInventoryItem(characterId, itemId, quantity, slot, callback)
    local sql = "SELECT * FROM inventory WHERE character_id = ? AND item_id = ? AND slot = ?"
    self:select(sql, {characterId, itemId, slot or 0}, function(result, err)
        if result and #result > 0 then
            local newQty = result[1].quantity - (quantity or 1)
            if newQty <= 0 then
                self:delete("DELETE FROM inventory WHERE id = ?", {result[1].id}, callback)
            else
                self:update("UPDATE inventory SET quantity = ? WHERE id = ?", {newQty, result[1].id}, callback)
            end
        else
            if callback then callback(0, "Item not found") end
        end
    end)
end

function Database:moveInventoryItem(characterId, fromSlot, toSlot, callback)
    self:update("UPDATE inventory SET slot = ? WHERE character_id = ? AND slot = ?", 
                {toSlot, characterId, fromSlot}, callback)
end

-- Logging
function Database:log(type, actorId, targetId, action, details, ip, callback)
    local sql = [[
        INSERT INTO logs (type, actor_id, target_id, action, details, ip, created_at)
        VALUES (?, ?, ?, ?, ?, ?, datetime('now'))
    ]]
    self:insert(sql, {type, actorId, targetId, action, details or "", ip or ""}, callback)
end

function Database:getLogs(type, limit, offset, callback)
    local sql = "SELECT * FROM logs"
    local params = {}
    
    if type then
        sql = sql .. " WHERE type = ?"
        table.insert(params, type)
    end
    
    sql = sql .. " ORDER BY created_at DESC"
    
    if limit then
        sql = sql .. " LIMIT ?"
        table.insert(params, limit)
        if offset then
            sql = sql .. " OFFSET ?"
            table.insert(params, offset)
        end
    end
    
    self:select(sql, params, callback)
end

-- Ban methods
function Database:addBan(serial, ip, accountId, reason, bannedBy, expiresAt, isPermanent, callback)
    local sql = [[
        INSERT INTO bans (serial, ip, account_id, reason, banned_by, expires_at, is_permanent)
        VALUES (?, ?, ?, ?, ?, ?, ?)
    ]]
    self:insert(sql, {serial, ip, accountId, reason, bannedBy, expiresAt, isPermanent and 1 or 0}, callback)
end

function Database:isBanned(serial, ip, callback)
    local sql = "SELECT * FROM bans WHERE (serial = ? OR ip = ?) AND (is_permanent = 1 OR expires_at > datetime('now'))"
    self:select(sql, {serial, ip}, function(result, err)
        if callback then callback(result and #result > 0, err) end
    end)
end

function Database:removeBan(banId, callback)
    self:delete("DELETE FROM bans WHERE id = ?", {banId}, callback)
end

function Database:getBans(callback)
    self:select("SELECT * FROM bans ORDER BY banned_at DESC", nil, callback)
end

-- Settings
function Database:setSetting(key, value, description, callback)
    local sql = [[
        INSERT OR REPLACE INTO settings (key, value, description) VALUES (?, ?, ?)
    ]]
    self:exec(sql, {key, value, description})
    if callback then callback(true) end
end

function Database:getSetting(key, callback)
    self:select("SELECT value FROM settings WHERE key = ?", {key}, function(result, err)
        if callback then callback(result and result[1] and result[1].value or nil, err) end
    end)
end

function Database:getAllSettings(callback)
    self:select("SELECT * FROM settings", nil, callback)
end

-- Cleanup
function Database:disconnect()
    if self.connection then
        destroyElement(self.connection)
        self.connection = nil
        self.isConnected = false
        Utils.logInfo("Database disconnected")
    end
end

-- Global instance
_G.Database = Database:new()

return Database