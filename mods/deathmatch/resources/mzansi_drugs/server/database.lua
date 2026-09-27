Mzansi = Mzansi or {}
Mzansi.Database = {}
Mzansi.Database._pool = nil

local function adaptQuery(sql, driver)
    if not sql then return "" end
    if driver == "sqlite" then
        sql = sql:gsub("ENGINE%s*=%s*[%w_]+", "")
        sql = sql:gsub("DEFAULT%s+CHARSET%s*=%s*[%w_]+", "")
        sql = sql:gsub("AUTO_INCREMENT", "AUTOINCREMENT")
        sql = sql:gsub("INT%s+AUTOINCREMENT%s+PRIMARY%s+KEY", "INTEGER PRIMARY KEY AUTOINCREMENT")
        sql = sql:gsub("NOW%(%)", "CURRENT_TIMESTAMP")
    end
    return sql
end

function Mzansi.Database.connect()
    local cfg = (Mzansi.Config and Mzansi.Config.Database) or {
        host = "127.0.0.1", port = 3306, username = "root", password = "", database = "mzansi_rp"
    }
    if cfg and cfg.host and cfg.database then
        Mzansi.Database._pool = dbConnect(
            "mysql",
            "dbname=" .. cfg.database .. ";host=" .. cfg.host .. ";port=" .. (cfg.port or 3306),
            cfg.username or "root",
            cfg.password or "",
            "share=1;reopen=1"
        )
        if Mzansi.Database._pool then
            Mzansi.Database._driver = "mysql"
            outputDebugString("[Mzansi-DB] Connected to MySQL database successfully.")
            Mzansi.Database.createTables()
            return true
        end
    end

    -- Embedded SQLite fallback (shared across all resources)
    outputDebugString("[Mzansi-DB] MySQL unavailable. Falling back to embedded SQLite database...", 2)
    Mzansi.Database._pool = dbConnect("sqlite", ":/databases/mzansi_rp.db")
    if Mzansi.Database._pool then
        Mzansi.Database._driver = "sqlite"
        outputDebugString("[Mzansi-DB] Connected to embedded SQLite database successfully.")
        Mzansi.Database.createTables()
        return true
    else
        outputDebugString("[Mzansi-DB] Failed to connect to any database!", 1)
        return false
    end
end

function Mzansi.Database.disconnect()
    if Mzansi.Database._pool then
        dbDestroy(Mzansi.Database._pool)
        Mzansi.Database._pool = nil
        outputDebugString("[Mzansi-DB] Disconnected from database.")
    end
end

