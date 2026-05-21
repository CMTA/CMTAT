# Stablecoin Deployment Guide

This document describes the **Light** deployment variant, which is designed for stablecoins, and explains when to use one of the alternative variants (**Standard** or **Permit**) if more features are required.

## Why Light for Stablecoins

Stablecoins typically need a smaller set of compliance features than equity or debt instruments:

- Issue and redeem tokens (mint / burn).
- Globally freeze activity (pause).
- Blacklist individual addresses (address freeze).
- Emergency burn from a blacklisted address (forced burn).
- Update name / symbol after deployment.

The Light variant provides exactly these capabilities with no overhead from modules that are irrelevant to most stablecoin designs (document management, snapshots, partial balance freeze, debt fields, or cross-chain bridges). The result is a contract roughly half the size of the Standard variant.

| Variant | Deployed bytecode |
|---|---|
| CMTAT Light | 11.298 KiB |
| CMTAT Standard | 22.243 KiB |
| CMTAT Permit | 23.268 KiB |

The 24.576 KiB EVM deployed bytecode limit is not a concern for Light, leaving substantial room for integrators who extend the contract.

---

## Light Variant — Feature Set

### Deployment contracts

| Type | Contract | File |
|---|---|---|
| Standalone (immutable) | `CMTATStandaloneLight` | `contracts/deployment/light/CMTATStandaloneLight.sol` |
| Upgradeable (Transparent / Beacon proxy) | `CMTATUpgradeableLight` | `contracts/deployment/light/CMTATUpgradeableLight.sol` |

Both extend `CMTATBaseCore` (`contracts/modules/0_CMTATBaseCore.sol`), which bundles the complete feature set in a single level-0 base.

### Constructor / Initializer Parameters

The Light variant takes a minimal set of constructor parameters compared to other variants:

```solidity
constructor(
    address admin,
    ICMTATConstructor.ERC20Attributes memory ERC20Attributes_
)
```

| Parameter | Type | Description |
|---|---|---|
| `admin` | `address` | Address receiving `DEFAULT_ADMIN_ROLE` on deployment. |
| `ERC20Attributes_.name` | `string` | Token name. |
| `ERC20Attributes_.symbol` | `string` | Token symbol. |
| `ERC20Attributes_.decimalsIrrevocable` | `uint8` | Token decimals (irrevocable after deployment). |

There is no `forwarderIrrevocable` parameter (no ERC-2771 support), no `extraInformationAttributes_` (no tokenId/terms/information), and no `engines_` (no external engine contracts).

### Module Inventory

| Module | What it provides |
|---|---|
| `ERC20BaseModule` | ERC-20 base — `transfer`, `transferFrom`, `approve`, `allowance`, `balanceOf`, `totalSupply`; updatable `name` / `symbol` (requires `DEFAULT_ADMIN_ROLE`); irrevocable `decimals` |
| `ERC20MintModule` | `mint(address, uint256, bytes)`, `mint(address, uint256)`, `batchMint`, `batchTransfer` — requires `MINTER_ROLE` |
| `ERC20BurnModule` | `burn(address, uint256, bytes)`, `burn(address, uint256)`, `batchBurn` — requires `BURNER_ROLE` |
| `PauseModule` | `pause()` / `unpause()` (requires `PAUSER_ROLE`); `deactivateContract()` (requires `DEFAULT_ADMIN_ROLE`); `paused()` / `deactivated()` view functions |
| `EnforcementModule` | `setAddressFrozen(address, bool)`, `batchSetAddressFrozen` (requires `ENFORCER_ROLE`); `isFrozen(address)` read |
| `ValidationModule` / `ValidationModuleCore` | Enforces pause and freeze checks on every transfer, `transferFrom`, `approve`, mint, and burn; `canSend(address)`, `canReceive(address)`, `canTransfer(from, to, value)`, `canTransferFrom(spender, from, to, value)` |
| `ValidationModuleAllowance` | Enforces pause and freeze checks on `approve` |
| `AccessControlModule` | OpenZeppelin RBAC — `grantRole`, `revokeRole`, `renounceRole`, `hasRole`; `DEFAULT_ADMIN_ROLE` has all roles by default |
| `VersionModule` | `version()` — returns the CMTAT version string |

`CMTATBaseCore` also defines the following multi-module operations directly:

