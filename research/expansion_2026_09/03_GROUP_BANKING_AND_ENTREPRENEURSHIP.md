# Dossier 03: Group Banking (Gangs) & Entrepreneurship Banking
**Mode**: Zero-Temperature Deep Research
**Physical Targets**:
- `mzansi_gangs/server/gangs.lua` (deposit/withdraw events L8–23; **balance writes L506, L538**)
- `mzansi_gangs/server/database.lua:189` — table has `treasury`, NOT `balance`
- `mzansi_gangs/client/gangs_client.lua:50–55, 165`
- `mzansi_core/server/database.lua:194–196` — `mzansi_business_ownership` CREATE only
- `mzansi_core/server/banking.lua` — consumer bank + loan tiers (Business R150k–500k at L16–21)
- `mzansi_core/shared/enums.lua:17` — `BUSINESS_OWNER = 12`
- `mzansi_housing/shared/housing_config.lua:15` — 1 static business property

**Status**: Audited — **CRITICAL BUG CONFIRMED**

---

## 1. Findings

### 1.1 Gang banking is BROKEN today (Chaotic → Act First)

| Claim | Evidence |
|-------|----------|
| SQL updates column `balance` | `gangs.lua:506`, `gangs.lua:538` |
| Schema column is `treasury` | `database.lua:189` CREATE `treasury` |
| `balance` column on `mzansi_gangs` does not exist | table def review; `balance` at L167 belongs to `mzansi_business_ownership` |
| In-memory balance init 0, never loaded | `gangs.lua:36` |
| Client shows balance | `gangs_client.lua:165` |

**Consequence**: deposit/withdraw SQL errors; group banking non-functional.

### 1.2 Entrepreneurship banking = dead schema

| Fact | Evidence |
|------|----------|
| Table created | `database.lua:194–196` |
| Zero runtime INSERT/UPDATE/SELECT on `mzansi_business_ownership` | exhaustive grep |
| Job enum exists | `BUSINESS_OWNER = 12` |
| Loan product exists | `banking.lua:16–21` Business tier |
| Only one business property | `housing_config.lua:15` |

**Status: PARTIAL (schema only).**

### 1.3 No generic "group account"

grep `group.?account|GroupAccount|joint.?account` → **zero** across resources.

---

## 2. Target Design

### 2.1 Fix first (Clear / Chaotic-stabilize)

1. Align gang money column: either rename code to `treasury` **or** `ALTER TABLE mzansi_gangs ADD COLUMN balance` — **prefer `treasury` as canonical** (matches schema + gang semantics).
2. Load treasury on character/gang load into memory; persist on change.
3. Authorization: leader/officer ranks only (existing rank field); audit log every txn.

### 2.2 Unified Group Account layer (new)

Generic table (conceptually):

```
mzansi_group_accounts(
  id, owner_type ENUM('gang','business','faction','club'),
  owner_id INT, name, balance BIGINT,
  created_at, updated_at
)
mzansi_group_transactions(
  id, account_id, char_id, tx_type, amount,
  balance_after, detail, created_at
)
```

- **Gangs**: migrate to this (or wrap treasury as account_id).
- **Businesses**: activate `mzansi_business_ownership` → account row per business; revenue events (housing rent, market sales) credit account.
- **Factions** (SAPS/EMS): optional read-only stipend accounts.
- UI: extend bank UI tab **"Groups"** + gang panel deposit/withdraw (fixed).

### 2.3 Authorization matrix

| Action | Who |
|--------|-----|
| View balance | member |
| Deposit | any member with cash |
| Withdraw | leader + treasurer rank |
| Transfer to personal | leader only |
| Statement | leader |

### 2.4 Entrepreneurship banking

- Business account = group account owner_type=business
- Payroll: BUSINESS_OWNER payday draws from business account if cash short (config)
- Loan collateral: business account balance can freeze against Business loan tier
- P&L: `mzansi_group_transactions` filter by business_id

---

## 3. Failure Modes

| Mode | Remediation |
|------|------------|
| Schema mismatch (existing bug) | Single source of truth column; migration in `runMigrations()` |
| SQL injection via names | parameterized queries (existing `?` pattern) |
| Rank spoofing | server-only rank check; `client or source` |
| Double-spend race | transactional update `UPDATE ... balance = balance + ? WHERE id = ?` then verify affected rows |
| Interest on group accounts | config flag; apply at same payday timer as personal interest |

---

## 4. Verification

```text
1. Deposit gang R1000 → SELECT treasury reflects 1000 after restart
2. Withdraw without rank → denied
3. Business account receive rent → balance_after logged
4. luac -p + meta src audit 0
```

## 5. Angels

- **Ledger Angel**: every group mutation writes `*_transactions` row
- **Rank Angel**: withdraw path re-validates rank server-side
- **Migration Angel**: `runMigrations()` idempotent column checks
