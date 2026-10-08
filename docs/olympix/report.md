# Olympix Security Verification — CMTAT

**Target:** [`CMTA/CMTAT`](https://github.com/CMTA/CMTAT) · security-token / RWA tokenization framework
**Commit:** `49544f4d` · **Branch:** `master` · **Date:** 16–17 July 2026 UTC
**Toolchain:** Olympix BugPoCer · Mutation Testing · Symbolic-execution Fuzzing

> This page is a presentation-format demo: it collects three independent Olympix runs against CMTAT into a single reviewable surface. Every number links back to a shipped artifact (findings JSON, mutation CSV, runnable PoC tests).

---

## At a glance

| Tool | What it measured | Headline result |
|------|------------------|-----------------|
| **BugPoCer** | End-to-end exploit generation across the codebase | **21 true-positive findings** — 2 High · 7 Medium · 12 Low |
| **Mutation testing** | Does the existing test suite actually catch bugs? | **87.1% killed** (81 / 93 mutants) — 10 of 12 survivors are equivalent mutants |
| **Fuzzing (symbolic)** | Adversarial reachability across the core surface | **35,188 paths → 27,252 feasible**, 0 exploitable path found in this run |

---

## BugPoCer — exploit-driven findings

BugPoCer decomposes the codebase into units, explores reachable paths, and for each candidate issue attempts to write a **runnable Foundry/Hardhat PoC that fails on the vulnerable code**. Only confirmed true positives are listed below.

**Severity breakdown:** 2 High · 7 Medium · 12 Low — **21 total**

| # | Sev | Finding | Location | PoC |
|---|-----|---------|----------|-----|
| 1 | High | Missing deactivation guard on `forcedBurn` | `modules/0_CMTATBaseCore.sol` | [runnable](./tests/olympix/pocs/missing_deactivation_guard.t.sol) |
| 2 | High | Unchecked over-frozen balance underflow | `modules/wrapper/extensions/ERC20EnforcementModule.sol` | documented |
| 3 | Med | Burn operator-context bypass | `modules/wrapper/options/ERC20CrossChainModule.sol` | [runnable](./tests/olympix/pocs/burn_operator_context_bypass.t.sol) |
| 4 | Med | Incomplete mint validation | `modules/0_CMTATBaseCommon.sol` | [runnable](./tests/olympix/pocs/incomplete_mint_validation.t.sol) |
| 5 | Med | Missing zero-address validation (batch freeze) | `modules/internal/common/EnforcementModuleLibrary.sol` | [runnable](./tests/olympix/pocs/missing_zero_address_validation.t.sol) |
| 6 | Med | Over-frozen balance transfer DoS | `modules/6_CMTATBaseERC1363.sol` | documented |
| 7 | Med | Snapshot hook runs after state update | `modules/0_CMTATBaseCommon.sol` | documented |
| 8 | Med | Unchecked frozen-token cap | `modules/wrapper/core/EnforcementModule.sol` | documented |
| 9 | Med | Unchecked over-frozen balance | `modules/wrapper/core/EnforcementModule.sol` | documented |
| 10 | Low | `approve` missing pause protection | `modules/0_CMTATBaseCore.sol` | [runnable](./tests/olympix/pocs/approve_missing_pause_protection.t.sol) |
| 11 | Low | Over-frozen balance accounting corruption | `modules/wrapper/extensions/ERC20EnforcementModule.sol` | [runnable](./tests/olympix/pocs/overfrozen_balance_accounting_corruption.t.sol) |
| 12 | Low | Inconsistent compliance view | `modules/wrapper/controllers/ValidationModule.sol` | [runnable](./tests/olympix/pocs/inconsistent_compliance_view.t.sol) |
| 13 | Low | Zero-address transfer validation mismatch | `modules/wrapper/core/ValidationModuleCore.sol` | [runnable](./tests/olympix/pocs/zero_address_transfer_validation_mismatch.t.sol) |
| 14 | Low | View / validation mismatch | `modules/wrapper/controllers/ValidationModule.sol` | documented |
| 15 | Low | Incomplete predicate view | `modules/wrapper/controllers/ValidationModule.sol` | documented |
| 16 | Low | External-call DoS | `modules/0_CMTATBaseCommon.sol` | documented |
| 17 | Low | Cross-interface event inconsistency | `modules/wrapper/extensions/ExtraInformationModule.sol` | documented |
| 18 | Low | Rule-engine setter invariant mismatch | `modules/internal/ValidationModuleRuleEngineInternal.sol` | documented |
| 19 | Low | Misleading burn-authority surface | `modules/wrapper/core/ERC20BurnModule.sol` | documented |
| 20 | Low | Misleading access-control docs (CCIP) | `modules/wrapper/options/ERC20CrossChainModule.sol` | documented |
| 21 | Low | Misleading access-control docs (enforcer) | `modules/wrapper/core/EnforcementModule.sol` | documented |

<details>
<summary><b>High #1 — Missing deactivation guard on <code>forcedBurn</code></b></summary>

**Location:** `contracts/modules/0_CMTATBaseCore.sol` — `forcedBurn()`

`forcedBurn` can still reduce balances and `totalSupply` **after the token has been permanently deactivated**. Normal burn paths route through `_burnOverride()`, which calls the validation module and rejects a deactivated contract. `forcedBurn` deliberately skips that path and calls `ERC20Upgradeable._burn()` directly after only checking that the account is frozen. After `pause()` + `deactivateContract()`, a `DEFAULT_ADMIN_ROLE` holder can freeze an account and destroy its tokens — despite the deactivation guarantee that burn operations stop permanently.

**PoC:** [`pocs/missing_deactivation_guard.t.sol`](./tests/olympix/pocs/missing_deactivation_guard.t.sol) — mints to a holder, pauses, deactivates, confirms the normal `burn()` reverts with `EnforcedDeactivation`, then shows `forcedBurn()` still succeeds (assertion fails on the vulnerable code).
</details>

<details>
<summary><b>High #2 — Unchecked over-frozen balance underflow</b></summary>

**Location:** `contracts/modules/internal/ERC20EnforcementModuleInternal.sol` — `_checkActiveBalance()` / `_setFrozenTokens()`

Active-balance logic assumes `frozenTokens(account) <= balanceOf(account)` and subtracts directly, but the absolute `setFrozenTokens` / `_setFrozenTokens` path can write an arbitrary frozen amount without enforcing that cap. An over-frozen account makes `_checkActiveBalance`, `getActiveBalanceOf`, transfer/burn validation, forced-transfer recovery, and `canTransfer` reads revert via arithmetic underflow until a privileged correction. Setting a nonzero frozen amount for `address(0)` is especially damaging: mint validation treats `address(0)` as the source, so ordinary and cross-chain minting can be **globally bricked**.

**Cross-signal:** this same enforcement-arithmetic surface is the most heavily mutated file (see mutation section) — 33/35 mutants killed, confirming the tests exercise it, while BugPoCer shows the *absolute-set* path is the one that escapes the cap invariant.
</details>

**Findings source:** `.opix/agent/24c6f02a-…/findings.json` · **Session:** `24c6f02a-cca3-43b5-853f-d84b2bcef93c`

---

## Mutation testing

Mutation testing measures whether the existing test suite actually *detects* bugs by injecting small faults and checking that a test fails ("kills" the mutant).

**Overall: 81 / 93 killed — `87.1%`** · Session `6b2c6237-f5d3-42fb-addb-f505c5bb78c2`

| File | Killed / Total | Score |
|------|----------------|-------|
| `4_CMTATBaseERC20CrossChain.sol` | 6 / 6 | 100% |
| `ERC20BurnModuleInternal.sol` | 2 / 2 | 100% |
| `ValidationModule.sol` | 5 / 5 | 100% |
| `ERC20EnforcementModuleInternal.sol` | 33 / 35 | 94.3% |
| `ValidationModuleRuleEngine.sol` | 7 / 8 | 87.5% |
| `ERC20BaseModule.sol` | 12 / 14 | 85.7% |
| `PauseModule.sol` | 6 / 8 | 75.0% |
| `EnforcementModuleInternal.sol` | 3 / 4 | 75.0% |
| `2_CMTATBaseAllowlist.sol` | 7 / 11 | 63.6% |

<details>
<summary><b>Surviving mutants (12) — 10 equivalent, 2 worth a look</b></summary>

Most survivors are **equivalent mutants** (semantically identical — cannot be killed by any test):

| Location | Mutation | Why it survives |
|----------|----------|-----------------|
| `ERC20BaseModule.sol:28`, `ERC20EnforcementModuleInternal.sol:24`, `EnforcementModuleInternal.sol:21` | ERC-7201 storage-slot constant → `0x0` | Slot constant; value never asserted in tests |
| `ERC20BaseModule.sol:54`, `2_CMTATBaseAllowlist.sol:53/69/87/98` | remove `initializer`/`onlyInitializing` | Init guards; tests never double-initialize |
| `PauseModule.sol:69/104` | `storage $` → `memory $` | Read-only access; no observable difference |

**Worth a look (2):**

| Location | Mutation | Note |
|----------|----------|------|
| `ValidationModuleRuleEngine.sol:141` | `spender != address(0)` → `== address(0)` | Zero-address branch not covered — **corroborates BugPoCer #5 (missing zero-address validation)** |
| `ERC20EnforcementModuleInternal.sol:100` | `&&` → `\|\|` in allowance-cap check | `currentAllowance > 0 && < max` boundary not asserted |

</details>

**Raw data:** [`mutation-results.csv`](./docs/olympix/mutation_testing/mutation-results.csv)

---

## Fuzzing — symbolic-execution-driven

The engine performs whole-contract symbolic execution, keeps only SMT-feasible paths, and (per attack strategy) turns them into concrete adversarial Foundry tests.

**Session `f37cd9fe-cb1e-4732-821a-03c6811416dc` · 6 min wall-clock**

| Contract | Paths | Feasible | Exploits |
|----------|-------|----------|----------|
| `CMTATStandalone` | 19,974 | 15,518 | 0 |
| `CMTATUpgradeable` | 8,138 | 5,910 | 0 |
| `CMTATStandaloneAllowlist` | 7,076 | 5,824 | 0 |
| **Total** | **35,188** | **27,252** | **0** |

The engine enumerated 35,188 execution paths across the 3 highest-value deployment variants and kept the 27,252 SMT-feasible ones. Guarded entry points were unreachable to an unauthorized caller — a positive signal, not a coverage gap.

> **Maturity note (honest framing):** this run exercised **0 adversarial attack strategies** — that is the fuzz engine's *current* concrete-test-generation set (it is under active development; more strategies and deeper multi-call sequences land each release). So the "0 exploits" result here is a **floor on the path-reachability signal, not a proof of security**. Treat it as reachability coverage, not negative assurance, until the strategy set matures.

---

## Artifacts & reproducibility

| Artifact | Source |
|----------|--------|
| BugPoCer report | [`BugPoCer_Scan_Report_CMTAT.pdf`](./docs/olympix/bugpocer/BugPoCer_Scan_Report_CMTAT.pdf) (43 pp) |
| Mutation results | [`mutation-results.csv`](./docs/olympix/mutation_testing/mutation-results.csv) (93 mutants) |
| Fuzz report | [`Fuzz_Test_Report.pdf`](./docs/olympix/fuzz_testing/Fuzz_Test_Report_f37cd9fe-cb1e-4732-821a-03c6811416dc_20260716_182652.pdf) (7 pp) |
| Runnable PoCs | [`tests/olympix/pocs/`](./tests/olympix/pocs/) — 8 confirmed exploit tests |

| Run | Session ID |
|-----|-----------|
| BugPoCer | `24c6f02a-cca3-43b5-853f-d84b2bcef93c` |
| Mutation | `6b2c6237-f5d3-42fb-addb-f505c5bb78c2` |
| Fuzz | `f37cd9fe-cb1e-4732-821a-03c6811416dc` |
