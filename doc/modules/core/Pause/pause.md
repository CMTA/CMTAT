# Pause Module

This document defines the Pause Module for the CMTA Token specification.

[TOC]

## Rationale

> The issuer must be able to “pause” the smart contract, to prevent execution of transactions on the distributed ledger until the issuer puts an end to the pause. This function can be used to block transactions in case of a “hard fork” of the distributed ledger, pending a decision of the issuer as to which version of the distributed ledger it will support.

The PauseModule contract introduces contract pausing functionality into the CMTAT ERC20 token. This prevents users from being able to perform transfers while the contract is paused.

However, this is not enforced in the functions that allow to change a user’s allowance. We don't think it is necessary to prevent allowance change while the contract is in the pause state.

Note that setting an allowance to **zero** — a revocation — is always permitted, including while the contract is paused or deactivated and when the owner or spender is frozen or off the allowlist. A revocation can only reduce what a spender may move, and a holder must always be able to sever ties with a compromised or sanctioned spender. Non-zero grants remain subject to the usual checks.

## What pause stops, and what it does not

Pause is an emergency stop on **circulation**, not on the issuer's control of the instrument. The dividing line is **who is acting**, not which function is called:

- **Issuer operations continue while paused.** Minting, issuer burns and enforcement actions express the issuer's own authority over supply. Blocking them would defeat the purpose of being able to pause: the issuer must retain the ability to act on the instrument precisely while circulation is halted.
- **Third-party operations are stopped.** Operations performed by a bridge, or by an operator spending someone else's allowance, are exactly what a pause is meant to halt. In particular, cross-chain settlement must stop rather than keep moving supply between chains against a frozen local state.

| Path | Module | Role | While paused |
| --- | --- | --- | --- |
| `mint`, `batchMint` | `ERC20MintModule` (issuer) | `MINTER_ROLE` | **Allowed** |
| `burn`, `batchBurn` | `ERC20BurnModule` (issuer) | `BURNER_ROLE` | **Allowed** |
| `forcedTransfer`, `forcedBurn` | enforcement (issuer) | `DEFAULT_ADMIN_ROLE` | **Allowed** |
| `transfer`, `transferFrom` | `ERC20BaseModule` (holders) | — | **Blocked** — `EnforcedPause()` |
| `burnFrom` | `ERC20CrossChainModule` (third party) | `BURNER_FROM_ROLE` | **Blocked** — `EnforcedPause()` |
| `burn(uint256)` (self-burn) | `ERC20CrossChainModule` (third party) | `BURNER_SELF_ROLE` | **Blocked** — `EnforcedPause()` |
| `crosschainMint`, `crosschainBurn` | `ERC20CrossChainModule` (bridge) | `CROSS_CHAIN_ROLE` | **Blocked** — `EnforcedPause()` |
| `approve(spender, 0)` (revocation) | allowance | — | **Allowed** |
| `approve(spender, n > 0)` | allowance | — | **Blocked** — `EnforcedPause()` |

The two burn families are easy to confuse because they share a name. `ERC20BurnModule.burn(address,uint256)` is the **issuer** burn and is not pause-gated; `ERC20CrossChainModule.burn(uint256)` and `burnFrom(address,uint256)` are **third-party** burns and are. See [ERC20Burn](../ERC20Burn/ERC20Burn.md) and [ERC20CrossChain](../../options/erc20crosschain/ERC20CrossChain.md) for the per-function requirements.