| Function | Role | Description |
|---|---|---|
| `forcedBurn(address, uint256, bytes)` | `DEFAULT_ADMIN_ROLE` | Burns tokens from a frozen (blacklisted) address. The account must be frozen first via `setAddressFrozen`. Emits `ForcedTransfer(operator, account, address(0), value, data)`. |
| `burnAndMint(address, address, uint256, uint256, bytes)` | `BURNER_ROLE` + `MINTER_ROLE` | Atomically burns from one address and mints to another in a single transaction. |

### Role Summary

| Role | Key operations |
|---|---|
| `DEFAULT_ADMIN_ROLE` | Grant/revoke all roles; `deactivateContract`; `forcedBurn`; `setName`; `setSymbol` |
| `MINTER_ROLE` | `mint`, `batchMint`, `batchTransfer` |
| `BURNER_ROLE` | `burn`, `batchBurn` |
| `PAUSER_ROLE` | `pause`, `unpause` |
| `ENFORCER_ROLE` | `setAddressFrozen`, `batchSetAddressFrozen` |

### What Light Does NOT Include

The following features are intentionally absent to keep the contract lean:

| Feature | Missing module | Notes |
|---|---|---|
| Partial balance freeze | `ERC20EnforcementModule` | No `freezePartialTokens` / `unfreezePartialTokens` / `setFrozenTokens`. Address-level freeze only. |
| Forced transfer to third party | `ERC20EnforcementModule` | Only `forcedBurn` is available. Cannot move tokens from a frozen account to another address. |
| On-chain token metadata | `ExtraInformationModule` | No `tokenId`, `terms`, `information` fields. |
| On-chain document management | `DocumentERC1643Module` | No ERC-1643 document storage. |
| Snapshot engine support | `SnapshotEngineModule` | No `setSnapshotEngine` / `operateOnTransfer` hook. |
| Gasless meta-transactions | `ERC2771Module` | No trusted forwarder / ERC-2771 support. |
| Signature-based approvals | `ERC20PermitUpgradeable` | No ERC-2612 `permit`. |
| Batch operations in one call | `MulticallUpgradeable` | No ERC-6357 `multicall`. |
| Transfer rule engine | `ValidationModuleRuleEngine` | No external RuleEngine. Transfer restrictions are pause + address freeze only. |
| ERC-1404 restricted transfer | `ValidationModuleERC1404` | No `detectTransferRestriction` / `messageForTransferRestriction`. |
| Cross-chain mint/burn | `ERC20CrossChainModule` | No ERC-7802, no CCIP. |
| ERC-1363 token callbacks | — | No `transferAndCall` / `approveAndCall`. |

### Transfer Restriction Logic

Every token movement is validated by `ValidationModule._canTransferGenericByModuleAndRevert`. The checks applied are:

1. Contract must not be paused (`PauseModule.paused()` is false).
2. Sender / spender must not be frozen (`EnforcementModule.isFrozen(account)` is false).
3. Recipient must not be frozen.

No external RuleEngine is consulted. There is no allowlist module in Light.

### Blacklisting Pattern

The standard stablecoin blacklisting pattern on Light:

1. Call `setAddressFrozen(blacklistedAddress, true)` with `ENFORCER_ROLE`.
2. The address is now blocked from sending and receiving tokens.
3. To recover tokens held by the blacklisted address, call `forcedBurn(blacklistedAddress, amount, data)` with `DEFAULT_ADMIN_ROLE` (the account must be frozen before `forcedBurn` can be called).

If you need to *move* the tokens to another address instead of burning them, Light cannot do this — use the Standard variant, which provides `forcedTransfer`.

### Deactivation

`deactivateContract()` (requires `DEFAULT_ADMIN_ROLE`, contract must be paused first) permanently disables the contract. After deactivation:
- All state-changing operations revert.
- Read functions still work.
- The state is irreversible.

---

## When to Use the Standard Variant Instead

Use **CMTAT Standard** (`CMTATStandardStandalone` / `CMTATStandardUpgradeable`) when any of the following is required:

### Forced Transfer to Another Address

Standard adds `ERC20EnforcementModule`, which provides:

```solidity
function forcedTransfer(address from, address to, uint256 value) external; // DEFAULT_ADMIN_ROLE
```

This moves tokens from any address to any other address without the sender's consent. Unlike `forcedBurn`, the source address does not need to be frozen, and the tokens are not destroyed — they are transferred. Frozen tokens are automatically unfrozen as needed to cover the amount.

