# CMTAT Feedback on Sequent Pre-Verification Report

Date: 2026-05-13  
Source reviewed: `doc/general/feedback/sequent-report-CMTAT.pdf`

## Table of Contents
- [Scope and Method](#scope-and-method)
- [Findings Summary](#findings-summary)
- [Executive Summary](#executive-summary)
- [Finding-by-Finding Assessment](#finding-by-finding-assessment)
  - [1) Reverting snapshot engine can halt state-changing operations](#1-reverting-snapshot-engine-can-halt-state-changing-operations)
  - [2) `setFrozenTokens` can exceed balance and break internal assumptions](#2-setfrozentokens-can-exceed-balance-and-break-internal-assumptions)
  - [3) Operator identity propagation in burn/mint/cross-chain RuleEngine paths](#3-operator-identity-propagation-in-burnmintcross-chain-ruleengine-paths)
  - [4) `setAddressFrozen(address(0))` should be rejected](#4-setaddressfrozenaddress0-should-be-rejected)
- [Action Plan for Next Release](#action-plan-for-next-release)

## Scope and Method
This feedback cross-checks each Sequent finding against the current CMTAT codebase and current architecture decisions (including recent deployment-variant split changes).

## Findings Summary
| # | Finding | Assessment | Status | Affected Releases | Fixed Commit | Report Severity (Sequent) | Severity (CMTAT Maintainer Perspective) | Severity Rationale (with Access Control Context) |
|---|---|---|---|---|---|---|---|---|
| 1 | Reverting snapshot engine can halt state-changing operations | Valid liveness/trust-boundary risk in snapshot-enabled variants | Accepted (open) | v3.0.0, v3.1.0, v3.2.0 (snapshot-enabled variants) | N/A (design/ops hardening pending) | Medium | Informational | Primarily a design/operational trust-boundary issue: snapshot engine address is configured via privileged roles, so arbitrary users cannot trigger this path by themselves; impact depends on governance hygiene. |
| 2 | `setFrozenTokens` can exceed balance and break internal assumptions | Valid internal-consistency issue under ERC-7943 permissive semantics | Fixed (with specification nuance) | v3.2.0 | `5982e79` | Medium | Medium | Trigger path is role-gated (`ERC20ENFORCER_ROLE`/admin-controlled workflows). The issue was due to missing robustness checks for `frozen > balance`; behavior is now hardened while keeping ERC-7943 permissive semantics by design. |
| 3 | Operator identity propagation in burn/mint/cross-chain RuleEngine paths | Valid policy-consistency gap for operator-aware RuleEngine policies | Fixed | v3.0.0, v3.1.0, v3.2.0 (only when RuleEngine is enabled and rules target spender/operator) | `10e87ff`, `7a7c975` | Medium | Informational | Initial design intentionally targeted spender checks primarily in the `transferFrom` path, which is not access-controlled. The gap was about policy scope consistency (not privilege bypass), and became relevant only for deployments relying on spender/operator-aware RuleEngine rules outside classic `transferFrom`. |
| 4 | `setAddressFrozen(address(0))` should be rejected | Valid misuse vector enabling unintended global blocking patterns | Fixed | v3.0.0, v3.1.0, v3.2.0 | `a61bdb0` | Medium (linked to Sequent Finding 2) | Low | Invocation is access-controlled (`ENFORCER_ROLE`/admin) and operationally reversible: admin can revoke compromised enforcer privileges and rollback the freeze state; no direct theft vector. |

## Finding-by-Finding Assessment

### 1) Reverting snapshot engine can halt state-changing operations
Status: **Accepted (snapshot-enabled deployments)**

#### Assessment
- For deployments including SnapshotEngine, a reverting snapshot engine can cause transfer-path reverts.
- This is a trust-boundary/liveness risk tied to privileged configuration.
- The impact is reduced in variants where snapshot was removed from standard flow.
- Snapshot behavior has been separated by deployment version, reducing unintended coupling in non-snapshot variants.

#### CMTAT Maintainer Position
- Accepted as an expected risk in snapshot-enabled variants unless additional governance controls are applied.
- This risk is now explicitly documented in CMTAT documentation (`doc/technical/snapshot.md` and access-control notes) as a transfer-liveness halt scenario if a reverting snapshot engine is configured.

#### Planned Action
- Clarify trust assumptions in docs and evaluate stronger governance constraints for `setSnapshotEngine` (allowlist/timelock/process controls).

#### Operational Runbook
If this occurs in production:
1. **Containment**
   - Revoke `SNAPSHOOTER_ROLE` from non-emergency operators.
   - If available in the deployment, pause token operations with the dedicated pause authority.
2. **Diagnosis**
   - Confirm transfer-path reverts originate from snapshot engine callback execution.
   - Verify current `snapshotEngine()` and recent privileged role actions.
3. **Recovery**
   - Set snapshot engine to `address(0)` (disable) or to a known-good approved engine.
   - Re-test representative state-changing flows (transfer/mint/burn/forced transfer) with small amounts.
4. **State reconciliation**
   - Reconcile planned snapshot schedules and any off-chain dependencies before resuming normal operations.
5. **Hardening**
   - Enforce multisig + timelock for snapshot engine changes.
   - Keep an allowlist of approved engine addresses/bytecode.
   - Add monitoring alerts for revert spikes after snapshot-engine updates.

---

### 2) `setFrozenTokens` can exceed balance and break internal assumptions
Status: **Fixed (with specification nuance)**

#### Assessment
- Sequent correctly identifies internal-path fragility when `frozen > balance` interacts with active-balance logic.
- However, ERC-7943 spec text explicitly allows this behavior:
  - `setFrozenTokens` MUST allow freezing more assets than currently held.
  - `getFrozenTokens` MAY exceed current balance.
- If internal logic is not hardened for this state, concrete consequences include:
  - unexpected reverts in transfer paths due to underflow-prone active-balance arithmetic;
  - incorrect `getActiveBalanceOf` behavior for wallets and integrators relying on that view;
  - forced-transfer/unfreeze workflows failing or behaving inconsistently under extreme frozen states;
  - operational incidents where compliance teams can set a legally valid frozen amount but trigger unintended token liveness issues;
  - mismatch between off-chain assumptions and on-chain execution, increasing integration and monitoring risk.

Example flow with actors:
1. **Issuer Admin** mints `100` tokens to **Investor A**.
2. **Compliance Officer** (has `ERC20ENFORCER_ROLE`) calls `setFrozenTokens(InvestorA, 150)` to pre-freeze future inflows (ERC-7943-permissive scenario).
3. **Investor A** still has on-chain `balance = 100`, `frozen = 150`.
4. **Custodian UI / Middleware** reads `getActiveBalanceOf(InvestorA)` to determine transferable amount.
5. If arithmetic is not hardened, this read path or subsequent transfer checks can revert with Solidity arithmetic underflow panic (`panic code 0x11`) instead of cleanly returning active balance `0`.
6. **Transfer Agent** attempts a compliance `forcedTransfer` of `20` from **Investor A** to **Investor B**.
7. If unfreeze/active-balance math is not robust to `frozen > balance`, forced transfer can revert with Solidity arithmetic underflow panic (`panic code 0x11`) before enforcement logic completes, creating an operational incident despite valid permissions.

#### CMTAT Maintainer Position
- This is not a pure ERC-7943 non-compliance issue.
- It was a CMTAT internal consistency issue caused by missing robustness checks when `frozen > balance`.
- The issue is remediated, while ERC-7943 permissive behavior remains an intentional design choice.

#### Clarification: Theft Risk and Recovery Procedure
- This issue is **not** a direct token-theft issue by itself.
- It does **not** grant unauthorized transfer rights to arbitrary actors.
- The main risk is operational/liveness failure (reverts, blocked compliance operations, inconsistent transfer behavior).

Safe recovery procedure (without allowing holder free transfer):
1. Keep the holder blocked at account level (`setAddressFrozen(holder, true)`) when available.
2. Use privileged enforcement role to normalize frozen accounting with `setFrozenTokens(holder, safeAmount)` under your selected policy/model.
3. If legal/compliance workflow requires custody movement, use `forcedTransfer(holder, recoveryWallet, amount)` while the holder remains frozen.
4. Reconcile balances/frozen values off-chain and on-chain before any unfreeze.
5. Unfreeze only when policy checks are complete and incident state is closed.

#### Planned Action
- Continue regression and edge-case test coverage around `frozen > balance` states under the retained ERC-7943 permissive model.

---

### 3) Operator identity propagation in burn/mint/cross-chain RuleEngine paths
Status: **Fixed**

#### Assessment
- Operator identity is not consistently propagated to RuleEngine write-path hooks in these flows.
- This can diverge from issuer expectations when operator-specific controls are used.
- This concern applies only to CMTAT deployments where RuleEngine is configured and the active rules explicitly target spender/operator semantics.

#### CMTAT Maintainer Position
- This was a policy-consistency issue, not a role-check bypass.
- The issue is remediated with operator-as-spender propagation and dedicated regression tests.
- Mint operator semantics are now explicitly documented: mint/crosschainMint propagate the effective operator as spender in compliance/RuleEngine paths.
- Side effect: `ENFORCER_ROLE` can block mint operations by freezing the minter/operator address (`setAddressFrozen`), since the minter is evaluated as spender in these paths.

#### Implementation Update (Current State)
- Initial behavior (no spender/operator propagation on some mint/burn/cross-chain paths) was a deliberate design choice focused on simple transfer semantics and role-gated module calls.
- After review, CMTAT decided to implement operator-as-spender propagation because it is a relevant feature for compliance policies and extends the RuleEngine use cases.
- The effective operator (`_msgSender()`) is now propagated into RuleEngine write-path checks for:
1. `burn`
2. `batchBurn`
3. `burnFrom`
4. `mint`
5. `batchMint`
6. `crosschainBurn`
7. `crosschainMint`
- Practical effect: RuleEngine policies can now differentiate and restrict operations based on the acting operator (treated as spender), not only on `from`/`to`/`amount`.
- `burnFrom` is treated as an access-controlled operator burn path (not as a classic `transferFrom` policy path). In hook-level parameters, `burn` and `burnFrom` both appear as burn semantics (`to == address(0)`), so RuleEngine cannot distinguish them from `(spender, from, to, value)` alone.
- Therefore, `burnFrom`-specific restrictions must be implemented by targeting the operator addresses authorized for `burnFrom` (role-scoped policy at RuleEngine level).

---

### 4) `setAddressFrozen(address(0))` should be rejected
Status: **Fixed**

#### Assessment
- Implemented zero-address guard in enforcement internal path.
- Added tests covering direct and batch freeze calls.
- Similar zero-address hardening also added to partial freeze/unfreeze paths.
- This hardening is linked to Sequent Finding 2 (`setFrozenTokens` / `address(0)` accounting side effects): both concern `address(0)`-based freeze states impacting transfer/mint paths.
- For report-severity mapping, this item is aligned to the same Sequent severity level as Finding 2 (**Medium**).
- This issue was also flagged before the Sequent report by Nethermind Audit Agent on the CMTAT Confidential version, with **Informational** severity: https://github.com/CMTA/CMTAT/issues/372

#### CMTAT Maintainer Position
- Resolved.
- CMTA maintainer severity is **Low** because:
1. the entry points are protected by privileged roles (`ENFORCER_ROLE` / admin-managed authorization), so unprivileged actors cannot directly trigger it;
2. there is no direct theft path from this issue;
3. the effect is operationally reversible by governance actions (revoke compromised enforcer permissions and rollback freeze state).

## Action Plan for Next Release
1. `setFrozenTokens` policy is now aligned on the ERC-7943 permissive model; continue hardening/coverage with additional regression and edge-case tests around `frozen > balance` edge states.
2. Keep operator-identity regression coverage in place for burn/mint/cross-chain flows where RuleEngine spender/operator rules are used.
3. Strengthen and document snapshot-engine governance assumptions for snapshot-enabled deployments (multisig/timelock/allowlist and incident runbook enforcement).

## Final Position
CMTAT accepts Sequent’s report as materially valuable.  
We classify the findings as:
- `Accepted/Open`: snapshot liveness risk (snapshot-enabled variants).
- `Resolved`: `setFrozenTokens` internal consistency issue under ERC-7943 permissive semantics.
- `Resolved`: operator-identity propagation consistency for RuleEngine spender/operator policies.
- `Resolved`: zero-address freeze in enforcement paths.
