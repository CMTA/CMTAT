# Snapshot Engine

The SnapshotEngine allows performing on-chain balance and total supply snapshots. It is defined in the `SnapshotEngineModule` and implemented through an external `SnapshotEngine` contract.

## How It Works

**Before** each transfer (mint, burn, or standard transfer), CMTAT calls `operateOnTransfer` on the configured engine. This records balances and total supply at that point in time so that historical queries remain accurate.

```solidity
interface ISnapshotEngine {
    /**
     * @notice Records balance and total supply snapshots before any token transfer occurs.
     * @dev Called inside the {_update} hook before any state changes from {_mint}, {_burn}, or {_transfer}.
     *
     * @param from     Address tokens are transferred from (zero address if minting).
     * @param to       Address tokens are transferred to (zero address if burning).
     * @param balanceFrom  Current balance of `from` before the transfer.
     * @param balanceTo    Current balance of `to` before the transfer.
     * @param totalSupply  Current total supply before the transfer.
     */
    function operateOnTransfer(
        address from,
        address to,
        uint256 balanceFrom,
        uint256 balanceTo,
        uint256 totalSupply
    ) external;
}
```

## Setting the Engine

An address with `SNAPSHOOTER_ROLE` configures the engine:

```solidity
function setSnapshotEngine(address snapshotEngine_) external;
```

## Security / Liveness Note

`setSnapshotEngine` is a privileged operation. If `SNAPSHOOTER_ROLE` sets an engine that always reverts, token state-changing flows that call `_update` can fail, creating a **transfer-liveness halt** (pause-like behavior).

## Deployment Versions

The Snapshot deployment version (`CMTATStandaloneSnapshot` / `CMTATUpgradeableSnapshot`) extends the standard CMTAT with `SnapshotEngine` support via `CMTATBaseERC2771Snapshot`.

It is also possible to extend CMTAT directly to include snapshot logic without an external contract. The [SnapshotEngine](https://github.com/CMTA/SnapshotEngine) repository provides such a deployment variant.

## Compatible SnapshotEngine Releases

| CMTAT version | SnapshotEngine |
|---|---|
| CMTAT v3.0.0 | [v0.3.0](https://github.com/CMTA/SnapshotEngine/releases/tag/v0.3.0) (unaudited) |
| CMTAT v2.3.0 | SnapshotEngine v0.1.0 (unaudited) |
| CMTAT v2.4.0, v2.5.0 | Included inside SnapshotModule (unaudited) |
| CMTAT v1.0.0 | Included inside SnapshotModule (audited) |

## Use Case

On-chain snapshots are primarily used for dividend distribution: a snapshot records balances at a given block, which can then be used by an external contract to compute and distribute dividends proportionally.
