Mzansi = Mzansi or {}
Mzansi.DB = Mzansi.DB or {}

local DB_DRIVER = "sqlite"
local DB_NAME = "mzansi_za.db"

local dbConnection = nil

local function createTables(connection)
    local statements = {
        [[
            CREATE TABLE IF NOT EXISTS mzansi_players (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                serial VARCHAR(64) UNIQUE,
                account_name VARCHAR(64) UNIQUE,
                first_name VARCHAR(64),
                last_name VARCHAR(64),
                money INTEGER DEFAULT 0,
                bank INTEGER DEFAULT 0,
                job INTEGER DEFAULT 0,
                faction INTEGER DEFAULT 0,
                x FLOAT DEFAULT 0,
                y FLOAT DEFAULT 0,
                z FLOAT DEFAULT 0,
                rotation FLOAT DEFAULT 0,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP
            );
        ]],
        [[
            CREATE TABLE IF NOT EXISTS mzansi_businesses (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name VARCHAR(128),
                type VARCHAR(64),
                region VARCHAR(64),
                owner VARCHAR(64),
                rent INTEGER DEFAULT 0
            );
        ]],
        [[
            CREATE TABLE IF NOT EXISTS mzansi_properties (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name VARCHAR(128),
                type VARCHAR(64),
                region VARCHAR(64),
                rent INTEGER DEFAULT 0,
                owner VARCHAR(64)
            );
        ]],
        [[
            CREATE TABLE IF NOT EXISTS mzansi_vehicles (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name VARCHAR(128),
                model INTEGER DEFAULT 0,
                class VARCHAR(64),
                region VARCHAR(64),
                owner VARCHAR(64)
            );
        ]]
    }

    for _, query in ipairs(statements) do
        dbExec(connection, query)
    end
end

local function seedCatalogs(connection)
    local catalogChecks = {
        {
            table = "mzansi_businesses",
            query = [[SELECT COUNT(*) AS count FROM mzansi_businesses;]],
            values = {
                { "Mzanzi Fuel & Transport", "fuel", "Johannesburg", "Civilian", 1200 },
                { "Cape Town Logistics Hub", "logistics", "Cape Town", "Business", 2500 },
                { "Pretoria Medical Supply Co.", "medical", "Pretoria", "EMS", 1900 },
                { "Durban Auto Works", "mechanic", "Durban", "Mechanic", 1600 },
            },
        },
        {
            table = "mzansi_properties",
            query = [[SELECT COUNT(*) AS count FROM mzansi_properties;]],
            values = {
                { "Johannesburg Executive Flat", "apartment", "Johannesburg", 1200, "Civilian" },
                { "Cape Town Waterfront Office", "office", "Cape Town", 2500, "Business" },
                { "Pretoria Medical House", "medical", "Pretoria", 1900, "EMS" },
            },
        },
        {
            table = "mzansi_vehicles",
            query = [[SELECT COUNT(*) AS count FROM mzansi_vehicles;]],
            values = {
                { "Toyota Corolla Quest", 562, "Civilian", "Johannesburg", "" },
                { "VW Polo Vivo", 496, "Civilian", "Cape Town", "" },
                { "Ford Ranger XL", 577, "Utility", "Pretoria", "" },
                { "Toyota Hilux", 571, "Business", "Durban", "" },
            },
        },
    }

    for _, catalog in ipairs(catalogChecks) do
        local rows = dbPoll(dbQuery(connection, catalog.query), -1)
        local count = rows and rows[1] and tonumber(rows[1].count or 0) or 0

        if count == 0 then
            for _, row in ipairs(catalog.values) do
                if catalog.table == "mzansi_businesses" then
                    dbExec(connection, [[INSERT INTO mzansi_businesses (name, type, region, owner, rent) VALUES (?, ?, ?, ?, ?)]], row[1], row[2], row[3], row[4], row[5])
                elseif catalog.table == "mzansi_properties" then
                    dbExec(connection, [[INSERT INTO mzansi_properties (name, type, region, rent, owner) VALUES (?, ?, ?, ?, ?)]], row[1], row[2], row[3], row[4], row[5])
                elseif catalog.table == "mzansi_vehicles" then
                    dbExec(connection, [[INSERT INTO mzansi_vehicles (name, model, class, region, owner) VALUES (?, ?, ?, ?, ?)]], row[1], row[2], row[3], row[4], row[5])
                end
            end
        end
    end
end

local function initDatabase()
    dbConnection = dbConnect(DB_DRIVER, DB_NAME)
    if not dbConnection then
        outputDebugString("[Mzansi-ZA] Failed to connect to SQLite database.", 1)
        return false
    end

    createTables(dbConnection)
    seedCatalogs(dbConnection)
    return true
end

function Mzansi.DB.connect()
    if dbConnection then
        return dbConnection
    end
    initDatabase()
    return dbConnection
end

function Mzansi.DB.getPlayerCharacter(accountName)
    local connection = Mzansi.DB.connect()
    if not connection then
        return nil
    end

    local result = dbQuery(connection, "SELECT * FROM mzansi_players WHERE account_name = ?", accountName)
    local rows = dbPoll(result, -1)
    return rows and rows[1] or nil
end

function Mzansi.DB.getPlayerCharacterBySerial(serial)
    local connection = Mzansi.DB.connect()
    if not connection then
        return nil
    end

    local result = dbQuery(connection, "SELECT * FROM mzansi_players WHERE serial = ?", serial)
    local rows = dbPoll(result, -1)
    return rows and rows[1] or nil
end

function Mzansi.DB.getCatalog(tableName)
    local connection = Mzansi.DB.connect()
    if not connection then
        return {}
    end

    local result = dbQuery(connection, "SELECT * FROM " .. tableName)
    local rows = dbPoll(result, -1)
    return rows or {}
end

function Mzansi.DB.savePlayerCharacter(player, data)
    local connection = Mzansi.DB.connect()
    if not connection then
        return false
    end

    local accountName = getAccountName(getPlayerAccount(player))
    local serial = getPlayerSerial(player)
    local firstName = tostring(data.firstName or data.first_name or "")
    local lastName = tostring(data.lastName or data.last_name or "")
    local money = tonumber(data.money or data.cash or 0)
    local bank = tonumber(data.bank or 0)
    local job = tonumber(data.job or Mzansi.Enums.Job.CIVILIAN)
    local faction = tonumber(data.faction or Mzansi.Enums.Faction.CIVILIAN)
    local x = tonumber(data.x or 0)
    local y = tonumber(data.y or 0)
    local z = tonumber(data.z or 0)
    local rotation = tonumber(data.rotation or 0)

    local result = dbQuery(connection, [[SELECT id FROM mzansi_players WHERE account_name = ? OR serial = ?]], accountName, serial)
    local rows = dbPoll(result, -1)

    if rows and rows[1] then
        dbExec(connection, [[
            UPDATE mzansi_players SET
                first_name = ?,
                last_name = ?,
                money = ?,
                bank = ?,
                job = ?,
                faction = ?,
                serial = ?,
                account_name = ?,
                x = ?,
                y = ?,
                z = ?,
                rotation = ?
            WHERE id = ?
        ]], firstName, lastName, money, bank, job, faction, serial, accountName, x, y, z, rotation, rows[1].id)
    else
        dbExec(connection, [[
            INSERT INTO mzansi_players (serial, account_name, first_name, last_name, money, bank, job, faction, x, y, z, rotation)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ]], serial, accountName, firstName, lastName, money, bank, job, faction, x, y, z, rotation)
    end

    return true
end

addEventHandler("onResourceStart", resourceRoot, function()
    Mzansi.DB.connect()
end)
