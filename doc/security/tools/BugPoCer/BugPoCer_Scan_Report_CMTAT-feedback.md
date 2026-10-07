# BugPoCer Scan Report — Maintainer Feedback

**Tool:** Olympix BugPoCer (agentic PoC-generating scanner)
**Report:** `BugPoCer_Scan_Report_CMTAT.pdf` — scan run 17 Jul 2026, findings *re-seeded from the 24 Jun 2026 scan of commit `49544f4`* (the `v3.2.0` release) ("Intercept demo: matches prior-scan TP").
**Triaged against:** **CMTAT v3.3.0-rc2 / rc3** (`dev` @ `8d3029d`) — **not** v3.2.0.
**Reviewer:** CMTA maintainers.
**Related PR:** [#387](https://github.com/CMTA/CMTAT/pull/387) — related to the BugPoCer scan, **not merged** (the project did not want to take all of its content).

> **Important context — version mismatch.** This feedback triages the report against **CMTAT v3.3.0-rc2/rc3** (branch `dev`, commit `8d3029d`), *not* CMTAT v3.2.0. BugPoCer's PoCs were generated and "proven true" against an **older commit** (`49544f4`), predating the v3.3.0-rc2/rc3 remediation work. Several file paths in the report no longer exist (`modules/internal/common/EnforcementModuleLibrary.sol` freeze logic, `modules/wrapper/controllers/ValidationModule.sol` layout has since changed) and most findings were remediated in the intervening work (notably the Nethermind AuditAgent v3.3.0-rc2 cycle). Every finding below was re-verified line-by-line against the **v3.3.0-rc2/rc3** source. A "True Positive" verdict from the tool means *reproducible on `49544f4`*, **not** *present on the reviewed v3.3.0-rc2/rc3 code*.

## Outcome

**21 findings (2 High · 7 Medium · 12 Low).** On the reviewed **CMTAT v3.3.0-rc2/rc3** code (`dev` @ `8d3029d`):

- **4.1.1 resolved by documentation (option 2)** — forced enforcement ops intentionally survive deactivation; the behaviour is now documented and the misleading "no operation after deactivation" wording corrected.
- **2 doc fixes applied** — 4.3.4, 4.3.7 (misleading NatSpec corrected).
- **13 already fixed** in code (the over-frozen cluster + operator/zero-address/mint findings).
- **5 accepted as design / informational** (trusted-engine DoS, optimistic view semantics, dual-interface events).

## Summary table

Fix commits were located with `git log -S` between the scanned commit `49544f4` (v3.2.0) and HEAD. `6434930` and `f6aceb2` (the 4.1.1 documentation and the 4.3.4 / 4.3.7 NatSpec) were made after the triage commit `8d3029d`, as follow-ups to this feedback.

| # | Sev | Title | Disposition on `dev` | Fix commit |
|---|-----|-------|----------------------|------------|
| 4.1.1 | High | Missing Deactivation Guard (forcedBurn/forcedTransfer) | Documented (intentional, option 2) | [`6434930`](https://github.com/CMTA/CMTAT/commit/6434930) |
| 4.1.2 | High | Unchecked Overfrozen Balance Underflow | Fixed | [`5982e79`](https://github.com/CMTA/CMTAT/commit/5982e79), [`087b127`](https://github.com/CMTA/CMTAT/commit/087b127) |
| 4.2.1 | Med | Overfrozen Balance Transfer DoS | Fixed | [`5982e79`](https://github.com/CMTA/CMTAT/commit/5982e79), [`087b127`](https://github.com/CMTA/CMTAT/commit/087b127) |
| 4.2.2 | Med | Unchecked Overfrozen Balance | Fixed | [`5982e79`](https://github.com/CMTA/CMTAT/commit/5982e79), [`087b127`](https://github.com/CMTA/CMTAT/commit/087b127) |
| 4.2.3 | Med | Unchecked Frozen Token Cap | Fixed | [`5982e79`](https://github.com/CMTA/CMTAT/commit/5982e79), [`087b127`](https://github.com/CMTA/CMTAT/commit/087b127) |
| 4.2.4 | Med | Burn Operator Context Bypass | Fixed | [`7a7c975`](https://github.com/CMTA/CMTAT/commit/7a7c975) |
| 4.2.5 | Med | Missing Zero Address Validation (batch freeze) | Fixed | [`a61bdb0`](https://github.com/CMTA/CMTAT/commit/a61bdb0) |
| 4.2.6 | Med | Incomplete Mint Validation | Fixed | [`087b127`](https://github.com/CMTA/CMTAT/commit/087b127) (recipient check present in v3.2.0 (`49544f4`)) |
| 4.2.7 | Med | Snapshot Hook After State Update | Accepted (design) | — |
| 4.3.1 | Low | External Call DoS (snapshot engine) | Accepted (trusted engine) | — |
| 4.3.2 | Low | View Validation Mismatch (zero-address) | Acknowledged (view semantics) | — |
| 4.3.3 | Low | Incomplete Predicate View (`canTransact`) | Acknowledged (view semantics) | — |
| 4.3.4 | Low | Misleading Access-Control Doc — `burn(uint256)` | Fixed (doc) | [`f6aceb2`](https://github.com/CMTA/CMTAT/commit/f6aceb2) |
| 4.3.5 | Low | Rule Engine Setter Invariant Mismatch | Addressed (public reverts same-value) | — (present in v3.2.0 (`49544f4`)) |
| 4.3.6 | Low | Inconsistent Compliance View (zero-to-zero) | Acknowledged (view semantics) | — |
| 4.3.7 | Low | Misleading Access-Control Doc — `onlyEnforcer` | Fixed (doc) | [`f6aceb2`](https://github.com/CMTA/CMTAT/commit/f6aceb2) |
| 4.3.8 | Low | Zero Address Transfer Validation Mismatch | Acknowledged (view semantics) | — |
| 4.3.9 | Low | Misleading Burn Authority Surface | Acknowledged (documented elsewhere) | — |
| 4.3.10 | Low | Overfrozen Balance Accounting Corruption | Fixed (dup of 4.1.2) | [`5982e79`](https://github.com/CMTA/CMTAT/commit/5982e79), [`087b127`](https://github.com/CMTA/CMTAT/commit/087b127) |
| 4.3.11 | Low | Cross-Interface Event Inconsistency (`setTerms`) | Addressed (both setters emit) | — (present in v3.2.0 (`49544f4`)) |
| 4.3.12 | Low | Approve Missing Pause Protection (Light) | Fixed | [`96e8012`](https://github.com/CMTA/CMTAT/commit/96e8012) |

---

## High

### 4.1.1 — Missing Deactivation Guard · **Documented (intentional — option 2)**
**Fix commit:** [`6434930`](https://github.com/CMTA/CMTAT/commit/6434930) — docs (`doc/README.md`, `doc/technical/stablecoin.md`) and NatSpec on `forcedBurn` / `_forcedTransfer`.

**Claim:** After `pause()` → `deactivateContract()`, `forcedBurn` (Light) and `forcedTransfer` still change balances/`totalSupply`, whereas the normal `burn`/`mint` paths revert with `EnforcedDeactivation`.

**Status on `dev`: intended behaviour, now documented.** The forced paths deliberately skip the pause/deactivation validation:
- `contracts/modules/0_CMTATBaseCore.sol` `forcedBurn` → `ERC20Upgradeable._burn(account, value)` directly, guarded only by `isFrozen(account)`.
- `contracts/modules/internal/ERC20EnforcementModuleInternal.sol` `_forcedTransfer` — moves tokens via `_update` without `_requireNotPaused` / `_requireNotDeactivated`.
- By contrast `ValidationModule._canMintByModuleAndRevert` / `_canBurnByModuleAndRevert` (`wrapper/controllers/ValidationModule.sol`) both call `_requireNotDeactivated()`.

This is the enforcer's regulatory tool: it must work while transfers are paused, and per **ERC-8343** a named privileged operation may remain available after deactivation (e.g. to sweep a frozen or migrated position on a terminated token). The maintainers chose **option 2 (document, keep the behaviour)**. `doc/technical/lifecycle.md` already stated this correctly; the fix corrected the remaining absolute wording and added the carve-out everywhere it was missing:

- `doc/README.md` — replaced *"it is no longer possible to perform transfer and burn/mint operations"* with the deactivation carve-out; added `forcedBurn` to the *Post-deactivation privileged operations* list, with the ERC-8343 rationale and the `DEFAULT_ADMIN_ROLE` key-management caveat.
- `doc/technical/stablecoin.md` — replaced *"All state-changing operations revert"* with the precise split (holder/standard revert; `forcedBurn`/`forcedTransfer` + freeze setters remain).
- NatSpec — added an explicit note to `ERC20EnforcementModuleInternal._forcedTransfer` and `CMTATBaseCore.forcedBurn` that they bypass pause/deactivation by design and survive deactivation per ERC-8343.

The consolidated reference (`doc/technical/lifecycle.md` §"what each state blocks", and the `doc/README.md` burn/mint summary table showing `forcedTransfer` ✔ while deactivated) is consistent with this.

### 4.1.2 — Unchecked Overfrozen Balance Underflow · **Fixed**
**Fix commits:** [`5982e79`](https://github.com/CMTA/CMTAT/commit/5982e79) — underflow-safe `_checkActiveBalance` / `_getActiveBalanceOf` (frozen > balance); [`087b127`](https://github.com/CMTA/CMTAT/commit/087b127) — `_setFrozenTokens` rejects `address(0)` (NM-15/17).

**Claim:** `setFrozenTokens` can set `frozenTokens > balance` (and on `address(0)`), so `balance − frozenTokens` underflows in the active-balance readers, bricking transfers/mints.

**Status on `dev`: fixed.** Both readers short-circuit before any subtraction, and `address(0)` is rejected:
- `ERC20EnforcementModuleInternal.sol:164` `_checkActiveBalance`: `if (frozenTokensLocal >= balance) { return (value == 0, 0); }` — no subtraction when over-frozen.
- `ERC20EnforcementModuleInternal.sol:190` `_getActiveBalanceOf`: `if (frozenTokens >= balance) return 0;`.
- `ERC20EnforcementModuleInternal.sol:41` `_setFrozenTokens`: reverts `CMTAT_ERC20EnforcementModule_ZeroAddressNotAllowed()` for `address(0)`, so mints can no longer be bricked via the zero sentinel.

Over-freezing a real holder is still *possible by design* (absolute setter), but is now **inert** (active balance floors at 0) rather than a DoS. Covered by the enforcement tests (infinite/zero-boundary and zero-address cases).

## Medium

### 4.2.1 / 4.2.2 / 4.2.3 — Overfrozen Transfer DoS / Unchecked Overfrozen Balance / Frozen Token Cap · **Fixed**
**Fix commits:** [`5982e79`](https://github.com/CMTA/CMTAT/commit/5982e79), [`087b127`](https://github.com/CMTA/CMTAT/commit/087b127) (same as 4.1.2).

All three are the same root cause as 4.1.2 (over-frozen underflow, including the `address(0)` mint-brick). Fixed by the same underflow-safe readers and the `address(0)` guard above. No separate action.

### 4.2.4 — Burn Operator Context Bypass · **Fixed**
**Fix commit:** [`7a7c975`](https://github.com/CMTA/CMTAT/commit/7a7c975) — `_burnOverride` / `_mintOverride` in `CMTATBaseCommon` pass `_msgSender()` instead of `address(0)`.

**Claim:** `burnFrom` drops the operator before validation — old `_burnOverride` hardcoded `_checkTransferred(address(0), …)`, so the RuleEngine saw the no-operator `transferred(from,to,value)` hook and spender-specific compliance was skipped.

**Status on `dev`: fixed.** `CMTATBaseCommon._burnOverride` (`0_CMTATBaseCommon.sol:139`) now passes `_checkTransferred(_msgSender(), account, address(0), value)`. On the `burnFrom` path `_msgSender()` is the operator (set at the entry, `ERC20CrossChainModule.sol:92`), so it reaches `ValidationModuleRuleEngine._transferred` with a non-zero spender → the **spender-aware** 4-arg overload runs `canTransferFrom` / spender-frozen checks. (This dispatch is now independently regression-tested — see `RuleEngineSpenderDispatchCommon.js`.)

### 4.2.5 — Missing Zero Address Validation (batch freeze) · **Fixed**
**Fix commit:** [`a61bdb0`](https://github.com/CMTA/CMTAT/commit/a61bdb0) — `_addAddressToTheList` reverts `CMTAT_Enforcement_ZeroAddressNotAllowed()`.

**Claim (per PoC):** Freezing `address(0)` bricks every direct `transfer`, because `transfer` passes `address(0)` as the spender sentinel and the frozen-check then rejects it.

**Status on `dev`: fixed.** `address(0)` can no longer be frozen: both single and batch freeze funnel through `EnforcementModuleInternal._addAddressToTheList` (`:38`), which reverts `CMTAT_Enforcement_ZeroAddressNotAllowed()`. Asserted for `setAddressFrozen` **and** `batchSetAddressFrozen` in `EnforcementModuleCommon.js`.

### 4.2.6 — Incomplete Mint Validation · **Fixed**
**Fix commit:** [`087b127`](https://github.com/CMTA/CMTAT/commit/087b127) for the `address(0)` mint brick. The recipient-frozen check was already present in v3.2.0 (`49544f4`) (`_canMintBurnByModuleAndRevert`), and was split into the directional `_canMintByModuleAndRevert` in [`f8531f3`](https://github.com/CMTA/CMTAT/commit/f8531f3).

**Claim:** Base `_checkTransferred` validates only the source, ignoring the recipient; and over-freezing the `address(0)` sentinel bricks mints.

**Status on `dev`: fixed.** The deployed bases validate the recipient on mint:
- Light: `CMTATBaseCore._mintOverride` (`0_CMTATBaseCore.sol:252`) → `ValidationModule._canMintByModuleAndRevert(to)` → checks recipient `isFrozen` (`ERC7943CannotReceive`) **and** `_requireNotDeactivated()`.
- RuleEngine / Allowlist bases override `_checkTransferred` to run the engine / allowlist on the recipient.

The `address(0)`-sentinel brick is independently closed by the `_setFrozenTokens` zero-address guard (4.1.2). Tested (`testCanTransferReturnsFalseForMintToFrozenAddress`, allowlist `ERC7943CannotReceive`).

### 4.2.7 — Snapshot Hook After State Update · **Accepted (design)**

**Claim:** Balances update *before* the snapshot hook, so the engine observes post-transfer state.

**Status on `dev`: not a defect.** `CMTATBaseSnapshot._update` (`0_CMTATBaseSnapshot.sol:19`) captures `fromBalanceBefore` / `toBalanceBefore` / `totalSupplyBefore` **before** `ERC20Upgradeable._update`, then passes those pre-values explicitly to `operateOnTransfer(...)`. The engine records the correct historical (pre-update) state; the SnapshotEngine is a trusted, admin-set component. The call ordering (after the mutation, with before-values as arguments) is intentional. No change.

## Low

### 4.3.4 — Misleading Access-Control Doc, `burn(uint256)` · **Fixed (doc)**
**Fix commit:** [`f6aceb2`](https://github.com/CMTA/CMTAT/commit/f6aceb2).
`ERC20CrossChainModule.sol` `burn(uint256)` NatSpec previously said *"Protected by the modifier `onlyBurnerFrom`"* while the function uses `onlySelfBurn`. Corrected to *"Protected by the modifier `onlySelfBurn` (BURNER_SELF_ROLE)."*

### 4.3.7 — Misleading Access-Control Doc, `onlyEnforcer` · **Fixed (doc)**
**Fix commit:** [`f6aceb2`](https://github.com/CMTA/CMTAT/commit/f6aceb2).
`EnforcementModule.sol` previously commented `onlyEnforcer` as *"restrict access to the burner functions"*, but it gates **address-freeze** mutations. Corrected to *"restrict access to the address-freeze functions (via `_authorizeFreeze`, ENFORCER_ROLE)."*

### 4.3.9 — Misleading Burn Authority Surface · **Acknowledged**
`ERC20BurnModule`'s `BURNER_ROLE` is not the whole burn surface — cross-chain adds `crosschainBurn` / `burnFrom` / `burn` under `CROSS_CHAIN_ROLE` / `BURNER_FROM_ROLE` / `BURNER_SELF_ROLE`. This is documented in `doc/technical/access-control.md` and the module pages; no code change. (Could add a cross-reference in the `ERC20BurnModule` NatSpec if desired.)

### 4.3.11 — Cross-Interface Event Inconsistency (`setTerms`) · **Addressed**
**Fix commit:** none — both `Terms` emits were already present in v3.2.0 (`49544f4`).
Both setters now emit a `Terms` event: the ICMTAT overload `ExtraInformationModule.setTerms(DocumentInfo)` (`:78`) → `_setTerms` → `emit Terms($._terms)`, and the ERC-7551 overload `ERC7551Module.setTerms(bytes32,string)` (`:56`) → `emit Terms(hash_, uri_)`. The two events have different signatures by virtue of being on two different interfaces (ICMTAT struct event vs ERC-7551 flat event); this is an interface-design consequence, not a missing event. No listener is left without an event.

### 4.3.12 — Approve Missing Pause Protection (Light) · **Fixed**
**Fix commit:** [`96e8012`](https://github.com/CMTA/CMTAT/commit/96e8012) — `ValidationModuleAllowance` (pause check on `approve`) added to Light (`CMTATBaseCore`).
`ValidationModuleAllowance._canAuthorizeAllowanceByModuleAndRevert` (`ValidationModuleAllowance.sol:45`) calls `_requireNotPaused()` for any non-zero `approve`, and Light (`CMTATBaseCore`) inherits it. Zero-value **revocation** is intentionally allowed while paused (NM-3/8). So allowances can no longer be *created/increased* while paused, in Light or the full variants.

### 4.3.5 — Rule Engine Setter Invariant Mismatch · **Addressed**
**Fix commit:** none — the same-value revert was already present in v3.2.0 (`49544f4`).
The public `setRuleEngine` (`ValidationModuleRuleEngine.sol:51`) reverts `CMTAT_ValidationModule_SameValue()` on an unchanged value before writing/emitting, so no misleading same-value `RuleEngine` event is observable through the public API. The internal setter is only reached with a changed value (or once at init). No change.

### 4.3.2 / 4.3.3 / 4.3.6 / 4.3.8 — View-semantics cluster · **Acknowledged, no code change**
These concern the **read-only** predicates (`canTransfer`, `canTransferFrom`, `canTransact`, `detectTransferRestriction`) being optimistic for zero-address endpoints (a `from == address(0)` query is evaluated as a *mint* check, `to == address(0)` as a *burn* check) or for `canTransact` not folding in pause/deactivation/RuleEngine state. These mirror the ERC-1404 / ERC-7943 view semantics and are **advisory pre-checks**: the authoritative state-changing paths (`transfer`, `transferFrom`, `mint`, `burn`) enforce every guard and revert. No funds risk. If desired, we can tighten the views to reject explicit zero-address endpoints and align `canTransact` with the full transfer guards, but this is a semantics/UX refinement, not a security fix.

### 4.3.1 — External Call DoS (snapshot engine) · **Accepted (trusted engine)**
Every balance change calls `snapshotEngine.operateOnTransfer` without try/catch, so a broken/malicious engine can halt transfers. The SnapshotEngine (like the RuleEngine/Document/Debt engines) is an **admin-set, trusted** dependency — a misbehaving engine can DoS but cannot seize or corrupt balances, and the fix is to set a correct engine (or `address(0)` to disable). This trust boundary is documented in the engines section; deliberately no isolation, to keep snapshot recording atomic with the transfer. No change.

---

## Suggested follow-ups

1. ~~Decide 4.1.1~~ — **done (option 2, documented):** kept the behaviour, documented that forced enforcement survives deactivation, and corrected the absolute wording in `doc/README.md` / `doc/technical/stablecoin.md` plus NatSpec.
2. ~~Fix the two NatSpec comments (4.3.4, 4.3.7)~~ — **done.**
3. *(Optional)* tighten the advisory views (4.3.2/3/6/8) and add a burn-authority cross-reference (4.3.9).