Use this for regulatory seizure scenarios where tokens must be redirected rather than destroyed.

### Partial Balance Freeze

Standard also adds partial-freeze functions via `ERC20EnforcementModule`:

```solidity
function freezePartialTokens(address account, uint256 value) external;   // ERC20ENFORCER_ROLE
function unfreezePartialTokens(address account, uint256 value) external;  // ERC20ENFORCER_ROLE
function setFrozenTokens(address account, uint256 value) external;        // ERC20ENFORCER_ROLE
function getFrozenTokens(address account) external view returns (uint256);
```

These lock a specific token amount on an address while leaving the rest transferable, as opposed to the full freeze in Light that blocks all transfers.

### On-Chain Document Attachment

Standard includes `DocumentERC1643Module` (via `CMTATBaseDocument` → `CMTATBaseAccessControl`), which stores regulatory documents directly in the token contract:

```solidity
function setDocument(bytes32 name, string calldata uri, bytes32 documentHash) external; // DOCUMENT_ROLE
function removeDocument(bytes32 name) external;                                          // DOCUMENT_ROLE
function getDocument(bytes32 name) external view returns (Document memory);
function getAllDocuments() external view returns (bytes32[] memory);
```

Useful when the regulator requires on-chain reference to a legal document (e.g., prospectus, terms of issuance).

### On-Chain Token Metadata

Standard includes `ExtraInformationModule`, which exposes:

```solidity
function setTokenId(string calldata tokenId_) external;                         // EXTRA_INFORMATION_ROLE
function setTerms(IERC1643CMTAT.DocumentInfo calldata terms_) external;         // EXTRA_INFORMATION_ROLE
function setInformation(string calldata information_) external;                 // EXTRA_INFORMATION_ROLE
```

Useful for associating an ISIN or other identifier with the token, or for storing a reference to the tokenization terms.

### Gasless Transactions (ERC-2771)

Standard includes `ERC2771Module`, which allows a trusted forwarder to relay transactions on behalf of users. The forwarder address is set at construction time and is irrevocable.

Use this if you want to sponsor gas fees for your users (e.g., the issuer pays gas for user redemptions).

Note: the forwarder is fixed at deployment. Verify that the chosen forwarder is trustworthy before deploying, as it can submit arbitrary calls on behalf of any user.

### External Transfer Rules (RuleEngine)

Standard includes `ValidationModuleRuleEngine`, which allows plugging in an external `RuleEngine` contract:

```solidity
function setRuleEngine(IRuleEngine ruleEngine_) external; // DEFAULT_ADMIN_ROLE
```

Use this when transfer restrictions beyond pause/freeze are needed — for example, jurisdiction-based restrictions, velocity limits, or identity checks — without modifying the token contract.

### Cross-Chain Transfers (ERC-7802 / Chainlink CCIP)

Standard includes `ERC20CrossChainModule`, which provides:

```solidity
function crosschainMint(address to, uint256 value) external;   // CROSS_CHAIN_ROLE
function crosschainBurn(address from, uint256 value) external; // CROSS_CHAIN_ROLE
```

These functions implement the [ERC-7802](https://eips.ethereum.org/EIPS/eip-7802) interface, making CMTAT compatible with any bridge or messaging layer that expects the standardized `crosschainMint` / `crosschainBurn` entry points (such as Chainlink CCIP's Burn-and-Mint token pool, or Optimism's Superchain token standard). The `CCIPModule` additionally exposes `getCCIPAdmin()` for Chainlink CCIP registry compatibility.

Note: this differs from USDC's approach. USDC cross-chain is handled by CCTP (Circle's own Cross-Chain Transfer Protocol), which reuses the standard `mint` / `burn` functions behind a privileged minter role — there are no dedicated `crosschainMint` / `crosschainBurn` entry points on the USDC contract, and USDC does not implement ERC-7802.

---

## When to Use the Permit Variant Instead

Use **CMTAT Permit** (`CMTATStandalonePermit` / `CMTATUpgradeablePermit`) when ERC-2612 `permit` or ERC-6357 `multicall` are required. Permit shares the same module set as Standard (including ERC-7802 cross-chain) but replaces ERC-2771 with `permit` and `multicall` — see the trade-off note below.

### ERC-2612 Permit — Gasless Approvals