function Mzansi.Database.createTables()
    local queries = {
        [[CREATE TABLE IF NOT EXISTS mzansi_accounts (
            id INT AUTO_INCREMENT PRIMARY KEY,
            username VARCHAR(64) NOT NULL UNIQUE,
            password_hash VARCHAR(256) NOT NULL,
            email VARCHAR(128),
            serial VARCHAR(64),
            admin_level INT DEFAULT 0,
            banned TINYINT(1) DEFAULT 0,
            ban_reason TEXT,
            play_time INT DEFAULT 0,
            last_login TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]],

        [[CREATE TABLE IF NOT EXISTS mzansi_characters (
            id INT AUTO_INCREMENT PRIMARY KEY,
            account_id INT NOT NULL,
            first_name VARCHAR(32) NOT NULL,
            last_name VARCHAR(32) NOT NULL,
            age INT DEFAULT 25,
            gender TINYINT DEFAULT 0,
            job INT DEFAULT 0,
            faction INT DEFAULT 0,
            faction_rank INT DEFAULT 0,
            cash INT DEFAULT 5000,
            bank INT DEFAULT 25000,
            health FLOAT DEFAULT 100,
            armor FLOAT DEFAULT 0,
            level INT DEFAULT 1,
            xp INT DEFAULT 0,
            jail_time INT DEFAULT 0,
            driver_license TINYINT(1) DEFAULT 0,
            weapon_license TINYINT(1) DEFAULT 0,
            fish_license TINYINT(1) DEFAULT 0,
            skin INT DEFAULT -1,
            wanted_level INT DEFAULT 0,
            spawn_x FLOAT DEFAULT 1682.5,
            spawn_y FLOAT DEFAULT -2267.0,
            spawn_z FLOAT DEFAULT 13.5,
            spawn_rot FLOAT DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            last_played TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (account_id) REFERENCES mzansi_accounts(id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]],

        [[CREATE TABLE IF NOT EXISTS mzansi_vehicles (
            id INT AUTO_INCREMENT PRIMARY KEY,
            owner_id INT,
            model_id INT NOT NULL,
            plate VARCHAR(10) NOT NULL UNIQUE,
            type INT DEFAULT 0,
            faction_id INT DEFAULT 0,
            x FLOAT DEFAULT 0,
            y FLOAT DEFAULT 0,
            z FLOAT DEFAULT 0,
            rotation FLOAT DEFAULT 0,
            health FLOAT DEFAULT 1000,
            fuel FLOAT DEFAULT 100,
            mileage FLOAT DEFAULT 0,
            color1 INT DEFAULT 0,
            color2 INT DEFAULT 0,
            upgrades TEXT,
            impounded TINYINT(1) DEFAULT 0,
            insurance TINYINT(1) DEFAULT 0,
            locked TINYINT(1) DEFAULT 1,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (owner_id) REFERENCES mzansi_characters(id) ON DELETE SET NULL
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]],

        [[CREATE TABLE IF NOT EXISTS mzansi_properties (
            id INT AUTO_INCREMENT PRIMARY KEY,
            owner_id INT,
            name VARCHAR(64) NOT NULL,
            type INT DEFAULT 0,
            x FLOAT NOT NULL,
            y FLOAT NOT NULL,
            z FLOAT NOT NULL,
            interior INT DEFAULT 0,
            dimension INT DEFAULT 0,
            price INT DEFAULT 0,
            rent_price INT DEFAULT 0,
            locked TINYINT(1) DEFAULT 1,
            storage TEXT,
            furniture TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (owner_id) REFERENCES mzansi_characters(id) ON DELETE SET NULL
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]],

        [[CREATE TABLE IF NOT EXISTS mzansi_inventory (
            id INT AUTO_INCREMENT PRIMARY KEY,
            owner_id INT NOT NULL,
            item_name VARCHAR(64) NOT NULL,
            item_type INT DEFAULT 0,
            quantity INT DEFAULT 1,
            metadata TEXT,
            slot INT DEFAULT 0,
            FOREIGN KEY (owner_id) REFERENCES mzansi_characters(id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]],

        [[CREATE TABLE IF NOT EXISTS mzansi_phone_contacts (
            id INT AUTO_INCREMENT PRIMARY KEY,
            owner_id INT NOT NULL,
            contact_name VARCHAR(64) NOT NULL,
            contact_number VARCHAR(20) NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (owner_id) REFERENCES mzansi_characters(id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]],

        [[CREATE TABLE IF NOT EXISTS mzansi_phone_messages (
            id INT AUTO_INCREMENT PRIMARY KEY,
            sender_id INT NOT NULL,
            receiver_id INT NOT NULL,
            message TEXT NOT NULL,
            read_status TINYINT(1) DEFAULT 0,
            sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (sender_id) REFERENCES mzansi_characters(id) ON DELETE CASCADE,
            FOREIGN KEY (receiver_id) REFERENCES mzansi_characters(id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]],

        [[CREATE TABLE IF NOT EXISTS mzansi_police_records (
            id INT AUTO_INCREMENT PRIMARY KEY,
            character_id INT NOT NULL,
            officer_id INT,
            charge VARCHAR(128) NOT NULL,
            description TEXT,
            fine INT DEFAULT 0,
            jail_time INT DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (character_id) REFERENCES mzansi_characters(id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]],

        [[CREATE TABLE IF NOT EXISTS mzansi_business_ownership (
            id INT AUTO_INCREMENT PRIMARY KEY,
            business_id INT NOT NULL,
            owner_id INT,
            balance INT DEFAULT 0,
            employees TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (owner_id) REFERENCES mzansi_characters(id) ON DELETE SET NULL
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]],

        [[CREATE TABLE IF NOT EXISTS mzansi_logs (
            id INT AUTO_INCREMENT PRIMARY KEY,
            log_type VARCHAR(32) NOT NULL,
            player_id INT,
            player_name VARCHAR(64),
            action TEXT NOT NULL,
            details TEXT,
            ip_address VARCHAR(45),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]],

        [[CREATE TABLE IF NOT EXISTS mzansi_gangs (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(64) NOT NULL UNIQUE,
            leader_id INT,
            color VARCHAR(16) DEFAULT '#FFFFFF',
            treasury INT DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (leader_id) REFERENCES mzansi_characters(id) ON DELETE SET NULL
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]],

        [[CREATE TABLE IF NOT EXISTS mzansi_gang_members (
            id INT AUTO_INCREMENT PRIMARY KEY,
            gang_id INT NOT NULL,
            character_id INT NOT NULL,
            rank INT DEFAULT 0,
            joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (gang_id) REFERENCES mzansi_gangs(id) ON DELETE CASCADE,
            FOREIGN KEY (character_id) REFERENCES mzansi_characters(id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]],

        [[CREATE TABLE IF NOT EXISTS mzansi_territories (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(64) NOT NULL,
            gang_id INT,
            x FLOAT NOT NULL,
            y FLOAT NOT NULL,
            z FLOAT NOT NULL,
            radius FLOAT DEFAULT 50,
            controlled TINYINT(1) DEFAULT 0,
            last_attack TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (gang_id) REFERENCES mzansi_gangs(id) ON DELETE SET NULL
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]],

        [[CREATE TABLE IF NOT EXISTS mzansi_drug_plots (
            id INT AUTO_INCREMENT PRIMARY KEY,
            location_id INT NOT NULL,
            plant_id INT NOT NULL,
            owner_id INT NOT NULL,
            drug_type VARCHAR(64) NOT NULL,
            growth INT DEFAULT 0,
            planted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (owner_id) REFERENCES mzansi_characters(id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]],

        [[CREATE TABLE IF NOT EXISTS mzansi_crime_records (
            id INT AUTO_INCREMENT PRIMARY KEY,
            character_id INT NOT NULL,
            crime_type VARCHAR(64) NOT NULL,
            description TEXT,
            reward_bounty INT DEFAULT 0,
            wanted_level INT DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (character_id) REFERENCES mzansi_characters(id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]],
    }

    for _, query in ipairs(queries) do
        local result = dbExec(Mzansi.Database._pool, adaptQuery(query, Mzansi.Database._driver))
        if not result then
            outputDebugString("[Mzansi-DB] Failed to execute table creation query!", 1)
        end
    end
    outputDebugString("[Mzansi-DB] Database tables initialized.")
end

function Mzansi.Database.lazyConnect()
    if Mzansi.Database._pool then return end
    if Mzansi.Database._lastConnectAttempt and (getTickCount() - Mzansi.Database._lastConnectAttempt) < 30000 then return end
    Mzansi.Database._lastConnectAttempt = getTickCount()
    Mzansi.Database.connect()
end

function Mzansi.Database.query(sql, ...)
    Mzansi.Database.lazyConnect()
    if not Mzansi.Database._pool then
        outputDebugString("[Mzansi-DB] No database connection!", 1)
        return nil
    end
    local result = dbPoll(dbQuery(Mzansi.Database._pool, sql, ...), -1)
    return result
end

function Mzansi.Database.insert(sql, ...)
    Mzansi.Database.lazyConnect()
    if not Mzansi.Database._pool then
        outputDebugString("[Mzansi-DB] No database connection!", 1)
        return nil
    end
    local _, _, lastInsert = dbPoll(dbQuery(Mzansi.Database._pool, sql, ...), -1)
    return lastInsert
end

function Mzansi.Database.update(sql, ...)
    Mzansi.Database.lazyConnect()
    if not Mzansi.Database._pool then
        outputDebugString("[Mzansi-DB] No database connection!", 1)
        return false
    end
    return dbExec(Mzansi.Database._pool, sql, ...)
end

function Mzansi.Database.delete(sql, ...)
    return Mzansi.Database.update(sql, ...)
end

function Mzansi.Database.getAccount(username)
    local result = Mzansi.Database.query(
        "SELECT * FROM mzansi_accounts WHERE username = ? LIMIT 1",
        username
    )
    if result and #result > 0 then
        return result[1]
    end
    return nil
end

function Mzansi.Database.createAccount(username, passwordHash, email, serial)
    return Mzansi.Database.insert(
        "INSERT INTO mzansi_accounts (username, password_hash, email, serial) VALUES (?, ?, ?, ?)",
        username, passwordHash, email or "", serial or ""
    )
end

function Mzansi.Database.getCharacter(accountId)
    local result = Mzansi.Database.query(
        "SELECT * FROM mzansi_characters WHERE account_id = ? LIMIT 1",
        accountId
    )
    if result and #result > 0 then
        return result[1]
    end
    return nil
end

function Mzansi.Database.createCharacter(accountId, firstName, lastName, age, gender)
    return Mzansi.Database.insert(
        "INSERT INTO mzansi_characters (account_id, first_name, last_name, age, gender) VALUES (?, ?, ?, ?, ?)",
        accountId, firstName, lastName, age or 25, gender or 0
    )
end

function Mzansi.Database.saveCharacter(charId, data)
    local fields = {}
    local values = {}
    for k, v in pairs(data) do
        fields[#fields + 1] = k .. " = ?"
        values[#values + 1] = v
    end
    values[#values + 1] = charId
    local sql = "UPDATE mzansi_characters SET " .. table.concat(fields, ", ") .. " WHERE id = ?"
    return Mzansi.Database.update(sql, unpack(values))
end

function Mzansi.Database.getVehicle(plate)
    local result = Mzansi.Database.query(
        "SELECT * FROM mzansi_vehicles WHERE plate = ? LIMIT 1",
        plate
    )
    if result and #result > 0 then
        return result[1]
    end
    return nil
end

function Mzansi.Database.getPlayerVehicles(charId)
    return Mzansi.Database.query(
        "SELECT * FROM mzansi_vehicles WHERE owner_id = ?",
        charId
    ) or {}
end

function Mzansi.Database.createVehicle(ownerId, modelId, plate, x, y, z, rot, color1, color2)
    return Mzansi.Database.insert(
        "INSERT INTO mzansi_vehicles (owner_id, model_id, plate, x, y, z, rotation, color1, color2) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
        ownerId, modelId, plate, x or 0, y or 0, z or 0, rot or 0, color1 or 0, color2 or 0
    )
end

function Mzansi.Database.saveVehicle(vehicleId, data)
    local fields = {}
    local values = {}
    for k, v in pairs(data) do
        fields[#fields + 1] = k .. " = ?"
        values[#values + 1] = v
    end
    values[#values + 1] = vehicleId
    local sql = "UPDATE mzansi_vehicles SET " .. table.concat(fields, ", ") .. " WHERE id = ?"
    return Mzansi.Database.update(sql, unpack(values))
end

function Mzansi.Database.deleteVehicle(vehicleId)
    return Mzansi.Database.delete("DELETE FROM mzansi_vehicles WHERE id = ?", vehicleId)
end

function Mzansi.Database.getProperty(propertyId)
    local result = Mzansi.Database.query(
        "SELECT * FROM mzansi_properties WHERE id = ? LIMIT 1",
        propertyId
    )
    if result and #result > 0 then
        return result[1]
    end
    return nil
end

function Mzansi.Database.getPlayerProperties(charId)
    return Mzansi.Database.query(
        "SELECT * FROM mzansi_properties WHERE owner_id = ?",
        charId
    ) or {}
end

function Mzansi.Database.logAction(logType, playerId, playerName, action, details, ipAddress)
    Mzansi.Database.insert(
        "INSERT INTO mzansi_logs (log_type, player_id, player_name, action, details, ip_address) VALUES (?, ?, ?, ?, ?, ?)",
        logType, playerId or 0, playerName or "SYSTEM", action, details or "", ipAddress or ""
    )
end

function Mzansi.Database.getGang(gangId)
    local result = Mzansi.Database.query(
        "SELECT * FROM mzansi_gangs WHERE id = ? LIMIT 1",
        gangId
    )
    if result and #result > 0 then
        return result[1]
    end
    return nil
end

function Mzansi.Database.createGang(name, leaderId, color)
    return Mzansi.Database.insert(
        "INSERT INTO mzansi_gangs (name, leader_id, color) VALUES (?, ?, ?)",
        name, leaderId, color or "#FFFFFF"
    )
end

function Mzansi.Database.getGangMember(characterId)
    local result = Mzansi.Database.query(
        "SELECT * FROM mzansi_gang_members WHERE character_id = ? LIMIT 1",
        characterId
    )
    if result and #result > 0 then
        return result[1]
    end
    return nil
end

function Mzansi.Database.addGangMember(gangId, characterId, rank)
    return Mzansi.Database.insert(
        "INSERT INTO mzansi_gang_members (gang_id, character_id, rank) VALUES (?, ?, ?)",
        gangId, characterId, rank or 0
    )
end

function Mzansi.Database.removeGangMember(characterId)
    return Mzansi.Database.delete("DELETE FROM mzansi_gang_members WHERE character_id = ?", characterId)
end

function Mzansi.Database.getGangMembers(gangId)
    return Mzansi.Database.query(
        "SELECT * FROM mzansi_gang_members WHERE gang_id = ?",
        gangId
    ) or {}
end

function Mzansi.Database.updateGangMemberRank(characterId, rank)
    return Mzansi.Database.update(
        "UPDATE mzansi_gang_members SET rank = ? WHERE character_id = ?",
        rank, characterId
    )
end

function Mzansi.Database.getTerritory(territoryId)
    local result = Mzansi.Database.query(
        "SELECT * FROM mzansi_territories WHERE id = ? LIMIT 1",
        territoryId
    )
    if result and #result > 0 then
        return result[1]
    end
    return nil
end

function Mzansi.Database.getAllTerritories()
    return Mzansi.Database.query("SELECT * FROM mzansi_territories") or {}
end

function Mzansi.Database.updateTerritoryOwner(territoryId, gangId)
    return Mzansi.Database.update(
        "UPDATE mzansi_territories SET gang_id = ?, controlled = 1 WHERE id = ?",
        gangId, territoryId
    )
end

function Mzansi.Database.getGangByLeader(characterId)
    local result = Mzansi.Database.query(
        "SELECT * FROM mzansi_gangs WHERE leader_id = ? LIMIT 1",
        characterId
    )
    if result and #result > 0 then
        return result[1]
    end
    return nil
end

function Mzansi.Database.getGangByName(name)
    local result = Mzansi.Database.query(
        "SELECT * FROM mzansi_gangs WHERE name = ? LIMIT 1",
        name
    )
    if result and #result > 0 then
        return result[1]
    end
    return nil
end

-- Export wrapper functions for cross-resource access
function database_getGang(gangId)
    return Mzansi.Database.getGang(gangId)
end

function database_createGang(name, leaderId, color)
    return Mzansi.Database.createGang(name, leaderId, color)
end

function database_getGangMember(characterId)
    return Mzansi.Database.getGangMember(characterId)
end

function database_addGangMember(gangId, characterId, rank)
    return Mzansi.Database.addGangMember(gangId, characterId, rank)
end

function database_removeGangMember(characterId)
    return Mzansi.Database.removeGangMember(characterId)
end

function database_getGangMembers(gangId)
    return Mzansi.Database.getGangMembers(gangId)
end

function database_updateGangMemberRank(characterId, rank)
    return Mzansi.Database.updateGangMemberRank(characterId, rank)
end

function database_getTerritory(territoryId)
    return Mzansi.Database.getTerritory(territoryId)
end

function database_getAllTerritories()
    return Mzansi.Database.getAllTerritories()
end

function database_updateTerritoryOwner(territoryId, gangId)
    return Mzansi.Database.updateTerritoryOwner(territoryId, gangId)
end

function database_getGangByLeader(characterId)
    return Mzansi.Database.getGangByLeader(characterId)
end

function database_getGangByName(name)
    return Mzansi.Database.getGangByName(name)
end

function database_logAction(logType, playerId, playerName, action, details, ipAddress)
    return Mzansi.Database.logAction(logType, playerId, playerName, action, details, ipAddress)
end

addEventHandler("onResourceStart", resourceRoot, function()
    Mzansi.Database.connect()
end)
