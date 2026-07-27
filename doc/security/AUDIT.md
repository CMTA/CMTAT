# Security Tools — Reports and Summaries

> More details on running tools are available in [USAGE.md](../USAGE.md).

## [Aderyn](https://github.com/Cyfrin/aderyn)

Here are the reports produced by [Aderyn](https://github.com/Cyfrin/aderyn):

| Version | File                                                         |
| ------- | ------------------------------------------------------------ |
| v3.3.0  | [v3.3.0-aderyn-report.md](./tools/aderyn/v3.3.0-aderyn-report.md)<br />[v3.3.0-aderyn-feedback.md](./tools/aderyn/v3.3.0-aderyn-feedback.md) |
| v3.0.0  | [v3.0.0-aderyn-report.md](./tools/aderyn/archive/v3.0.0-aderyn-report.md) |

Summary (v3.3.0 — refreshed 2026-07-22, `aderyn 0.6.5`, mocks excluded, 101 files / 3736 nSLOC):

| Category | Tool Severity | Count | CMTAT Maintainer Assessment | Status |
| ------- | ------------- | ----- | --------------------------- | ------ |
| H-1..H-2 | High | 2 | Mixed (false positive H-1 + design choice H-2) | Reviewed |
| L-1..L-10 | Low | 10 | Mixed (valid, design choices, environment, style/optimization) | Reviewed |

**Nothing to fix** — no exploitable finding; the only valid, accept-and-mitigate item is L-1 Centralization (governance mitigation at deployment). See [feedback](./tools/aderyn/v3.3.0-aderyn-feedback.md).

## [Slither](https://github.com/crytic/slither)

Here are the reports produced by [Slither](https://github.com/crytic/slither):

| Version | File                                                         |
| ------- | ------------------------------------------------------------ |
| v3.3.0  | [v3.3.0-slither-report.md](./tools/slither/v3.3.0-slither-report.md)<br />[v3.3.0-slither-feedback.md](./tools/slither/v3.3.0-slither-feedback.md) |
| v3.0.0  | [v3.0.0-slither-report.md](./tools/slither/archive/v3.0.0-slither-report.md) |
| v2.3.0  | [v2.3.0-slither-report.md](./tools/slither/archive/v2.3.0-slither-report.md) |

Summary (v3.3.0 — refreshed 2026-07-22, `slither 0.11.5`, mocks excluded, 110 results):

| Detector | Tool Severity | Count | CMTAT Maintainer Assessment | Status |
| ------- | ------------- | ----- | --------------------------- | ------ |
| `uninitialized-local` | Medium | 1 | False positive (local defaults to `0`, intentional) | Closed |
| `unused-return` | Medium | 2 | False positive (DocumentEngine forwards / intentionally discards `lastModified`) | Closed |
| `calls-loop` | Low | 28 | Design choice (batch/hook external calls) | Accepted |
| `reentrancy-events` | Low | 2 | Design choice (ERC-1643 dual-emit after trusted engine call) | Accepted |
| `assembly` | Informational | 16 | Expected pattern (ERC-7201 slots) | Accepted |
| `dead-code` | Informational | 1 | False positive (mandatory `_msgData` override) | Closed |
| `naming-convention` | Informational | 60 | Style-only | Closed |

**Nothing to fix** — 0 High; both Medium and both Low categories are false positives or documented design choices. The two new detectors vs the prior snapshot (`unused-return`, `reentrancy-events`) both stem from the intentional ERC-1643 document-engine dual-emission. See [feedback](./tools/slither/v3.3.0-slither-feedback.md).

## [Mythril](https://github.com/Consensys/mythril)

Here are the reports produced by Mythril:

| Version | File                                                         |
| ------- | ------------------------------------------------------------ |
| v3.0.0  | Mythril currently generates a fatal error, impossible to run the tool |
| v2.5.0  | [mythril-report-standalone.md](./tools/mythril/v2.5.0/myth_standalone_report.md)<br />[mythril-report-proxy.md](./tools/mythril/v2.5.0/myth_proxy_report.md) |

## [Nethermind Audit Agent](https://auditagent.nethermind.io)

Here are the reports produced by [Nethermind Audit Agent](https://auditagent.nethermind.io):

> **Note: these scans were performed by an AI-powered automated tool, not a formal human-led audit.** AuditAgent's
> own notice states the report is "generated entirely by AI … not a full security audit … must be independently
> verified". The linked feedback files are that independent verification by CMTA maintainers.

| Version      | File                                                         |
| ------------ | ------------------------------------------------------------ |
| v3.3.0-rc2   | [audit_agent_report_v3.3.0-rc2.pdf](./tools/nethermind-audit-agent/v3.3.0-rc2/audit_agent_report_v3.3.0-rc2.pdf)<br />[audit_agent_report_v3.3.0-rc2-feedback.md](./tools/nethermind-audit-agent/v3.3.0-rc2/audit_agent_report_v3.3.0-rc2-feedback.md) |
| v3.1.0       | [nethermind-audit-agent/v3.1.0](./tools/nethermind-audit-agent/v3.1.0) |
| v3.0.0-rc5   | [nethermind-audit-agent/v3.0.0-rc5](./tools/nethermind-audit-agent/v3.0.0-rc5) |

### Results by version

| Version | High | Medium | Low | Info | Best practices | Anything to fix? |
| ------- | ---: | -----: | --: | ---: | -------------: | ---------------- |
| v3.3.0-rc2 | 1 | 4 | 3 | 14 | 2 | **3 defects fixed** (NM-15/17 zero-address guard, NM-3/8 allowance revocation, NM-22 terms name), NM-7 cluster partially fixed (reentrancy guard where size permits); NM-4/6/20/21/24 documented. Nothing exploitable; the High is a false positive; **no open item**. |
| v3.1.0 | 2 | 2 | 10 | — | — | No — 7 invalid, 7 design choices. |

### v3.3.0-rc2 (Scan ID 9, 2026-07-23, commit `35d8940b…9d92e4ae`)

**24 findings** (1 high, 4 medium, 3 low, 14 info, 2 best practices) across 100 contracts / 8067 LoC. Triage
outcome: **5 fixed (behaviour) · 1 fixed doc-only (NM-24) · 14 accepted as design · 4 rejected (false positive /
false premise)** (NM-15/NM-17 and NM-3/NM-8 are duplicate pairs, so the five behaviour fixes cover three distinct
defects; the NM-7 cluster is additionally guarded on the variants with bytecode headroom).

| ID | Title | Severity (tool → CMTA) | Disposition |
| --- | --- | --- | --- |
| NM-1 | Uninitialized proxy can be seized by the first caller to `initialize` | High → Info | Rejected (false positive) |
| NM-2 | Anyone can claim an uninitialized proxy by calling `initialize` first | Medium → Info | Rejected (duplicate of NM-1) |
| NM-3 | Paused/restricted holders cannot revoke stale allowances | Medium → Low | **Fixed** |
| NM-4 | Inconsistent context resolution (`msg.sender` vs `_msgSender()`) in the bridge gate | Medium → Info | Rejected (intentional) — **deployment constraint documented** (never grant `CROSS_CHAIN_ROLE` to the ERC-2771 forwarder) |
| NM-5 | Missing freeze enforcement on `spender` for `burnFrom` / minter transfers | Medium → Info | Design choice (spender propagation traced + probed; freeze is a holder-level control, `revokeRole` is the operator lever) |
| NM-6 | Zero-value delegated transfers mutate RuleEngine state | Low → Info | Design choice (RuleEngine responsibility) — **documented** in `IRuleEngine` NatSpec + RuleEngine integration notes |
| NM-7, NM-9, NM-11, NM-16, NM-18 | RuleEngine callback runs before balance effects (reentrancy ordering) | Low / Info ×4 → Low | **Partially fixed** — OZ `ReentrancyGuardTransient` on variants with bytecode headroom (Standard, Snapshot, ERC-7551); others documented (trusted RuleEngine) |
| NM-8 | Allowance revocation blocked for frozen/non-allowlisted spenders | Low → Low | **Fixed** (same change as NM-3) |
| NM-10 | Documented two-step default-admin protection is absent | Info → Info | Rejected (false premise — quotes OpenZeppelin's own comment) |
| NM-12 | `setDocument` emits raw inputs instead of the engine post-state | Info → Info | Design choice (documented dual-emission) |
| NM-13, NM-14, NM-19 | Engine setters accept `address(this)` / non-compliant addresses | Info ×3 → Info | Design choice (privileged, recoverable) — ERC-165 hardening tracked in [#395](https://github.com/CMTA/CMTAT/issues/395) |
| **NM-15, NM-17** | **`setFrozenTokens` can freeze the zero address and brick all mint paths** | **Info ×2 → Low** | **Fixed** |
| NM-20 | Pausing disables privileged burn interfaces | Info → Info | Design choice — **documented**; pause stops **third-party/bridge** supply ops (`burnFrom`, self-burn, `crosschainMint/Burn`), **issuer** ops (`BURNER_ROLE` burn, mint, enforcement) survive |
| NM-21 | Mutable token name desynchronizes the EIP-712 domain separator | Info → Info | Design choice — **documented**; probed: `permit` still works via ERC-5267 `eip712Domain()`, so the reported DoS does not occur |
| **NM-22** | **ERC-7551 `setTerms` overload silently erases the document name** | **Info → Info** | **Fixed** |
| NM-23 | `detectTransferRestrictionFrom` reports `SPENDER_FROZEN` before deactivated/paused | Best practice → Info | Design choice (reporting nit, no bypass) |
| **NM-24** | **Unconditional `Spend` emission contradicts `IERC20Allowance` NatSpec** | **Best practice → Info** | **Fixed (doc-only)** — NatSpec corrected; consistency improvement in [allowance-spend-event.md](../technical/allowance-spend-event.md) |

**Nothing exploitable by an unprivileged actor and no funds at risk.** The single High and its Medium duplicate
are false positives (implementations call `_disableInitializers()`; proxies are initialized atomically). The last
best-practice item, the stale `IERC20Allowance.Spend` NatSpec (NM-24), has been corrected (doc-only), leaving **no
open item**. Full rationale per finding: [feedback](./tools/nethermind-audit-agent/v3.3.0-rc2/audit_agent_report_v3.3.0-rc2-feedback.md).

**Substantive findings addressed in this release:**

| ID | Fix | Files / tests |
| --- | --- | --- |
| NM-3 / NM-8 | `_canAuthorizeAllowanceByModuleAndRevert` now takes the allowance `value` and returns early when it is zero, so setting an allowance to zero — a revocation, which can only reduce a spender's reach — is always authorized, including while paused/deactivated or when the owner or spender is frozen or off the allowlist. Non-zero grants stay gated exactly as before; the redundant `whenNotPaused` modifier was removed from the two `approve` overrides (the pause check lives inside the internal function). | `contracts/modules/wrapper/extensions/ValidationModule/ValidationModuleAllowance.sol`, `0_CMTATBaseCore.sol`, `3_CMTATBaseRuleEngine.sol`, `3_CMTATBaseAllowlist.sol`, `6_CMTATBaseERC2612.sol` (`permit`); 7 regression tests across `test/common/{PauseModuleCommon,EnforcementModuleCommon,AllowlistModuleCommon}.js`, including two negative guards. |
| NM-22 | The ERC-7551 `setTerms(bytes32,string)` overload — whose signature carries no document name — now updates only the document (`uri`, `documentHash`, `lastModified`) via a new internal `_setTermsDocument`, instead of forwarding an empty name through `_setTerms` and silently erasing a name set through the `ICMTATBase` overload. | `contracts/modules/wrapper/extensions/ExtraInformationModule.sol`, `contracts/modules/wrapper/options/ERC7551Module.sol`; `testERC7551SetTermsPreservesDocumentName` in `test/common/ERC7551ModuleCommon.js` (the pre-existing `testAdminCanUpdateTerms` had encoded the erasure and was corrected). |
| NM-15 / NM-17 | `_setFrozenTokens` now rejects `address(0)` with `CMTAT_ERC20EnforcementModule_ZeroAddressNotAllowed()`, matching `_freezePartialTokens` / `_unfreezePartialTokens` and `EnforcementModule`'s full-address freeze. Prevents an `ERC20ENFORCER_ROLE` holder from bricking every mint path (`mint`, `batchMint`, `crosschainMint`, the mint leg of `burnAndMint`) with a single call. | `contracts/modules/internal/ERC20EnforcementModuleInternal.sol`; 5 regression tests in `test/common/ERC20EnforcementModuleCommon.js` (a pre-existing test that pinned the buggy behaviour under the misleading name `testSetFrozenTokensOnZeroAddressDoesNotBreakMintFlow` was removed). |

### v3.1.0

The v3.1.0 report identified **14 findings** (2 high, 2 medium, 10 low). All findings were reviewed by CMTA maintainers; 7 were assessed as invalid and 7 were acknowledged as design choices. No finding required a code fix.

| N° | Title | Severity | Validity |
|----|-------|----------|----------|
| 1 | Partial-freeze not enforced on transfer path | High | Invalid |
| 2 | Unprotected `initialize()` allows front-running of proxy initialization | High | Invalid |
| 3 | Missing spender validation in transfer check function | Medium | Design choice |
| 4 | Missing contract validation for RuleEngine address | Medium | Design choice |
| 5 | Transfers ignore pause/deactivation in `CMTATBaseCommon` | Low | Design choice |
| 6 | Transfers to frozen recipients possible in `CMTATBaseCommon.transfer()` | Low | Design choice |
| 7 | Reentrancy window between unfreeze and balance update | Low | Invalid |
| 8 | `canTransfer`/`canTransferFrom` can return `true` when transfer would revert | Low | Design choice |
| 9 | SnapshotEngine hook bypassed in `_update` | Low | Design choice |
| 10 | RuleEngine spender hardcoded to `address(0)` for minter-initiated transfers | Low | Invalid |
| 11 | Forced transfers still enforced by standard validation | Low | Invalid |
| 12 | Inconsistent deactivation handling between `canTransfer()` and `detectTransferRestriction()` | Low | Invalid |
| 13 | `approve` not protected by pause modifier | Low | Design choice |
| 14 | ERC2771 forwarder set via constructor in upgradeable deployments | Low | Invalid |

A detailed response to each finding is available in [CMTAT_AuditAgent_Report_Comment_v3.1.0.md](./tools/nethermind-audit-agent/v3.1.0/CMTAT_AuditAgent_Report_Comment_v3.1.0.md).

## [Wake Arena](https://ackee.xyz) (Ackee Blockchain Security)

Here are the reports produced by [Wake Arena](https://ackee.xyz), an automated AI vulnerability analysis tool developed by Ackee Blockchain Security:

| Version      | File                                                         |
| ------------ | ------------------------------------------------------------ |
| v3.2.0-rc2   | [Wake Arena Report - CMTA: CMTAT-v3.2.0-rc2](./tools/ackee-wake-arena/Wake Arena Report - CMTA_ CMTAT-v3.2.0-rc2.pdf) |

> Ackee Blockchain Security, Wake Arena AI Report \| CMTA: CMTAT, February 10, 2026 12:24 UTC.

The report (v3.2.0-rc2, February 10, 2026) identified **6 findings** (0 critical, 0 high, 3 medium, 2 low, 1 info):

| ID | Title | Impact | Status |
|----|-------|--------|--------|
| M1 | Double invocation of compliance hook in `_minterTransferOverride` | Medium | Fixed |
| M2 | Double invocation of compliance hook in `_burnOverride` | Medium | Fixed |
| M3 | Double invocation of compliance hook in `_mintOverride` | Medium | Fixed |
| L1 | Misleading `Spend` event emitted on `transferFrom` when allowance is infinite | Low | Acknowledged (comment added) |
| L2 | Unmitigated ERC20 `approve` allowance change race condition | Low | Acknowledged – won't fix |
| I1 | Documentation mismatch: `_authorizeSelfBurn` comment referenced wrong role | Info | Fixed |

A detailed feedback and response to each finding is available in [CMTAT-wake-arena-feedback.md](./tools/ackee-wake-arena/CMTAT-wake-arena-feedback.md).

## [Sequent](https://www.sequent.inc) (Pre-verification Review)

Here are the reports produced by Sequent:

| Version | File |
| ------- | ---- |
| v3.3.0-pre | [sequent-report-CMTAT.pdf](./pre-review/sequent-report-CMTAT.pdf)<br />[SequentReport-feedback.md](./pre-review/SequentReport-feedback.md) |