```solidity
function permit(
    address owner,
    address spender,
    uint256 value,
    uint256 deadline,
    uint8 v, bytes32 r, bytes32 s
) external;
```

Allows a token owner to set an allowance using an off-chain signature instead of an on-chain `approve` transaction. The spender (or any relayer) can then submit the signature to the chain. This enables:

- Gas-sponsored approval flows (spender pays gas, not the owner).
- Single-step approve-and-use UX without a separate approve transaction.

The same compliance checks that apply to `approve` also apply to `permit`: the contract must not be paused, and neither `owner` nor `spender` may be frozen.

### ERC-6357 Multicall — Batched Operations

```solidity
function multicall(bytes[] calldata data) external returns (bytes[] memory results);
```

Executes multiple function calls on the token contract atomically in a single transaction. Useful for:

- Minting to several addresses in one call when `batchMint` is insufficient.
- Combining `permit` + `transferFrom` in a single transaction for a DeFi integration.
- Performing administrative actions (pause + update metadata + batch freeze) atomically.

### Trade-Off: No ERC-2771

The Permit variant does **not** include `ERC2771Module`. The two features are mutually exclusive in the current deployment variants: Permit uses `MulticallUpgradeable` and `ERC20PermitUpgradeable`, which occupy contract size that ERC-2771 support would exceed.

If you need both meta-transactions and permit-style approvals, consider an external gasless relayer architecture that calls `permit` directly.

---

## Variant Comparison

| Feature | Light | Standard | Permit |
|---|---|---|---|
| `mint` / `batchMint` | ✓ | ✓ | ✓ |
| `burn` / `batchBurn` | ✓ | ✓ | ✓ |
| `batchTransfer` (minter) | ✓ | ✓ | ✓ |
| `burnAndMint` | ✓ | ✓ | ✓ |
| `pause` / `unpause` / `deactivateContract` | ✓ | ✓ | ✓ |
| Address freeze (`setAddressFrozen`) | ✓ | ✓ | ✓ |
| `canSend` / `canReceive` / `canTransfer` | ✓ | ✓ | ✓ |
| `forcedBurn` (burn from frozen address) | ✓ | — | — |
| `forcedTransfer` (move tokens to third party) | — | ✓ | ✓ |
| Partial balance freeze (`freezePartialTokens`) | — | ✓ | ✓ |
| `ExtraInformationModule` (tokenId, terms, info) | — | ✓ | ✓ |
| `DocumentERC1643Module` (ERC-1643 documents) | — | ✓ | ✓ |
| ERC-2771 meta-transactions (gasless) | — | ✓ | — |
| ERC-7802 / CCIP cross-chain | — | ✓ | ✓ |
| External RuleEngine | — | ✓ | ✓ |
| ERC-1404 (`restrictedTransferOf`) | — | ✓ | ✓ |
| ERC-2612 `permit` | — | — | ✓ |
| ERC-6357 `multicall` | — | — | ✓ |
| Deployed bytecode | 11.298 KiB | 22.243 KiB | 23.268 KiB |

---

## Decision Guide

```
Do you need on-chain documents, tokenId/terms, 
partial freeze, or forcedTransfer?
    ├── No  → Do you need permit or multicall?
    │             ├── No  → CMTAT Light
    │             └── Yes → CMTAT Permit (no ERC-2771)
    └── Yes → Do you need permit or multicall?
                  ├── No  → Do you need gasless (ERC-2771)?
                  │             ├── Yes → CMTAT Standard
                  │             └── No  → CMTAT Standard or Permit
                  └── Yes → CMTAT Permit (no ERC-2771)
```

---

## Comparison with USDC and USDT

