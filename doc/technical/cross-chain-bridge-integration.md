# Cross-Chain Bridge Integration

CMTAT supports cross-chain token transfers through three mechanisms:

| Mechanism | Standard | Module |
|---|---|---|
| Chainlink CCIP | [Cross-Chain Token (CCT)](https://docs.chain.link/ccip/concepts/cross-chain-token) | `CCIPModule` + `ERC20CrossChain` |
| Optimism Superchain | [ERC-7802](https://eips.ethereum.org/EIPS/eip-7802) | `ERC20CrossChain` |
| LayerZero | OFT adapter | External adapter (see [CMTAT-LayerZero](https://github.com/CMTA/CMTAT-LayerZero)) |

## Chainlink CCIP (Cross-Chain Token Standard)

CMTAT implements the [Cross-Chain Token Standard (CCT)](https://docs.chain.link/ccip/concepts/cross-chain-token/evm/tokens#overview), enabling self-service registration with Chainlink CCIP without needing Chainlink's assistance.

### Registration

CMTAT exposes `getCCIPAdmin()` (recommended over `owner()` by CCIP documentation) to return the address authorized to register the token.

```solidity
// CCIPModule
function getCCIPAdmin() public view virtual returns (address)
function setCCIPAdmin(address newAdmin) public virtual  // DEFAULT_ADMIN_ROLE
```

### Transfer Functions (Burn and Mint)

| Function | Module | Role |
|---|---|---|
| `mint(address, uint256)` | `ERC20MintModule` | `MINTER_ROLE` |
| `burn(uint256)` | `ERC20CrossChain` | `BURNER_SELF_ROLE` |
| `burnFrom(address, uint256)` | `ERC20CrossChain` | `BURNER_FROM_ROLE` |
| `decimals()` | `ERC20BaseModule` | - |
| `balanceOf(address)` | OpenZeppelin ERC20 | - |

The CCIP pool must be granted the required `MINTER_ROLE` and `BURNER_FROM_ROLE` (or `BURNER_SELF_ROLE`) to operate.

**Note**: Pausing the contract via `PauseModule` does **not** block `MintModule.mint()`, so CCIP minting still works while paused. However, `burnFrom`, `crosschainMint`, and `crosschainBurn` all have `whenNotPaused` checks and are blocked while paused. To block minting during a pause, revoke `MINTER_ROLE` from the CCIP pool.

`Lock and Mint` / `Burn and Unlock` models are also compatible through the `Burn and Mint` requirement set. `Lock and Unlock` needs no special token contract support.

### Example

[CMTAT-CCIP](https://github.com/CMTA/CMTAT-CCIP) provides Foundry deployment scripts for CMTAT v3.1.0 with CCIP contracts, built by [Nox Labs](https://github.com/Nox-Labs) in collaboration with CMTA and [Taurus](https://www.taurushq.com).

## Optimism Superchain (ERC-7802)

CMTAT implements [ERC-7802](https://eips.ethereum.org/EIPS/eip-7802) in `ERC20CrossChain`, enabling asset interoperability within the Optimism Superchain by burning on the source chain and minting on the destination chain.

Reference: [docs.optimism.io/interop/superchain-erc20](https://docs.optimism.io/interop/superchain-erc20)

### Source Chain Flow

1. User calls [`SuperchainTokenBridge.sendERC20`](https://github.com/ethereum-optimism/optimism/blob/develop/packages/contracts-bedrock/src/L2/SuperchainTokenBridge.sol#L52-L78).
2. The bridge calls `CMTAT.crosschainBurn` to burn tokens.
3. The bridge emits an initiating message via `L2ToL2CrossDomainMessenger`.

### Destination Chain Flow

1. An autorelayer (or any off-chain entity) sends an executing message to `L2ToL2CrossDomainMessenger`.
2. The destination bridge calls `CMTAT.crosschainMint` to mint tokens for the recipient.

### Requirements

- Grant the `SuperchainTokenBridge` permission to call `crosschainMint` and `crosschainBurn` (`CROSS_CHAIN_ROLE`).
- Deploy CMTAT at the **same address** on every Superchain network where the token should be available.

## LayerZero

Two OFT adapters (ERC-3643 and ERC-7802 variants) are available at [CMTAT-LayerZero](https://github.com/CMTA/CMTAT-LayerZero), built by [Nox Labs](https://github.com/Nox-Labs) in collaboration with CMTA and [Taurus](https://www.taurushq.com).

CMTAT provides two burn/mint interfaces for adapters to use:

- **Standard burn/mint** — same interface as ERC-3643 (`burn(address, uint256)` / `mint(address, uint256)`)
- **Cross-chain burn/mint** — ERC-7802 (`crosschainBurn` / `crosschainMint`)

Choose the adapter that matches the interface used by the LayerZero pool.

## Access Control Summary

| Function | Role | Notes |
|---|---|---|
| `crosschainMint(address, uint256)` | `CROSS_CHAIN_ROLE` | Grant to bridge/pool contract |
| `crosschainBurn(address, uint256)` | `CROSS_CHAIN_ROLE` | Grant to bridge/pool contract |
| `burnFrom(address, uint256)` | `BURNER_FROM_ROLE` | Grant to CCIP pool |
| `burn(uint256)` | `BURNER_SELF_ROLE` | Grant to CCIP pool |
| `mint(address, uint256)` | `MINTER_ROLE` | Grant to CCIP pool |
| `setCCIPAdmin(address)` | `DEFAULT_ADMIN_ROLE` | Manage CCIP registration |
