# ERC-7943 (uRWA) Integration

> [ERC specification](https://eips.ethereum.org/EIPS/eip-7943) / [Ethereum Magicians](https://ethereum-magicians.org/t/erc-7943-universal-rwa-interface-urwa/23972)
>
> Status: Review

## Overview

ERC-7943 defines a standard set of interfaces for tokenized Real World Assets (RWAs). It extends ERC-20 (or ERC-721/ERC-1155) with essential compliance functions — transfer restrictions, asset freezing, forced transfer — while remaining minimal and unopinionated about internal implementation.

CMTAT implements the fungible (`IERC7943Fungible`) variant of ERC-7943. The ERC-165 interface ID for the fungible interface is `0x3edbb4c4`.

## Interface Breakdown

All related interfaces are defined in [`draft-IERC7943.sol`](../../contracts/interfaces/tokenization/draft-IERC7943.sol).

| Interface | Purpose |
|---|---|
| `IERC7943FungibleEnforcement` | `forcedTransfer`, `getFrozenTokens` |
| `IERC7943FungibleEnforcementSpecific` | `setFrozenTokens` |
| `IERC7943FungibleEnforcementEventAndError` | `Frozen`, `ForcedTransfer` events; `ERC7943InsufficientUnfrozenBalance` error |
| `IERC7943FungibleSendReceiveError` | `ERC7943CannotSend`, `ERC7943CannotReceive` errors |
| `IERC7943FungibleTransferError` | `ERC7943CannotTransfer` error |
| `IERC7943FungibleSendReceiveCheck` | `canSend(account)`, `canReceive(account)` |

## Implementation Mapping

| ERC-7943 Requirement | CMTAT Implementation |
|---|---|
| **Functions** | |
| `forcedTransfer(from, to, amount)` | `ERC20EnforcementModule.sol` |
| `setFrozenTokens(account, amount)` | `ERC20EnforcementModule.sol` |
| `getFrozenTokens(account)` | `ERC20EnforcementModule.sol` |
| `canSend(account)` | `ValidationModule.sol` |
| `canReceive(account)` | `ValidationModule.sol` |
| `canTransfer(from, to, amount)` | `ValidationModuleCore.sol` |
| **Errors** | |
| `ERC7943CannotSend` | `ValidationModule.sol` |
| `ERC7943CannotReceive` | `ValidationModule.sol` |
| `ERC7943CannotTransfer` | Defined in `draft-IERC7943.sol` (interface only; not currently reverted by CMTAT — the RuleEngine uses its own errors) |
| `ERC7943InsufficientUnfrozenBalance` | `ERC20EnforcementModuleInternal.sol` |
| **Events** | |
| `Frozen` | `ERC20EnforcementModuleInternal.sol` |
| `ForcedTransfer` | `ERC20EnforcementModuleInternal.sol` |

## Event Semantics Across ERC-7943 / ERC-3643 / ERC-7551

At the base enforcement layer, CMTAT emits the ERC-7943 `Frozen(account, amount)` event as a normalized "frozen amount changed" signal. This applies to both freeze and unfreeze transitions, and `amount` is the resulting frozen amount after the operation.

This is aligned with ERC-7943, which defines a single `Frozen` event and does not define a distinct `Unfrozen` event.

For direction-aware integrations, CMTAT emits dedicated events at wrapper level:

- ERC-3643 path: `TokensFrozen(account, value)` and `TokensUnfrozen(account, value)`.
- ERC-7551 path: `TokensFrozen(account, value, data)` and `TokensUnfrozen(account, value, data)`.

Indexer guidance:

- If you need the current frozen-state trajectory only, indexing `Frozen` is sufficient.
- If you need action direction (freeze vs unfreeze), index `TokensFrozen` and `TokensUnfrozen` (ERC-3643/ERC-7551 events) instead of relying on event name from `Frozen`.

## `canSend` / `canReceive`

These are account-level eligibility checks independent of transfer parameters.

- `canSend(account)` returns `true` if the account is allowed to send tokens (not frozen, not on an allowlist that excludes it).
- `canReceive(account)` returns `true` if the account is allowed to receive tokens.

Both are public view functions defined in `ValidationModule` and can be overridden in subclasses (e.g., `ValidationModuleAllowlist` adds an allowlist check on top).

## Transfer Flow Diagram

When a standard transfer is attempted:

```
transfer(to, 100)
│
├─ Is contract paused? ──────────────→ revert EnforcedPause()
│
├─ Is sender/spender frozen? ────────→ revert ERC7943CannotSend(account)
├─ Is receiver frozen? ──────────────→ revert ERC7943CannotReceive(account)
│
├─ RuleEngine says no? ─────────────→ RuleEngine reverts with its own errors
│
├─ Not enough active balance? ───────→ revert ERC7943InsufficientUnfrozenBalance(...)
│
└─ Transfer executes
```

## Error Semantics

| Error | When emitted |
|---|---|
| `ERC7943CannotSend(account)` | The sender, spender, or burn source is not allowed to send |
| `ERC7943CannotReceive(account)` | The recipient or mint target is not allowed to receive |
| `ERC7943CannotTransfer(from, to, amount)` | Defined by the standard; available for custom extensions but not currently reverted by CMTAT itself |
| `ERC7943InsufficientUnfrozenBalance(account, amount, unfrozen)` | The transfer amount exceeds the unfrozen balance |

Note: `ERC7943CannotTransfer` is currently kept for interface/spec completeness and potential future use, but is not emitted by current CMTAT runtime validation paths.

## Pre-Check Functions

CMTAT provides pre-check functions to verify whether a transfer will succeed before executing it.

### ERC-7943 Native Pre-Checks

| Function | Standard | Purpose | Module |
|---|---|---|---|
| `canTransfer(from, to, value)` | ERC-7943 | Check if a direct transfer is allowed | `ValidationModuleCore` |
| `canSend(account)` | ERC-7943 | Check if an account is allowed to send | `ValidationModule` |
| `canReceive(account)` | ERC-7943 | Check if an account is allowed to receive | `ValidationModule` |

### CMTAT Extension / Related Standards

The following function is not part of ERC-7943. It is included by CMTAT through ERC-7551-related compliance support:

| Function | Standard | Purpose | Module |
|---|---|---|---|
| `canTransferFrom(spender, from, to, value)` | ERC-7551 | Check if a delegated transfer is allowed | `ValidationModuleCore` |

For how `spender` is populated across all operation types (mint, burn, `transferFrom`, `minterTransfer`) when a RuleEngine is configured, see [ruleengine-integration.md — Spender / Operator Semantics](./ruleengine-integration.md#spender--operator-semantics).

## ERC-165

CMTAT returns `true` for `supportsInterface(0x3edbb4c4)` (the fungible ERC-7943 interface ID).