The table below maps common stablecoin features to the relevant CMTAT variant. Sources: [USDC implementation (Ethereum)](https://etherscan.io/address/0x43506849d7c04f9138d1a2050bbf3a0c054402dd#code), [USDT (Ethereum)](https://etherscan.io/address/0xdac17f958d2ee523a2206206994597c13d831ec7).

### Standards

| Feature | USDC | USDT | CMTAT Light | CMTAT Standard | CMTAT Permit |
|---|---|---|---|---|---|
| [ERC-20](https://eips.ethereum.org/EIPS/eip-20) | ✓ | ✓ | ✓ | ✓ | ✓ |
| [ERC-2612 Permit](https://eips.ethereum.org/EIPS/eip-2612) | ✓ | — | — | — | ✓ |
| [ERC-3009](https://eips.ethereum.org/EIPS/eip-3009) (Transfer With Authorization) | ✓ | — | — | — | — |
| [ERC-2771](https://eips.ethereum.org/EIPS/eip-2771) (meta-transactions / gasless) | — | — | — | ✓ | — |
| [ERC-7802](https://eips.ethereum.org/EIPS/eip-7802) (cross-chain) | — | — | — | ✓ | ✓ |

### ERC-20 Operations

| Feature | USDC | USDT | CMTAT Light | CMTAT Standard | CMTAT Permit |
|---|---|---|---|---|---|
| Mint to any address | Partial² | ✓ | ✓ | ✓ | ✓ |
| Mint with dedicated allowance (`mintFrom`) | ✓ | — | — | — | — |
| `batchMint` | — | — | ✓ | ✓ | ✓ |
| `batchTransfer` (minter path) | — | — | ✓ | ✓ | ✓ |
| Burn / redeem | ✓ | ✓ (`redeem`) | ✓ | ✓ | ✓ |
| Set `name` after deployment | — | — | ✓ | ✓ | ✓ |
| Set `symbol` after deployment | — | — | ✓ | ✓ | ✓ |

² USDC minters hold a per-minter allowance (`minterAllowance`) that is decremented on each mint call, rather than minting directly to any address without a cap.

### Compliance and Regulatory

| Feature | USDC | USDT | CMTAT Light | CMTAT Standard | CMTAT Permit |
|---|---|---|---|---|---|
| Blacklist inside token contract | ✓ | ✓ | ✓ (`setAddressFrozen`) | ✓ | ✓ |
| External / shared blacklist | — | — | — | ✓ (via RuleEngine) | ✓ (via RuleEngine) |
| Forced transfer to a third party | ✓ (`instantTransfer`) | ✓ (`size`) | — | ✓ | ✓ |
| Forced burn from blacklisted address | — | ✓ (`destroyBlackFunds`) | ✓ (`forcedBurn`) | — | — |
| Partial balance freeze | — | — | — | ✓ | ✓ |
| Pause all transfers | ✓ | ✓ | ✓ | ✓ | ✓ |
| Deactivation (permanent, irreversible) | — | — | ✓ | ✓ | ✓ |
| Fee on transfer | — | ✓ (set at 0) | — | — | — |
| Restriction on `transferFrom` spender | ✓³ | — | ✓ (frozen spender) | ✓ (frozen spender; or full ban via RuleEngine) | ✓ (frozen spender; or full ban via RuleEngine) |
| External rule engine (custom policies) | — | — | — | ✓ | ✓ |

³ USDC allows the contract owner to disable third-party (`transferFrom`) transfers entirely via `disableERC20ThirdPartyTransfer` / `enableERC20ThirdPartyTransfer`. All CMTAT variants block `transferFrom` when the spender is frozen. Standard and Permit can additionally enforce a complete third-party transfer ban by deploying a RuleEngine rule that rejects calls where `spender != from && spender != address(0) && from != address(0) && to != address(0)` (i.e., a genuine delegated transfer, excluding mints and burns).

### Access Control

| Feature | USDC | USDT | CMTAT Light | CMTAT Standard | CMTAT Permit |
|---|---|---|---|---|---|
| Single-owner model | ✓ | ✓ | — | — | — |
| Role-based access control (RBAC) | ✓ (Minter + Blacklister roles) | — | ✓ (5 roles) | ✓ (10+ roles) | ✓ (10+ roles) |
| Granular per-function roles | Partial | — | ✓ | ✓ | ✓ |

CMTAT replaces the single-owner pattern with `DEFAULT_ADMIN_ROLE`, which holds all roles by default. Each operational permission (mint, burn, pause, freeze, …) can be delegated to a separate address independently.

### Upgradeability

| Feature | USDC | USDT | CMTAT Light | CMTAT Standard | CMTAT Permit |
|---|---|---|---|---|---|
| Standalone (immutable) | — | ✓ | ✓ | ✓ | ✓ |
| Upgradeable — Transparent / Beacon proxy | ✓ | — | ✓ | ✓ | ✓ |
| Upgradeable — UUPS | — | — | — | ✓ (dedicated variant) | ✓ (dedicated variant) |
| Migrate function (balance carry-over) | — | ✓⁴ | — | — | — |

⁴ USDT includes a `migrate` function because it predates the proxy upgrade pattern and needed a manual balance migration path. CMTAT upgradeable variants use ERC-7201 namespaced storage, which makes migrations transparent.

### Key Differences Versus USDC

**Features USDC has that CMTAT Light lacks:**
- **ERC-2612 Permit** — available via CMTAT Permit variant.
- **ERC-3009 Transfer With Authorization** — not implemented in any CMTAT variant.
- **Mint allowance per minter** (`minterAllowance`) — CMTAT uses an uncapped `MINTER_ROLE` instead. A per-minter cap could be implemented via a custom RuleEngine or a minter proxy.
- **Forced transfer** (`instantTransfer`) — available in CMTAT Standard and Permit via `forcedTransfer`.

**Features CMTAT Light has that USDC lacks:**
- **`forcedBurn`** — burns tokens directly from a frozen (blacklisted) address in a single call. USDC has no equivalent; CMTAT Standard and Permit also lack this function (they provide `forcedTransfer` to move tokens instead).
- **`batchMint` / `batchTransfer`** — batch operations not available in USDC.
- **`setName` / `setSymbol`** — USDC name and symbol are fixed at deployment.
- **Deactivation** — CMTAT provides an irreversible shutdown mechanism; USDC does not.
- **RBAC granularity** — CMTAT separates minting, burning, pausing, and freezing into independent roles; USDC has Minter and Blacklister but the owner holds broader control.

**Additional CMTAT features (Standard / Permit) that USDC also lacks:**
- **ERC-7802 cross-chain interface** — USDC does not implement ERC-7802. USDC cross-chain transfers use CCTP (Circle's own Cross-Chain Transfer Protocol), which reuses the existing `mint` / `burn` functions behind a privileged minter role (the `TokenMinter` contract). There are no dedicated `crosschainMint` / `crosschainBurn` entry points on the USDC contract. CMTAT Standard and Permit expose these as proper ERC-7802 functions callable by `CROSS_CHAIN_ROLE`.
- **ERC-2771 meta-transactions** — available in CMTAT Standard (not in Permit).
- **External RuleEngine** — available in CMTAT Standard and Permit for custom per-transfer compliance logic.

### Key Differences Versus USDT

**Features USDT has that CMTAT lacks (across all variants):**
- **Fee on transfer** — USDT has a configurable fee (currently 0). CMTAT has no fee mechanism.

**Features USDT has that CMTAT Light lacks:**
- **Forced transfer** (`size`) — available in CMTAT Standard and Permit via `forcedTransfer`.

**Functional equivalences:**
- **`destroyBlackFunds`** — USDT can burn from a blacklisted address without explicit role separation. CMTAT Light provides equivalent functionality via `forcedBurn` (`DEFAULT_ADMIN_ROLE`; the account must be frozen first via `setAddressFrozen`).
- **Migrate function** — USDT includes a manual balance migration function from a previous contract. CMTAT upgradeable variants use ERC-7201 namespaced storage, making storage layout compatible across upgrades without a manual migration step.

**Features CMTAT Light has that USDT lacks:**
- **RBAC** — USDT uses a single-owner model; CMTAT provides granular role separation.
- **Transparent proxy upgradeability** — USDT is immutable; CMTAT upgradeable variants support Transparent, Beacon, and UUPS proxies.
- **`batchMint` / `batchBurn`** — batch operations not available in USDT.
- **`setName` / `setSymbol`** — USDT name and symbol are fixed at deployment.
- **Deactivation** — irreversible shutdown mechanism not present in USDT.

**Additional CMTAT features (Standard / Permit) that USDT also lacks:**
- **ERC-2612 Permit** — available via CMTAT Permit variant.
- **ERC-2771 meta-transactions** — available in CMTAT Standard.
- **External RuleEngine** — available in CMTAT Standard and Permit for configurable transfer policies.

---

## See Also

- [`doc/technical/deployment.md`](./deployment.md) — full deployment model reference
- [`doc/technical/access-control.md`](./access-control.md) — role list and function-to-role table
- [`doc/technical/permit-multicall.md`](./permit-multicall.md) — ERC-2612 and ERC-6357 details
- [`doc/modules/base/0_CMTATBaseCore.md`](../modules/base/0_CMTATBaseCore.md) — CMTATBaseCore module reference
