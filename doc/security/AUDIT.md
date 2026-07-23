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

| Version    | File                                                         |
| ---------- | ------------------------------------------------------------ |
| v3.1.0     | [nethermind-audit-agent/v3.1.0](./tools/nethermind-audit-agent/v3.1.0) |
| v3.0.0-rc5 | [nethermind-audit-agent/v3.0.0-rc5](./tools/nethermind-audit-agent/v3.0.0-rc5) |

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
