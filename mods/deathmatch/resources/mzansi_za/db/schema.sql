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

CREATE INDEX IF NOT EXISTS idx_mzansi_players_account ON mzansi_players(account_name);
CREATE INDEX IF NOT EXISTS idx_mzansi_players_serial ON mzansi_players(serial);
