# Permit (ERC-2612) + Multicall (ERC-6357)

The Permit deployment version adds support for [ERC-2612 Permit](https://eips.ethereum.org/EIPS/eip-2612) and [ERC-6357 single-contract Multicall](https://eips.ethereum.org/EIPS/eip-6357).

## Deployment Contracts

- `CMTATStandalonePermit` — immutable deployment
- `CMTATUpgradeablePermit` — proxy-compatible deployment

Compared to the standard deployment:
- Adds signature-based approvals via `permit`
- Adds call batching via `multicall`
- Does **not** include `ERC2771Module`, to keep bytecode lean

## ERC-2612 Permit

`permit` allows a token owner to approve a spender using an off-chain signature instead of an on-chain transaction. This enables gas-sponsored approval workflows.

```solidity
function permit(
    address owner,
    address spender,
    uint256 value,
    uint256 deadline,
    uint8 v, bytes32 r, bytes32 s
) external;
```

### Allowance Authorization Checks

The same checks apply to both `approve` and `permit`:

- The contract must not be paused.
- The `owner` must not be frozen (checked via `canSend`).
- The `spender` must not be frozen (checked via `canSend`). In the Allowlist deployment variant, both must also be allowlisted.

These checks are enforced in `ValidationModuleAllowance._canAuthorizeAllowanceByModuleAndRevert`.

## ERC-6357 Multicall

`multicall` batches multiple calls to the same contract in a single transaction. Useful for atomic combinations of mint, burn, freeze, or approve operations.

```solidity
function multicall(bytes[] calldata data) external returns (bytes[] memory results);
```

## How to Use

1. Select `CMTATStandalonePermit` or `CMTATUpgradeablePermit`.
2. Use `permit(owner, spender, value, deadline, v, r, s)` to set an allowance from an off-chain signature.
3. Use `multicall(bytes[] calldata data)` to batch several operations in one transaction.

This deployment version is well-suited for workflows that require:
- Gas-sponsored approvals (the spender pays gas, not the owner)
- Signature-based UX (no separate approve transaction)
- Atomic batching of multiple token operations
