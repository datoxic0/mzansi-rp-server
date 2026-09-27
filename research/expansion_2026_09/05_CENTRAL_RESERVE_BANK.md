# Dossier 05: Central / Reserve Bank
**Mode**: Zero-Temperature Deep Research
**Physical Targets**:
- `mzansi_core/server/world_populator.lua:16` — `CENTRAL_BANK` marker ("Standard Bank — Central")
- `mzansi_core/server/activity_system.lua:44–47` — teller NPC "Forex & Transfers"; L600 "Central Bank Lobby"
- `mzansi_core/server/banking.lua` — full consumer bank
- `mzansi_core/shared/config.lua:17–18` — `interestRate=0.02`, `taxRate=0.05`
- Interest application: `mzansi_jobs/server/jobs.lua:93–97` payday only

**Status**: Audited — flavor only, **no reserve mechanics**

---

## 1. Gap

| Element | Exists? |
|---------|---------|
| Physical central bank location + NPCs | YES |
| Consumer deposit/withdraw/transfer/loans | YES |
| Monetary policy (set rates) | NO |
| Interbank settlement | NO |
| Money supply tracking | NO |
| taxRate enforced | NO — config echoed `banking.lua:348–349` but **never charged** (confirmed prior session) |
| Lender of last resort | NO |

**PARTIAL → design full reserve layer.**

---

## 2. Target Design

### 2.1 Roles

| Role | Access |
|------|--------|
| Player | consumer bank UI (existing) |
| Business/Gang | group accounts (Dossier 03) |
| **Reserve Governor** (admin/special job) | rate panel, open market ops, emergency liquidity |
| System (Angel) | apply rates at tick, settle interbank, enforce reserve ratio |

### 2.2 Core tables (concept)

```
mzansi_reserve_policy(id=1, policy_rate, reserve_ratio, tax_rate, discount_rate, updated_at, updated_by)
mzansi_money_supply(snapshot_at, m0_cash, m1_deposits, m2_with_interest_proxy)
mzansi_interbank(from_acct, to_acct, amount, reason, created_at)
```

### 2.3 Mechanics (game-realistic, not academic)

1. **Policy rate** → scales personal interest + loan APR (replace hard-coded payday interest with `jobs.lua` reading policy).
2. **Reserve ratio** → sum of group+personal deposits must cover configured %; Angel warns admin if breached (event log, not player-visible crash).
3. **Tax** → actually implement: payday tax % or transfer fee already exists — wire `taxRate` into transfer fee formula or salary net (choose one; document).
4. **Open market ops** (admin): inject/sink cash by buying/selling a reserve bond instrument → affects liquidity for markets (04).
5. **Emergency liquidity**: gang/business overdraft window with penalty fee — last-resort Angel.
6. **Settlement**: group↔personal transfers clear through reserve ledger row (audit).

### 2.4 UI

- Admin/reserve panel: current rates, money supply sparkline, recent interbank ops
- Player-facing: only show "Central Bank policy rate" as tooltip in bank UI (transparency)

### 2.5 Where it lives

- Prefer **inside mzansi_core** (protected resource): `server/reserve_bank.lua` + shared policy config — avoids cross-VM export pain
- Or dedicated `mzansi_reserve` resource if we want independent restart — **recommendation: core** (needs banking internals)

---

## 3. Failure Modes

| Mode | Remediation |
|------|------------|
| Deflation spiral from over-tight policy | clamp policy_rate to [0, 0.15]; admin confirm |
| Double interest (payday + reserve) | single interest function called once |
| taxRate still dead | explicit unit test: transfer/salary charges tax |
| Admin key compromise | reserve ops require role=admin + audit row |

---

## 4. Verification

- Set policy_rate 0.05 → next payday interest = deposits * 0.05 (± rounding)
- Transfer shows tax if configured
- Interbank row appears on settlement
- luac -p + meta audit

## 5. Angels

- **Policy Angel**: apply rates on timer
- **Supply Angel**: periodic money aggregates snapshot
- **Solvency Angel**: reserve ratio warning
- **Audit Angel**: every reserve op logged
