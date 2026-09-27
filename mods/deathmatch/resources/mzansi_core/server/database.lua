Mzansi = Mzansi or {}
Mzansi.Database = {}
Mzansi.Database._pool = nil
Mzansi.Database._driver = "mysql"

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

    -- Attempt 1: MariaDB / MySQL
    if cfg and cfg.host and cfg.database then
        outputDebugString("[Mzansi-DB] Attempting MySQL connection (" .. cfg.host .. ":" .. (cfg.port or 3306) .. ")...")
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

    -- Attempt 2: Embedded SQLite fallback
    outputDebugString("[Mzansi-DB] MySQL unavailable. Falling back to embedded SQLite database...", 2)
    Mzansi.Database._pool = dbConnect("sqlite", ":/databases/mzansi_rp.db")
    if Mzansi.Database._pool then
        Mzansi.Database._driver = "sqlite"
        outputDebugString("[Mzansi-DB] Connected to embedded SQLite database successfully.")
        Mzansi.Database.createTables()
        return true
    else
        outputDebugString("[Mzansi-DB] CRITICAL: Failed to initialize any database connection!", 1)
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

        [[CREATE TABLE IF NOT EXISTS mzansi_investments (
            id INT AUTO_INCREMENT PRIMARY KEY,
            owner_id INT NOT NULL,
            investment_key VARCHAR(64) NOT NULL,
            principal INT NOT NULL,
            accrued_interest INT DEFAULT 0,
            rate_per_cycle FLOAT DEFAULT 0,
            last_payout TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (owner_id) REFERENCES mzansi_characters(id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]],

        [[CREATE TABLE IF NOT EXISTS mzansi_bank_transactions (
            id INT AUTO_INCREMENT PRIMARY KEY,
            character_id INT NOT NULL,
            tx_type VARCHAR(32) NOT NULL,
            amount INT NOT NULL DEFAULT 0,
            balance_after INT NOT NULL DEFAULT 0,
            detail TEXT,
            counterparty VARCHAR(64) DEFAULT '',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (character_id) REFERENCES mzansi_characters(id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]],

        [[CREATE TABLE IF NOT EXISTS mzansi_group_accounts (
            id INT AUTO_INCREMENT PRIMARY KEY,
            owner_type VARCHAR(32) NOT NULL,
            owner_id INT NOT NULL,
            name VARCHAR(64) NOT NULL,
            balance INT DEFAULT 0,
            withdraw_level INT DEFAULT 5,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            UNIQUE KEY uq_group_owner (owner_type, owner_id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]],

        [[CREATE TABLE IF NOT EXISTS mzansi_group_transactions (
            id INT AUTO_INCREMENT PRIMARY KEY,
            account_id INT NOT NULL,
            character_id INT,
            tx_type VARCHAR(32) NOT NULL,
            amount INT NOT NULL DEFAULT 0,
            balance_after INT DEFAULT 0,
            detail TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (account_id) REFERENCES mzansi_group_accounts(id) ON DELETE CASCADE,
            FOREIGN KEY (character_id) REFERENCES mzansi_characters(id) ON DELETE SET NULL
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]],

        [[CREATE TABLE IF NOT EXISTS mzansi_reserve_policy (
            id INT PRIMARY KEY,
            policy_rate FLOAT DEFAULT 0.02,
            reserve_ratio FLOAT DEFAULT 0.10,
            tax_rate FLOAT DEFAULT 0.05,
            discount_rate FLOAT DEFAULT 0.03,
            updated_by INT DEFAULT 0,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]],

        [[CREATE TABLE IF NOT EXISTS mzansi_money_supply (
            id INT AUTO_INCREMENT PRIMARY KEY,
            m0_cash BIGINT DEFAULT 0,
            m1_deposits BIGINT DEFAULT 0,
            m2_proxy BIGINT DEFAULT 0,
            snapshot_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]],

        [[CREATE TABLE IF NOT EXISTS mzansi_market_positions (
            id INT AUTO_INCREMENT PRIMARY KEY,
            character_id INT NOT NULL,
            symbol VARCHAR(16) NOT NULL,
            qty INT NOT NULL DEFAULT 0,
            avg_price FLOAT NOT NULL DEFAULT 0,
            realized_pnl FLOAT NOT NULL DEFAULT 0,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            UNIQUE KEY uq_pos (character_id, symbol),
            FOREIGN KEY (character_id) REFERENCES mzansi_characters(id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]],

        [[CREATE TABLE IF NOT EXISTS mzansi_funds (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(64) NOT NULL,
            sponsor_type VARCHAR(32) DEFAULT 'character',
            sponsor_id INT NOT NULL,
            strategy VARCHAR(32) DEFAULT 'balanced',
            aum INT DEFAULT 0,
            nav FLOAT DEFAULT 1.0,
            status VARCHAR(16) DEFAULT 'open',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]],

        [[CREATE TABLE IF NOT EXISTS mzansi_fund_members (
            id INT AUTO_INCREMENT PRIMARY KEY,
            fund_id INT NOT NULL,
            character_id INT NOT NULL,
            units FLOAT NOT NULL DEFAULT 0,
            joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            UNIQUE KEY uq_fund_member (fund_id, character_id),
            FOREIGN KEY (fund_id) REFERENCES mzansi_funds(id) ON DELETE CASCADE,
            FOREIGN KEY (character_id) REFERENCES mzansi_characters(id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]],

        [[CREATE TABLE IF NOT EXISTS mzansi_fund_tx (
            id INT AUTO_INCREMENT PRIMARY KEY,
            fund_id INT NOT NULL,
            character_id INT,
            tx_type VARCHAR(16) NOT NULL,
            amount INT NOT NULL DEFAULT 0,
            units FLOAT NOT NULL DEFAULT 0,
            nav FLOAT NOT NULL DEFAULT 1.0,
            detail TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]],

        [[CREATE TABLE IF NOT EXISTS mzansi_ce_tickets (
            id INT AUTO_INCREMENT PRIMARY KEY,
            character_id INT,
            title VARCHAR(128) NOT NULL,
            severity VARCHAR(16) DEFAULT 'easy',
            reward INT DEFAULT 0,
            status VARCHAR(16) DEFAULT 'open',
            completed_at TIMESTAMP NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            UNIQUE KEY uq_ce_ticket (character_id, id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]],

        [[CREATE TABLE IF NOT EXISTS mzansi_mech_progress (
            id INT AUTO_INCREMENT PRIMARY KEY,
            character_id INT NOT NULL,
            stage INT DEFAULT 0,
            score INT DEFAULT 0,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            UNIQUE KEY uq_mech_char (character_id),
            FOREIGN KEY (character_id) REFERENCES mzansi_characters(id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]],

        [[CREATE TABLE IF NOT EXISTS mzansi_ai_messages (
            id INT AUTO_INCREMENT PRIMARY KEY,
            account_id INT,
            session_id VARCHAR(64) DEFAULT '',
            role VARCHAR(16) NOT NULL,
            content TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]],

        [[CREATE TABLE IF NOT EXISTS mzansi_lab_designs (
            id INT AUTO_INCREMENT PRIMARY KEY,
            character_id INT NOT NULL,
            challenge_id VARCHAR(48) NOT NULL,
            circuit_json MEDIUMTEXT,
            status VARCHAR(16) DEFAULT 'draft',
            score INT DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            UNIQUE KEY uq_lab_design (character_id, challenge_id),
            FOREIGN KEY (character_id) REFERENCES mzansi_characters(id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]],
    }

    for _, query in ipairs(queries) do
        local adapted = adaptQuery(query, Mzansi.Database._driver)
        local result = dbExec(Mzansi.Database._pool, adapted)
        if not result then
            outputDebugString("[Mzansi-DB] Notice: table query execution skipped or already exists.", 3)
        end
    end

    Mzansi.Database.runMigrations()
    outputDebugString("[Mzansi-DB] Database tables initialized (" .. Mzansi.Database._driver .. ").")
end

function Mzansi.Database.runMigrations()
    if not Mzansi.Database._pool then return end

    local function columnExists(tableName, columnName)
        local q = "SELECT `" .. tostring(columnName) .. "` FROM `" .. tostring(tableName) .. "` LIMIT 0"
        local ok, res = pcall(function()
            local qh = dbQuery(Mzansi.Database._pool, adaptQuery(q, Mzansi.Database._driver))
            if not qh then return false end
            local rows = dbPoll(qh, 1000)
            if rows == nil then
                dbFree(qh)
                return false
            end
            return rows ~= false
        end)
        return ok and res or false
    end

    if not columnExists("mzansi_characters", "skin") then
        local ok, err = pcall(function()
            dbExec(Mzansi.Database._pool, "ALTER TABLE mzansi_characters ADD COLUMN skin INT DEFAULT -1")
        end)
        if ok then
            outputDebugString("[Mzansi-DB] Migration: added skin column to mzansi_characters.")
        else
            outputDebugString("[Mzansi-DB] Migration skin column failed: " .. tostring(err), 2)
        end
    end

    if not columnExists("mzansi_characters", "wanted_level") then
        local ok, err = pcall(function()
            dbExec(Mzansi.Database._pool, "ALTER TABLE mzansi_characters ADD COLUMN wanted_level INT DEFAULT 0")
        end)
        if ok then
            outputDebugString("[Mzansi-DB] Migration: added wanted_level column to mzansi_characters.")
        else
            outputDebugString("[Mzansi-DB] Migration wanted_level column failed: " .. tostring(err), 2)
        end
    end

    if not columnExists("mzansi_bank_transactions", "id") then
        outputDebugString("[Mzansi-DB] mzansi_bank_transactions missing — recreate via createTables.", 2)
    end

    -- Group banking tables (P1)
    local okG, errG = pcall(function()
        dbExec(Mzansi.Database._pool, adaptQuery(
            [[CREATE TABLE IF NOT EXISTS mzansi_group_accounts (
                id INT AUTO_INCREMENT PRIMARY KEY,
                owner_type VARCHAR(32) NOT NULL,
                owner_id INT NOT NULL,
                name VARCHAR(64) NOT NULL,
                balance INT DEFAULT 0,
                withdraw_level INT DEFAULT 5,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]],
            Mzansi.Database._driver
        ))
        dbExec(Mzansi.Database._pool, adaptQuery(
            [[CREATE TABLE IF NOT EXISTS mzansi_group_transactions (
                id INT AUTO_INCREMENT PRIMARY KEY,
                account_id INT NOT NULL,
                character_id INT,
                tx_type VARCHAR(32) NOT NULL,
                amount INT NOT NULL DEFAULT 0,
                balance_after INT DEFAULT 0,
                detail TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]],
            Mzansi.Database._driver
        ))
    end)
    if okG then
        outputDebugString("[Mzansi-DB] Migration: group banking tables ensured.")
    else
        outputDebugString("[Mzansi-DB] Migration group tables failed: " .. tostring(errG), 2)
    end

    -- Reserve bank policy (P3)
    local okR, errR = pcall(function()
        dbExec(Mzansi.Database._pool, adaptQuery(
            [[CREATE TABLE IF NOT EXISTS mzansi_reserve_policy (
                id INT PRIMARY KEY,
                policy_rate FLOAT DEFAULT 0.02,
                reserve_ratio FLOAT DEFAULT 0.10,
                tax_rate FLOAT DEFAULT 0.05,
                discount_rate FLOAT DEFAULT 0.03,
                updated_by INT DEFAULT 0,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]],
            Mzansi.Database._driver
        ))
        dbExec(Mzansi.Database._pool, adaptQuery(
            [[CREATE TABLE IF NOT EXISTS mzansi_money_supply (
                id INT AUTO_INCREMENT PRIMARY KEY,
                m0_cash BIGINT DEFAULT 0,
                m1_deposits BIGINT DEFAULT 0,
                m2_proxy BIGINT DEFAULT 0,
                snapshot_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]],
            Mzansi.Database._driver
        ))
    end)
    if okR then
        outputDebugString("[Mzansi-DB] Migration: reserve bank tables ensured.")
    else
        outputDebugString("[Mzansi-DB] Migration reserve tables failed: " .. tostring(errR), 2)
    end

    -- P4–P8: market / funds / CE / mech / AI tables
    local okM, errM = pcall(function()
        dbExec(Mzansi.Database._pool, adaptQuery(
            [[CREATE TABLE IF NOT EXISTS mzansi_market_positions (
                id INT AUTO_INCREMENT PRIMARY KEY,
                character_id INT NOT NULL,
                symbol VARCHAR(16) NOT NULL,
                qty INT NOT NULL DEFAULT 0,
                avg_price FLOAT NOT NULL DEFAULT 0,
                realized_pnl FLOAT NOT NULL DEFAULT 0,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                UNIQUE KEY uq_pos (character_id, symbol)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]],
            Mzansi.Database._driver
        ))
        dbExec(Mzansi.Database._pool, adaptQuery(
            [[CREATE TABLE IF NOT EXISTS mzansi_funds (
                id INT AUTO_INCREMENT PRIMARY KEY,
                name VARCHAR(64) NOT NULL,
                sponsor_type VARCHAR(32) DEFAULT 'character',
                sponsor_id INT NOT NULL,
                strategy VARCHAR(32) DEFAULT 'balanced',
                aum INT DEFAULT 0,
                nav FLOAT DEFAULT 1.0,
                status VARCHAR(16) DEFAULT 'open',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]],
            Mzansi.Database._driver
        ))
        dbExec(Mzansi.Database._pool, adaptQuery(
            [[CREATE TABLE IF NOT EXISTS mzansi_fund_members (
                id INT AUTO_INCREMENT PRIMARY KEY,
                fund_id INT NOT NULL,
                character_id INT NOT NULL,
                units FLOAT NOT NULL DEFAULT 0,
                joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                UNIQUE KEY uq_fund_member (fund_id, character_id)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]],
            Mzansi.Database._driver
        ))
        dbExec(Mzansi.Database._pool, adaptQuery(
            [[CREATE TABLE IF NOT EXISTS mzansi_fund_tx (
                id INT AUTO_INCREMENT PRIMARY KEY,
                fund_id INT NOT NULL,
                character_id INT,
                tx_type VARCHAR(16) NOT NULL,
                amount INT NOT NULL DEFAULT 0,
                units FLOAT NOT NULL DEFAULT 0,
                nav FLOAT NOT NULL DEFAULT 1.0,
                detail TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]],
            Mzansi.Database._driver
        ))
        dbExec(Mzansi.Database._pool, adaptQuery(
            [[CREATE TABLE IF NOT EXISTS mzansi_ce_tickets (
                id INT AUTO_INCREMENT PRIMARY KEY,
                character_id INT,
                title VARCHAR(128) NOT NULL,
                severity VARCHAR(16) DEFAULT 'easy',
                reward INT DEFAULT 0,
                status VARCHAR(16) DEFAULT 'open',
                completed_at TIMESTAMP NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]],
            Mzansi.Database._driver
        ))
        dbExec(Mzansi.Database._pool, adaptQuery(
            [[CREATE TABLE IF NOT EXISTS mzansi_mech_progress (
                id INT AUTO_INCREMENT PRIMARY KEY,
                character_id INT NOT NULL,
                stage INT DEFAULT 0,
                score INT DEFAULT 0,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                UNIQUE KEY uq_mech_char (character_id)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]],
            Mzansi.Database._driver
        ))
        dbExec(Mzansi.Database._pool, adaptQuery(
            [[CREATE TABLE IF NOT EXISTS mzansi_ai_messages (
                id INT AUTO_INCREMENT PRIMARY KEY,
                account_id INT,
                session_id VARCHAR(64) DEFAULT '',
                role VARCHAR(16) NOT NULL,
                content TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]],
            Mzansi.Database._driver
        ))
        dbExec(Mzansi.Database._pool, adaptQuery(
            [[CREATE TABLE IF NOT EXISTS mzansi_lab_designs (
                id INT AUTO_INCREMENT PRIMARY KEY,
                character_id INT NOT NULL,
                challenge_id VARCHAR(48) NOT NULL,
                circuit_json MEDIUMTEXT,
                status VARCHAR(16) DEFAULT 'draft',
                score INT DEFAULT 0,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                UNIQUE KEY uq_lab_design (character_id, challenge_id)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]],
            Mzansi.Database._driver
        ))
    end)
    if okM then
        outputDebugString("[Mzansi-DB] Migration: market/funds/CE/mech/AI/lab tables ensured.")
    else
        outputDebugString("[Mzansi-DB] Migration expansion tables failed: " .. tostring(errM), 2)
    end
end

function Mzansi.Database.lazyConnect()
    if Mzansi.Database._pool then return end
    if Mzansi.Database._lastConnectAttempt and (getTickCount() - Mzansi.Database._lastConnectAttempt) < 10000 then return end
    Mzansi.Database._lastConnectAttempt = getTickCount()
    Mzansi.Database.connect()
end

function database_insert(sql, ...)
    return Mzansi.Database.insert(sql, ...)
end

function database_update(sql, ...)
    return Mzansi.Database.update(sql, ...)
end

function database_delete(sql, ...)
    return Mzansi.Database.delete(sql, ...)
end

function database_logTransaction(characterId, txType, amount, balanceAfter, detail, counterparty)
    if Mzansi.Database.logTransaction then
        return Mzansi.Database.logTransaction(characterId, txType, amount, balanceAfter, detail, counterparty)
    end
    return Mzansi.Database.insert(
        "INSERT INTO mzansi_bank_transactions (character_id, tx_type, amount, balance_after, detail, counterparty) VALUES (?, ?, ?, ?, ?, ?)",
        characterId, txType, amount or 0, balanceAfter or 0, detail or "", counterparty or ""
    )
end

function Mzansi.Database.query(sql, ...)
    Mzansi.Database.lazyConnect()
    if not Mzansi.Database._pool then
        outputDebugString("[Mzansi-DB] No database connection!", 1)
        return nil
    end
    local adapted = adaptQuery(sql, Mzansi.Database._driver)
    local qh = dbQuery(Mzansi.Database._pool, adapted, ...)
    if not qh then return nil end
    local result = dbPoll(qh, 1000)
    if result == nil then
        dbFree(qh)
        outputDebugString("[Mzansi-DB] Query timed out (1000ms): " .. tostring(sql):sub(1, 60), 2)
        return nil
    end
    return result
end

function Mzansi.Database.insert(sql, ...)
    Mzansi.Database.lazyConnect()
    if not Mzansi.Database._pool then
        outputDebugString("[Mzansi-DB] No database connection!", 1)
        return nil
    end
    local adapted = adaptQuery(sql, Mzansi.Database._driver)
    local qh = dbQuery(Mzansi.Database._pool, adapted, ...)
    if not qh then return nil end
    local result, numAffected, lastInsert = dbPoll(qh, 1000)
    if result == nil then
        dbFree(qh)
        outputDebugString("[Mzansi-DB] Insert timed out (1000ms): " .. tostring(sql):sub(1, 60), 2)
        return nil
    end
    return lastInsert
end

function Mzansi.Database.update(sql, ...)
    Mzansi.Database.lazyConnect()
    if not Mzansi.Database._pool then
        outputDebugString("[Mzansi-DB] No database connection!", 1)
        return false
    end
    local adapted = adaptQuery(sql, Mzansi.Database._driver)
    return dbExec(Mzansi.Database._pool, adapted, ...)
end

function Mzansi.Database.delete(sql, ...)
    return Mzansi.Database.update(sql, ...)
end

function Mzansi.Database.getAccount(username)
    local result = Mzansi.Database.query(
        "SELECT * FROM mzansi_accounts WHERE LOWER(username) = LOWER(?) LIMIT 1",
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

function Mzansi.Database.getPlayerInvestments(charId)
    return Mzansi.Database.query(
        "SELECT * FROM mzansi_investments WHERE owner_id = ?",
        charId
    ) or {}
end

function Mzansi.Database.getAllInvestments()
    return Mzansi.Database.query(
        "SELECT * FROM mzansi_investments"
    ) or {}
end

function Mzansi.Database.createInvestment(ownerId, investmentKey, principal, ratePerCycle)
    return Mzansi.Database.insert(
        "INSERT INTO mzansi_investments (owner_id, investment_key, principal, accrued_interest, rate_per_cycle) VALUES (?, ?, ?, 0, ?)",
        ownerId, investmentKey, principal, ratePerCycle
    )
end

function Mzansi.Database.updateInvestment(investmentId, data)
    local fields = {}
    local values = {}
    for k, v in pairs(data) do
        fields[#fields + 1] = k .. " = ?"
        values[#values + 1] = v
    end
    values[#values + 1] = investmentId
    local sql = "UPDATE mzansi_investments SET " .. table.concat(fields, ", ") .. " WHERE id = ?"
    return Mzansi.Database.update(sql, unpack(values))
end

function Mzansi.Database.deleteInvestment(investmentId)
    return Mzansi.Database.delete("DELETE FROM mzansi_investments WHERE id = ?", investmentId)
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

-- ============================================================
-- ADMIN HELPERS
-- ============================================================

--- Returns all accounts joined with their primary character (if any).
--- Used by the admin panel to list all registered members (online + offline).
function Mzansi.Database.getAllAccounts()
    if not Mzansi.Database._pool then return {} end
    local query = [[
        SELECT
            a.id            AS account_id,
            a.username,
            a.admin_level,
            a.banned,
            a.ban_reason,
            a.last_login,
            a.created_at,
            a.serial,
            c.id            AS char_id,
            c.first_name,
            c.last_name,
            c.cash,
            c.bank,
            c.job,
            c.faction,
            c.level
        FROM mzansi_accounts a
        LEFT JOIN mzansi_characters c ON c.account_id = a.id
        ORDER BY a.last_login DESC
        LIMIT 500
    ]]
    local result = dbQuery(Mzansi.Database._pool, adaptQuery(query, Mzansi.Database._driver))
    if not result then return {} end
    local rows = {}
    while true do
        local row = dbFetch(result)
        if not row then break end
        rows[#rows + 1] = row
    end
    return rows
end

--- Marks an account as banned with the provided reason.
--- @param accountId  number  The account's primary key.
--- @param reason     string  Human-readable ban reason.
--- @return boolean   true if update succeeded.
function Mzansi.Database.banAccount(accountId, reason)
    if not Mzansi.Database._pool or not accountId then return false end
    reason = tostring(reason or "Banned by admin.")
    local result = Mzansi.Database.update(
        "UPDATE mzansi_accounts SET banned = 1, ban_reason = ? WHERE id = ?",
        reason, accountId
    )
    return result ~= false
end

--- Export wrapper: getAllAccounts
function database_getAllAccounts()
    return Mzansi.Database.getAllAccounts()
end

--- Export wrapper: banAccount
function database_banAccount(accountId, reason)
    return Mzansi.Database.banAccount(accountId, reason)
end

--- Export wrapper: raw query pass-through (used by mzansi_admin accounts tab)
function database_query(sql, ...)
    return Mzansi.Database.query(sql, ...)
end

addEventHandler("onResourceStart", resourceRoot, function()
    Mzansi.Database.connect()
end)
