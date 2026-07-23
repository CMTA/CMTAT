# CMTAT Base Core

This document defines the CMTAT Base Core Module for the CMTA Token specification.

[TOC]

## Hierarchy Context

`CMTATBaseCore` sits at **level 0** in the CMTAT inheritance hierarchy. It is the self-contained base used exclusively by the **Light** deployment variants (`CMTATStandaloneLight`, `CMTATUpgradeableLight`).

Unlike `CMTATBaseCommon` (also level 0), `CMTATBaseCore` bundles access control, pause, full validation (`ValidationModule`, `ValidationModuleAllowance`), and enforcement into a single compact base:

| Feature | `CMTATBaseCore` | `CMTATBaseCommon` |
|---|---|---|
| ERC-20 (mint, burn, base) | ✓ | ✓ |
| `AccessControlModule` (RBAC, concrete `_authorize*` overrides) | ✓ | — |
| `PauseModule` + `EnforcementModule` + `ValidationModule` | ✓ | — |
| `ValidationModuleAllowance` (approve/permit checks) | ✓ | — |
| `ERC20EnforcementModule` (partial freeze, forced transfer) | — | ✓ |
| `ExtraInformationModule` | — | ✓ |

`CMTATBaseCommon` is intended to be composed further up the hierarchy (through `CMTATBaseAccessControl` at level 2), where RBAC, enforcement, and extension modules are layered on separately. `CMTATBaseCore` collapses that into one level for the Light case, where only core operations (mint, burn, pause, freeze, `forcedBurn`) are needed.

## Schema

![CMTATBaseCore](../../schema/plantuml/class/CMTATBaseCore.png)

### Inheritance

![surya_inheritance_BurnModule.sol](../../schema/surya_inheritance/surya_inheritance_0_CMTATBaseCore.sol.png)



### Graph

![surya_graph_CMTATBaseCoreModule.sol](../../schema/surya_graph/surya_graph_0_CMTATBaseCore.sol.png)

## API for Ethereum

This section describes the Ethereum API of Burn Module.

### IForcedBurnERC20

#### forcedBurn(address,uint256,bytes)

```solidity
function forcedBurn(address account,uint256 value,bytes memory data) 
public virtual override(IForcedBurnERC20) 
onlyERC20ForcedBurnManager
```

Allows an authorized issuer to burn tokens from a frozen account.

| Parameter | Type    | Description                             |
| --------- | ------- | --------------------------------------- |
| `account` | address | The frozen account to burn tokens from. |
| `value`   | uint256 | Number of tokens to burn.               |
| `data`    | bytes   | Metadata related to the burn action.    |

##### Requirements

Only authorized users (*DEFAULT_ADMIN_ROLE*) are allowed to call this function.

**Returns:** None

##### Events

###### `ForcedTransfer (address,address,address,uint256,bytes)`

```solidity
event ForcedTransfer(address indexed operator, address indexed from, address indexed to, uint256 value, bytes data);
```

Emitted when the specified `value` amount of tokens are force-moved by `operator`.
In `forcedBurn`, this is emitted with `to = address(0)` to represent a forced burn with `data`.

​    

### burnAndMint(address from, address to, uint256 amountToBurn, uint256 amountToMint, bytes data) public override

Burns tokens from one account and mints new tokens to another account atomically.

**Details:**

- Ensures both burn and mint happen in a single transaction (all-or-nothing).
- Access control is enforced by the underlying `burn` (from **ERC20BurnModule**) and `mint` (from **ERC20MintModule**) functions.
- Input validation is also handled within those modules.
- It is possible to mint **more tokens than are burned**.

**Access Control:**

- See {burn} and {mint} for specific access restrictions.

**Input Parameters:**

| Name         | Type    | Description                                             |
| ------------ | ------- | ------------------------------------------------------- |
| from         | address | The current token holder whose tokens will be burned.   |
| to           | address | The recipient who will receive the newly minted tokens. |
| amountToBurn | uint256 | The number of tokens to burn from `from`.               |
| amountToMint | uint256 | The number of tokens to mint to `to`.                   |
| data         | bytes   | Additional calldata for extensibility or hooks.         |