> **Consequence for ERC-1404 prediction.** Because the pause rule differs *between entry points of
> the same operation* (issuer mint/burn allowed, bridge and third-party mint/burn blocked), a single
> `detectTransferRestriction(address(0), to, value)` / `detectTransferRestriction(from, address(0), value)`
> answer cannot describe every mint or every burn — the ERC-1404 signature carries no entry-point
> discriminator. CMTAT therefore designates **no** ERC-1404 predictor for supply-changing operations:
> those methods cover `transfer` / `transferFrom` only, and mint/burn must be predicted with
> `canTransfer` / `canTransferFrom`. See the
> [ERC-1404 scope note](../../../README.md#scope-transfers-only-never-mint-or-burn).

## Schema

![PauseUML](../../../schema/plantuml/class/PauseModule.png)

### Inheritance

![surya_inheritance_PauseModule.sol](../../../schema/surya_inheritance/surya_inheritance_PauseModule.sol.png)

### Graph

![surya_graph_PauseModule.sol](../../../schema/surya_graph/surya_graph_PauseModule.sol.png)



## Ethereum API

This section describes the Ethereum API of the Pause Module.

### OpenZepplin PausableUpgradeable

See [docs.openzeppelin.com/contracts/5.x/api/utils#Pausable](https://docs.openzeppelin.com/contracts/5.x/api/utils#Pausable)

#### Events

##### `Paused(address)`

```solidity
event Paused(address account)
```

Emitted when token transfers were paused.

##### `Unpaused(address)`

```solidity
event Unpaused(address account)
```

Emitted when token transfers were unpaused.

### Interface: `IERC8343` (ERC-8343)

 This interface (proposed as [ERC-8343](https://github.com/ethereum/ERCs/pull/1900) — a draft, **not yet merged**; formerly `ICMTATDeactivate`) defines functions and events for irreversibly deactivating a smart contract. Once deactivated, the contract becomes permanently non-functional. This mechanism is useful for compliance-focused or end-of-life lifecycle token contracts.

------

#### Events

##### `Deactivated`

```solidity
event Deactivated(address account);
```

| Name      | Type    | Description                                            |
| --------- | ------- | ------------------------------------------------------ |
| `account` | address | The address that permanently deactivated the contract. |

#### Functions

##### `deactivateContract`

```solidity
function deactivateContract() external;
```

```solidity
function deactivateContract()
public virtual override(IERC8343)
onlyRole(DEFAULT_ADMIN_ROLE)
```

Permanently disables the contract.
**Warning:** This action is irreversible. Once the contract is deactivated, it can never be used again.

**Requirement**

- The contract must be paused before it can be deactivated.
  - Error: `ExpectedPause()`
- The contract must not already be deactivated.
  - Error: `AlreadyDeactivated()`
- Only authorized users (`DEFAULT_ADMIN_ROLE`) are allowed to call this function.

**Emits** 

- Deactivated

##### `deactivated`

```solidity
function deactivated() external view returns (bool isDeactivated);
```

```solidity
function deactivated() public view 
virtual override(IERC8343) 
returns (bool)
```

Returns the current deactivation status of the contract.

**Returns**

| Returns         | Type | Description                                      |
| --------------- | ---- | ------------------------------------------------ |
| `isDeactivated` | bool | True if the contract is permanently deactivated. |



### `IERC3643Pause`

> Interface for pausing and unpausing token transfers, used in both CMTAT and ERC3643 token standards.
>  This interface allows toggling a pause state that disables or enables token transfers.

------

#### `paused`

```solidity
function paused() external view returns (bool);
```

```solidity
function paused() 
public virtual view override(IERC3643Pause, IERC7551Pause, PausableUpgradeable) returns (bool){
```

Returns whether the contract is currently paused.

| Name     | Type | Description                                          |
| -------- | ---- | ---------------------------------------------------- |
| `return` | bool | `true` if the contract is paused, otherwise `false`. |

#### `pause`

```solidity
function pause() external;
```

```solidity
function pause() 
public virtual override(IERC3643Pause, IERC7551Pause) 
onlyPauseManager
```

| Description                                                  |
| ------------------------------------------------------------ |
| Disables transfer functions across the contract. <br />Pauses all token transfers. |

##### Emits

Emits a `Paused` event.

##### Requirements

- Only authorized users (`PAUSER_ROLE`) are allowed to call this function.
- The contract must not be paused 
  - error: `EnforcedPause()`

#### `unpause`

```solidity
function unpause() external;
```

```solidity
function unpause() 
public virtual override(IERC3643Pause, IERC7551Pause) 
onlyPauseManager
```


| Description                                                  |
| ------------------------------------------------------------ |
| Unpauses all token transfers.  <br />Re-enables transfer functions across the contract. |


##### Emits

Emits an `Unpaused` event.

##### Requirements

- Only authorized users (`PAUSER_ROLE`) are allowed to call this function.
- The contract must be paused 
  - error: `ExpectedPause()`
