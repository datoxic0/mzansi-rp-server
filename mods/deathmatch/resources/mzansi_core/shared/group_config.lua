Mzansi = Mzansi or {}
Mzansi.GroupBank = Mzansi.GroupBank or {}

-- ==============================================================
-- GROUP ACCOUNT RANKS & PERMISSIONS
-- ==============================================================
-- withdrawLevel: minimum rank level to withdraw (matches gang rankLevel scale ~1-10)
Mzansi.GroupBank.Config = {
    MinDeposit = 1,
    MaxDeposit = 1000000,
    MinWithdraw = 1,
    MaxWithdraw = 500000,
    -- owner types
    OwnerTypes = {
        gang = "Gang",
        business = "Business",
        faction = "Faction",
        club = "Club",
    },
    -- which bank UI tabs can see groups
    ShowInBankUI = true,
}

-- ==============================================================
-- SCHEMA (created from database.lua createTables + migrations)
-- mzansi_group_accounts(
--   id, owner_type, owner_id, name, balance, withdraw_level,
--   created_at, updated_at
-- )
-- mzansi_group_transactions(
--   id, account_id, character_id, tx_type, amount,
--   balance_after, detail, created_at
-- )
-- ==============================================================
