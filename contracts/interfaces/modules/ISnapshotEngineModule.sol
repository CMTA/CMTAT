// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== Engine === */
import {ISnapshotEngine} from "../engine/ISnapshotEngine.sol";

/**
 * @title ISnapshotEngineModule
 * @notice Minimal interface for integrating a snapshot engine module.
 * @dev Provides methods to set and retrieve a snapshot engine used for capturing and referencing token states.
 */
interface ISnapshotEngineModule {
    /* ============ Events ============ */
    /**
     * @notice Emitted when a new snapshot engine is set.
     * @param newSnapshotEngine The address of the newly assigned snapshot engine contract.
     */

    event SnapshotEngine(ISnapshotEngine indexed newSnapshotEngine);
    /* ============ Error ============ */
    /**
     * @dev Reverts if the new snapshot engine is the same as the current one.
     */
    error CMTAT_SnapshotModule_SameValue();
    /* ============ Functions ============ */
    /**
     * @notice Sets the address of the snapshot engine contract.
     * @dev The snapshot engine is responsible for recording historical balances and supply snapshots.
     * Emits a {SnapshotEngine} event.
     * Reverts with {CMTAT_SnapshotModule_SameValue} if the new engine is the same as the current one.
     * @param snapshotEngine_ The new snapshot engine contract address to set.
     */
    function setSnapshotEngine(
        ISnapshotEngine snapshotEngine_
    ) external;
    /**
     * @notice Returns the currently set snapshot engine.
     * @return The address of the active snapshot engine contract.
     */
    function  snapshotEngine() external view returns (ISnapshotEngine);
}
