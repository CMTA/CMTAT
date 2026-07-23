# ERC-3643 Implementation In CMTAT

## Scope

This document explains how CMTAT implements ERC-3643 semantics, where it intentionally diverges from the T-REX profile, and how the implementation is composed across modules and deployment variants.

Reference specification used for comparison: [doc/ERCSpecification/erc-3643-trex.md](../ERCSpecification/erc-3643-trex.md).

## Executive Summary

CMTAT implements a substantial ERC-3643-compatible token surface (pause, freeze, partial freeze, forced transfer, mint/burn, batch operations, compliance pre-checks), but it does not embed the full T-REX identity stack (`IdentityRegistry`, `TrustedIssuersRegistry`, `ClaimTopicsRegistry`, `onchainID` plumbing). Instead, CMTAT externalizes transfer eligibility/compliance to a configurable RuleEngine/validation architecture and uses RBAC roles instead of the Owner/Agent governance model described in T-REX.

## Interface Coverage

Primary CMTAT interface:
- [IERC3643Partial.sol](/home/ryan/Pictures/dev/CMTAT/contracts/interfaces/tokenization/IERC3643Partial.sol)

Implemented ERC-3643-related interface groups in CMTAT:
- `IERC3643Pause`
- `IERC3643ERC20Base`
- `IERC3643BatchTransfer`
- `IERC3643Version`
- `IERC3643Enforcement` and `IERC3643EnforcementEvent`
- `IERC3643ERC20Enforcement`
- `IERC3643Mint`
- `IERC3643Burn`
- `IERC3643ComplianceRead`
- `IERC3643IComplianceContract` (implemented by RuleEngine side, not token side)

## Requirement Mapping (T-REX -> CMTAT)

1. ERC-20 compatibility: implemented.
2. On-chain identity system mandatory: not implemented in-core (intentional gap).
3. Compliance rules on transfers: implemented through RuleEngine/validation hooks.
4. Standard pre-check before transfer: implemented (`canTransfer` and related checks).
5. Recovery system (lost key): not implemented in core CMTAT.
6. Freeze wallet / partial freeze: implemented.
7. Pause token: implemented.
8. Mint and burn: implemented.
9. Agent + Owner role model: replaced by granular RBAC roles.
10. Forced transfers by privileged operator: implemented.
11. Batch operations: implemented (batch mint/burn/transfer/freeze operations depending on module).

## Module-Level Implementation

Core ERC-3643 behavior is split across wrapper modules:

- Pause:
  - [PauseModule.sol](/home/ryan/Pictures/dev/CMTAT/contracts/modules/wrapper/core/PauseModule.sol)
  - Implements `pause`, `unpause`, `paused`.

- Token metadata updates:
  - [TokenAttributeModule.sol](/home/ryan/Pictures/dev/CMTAT/contracts/modules/wrapper/core/TokenAttributeModule.sol)
  - Implements `setName`, `setSymbol` (moved out of `ERC20BaseModule` into `TokenAttributeModule`, with their own ERC-7201 storage; `ERC20BaseModule` now holds only `decimals`).

- Mint / batch mint / ERC-3643 batch transfer path:
  - [ERC20MintModule.sol](/home/ryan/Pictures/dev/CMTAT/contracts/modules/wrapper/core/ERC20MintModule.sol)
  - `batchTransfer` is role-gated and mapped to internal minter-transfer flow.

- Burn / batch burn:
  - [ERC20BurnModule.sol](/home/ryan/Pictures/dev/CMTAT/contracts/modules/wrapper/core/ERC20BurnModule.sol)

- Address freeze:
  - [EnforcementModule.sol](/home/ryan/Pictures/dev/CMTAT/contracts/modules/wrapper/core/EnforcementModule.sol)
  - Implements `setAddressFrozen`, `batchSetAddressFrozen`, `isFrozen`.

- Partial freeze and forced transfer:
  - [ERC20EnforcementModule.sol](/home/ryan/Pictures/dev/CMTAT/contracts/modules/wrapper/extensions/ERC20EnforcementModule.sol)
  - Implements `freezePartialTokens`, `unfreezePartialTokens`, `forcedTransfer`, `getFrozenTokens`.

- Compliance pre-check surface:
  - [ValidationModuleCore.sol](/home/ryan/Pictures/dev/CMTAT/contracts/modules/wrapper/core/ValidationModuleCore.sol)
  - Implements `canTransfer`; integrates with generic validation path.

## Deployment Coverage

From deployment composition, ERC-3643 functionality is not all-or-nothing across every variant.

- Standard (`CMTATStandardStandalone`, `CMTATStandardUpgradeable`):
  - Includes the main ERC-3643-compatible tokenization surface (without T-REX identity stack).

- Light:
  - Reduced surface; intended minimal feature set.

- Allowlist / Debt / DebtEngine / Snapshot / ERC-7551 / ERC-1363 / Permit:
  - Inherit different subsets/extensions; ERC-3643-related behavior is preserved where inherited modules remain in the chain.

For exact variant inheritance, see [doc/SUMMARY.md](../SUMMARY.md) and the deployment table in [doc/README.md](../README.md).

## Main Differences Vs ERC-3643 T-REX

1. Identity architecture omitted in-core.
CMTAT does not natively expose T-REX token getters/setters like `identityRegistry()`, `compliance()`, `setIdentityRegistry()`, `setCompliance()`, `onchainID()`, or identity-registry contract suite APIs.

2. Governance model differs.
T-REX relies on Owner/Agent role conventions; CMTAT uses granular `AccessControl` roles (admin, minter, burner, enforcers, etc.).

3. Compliance integration model differs.
T-REX couples token and compliance/identity contracts in a canonical stack; CMTAT uses pluggable RuleEngine/validation modules and can operate without on-chain identity.

4. Extended events and overloads.
CMTAT emits additional events and supports extra overloads (for example `bytes data` in several flows), which are beyond the strict minimal ERC-3643 interface profile.

5. `batchTransfer` semantics.
CMTAT models ERC-3643 `batchTransfer` through minter-controlled transfer logic; this is not identical to every T-REX token implementation assumption and should be treated as CMTAT policy design.

6. Freeze event layering.
At base level (ERC-7943 enforcement core), CMTAT uses `Frozen(account, amount)` as a normalized frozen-state update event for both increase and decrease of frozen balances. For ERC-3643 direction semantics, wrapper modules emit `TokensFrozen` and `TokensUnfrozen`. Integrations requiring freeze/unfreeze direction should consume ERC-3643 (or ERC-7551) directional events.

## Practical Integration Notes

If strict T-REX parity is required, a dedicated deployment variant should add:
- token-level identity/compliance contract bindings (`identityRegistry`, `compliance`, `onchainID`),
- identity-registry stack contracts and wiring,
- recovery flows (`recoveryAddress`) and associated history/events,
- any missing batch administrative functions expected by a target T-REX integration.

If the objective is regulated transfer control without on-chain identity, current CMTAT architecture is intentional and already provides strong compliance hooks.

## Cross-References

- ERC-3643 reference: [erc-3643-trex.md](../ERCSpecification/erc-3643-trex.md)
- CMTAT partial interface: [IERC3643Partial.sol](/home/ryan/Pictures/dev/CMTAT/contracts/interfaces/tokenization/IERC3643Partial.sol)
- Main README ERC-3643 section: [doc/README.md](../README.md)
